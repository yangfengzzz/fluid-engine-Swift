//
//  grid_fractional_single_phase_pressure_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D fractional single-phase pressure solver.
///
/// This class implements 3-D fractional (or variational) single-phase pressure
/// solver. It is called fractional because the solver encodes the boundaries
/// to the grid cells like anti-aliased pixels, meaning that a grid cell will
/// record the partially overlapping boundary as a fractional number.
/// Alternative apporach is to represent boundaries like Lego blocks which is
/// the case for GridSinglePhasePressureSolver3.
/// In addition, this class solves single-phase flow, solving the pressure for
/// selected fluid region only and treat other area as an atmosphere region.
/// Thus, the pressure outside the fluid will be set to a constant value and
/// velocity field won't be altered. This solver also computes the fluid
/// boundary in fractional manner, meaning that the solver tries to capture the
/// subgrid structures. This class uses ghost fluid method for such calculation.
///
/// \see Batty, Christopher, Florence Bertails, and Robert Bridson.
///     "A fast variational framework for accurate solid-fluid coupling."
///     ACM Transactions on Graphics (TOG). Vol. 26. No. 3. ACM, 2007.
/// \see Enright, Doug, et al. "Using the particle level set method and
///     a second order accurate pressure boundary condition for free surface
///     flows." ASME/JSME 2003 4th Joint Fluids Summer Engineering Conference.
///     American Society of Mechanical Engineers, 2003.
class GridFractionalSinglePhasePressureSolver3: GridPressureSolver3 {
    var _system = FdmLinearSystem3()
    var _systemSolver:FdmLinearSystemSolver3?
    
    var _mgSystem = FdmMgLinearSystem3()
    var _mgSystemSolver:FdmMgSolver3?
    
    var _uWeights:[Array3<Float>] = []
    var _vWeights:[Array3<Float>] = []
    var _wWeights:[Array3<Float>] = []
    var _fluidSdf:[Array3<Float>] = []
    
    var _boundaryVel:((Vector3F)->Vector3F)?
    
    init() {
        _systemSolver = FdmIccgSolver3(maxNumberOfIterations: 100,
                                       tolerance: kDefaultTolerance)
    }
    
    /// Solves the pressure term and apply it to the velocity field.
    ///
    /// This function takes input velocity field and outputs pressure-applied
    /// velocity field. It also accepts extra arguments such as \p boundarySdf
    /// and \p fluidSdf that represent signed-distance representation of the
    /// boundary and fluid area. The negative region of \p boundarySdf means
    /// it is occupied by solid object. Also, the positive / negative area of
    /// the \p fluidSdf means it is occupied by fluid / atmosphere. If not
    /// specified, constant scalar field with kMaxD will be used for
    /// \p boundarySdf meaning that no boundary at all. Similarly, a constant
    /// field with -kMaxD will be used for \p fluidSdf which means it's fully
    /// occupied with fluid without any atmosphere.
    /// - Parameters:
    ///   - input: The input velocity field.
    ///   - timeIntervalInSeconds: The time interval for the sim.
    ///   - output: The output velocity field.
    ///   - boundarySdf: The SDF of the boundary.
    ///   - fluidSdf: The SDF of the fluid/atmosphere.
    func solve(input: FaceCenteredGrid3,
               timeIntervalInSeconds: Double,
               output: inout FaceCenteredGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               boundaryVelocity: VectorField3 = ConstantVectorField3(value: [0, 0]),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        buildWeights(input: input, boundarySdf: boundarySdf, boundaryVelocity: boundaryVelocity, fluidSdf: fluidSdf)
        buildSystem(input: input)
        
        if (_systemSolver != nil) {
            // Solve the system
            if (_mgSystemSolver == nil) {
                _ = _systemSolver!.solve(system: &_system)
            } else {
                _ = _mgSystemSolver!.solve(system: &_mgSystem)
            }
            
            // Apply pressure gradient
            if Renderer.arch == .CPU {
                applyPressureGradient(input: input, output: &output)
            } else {
                applyPressureGradient_GPU(input: input, output: &output)
            }            
        }
    }
    
    /// Returns the best boundary condition solver for this solver.
    ///
    /// This function returns the best boundary condition solver that works well
    /// with this pressure solver. Depending on the pressure solver
    /// implementation, different boundary condition solver might be used. For
    /// this particular class, an instance of
    /// GridFractionalBoundaryConditionSolver3 will be returned.
    func suggestedBoundaryConditionSolver()->GridBoundaryConditionSolver3 {
        return GridFractionalBoundaryConditionSolver3()
    }
    
    /// Returns the linear system solver.
    func linearSystemSolver()->FdmLinearSystemSolver3 {
        return _systemSolver!
    }
    
    /// Sets the linear system solver.
    func setLinearSystemSolver(solver:FdmLinearSystemSolver3) {
        _systemSolver = solver
        _mgSystemSolver = _systemSolver as? FdmMgSolver3
        
        if (_mgSystemSolver == nil) {
            // In case of non-mg system, use flat structure.
            _mgSystem.clear()
        } else {
            // In case of mg system, use multi-level structure.
            _system.clear()
        }
    }
    
    /// Returns the pressure field.
    func pressure()->FdmVector3 {
        if (_mgSystemSolver == nil) {
            return _system.x
        } else {
            return _mgSystem.x.levels.first!
        }
    }
    
    func buildWeights(input:FaceCenteredGrid3,
                      boundarySdf:ScalarField3,
                      boundaryVelocity:VectorField3,
                      fluidSdf:ScalarField3) {
        let size = input.resolution()
        
        // Build levels
        var maxLevels:size_t = 1
        if (_mgSystemSolver != nil) {
            maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
        }
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: size, maxNumberOfLevels: maxLevels, levels: &_fluidSdf)
        _uWeights = Array<Array3<Float>>(repeating: Array3<Float>(), count: _fluidSdf.count)
        _vWeights = Array<Array3<Float>>(repeating: Array3<Float>(), count: _fluidSdf.count)
        _wWeights = Array<Array3<Float>>(repeating: Array3<Float>(), count: _fluidSdf.count)
        for l in 0..<_fluidSdf.count {
            _uWeights[l].resize(size: _fluidSdf[l].size() &+ Size3(1, 0, 0))
            _vWeights[l].resize(size: _fluidSdf[l].size() &+ Size3(0, 1, 0))
            _wWeights[l].resize(size: _fluidSdf[l].size() &+ Size3(0, 0, 1))
        }
        
        // Build top-level grids
        let cellPos = input.cellCenterPosition()
        let uPos = input.uPosition()
        let vPos = input.vPosition()
        let wPos = input.wPosition()
        _boundaryVel = boundaryVelocity.sampler()
        let h = input.gridSpacing()
        
        _fluidSdf.withUnsafeMutableBufferPointer { _fluidSdfPtr in
            _fluidSdfPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                _fluidSdfPtr[0][i, j, k] = fluidSdf.sample(x: cellPos(i, j, k))
            }
        }
        
        _uWeights.withUnsafeMutableBufferPointer { _uWeightsPtr in
            _uWeightsPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let pt = uPos(i, j, k)
                let phi0 =
                    boundarySdf.sample(x: pt + Vector3F(0.0, -0.5 * h.y, -0.5 * h.z))
                let phi1 =
                    boundarySdf.sample(x: pt + Vector3F(0.0, 0.5 * h.y, -0.5 * h.z))
                let phi2 =
                    boundarySdf.sample(x: pt + Vector3F(0.0, -0.5 * h.y, 0.5 * h.z))
                let phi3 =
                    boundarySdf.sample(x: pt + Vector3F(0.0, 0.5 * h.y, 0.5 * h.z))
                let frac = fractionInside(phiBottomLeft: phi0, phiBottomRight: phi1,
                                          phiTopLeft: phi2, phiTopRight: phi3)
                var weight = Math.clamp(val: 1.0 - frac, low: 0.0, high: 1.0)
                
                // Clamp non-zero weight to kMinWeight. Having nearly-zero element
                // in the matrix can be an issue.
                if (weight < kMinWeight && weight > 0.0) {
                    weight = kMinWeight
                }
                
                _uWeightsPtr[0][i, j, k] = weight
            }
        }
        
        _vWeights.withUnsafeMutableBufferPointer { _vWeightsPtr in
            _vWeightsPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let pt = vPos(i, j, k)
                let phi0 =
                    boundarySdf.sample(x: pt + Vector3F(-0.5 * h.x, 0.0, -0.5 * h.z))
                let phi1 =
                    boundarySdf.sample(x: pt + Vector3F(-0.5 * h.x, 0.0, 0.5 * h.z))
                let phi2 =
                    boundarySdf.sample(x: pt + Vector3F(0.5 * h.x, 0.0, -0.5 * h.z))
                let phi3 =
                    boundarySdf.sample(x: pt + Vector3F(0.5 * h.x, 0.0, 0.5 * h.z))
                let frac = fractionInside(phiBottomLeft: phi0, phiBottomRight: phi1,
                                          phiTopLeft: phi2, phiTopRight: phi3)
                var weight = Math.clamp(val: 1.0 - frac, low: 0.0, high: 1.0)
                
                // Clamp non-zero weight to kMinWeight. Having nearly-zero element
                // in the matrix can be an issue.
                if (weight < kMinWeight && weight > 0.0) {
                    weight = kMinWeight
                }
                
                _vWeightsPtr[0][i, j, k] = weight
            }
        }
        
        _wWeights.withUnsafeMutableBufferPointer { _wWeightsPtr in
            _wWeightsPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let pt = wPos(i, j, k)
                let phi0 =
                    boundarySdf.sample(x: pt + Vector3F(-0.5 * h.x, -0.5 * h.y, 0.0))
                let phi1 =
                    boundarySdf.sample(x: pt + Vector3F(-0.5 * h.x, 0.5 * h.y, 0.0))
                let phi2 =
                    boundarySdf.sample(x: pt + Vector3F(0.5 * h.x, -0.5 * h.y, 0.0))
                let phi3 =
                    boundarySdf.sample(x: pt + Vector3F(0.5 * h.x, 0.5 * h.y, 0.0))
                let frac = fractionInside(phiBottomLeft: phi0, phiBottomRight: phi1,
                                          phiTopLeft: phi2, phiTopRight: phi3)
                var weight = Math.clamp(val: 1.0 - frac, low: 0.0, high: 1.0)
                
                // Clamp non-zero weight to kMinWeight. Having nearly-zero element
                // in the matrix can be an issue.
                if (weight < kMinWeight && weight > 0.0) {
                    weight = kMinWeight
                }
                
                _wWeightsPtr[0][i, j, k] = weight
            }
        }
        
        // Build sub-levels
        for l in 1..<_fluidSdf.count {
            let finerFluidSdf = _fluidSdf[l - 1]
            var coarserFluidSdf = _fluidSdf[l]
            let finerUWeight = _uWeights[l - 1]
            var coarserUWeight = _uWeights[l]
            let finerVWeight = _vWeights[l - 1]
            var coarserVWeight = _vWeights[l]
            let finerWWeight = _wWeights[l - 1]
            var coarserWWeight = _wWeights[l]
            
            // Fluid SDF
            if Renderer.arch == .CPU {
                restrict(finer: finerFluidSdf, coarser: &coarserFluidSdf)
                restrict(finer: finerUWeight, coarser: &coarserUWeight)
                restrict(finer: finerVWeight, coarser: &coarserVWeight)
                restrict(finer: finerWWeight, coarser: &coarserWWeight)
            } else {
                restrict_GPU(finer: finerFluidSdf, coarser: &coarserFluidSdf)
                restrict_GPU(finer: finerUWeight, coarser: &coarserUWeight)
                restrict_GPU(finer: finerVWeight, coarser: &coarserVWeight)
                restrict_GPU(finer: finerWWeight, coarser: &coarserWWeight)
            }
        }
    }
    
    func buildSystem(input:FaceCenteredGrid3) {
        let size = input.resolution()
        var numLevels:size_t = 1
        
        if (_mgSystemSolver == nil) {
            _system.resize(size: size)
        } else {
            // Build levels
            let maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
            FdmMgUtils3.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.A.levels)
            FdmMgUtils3.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.x.levels)
            FdmMgUtils3.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.b.levels)
            
            numLevels = _mgSystem.A.levels.count
        }
        
        // Build top level
        var finer = input
        if (_mgSystemSolver == nil) {
            var A = FdmMatrix3(size: _system.A.size())
            var b = FdmVector3(size: _system.b.size())
            buildSingleSystem(A: &A, b: &b, fluidSdf: _fluidSdf[0],
                              uWeights: _uWeights[0], vWeights: _vWeights[0], wWeights: _wWeights[0],
                              boundaryVel: _boundaryVel!, input: finer)
            _system.A = A
            _system.b = b
        } else {
            var A = FdmMatrix3(size: _mgSystem.A.levels[0].size())
            var b = FdmVector3(size: _mgSystem.b.levels[0].size())
            buildSingleSystem(A: &A, b: &b, fluidSdf: _fluidSdf[0],
                              uWeights: _uWeights[0], vWeights: _vWeights[0], wWeights: _wWeights[0],
                              boundaryVel: _boundaryVel!, input: finer)
            _mgSystem.A.levels[0] = A
            _mgSystem.b.levels[0] = b
        }
        
        // Build sub-levels
        let coarser = FaceCenteredGrid3()
        for l in 1..<numLevels {
            var res = finer.resolution()
            var h = finer.gridSpacing()
            let o = finer.origin()
            res.x = res.x >> 1
            res.y = res.y >> 1
            res.z = res.z >> 1
            h *= 2.0
            
            // Down sample
            coarser.resize(resolution: res, gridSpacing: h, origin: o)
            coarser.fill(function: finer.sampler())
            
            var A = FdmMatrix3(size: _mgSystem.A.levels[l].size())
            var b = FdmVector3(size: _mgSystem.b.levels[l].size())
            buildSingleSystem(A: &A, b: &b,
                              fluidSdf: _fluidSdf[l],
                              uWeights: _uWeights[l], vWeights: _vWeights[l], wWeights: _wWeights[l],
                              boundaryVel: _boundaryVel!, input: coarser)
            _mgSystem.A.levels[l] = A
            _mgSystem.b.levels[l] = b
            
            finer = coarser
        }
    }
    
    func applyPressureGradient(input:FaceCenteredGrid3,
                               output:inout FaceCenteredGrid3) {
        let size = input.resolution()
        let u = input.uConstAccessor()
        let v = input.vConstAccessor()
        let w = input.wConstAccessor()
        var u0 = output.uAccessor()
        var v0 = output.vAccessor()
        var w0 = output.wAccessor()
        
        let x = pressure()
        
        let invH = 1.0 / input.gridSpacing()
        
        x.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let centerPhi = _fluidSdf[0][i, j, k]
            
            if (i + 1 < size.x && _uWeights[0][i + 1, j, k] > 0.0 &&
                (isInsideSdf(phi: centerPhi) ||
                    isInsideSdf(phi: _fluidSdf[0][i + 1, j, k]))) {
                let rightPhi = _fluidSdf[0][i + 1, j, k]
                var theta = fractionInsideSdf(phi0: centerPhi, phi1: rightPhi)
                theta = max(theta, 0.01)
                
                u0[i + 1, j, k] = u[i + 1, j, k] + invH.x / theta * (x[i + 1, j, k] - x[i, j, k])
            }
            
            if (j + 1 < size.y && _vWeights[0][i, j + 1, k] > 0.0 &&
                (isInsideSdf(phi: centerPhi) ||
                    isInsideSdf(phi: _fluidSdf[0][i, j + 1, k]))) {
                let upPhi = _fluidSdf[0][i, j + 1, k]
                var theta = fractionInsideSdf(phi0: centerPhi, phi1: upPhi)
                theta = max(theta, 0.01)
                
                v0[i, j + 1, k] = v[i, j + 1, k] + invH.y / theta * (x[i, j + 1, k] - x[i, j, k])
            }
            
            if (k + 1 < size.z && _wWeights[0][i, j, k + 1] > 0.0 &&
                (isInsideSdf(phi: centerPhi) ||
                    isInsideSdf(phi: _fluidSdf[0][i, j, k + 1]))) {
                let frontPhi = _fluidSdf[0][i, j, k + 1]
                var theta = fractionInsideSdf(phi0: centerPhi, phi1: frontPhi)
                theta = max(theta, 0.01)
                
                w0[i, j, k + 1] = w[i, j, k + 1] + invH.z / theta * (x[i, j, k + 1] - x[i, j, k])
            }
        }
    }
}

func restrict(finer:Array3<Float>, coarser:inout Array3<Float>) {
    // --*--|--*--|--*--|--*--
    //  1/8   3/8   3/8   1/8
    //           to
    // -----|-----*-----|-----
    let centeredKernel:[Float] = [0.135, 0.375, 0.375, 0.135]
    
    // -|----|----|----|----|-
    //      1/4  1/3  1/4
    //           to
    // -|---------|---------|-
    let staggeredKernel:[Float] = [0.0, 1.0, 0.0, 0.0]
    
    var kernelSize = Array<Int>(repeating: 0, count: 3)
    kernelSize[0] = finer.size().x != 2 * coarser.size().x ? 3 : 4
    kernelSize[1] = finer.size().y != 2 * coarser.size().y ? 3 : 4
    kernelSize[2] = finer.size().z != 2 * coarser.size().y ? 3 : 4
    
    var kernels = Array<Array<Float>>(repeating: Array<Float>(repeating: 0, count: 4), count: 3)
    kernels[0] = (kernelSize[0] == 3) ? staggeredKernel : centeredKernel
    kernels[1] = (kernelSize[1] == 3) ? staggeredKernel : centeredKernel
    kernels[2] = (kernelSize[2] == 3) ? staggeredKernel : centeredKernel
    
    let n = coarser.size()
    parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                     beginIndexY: 0, endIndexY: n.y,
                     beginIndexZ: 0, endIndexZ: n.z){(
                        iBegin:size_t, iEnd:size_t,
                        jBegin:size_t, jEnd:size_t,
                        kBegin:size_t, kEnd:size_t) in
                        var kIndices = Array<size_t>(repeating: 0, count: 4)
                        
                        for k in kBegin..<kEnd {
                            if (kernelSize[2] == 3) {
                                kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k
                                kIndices[1] = 2 * k
                                kIndices[2] = (k + 1 < n.z) ? 2 * k + 1 : 2 * k
                            } else {
                                kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k
                                kIndices[1] = 2 * k
                                kIndices[2] = 2 * k + 1
                                kIndices[3] = (k + 1 < n.z) ? 2 * k + 2 : 2 * k + 1
                            }
                            
                            var jIndices = Array<size_t>(repeating: 0, count: 4)
                            for j in jBegin..<jEnd {
                                if (kernelSize[1] == 3) {
                                    jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j
                                    jIndices[1] = 2 * j
                                    jIndices[2] = (j + 1 < n.y) ? 2 * j + 1 : 2 * j
                                } else {
                                    jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j
                                    jIndices[1] = 2 * j
                                    jIndices[2] = 2 * j + 1
                                    jIndices[3] = (j + 1 < n.y) ? 2 * j + 2 : 2 * j + 1
                                }
                                
                                var iIndices = Array<size_t>(repeating: 0, count: 4)
                                for i in iBegin..<iEnd {
                                    if (kernelSize[0] == 3) {
                                        iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i
                                        iIndices[1] = 2 * i
                                        iIndices[2] = (i + 1 < n.x) ? 2 * i + 1 : 2 * i
                                    } else {
                                        iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i
                                        iIndices[1] = 2 * i
                                        iIndices[2] = 2 * i + 1
                                        iIndices[3] = (i + 1 < n.x) ? 2 * i + 2 : 2 * i + 1
                                    }
                                    
                                    var sum:Float = 0.0
                                    for z in 0..<kernelSize[2] {
                                        for y in 0..<kernelSize[1] {
                                            for x in 0..<kernelSize[0] {
                                                let w = kernels[0][x] * kernels[1][y] * kernels[2][z]
                                                sum += w * finer[iIndices[x], jIndices[y],
                                                                 kIndices[z]]
                                            }
                                        }
                                    }
                                    coarser[i, j, k] = sum
                                }
                            }
                        }
    }
}

func buildSingleSystem(A:inout FdmMatrix3, b:inout FdmVector3,
                       fluidSdf:Array3<Float>,
                       uWeights:Array3<Float>,
                       vWeights:Array3<Float>,
                       wWeights:Array3<Float>,
                       boundaryVel:(Vector3F)->Vector3F,
                       input:FaceCenteredGrid3) {
    if Renderer.arch == .CPU {
        let size = input.resolution()
        let uPos = input.uPosition()
        let vPos = input.vPosition()
        let wPos = input.wPosition()
        
        let invH = 1.0 / input.gridSpacing()
        let invHSqr = invH * invH
        
        // Build linear system
        A.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            // initialize
            A[i, j, k].center = 0.0
            A[i, j, k].right = 0.0
            A[i, j, k].up = 0.0
            A[i, j, k].front = 0.0
            b[i, j, k] = 0.0
            
            let centerPhi = fluidSdf[i, j, k]
            
            if (isInsideSdf(phi: centerPhi)) {
                var term:Float = 0
                
                if (i + 1 < size.x) {
                    term = uWeights[i + 1, j, k] * invHSqr.x
                    let rightPhi = fluidSdf[i + 1, j, k]
                    if (isInsideSdf(phi: rightPhi)) {
                        A[i, j, k].center += term
                        A[i, j, k].right -= term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: rightPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] +=
                        uWeights[i + 1, j, k] * input.u(i: i + 1, j: j, k: k) * invH.x
                } else {
                    b[i, j, k] += input.u(i: i + 1, j: j, k: k) * invH.x
                }
                
                if (i > 0) {
                    term = uWeights[i, j, k] * invHSqr.x
                    let leftPhi = fluidSdf[i - 1, j, k]
                    if (isInsideSdf(phi: leftPhi)) {
                        A[i, j, k].center += term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: leftPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] -= uWeights[i, j, k] * input.u(i: i, j: j, k: k) * invH.x
                } else {
                    b[i, j, k] -= input.u(i: i, j: j, k: k) * invH.x
                }
                
                if (j + 1 < size.y) {
                    term = vWeights[i, j + 1, k] * invHSqr.y
                    let upPhi = fluidSdf[i, j + 1, k]
                    if (isInsideSdf(phi: upPhi)) {
                        A[i, j, k].center += term
                        A[i, j, k].up -= term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: upPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] +=
                        vWeights[i, j + 1, k] * input.v(i: i, j: j + 1, k: k) * invH.y
                } else {
                    b[i, j, k] += input.v(i: i, j: j + 1, k: k) * invH.y
                }
                
                if (j > 0) {
                    term = vWeights[i, j, k] * invHSqr.y
                    let downPhi = fluidSdf[i, j - 1, k]
                    if (isInsideSdf(phi: downPhi)) {
                        A[i, j, k].center += term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: downPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] -= vWeights[i, j, k] * input.v(i: i, j: j, k: k) * invH.y
                } else {
                    b[i, j, k] -= input.v(i: i, j: j, k: k) * invH.y
                }
                
                if (k + 1 < size.z) {
                    term = wWeights[i, j, k + 1] * invHSqr.z
                    let frontPhi = fluidSdf[i, j, k + 1]
                    if (isInsideSdf(phi: frontPhi)) {
                        A[i, j, k].center += term
                        A[i, j, k].front -= term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: frontPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] +=
                        wWeights[i, j, k + 1] * input.w(i: i, j: j, k: k + 1) * invH.z
                } else {
                    b[i, j, k] += input.w(i: i, j: j, k: k + 1) * invH.z
                }
                
                if (k > 0) {
                    term = wWeights[i, j, k] * invHSqr.z
                    let backPhi = fluidSdf[i, j, k - 1]
                    if (isInsideSdf(phi: backPhi)) {
                        A[i, j, k].center += term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: backPhi)
                        theta = max(theta, 0.01)
                        A[i, j, k].center += term / theta
                    }
                    b[i, j, k] -= wWeights[i, j, k] * input.w(i: i, j: j, k: k) * invH.z
                } else {
                    b[i, j, k] -= input.w(i: i, j: j, k: k) * invH.z
                }
                
                // Accumulate contributions from the moving boundary
                let boundaryContribution =
                    (1.0 - uWeights[i + 1, j, k]) *
                        boundaryVel(uPos(i + 1, j, k)).x * invH.x -
                        (1.0 - uWeights[i, j, k]) * boundaryVel(uPos(i, j, k)).x *
                        invH.x +
                        (1.0 - vWeights[i, j + 1, k]) *
                        boundaryVel(vPos(i, j + 1, k)).y * invH.y -
                        (1.0 - vWeights[i, j, k]) * boundaryVel(vPos(i, j, k)).y *
                        invH.y +
                        (1.0 - wWeights[i, j, k + 1]) *
                        boundaryVel(wPos(i, j, k + 1)).z * invH.z -
                        (1.0 - wWeights[i, j, k]) * boundaryVel(wPos(i, j, k)).z *
                        invH.z
                b[i, j, k] += boundaryContribution
                
                // If row.center is near-zero, the cell is likely inside a solid
                // boundary.
                if (A[i, j, k].center < Float.leastNonzeroMagnitude) {
                    A[i, j, k].center = 1.0
                    b[i, j, k] = 0.0
                }
            } else {
                A[i, j, k].center = 1.0
            }
        }
    } else {
        buildSingleSystem_GPU(A: &A, b: &b, fluidSdf: fluidSdf,
                              uWeights: uWeights, vWeights: vWeights, wWeights: wWeights,
                              boundaryVel: boundaryVel, input: input)
    }
}

//MARK:- GPU Methods
extension GridFractionalSinglePhasePressureSolver3 {
    func applyPressureGradient_GPU(input:FaceCenteredGrid3,
                                   output:inout FaceCenteredGrid3) {
        var x = pressure()
        var invH = 1.0 / input.gridSpacing()
        
        x.parallelForEachIndex(name: "GridFractionalSinglePhasePressureSolver3::applyPressureGradient") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _fluidSdf[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _uWeights[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _vWeights[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _wWeights[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = output.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&invH, length: MemoryLayout<Vector3F>.stride, index: index)
        }
    }
}

func restrict_GPU(finer:Array3<Float>, coarser:inout Array3<Float>) {
    let n = coarser.size();
    parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                     beginIndexY: 0, endIndexY: n.y,
                     beginIndexZ: 0, endIndexZ: n.z,
                     name: "GridFractionalSinglePhasePressureSolver3::restricted") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = finer.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = coarser.loadGPUBuffer(encoder: &encoder, index_begin: index)
    }
}

func buildSingleSystem_GPU(A:inout FdmMatrix3, b:inout FdmVector3,
                           fluidSdf:Array3<Float>,
                           uWeights:Array3<Float>,
                           vWeights:Array3<Float>,
                           wWeights:Array3<Float>,
                           boundaryVel:(Vector3F)->Vector3F,
                           input:FaceCenteredGrid3) {
    var invH = 1.0 / input.gridSpacing()
    var invHSqr = invH * invH
    A.parallelForEachIndex(name: "GridFractionalSinglePhasePressureSolver3::buildSingleSystem") {
        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
        index = b.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = fluidSdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = uWeights.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = vWeights.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = wWeights.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
        encoder.setBytes(&invH, length: MemoryLayout<Vector3F>.stride, index: index)
        encoder.setBytes(&invHSqr, length: MemoryLayout<Vector3F>.stride, index: index+1)
    }
    
    let uPos = input.uPosition()
    let vPos = input.vPosition()
    let wPos = input.wPosition()
    // Build linear system
    A.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
        let centerPhi = fluidSdf[i, j, k]
        
        if (isInsideSdf(phi: centerPhi)) {
            // Accumulate contributions from the moving boundary
            let boundaryContribution =
                (1.0 - uWeights[i + 1, j, k]) *
                    boundaryVel(uPos(i + 1, j, k)).x * invH.x -
                    (1.0 - uWeights[i, j, k]) * boundaryVel(uPos(i, j, k)).x *
                    invH.x +
                    (1.0 - vWeights[i, j + 1, k]) *
                    boundaryVel(vPos(i, j + 1, k)).y * invH.y -
                    (1.0 - vWeights[i, j, k]) * boundaryVel(vPos(i, j, k)).y *
                    invH.y +
                    (1.0 - wWeights[i, j, k + 1]) *
                    boundaryVel(wPos(i, j, k + 1)).z * invH.z -
                    (1.0 - wWeights[i, j, k]) * boundaryVel(wPos(i, j, k)).z *
                    invH.z
            b[i, j, k] += boundaryContribution
        }
    }
}
