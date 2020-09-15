//
//  grid_fractional_single_phase_pressure_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

let kMinWeight:Float = 0.01

/// 2-D fractional single-phase pressure solver.
///
/// This class implements 2-D fractional (or variational) single-phase pressure
/// solver. It is called fractional because the solver encodes the boundaries
/// to the grid cells like anti-aliased pixels, meaning that a grid cell will
/// record the partially overlapping boundary as a fractional number.
/// Alternative apporach is to represent boundaries like Lego blocks which is
/// the case for GridSinglePhasePressureSolver2.
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
class GridFractionalSinglePhasePressureSolver2: GridPressureSolver2 {
    var _system = FdmLinearSystem2()
    var _systemSolver:FdmLinearSystemSolver2?
    
    var _mgSystem = FdmMgLinearSystem2()
    var _mgSystemSolver:FdmMgSolver2?
    
    var _uWeights:[Array2<Float>] = []
    var _vWeights:[Array2<Float>] = []
    var _fluidSdf:[Array2<Float>] = []
    
    var _boundaryVel:((Vector2F)->Vector2F)?
    
    init() {
        _systemSolver = FdmIccgSolver2(maxNumberOfIterations: 100,
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
    func solve(input: FaceCenteredGrid2,
               timeIntervalInSeconds: Double,
               output: inout FaceCenteredGrid2,
               boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
               boundaryVelocity: VectorField2 = ConstantVectorField2(value: [0, 0]),
               fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
    /// GridFractionalBoundaryConditionSolver2 will be returned.
    func suggestedBoundaryConditionSolver()->GridBoundaryConditionSolver2 {
        return GridFractionalBoundaryConditionSolver2()
    }
    
    /// Returns the linear system solver.
    func linearSystemSolver()->FdmLinearSystemSolver2 {
        return _systemSolver!
    }
    
    /// Sets the linear system solver.
    func setLinearSystemSolver(solver:FdmLinearSystemSolver2) {
        _systemSolver = solver
        _mgSystemSolver = _systemSolver as? FdmMgSolver2
        
        if (_mgSystemSolver == nil) {
            // In case of non-mg system, use flat structure.
            _mgSystem.clear()
        } else {
            // In case of mg system, use multi-level structure.
            _system.clear()
        }
    }
    
    /// Returns the pressure field.
    func pressure()->FdmVector2 {
        if (_mgSystemSolver == nil) {
            return _system.x
        } else {
            return _mgSystem.x.levels.first!
        }
    }
    
    func buildWeights(input:FaceCenteredGrid2,
                      boundarySdf:ScalarField2,
                      boundaryVelocity:VectorField2,
                      fluidSdf:ScalarField2) {
        let size = input.resolution()
        
        // Build levels
        var maxLevels:size_t = 1
        if (_mgSystemSolver != nil) {
            maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
        }
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: size, maxNumberOfLevels: maxLevels, levels: &_fluidSdf)
        _uWeights = Array<Array2<Float>>(repeating: Array2<Float>(), count: _fluidSdf.count)
        _vWeights = Array<Array2<Float>>(repeating: Array2<Float>(), count: _fluidSdf.count)
        for l in 0..<_fluidSdf.count {
            _uWeights[l].resize(size: _fluidSdf[l].size() &+ Size2(1, 0))
            _vWeights[l].resize(size: _fluidSdf[l].size() &+ Size2(0, 1))
        }
        
        // Build top-level grids
        let cellPos = input.cellCenterPosition()
        let uPos = input.uPosition()
        let vPos = input.vPosition()
        _boundaryVel = boundaryVelocity.sampler()
        let h = input.gridSpacing()
        
        _fluidSdf.withUnsafeMutableBufferPointer { _fluidSdfPtr in
            _fluidSdfPtr[0].parallelForEachIndex(){(i:size_t, j:size_t) in
                _fluidSdfPtr[0][i, j] = fluidSdf.sample(x: cellPos(i, j))
            }
        }
        
        _uWeights.withUnsafeMutableBufferPointer { _uWeightsPtr in
            _uWeightsPtr[0].parallelForEachIndex(){(i:size_t, j:size_t) in
                let pt = uPos(i, j)
                let phi0 = boundarySdf.sample(x: pt - Vector2F(0.5 * h.x, 0.0))
                let phi1 = boundarySdf.sample(x: pt + Vector2F(0.5 * h.x, 0.0))
                let frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
                var weight = Math.clamp(val: 1.0 - frac, low: 0.0, high: 1.0)
                
                // Clamp non-zero weight to kMinWeight. Having nearly-zero element
                // in the matrix can be an issue.
                if (weight < kMinWeight && weight > 0.0) {
                    weight = kMinWeight
                }
                
                _uWeightsPtr[0][i, j] = weight
            }
        }
        
        _vWeights.withUnsafeMutableBufferPointer { _vWeightsPtr in
            _vWeightsPtr[0].parallelForEachIndex(){(i:size_t, j:size_t) in
                let pt = vPos(i, j)
                let phi0 = boundarySdf.sample(x: pt - Vector2F(0.0, 0.5 * h.y))
                let phi1 = boundarySdf.sample(x: pt + Vector2F(0.0, 0.5 * h.y))
                let frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
                var weight = Math.clamp(val: 1.0 - frac, low: 0.0, high: 1.0)
                
                // Clamp non-zero weight to kMinWeight. Having nearly-zero element
                // in the matrix can be an issue.
                if (weight < kMinWeight && weight > 0.0) {
                    weight = kMinWeight
                }
                
                _vWeightsPtr[0][i, j] = weight
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
            
            // Fluid SDF
            if Renderer.arch == .CPU {
                restrict(finer: finerFluidSdf, coarser: &coarserFluidSdf)
                restrict(finer: finerUWeight, coarser: &coarserUWeight)
                restrict(finer: finerVWeight, coarser: &coarserVWeight)
            } else {
                restrict_GPU(finer: finerFluidSdf, coarser: &coarserFluidSdf)
                restrict_GPU(finer: finerUWeight, coarser: &coarserUWeight)
                restrict_GPU(finer: finerVWeight, coarser: &coarserVWeight)
            }
        }
    }
    
    func buildSystem(input:FaceCenteredGrid2) {
        let size = input.resolution()
        var numLevels:size_t = 1
        
        if (_mgSystemSolver == nil) {
            _system.resize(size: size)
        } else {
            // Build levels
            let maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
            FdmMgUtils2.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.A.levels)
            FdmMgUtils2.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.x.levels)
            FdmMgUtils2.resizeArrayWithFinest(finestResolution: size,
                                              maxNumberOfLevels: maxLevels,
                                              levels: &_mgSystem.b.levels)
            
            numLevels = _mgSystem.A.levels.count
        }
        
        // Build top level
        var finer = input
        if (_mgSystemSolver == nil) {
            var A = FdmMatrix2(size: _system.A.size())
            var b = FdmVector2(size: _system.b.size())
            buildSingleSystem(A: &A, b: &b, fluidSdf: _fluidSdf[0],
                              uWeights: _uWeights[0], vWeights: _vWeights[0],
                              boundaryVel: _boundaryVel!, input: finer)
            _system.A = A
            _system.b = b
        } else {
            var A = FdmMatrix2(size: _mgSystem.A.levels[0].size())
            var b = FdmVector2(size: _mgSystem.b.levels[0].size())
            buildSingleSystem(A: &A, b: &b, fluidSdf: _fluidSdf[0],
                              uWeights: _uWeights[0], vWeights: _vWeights[0],
                              boundaryVel: _boundaryVel!, input: finer)
            _mgSystem.A.levels[0] = A
            _mgSystem.b.levels[0] = b
        }
        
        // Build sub-levels
        let coarser = FaceCenteredGrid2()
        for l in 1..<numLevels {
            var res = finer.resolution()
            var h = finer.gridSpacing()
            let o = finer.origin()
            res.x = res.x >> 1
            res.y = res.y >> 1
            h *= 2.0
            
            // Down sample
            coarser.resize(resolution: res, gridSpacing: h, origin: o)
            coarser.fill(function: finer.sampler())
            
            var A = FdmMatrix2(size: _mgSystem.A.levels[l].size())
            var b = FdmVector2(size: _mgSystem.b.levels[l].size())
            buildSingleSystem(A: &A, b: &b,
                              fluidSdf: _fluidSdf[l],
                              uWeights: _uWeights[l], vWeights: _vWeights[l],
                              boundaryVel: _boundaryVel!, input: coarser)
            _mgSystem.A.levels[l] = A
            _mgSystem.b.levels[l] = b
            
            finer = coarser
        }
    }
    
    func applyPressureGradient(input:FaceCenteredGrid2,
                               output:inout FaceCenteredGrid2) {
        let size = input.resolution()
        let u = input.uConstAccessor()
        let v = input.vConstAccessor()
        var u0 = output.uAccessor()
        var v0 = output.vAccessor()
        
        let x = pressure()
        
        let invH = 1.0 / input.gridSpacing()
        
        x.parallelForEachIndex(){(i:size_t, j:size_t) in
            let centerPhi = _fluidSdf[0][i, j]
            
            if (i + 1 < size.x && _uWeights[0][i + 1, j] > 0.0 &&
                (isInsideSdf(phi: centerPhi) || isInsideSdf(phi: _fluidSdf[0][i + 1, j]))) {
                let rightPhi = _fluidSdf[0][i + 1, j]
                var theta = fractionInsideSdf(phi0: centerPhi, phi1: rightPhi)
                theta = max(theta, 0.01)
                
                u0[i + 1, j] = u[i + 1, j] + invH.x / theta * (x[i + 1, j] - x[i, j])
            }
            
            if (j + 1 < size.y && _vWeights[0][i, j + 1] > 0.0 &&
                (isInsideSdf(phi: centerPhi) || isInsideSdf(phi: _fluidSdf[0][i, j + 1]))) {
                let upPhi = _fluidSdf[0][i, j + 1]
                var theta = fractionInsideSdf(phi0: centerPhi, phi1: upPhi)
                theta = max(theta, 0.01)
                
                v0[i, j + 1] = v[i, j + 1] + invH.y / theta * (x[i, j + 1] - x[i, j])
            }
        }
    }
}

func restrict(finer:Array2<Float>, coarser:inout Array2<Float>) {
    // --*--|--*--|--*--|--*--
    //  1/8   3/8   3/8   1/8
    //           to
    // -----|-----*-----|-----
    let centeredKernel:[Float] = [0.125, 0.375, 0.375, 0.125]
    
    // -|----|----|----|----|-
    //      1/4  1/2  1/4
    //           to
    // -|---------|---------|-
    let staggeredKernel:[Float] = [0.0, 1.0, 0.0, 0.0]
    
    var kernelSize = Array<Int>(repeating: 0, count: 2)
    kernelSize[0] = finer.size().x != 2 * coarser.size().x ? 3 : 4
    kernelSize[1] = finer.size().y != 2 * coarser.size().y ? 3 : 4
    
    var kernels = Array<Array<Float>>(repeating: Array<Float>(repeating: 0, count: 4), count: 2)
    kernels[0] = (kernelSize[0] == 3) ? staggeredKernel : centeredKernel
    kernels[1] = (kernelSize[1] == 3) ? staggeredKernel : centeredKernel
    
    let n = coarser.size()
    parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                     beginIndexY: 0, endIndexY: n.y){(
                        iBegin:size_t, iEnd:size_t,
                        jBegin:size_t, jEnd:size_t) in
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
                                for y in 0..<kernelSize[1] {
                                    for x in 0..<kernelSize[0] {
                                        let w = kernels[0][x] * kernels[1][y]
                                        sum += w * finer[iIndices[x], jIndices[y]]
                                    }
                                }
                                coarser[i, j] = sum
                            }
                        }
    }
}

func buildSingleSystem(A:inout FdmMatrix2, b:inout FdmVector2,
                       fluidSdf:Array2<Float>,
                       uWeights:Array2<Float>,
                       vWeights:Array2<Float>,
                       boundaryVel:(Vector2F)->Vector2F,
                       input:FaceCenteredGrid2) {
    if Renderer.arch == .CPU {
        let size = input.resolution()
        let uPos = input.uPosition()
        let vPos = input.vPosition()
        
        let invH = 1.0 / input.gridSpacing()
        let invHSqr = invH * invH
        
        // Build linear system
        A.parallelForEachIndex(){(i:size_t, j:size_t) in
            // initialize
            A[i, j].center = 0.0
            A[i, j].right = 0.0
            A[i, j].up = 0.0
            b[i, j] = 0.0
            
            let centerPhi = fluidSdf[i, j]
            
            if (isInsideSdf(phi: centerPhi)) {
                var term:Float = 0
                
                if (i + 1 < size.x) {
                    term = uWeights[i + 1, j] * invHSqr.x
                    let rightPhi = fluidSdf[i + 1, j]
                    if (isInsideSdf(phi: rightPhi)) {
                        A[i, j].center += term
                        A[i, j].right -= term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: rightPhi)
                        theta = max(theta, 0.01)
                        A[i, j].center += term / theta
                    }
                    b[i, j] += uWeights[i + 1, j] * input.u(i: i + 1, j: j) * invH.x
                } else {
                    b[i, j] += input.u(i: i + 1, j: j) * invH.x
                }
                
                if (i > 0) {
                    term = uWeights[i, j] * invHSqr.x
                    let leftPhi = fluidSdf[i - 1, j]
                    if (isInsideSdf(phi: leftPhi)) {
                        A[i, j].center += term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: leftPhi)
                        theta = max(theta, 0.01)
                        A[i, j].center += term / theta
                    }
                    b[i, j] -= uWeights[i, j] * input.u(i: i, j: j) * invH.x
                } else {
                    b[i, j] -= input.u(i: i, j: j) * invH.x
                }
                
                if (j + 1 < size.y) {
                    term = vWeights[i, j + 1] * invHSqr.y
                    let upPhi = fluidSdf[i, j + 1]
                    if (isInsideSdf(phi: upPhi)) {
                        A[i, j].center += term
                        A[i, j].up -= term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: upPhi)
                        theta = max(theta, 0.01)
                        A[i, j].center += term / theta
                    }
                    b[i, j] += vWeights[i, j + 1] * input.v(i: i, j: j + 1) * invH.y
                } else {
                    b[i, j] += input.v(i: i, j: j + 1) * invH.y
                }
                
                if (j > 0) {
                    term = vWeights[i, j] * invHSqr.y
                    let downPhi = fluidSdf[i, j - 1]
                    if (isInsideSdf(phi: downPhi)) {
                        A[i, j].center += term
                    } else {
                        var theta = fractionInsideSdf(phi0: centerPhi, phi1: downPhi)
                        theta = max(theta, 0.01)
                        A[i, j].center += term / theta
                    }
                    b[i, j] -= vWeights[i, j] * input.v(i: i, j: j) * invH.y
                } else {
                    b[i, j] -= input.v(i: i, j: j) * invH.y
                }
                
                // Accumulate contributions from the moving boundary
                let boundaryContribution =
                    (1.0 - uWeights[i + 1, j]) * boundaryVel(uPos(i + 1, j)).x *
                        invH.x -
                        (1.0 - uWeights[i, j]) * boundaryVel(uPos(i, j)).x * invH.x +
                        (1.0 - vWeights[i, j + 1]) * boundaryVel(vPos(i, j + 1)).y *
                        invH.y -
                        (1.0 - vWeights[i, j]) * boundaryVel(vPos(i, j)).y * invH.y
                b[i, j] += boundaryContribution
                
                // If row.center is near-zero, the cell is likely inside a solid
                // boundary.
                if (A[i, j].center < Float.leastNonzeroMagnitude) {
                    A[i, j].center = 1.0
                    b[i, j] = 0.0
                }
            } else {
                A[i, j].center = 1.0
            }
        }
    } else {
        buildSingleSystem_GPU(A: &A, b: &b, fluidSdf: fluidSdf,
                              uWeights: uWeights, vWeights: vWeights,
                              boundaryVel: boundaryVel, input: input)
    }
}

//MARK:- GPU Methods
extension GridFractionalSinglePhasePressureSolver2 {
    func applyPressureGradient_GPU(input:FaceCenteredGrid2,
                                   output:inout FaceCenteredGrid2) {
        var x = pressure()
        var invH = 1.0 / input.gridSpacing()
        
        x.parallelForEachIndex(name: "GridFractionalSinglePhasePressureSolver2::applyPressureGradient") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _fluidSdf[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _uWeights[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _vWeights[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = output.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&invH, length: MemoryLayout<Vector2F>.stride, index: index)
        }
    }
}

func restrict_GPU(finer:Array2<Float>, coarser:inout Array2<Float>) {
    let n = coarser.size();
    parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                     beginIndexY: 0, endIndexY: n.y,
                     name: "GridFractionalSinglePhasePressureSolver2::restricted") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = finer.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = coarser.loadGPUBuffer(encoder: &encoder, index_begin: index)
    }
}

func buildSingleSystem_GPU(A:inout FdmMatrix2, b:inout FdmVector2,
                           fluidSdf:Array2<Float>,
                           uWeights:Array2<Float>,
                           vWeights:Array2<Float>,
                           boundaryVel:(Vector2F)->Vector2F,
                           input:FaceCenteredGrid2) {
    var invH = 1.0 / input.gridSpacing()
    var invHSqr = invH * invH
    A.parallelForEachIndex(name: "GridFractionalSinglePhasePressureSolver2::buildSingleSystem") {
        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
        index = b.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = fluidSdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = uWeights.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = vWeights.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
        encoder.setBytes(&invH, length: MemoryLayout<Vector2F>.stride, index: index)
        encoder.setBytes(&invHSqr, length: MemoryLayout<Vector2F>.stride, index: index+1)
    }
    
    let uPos = input.uPosition()
    let vPos = input.vPosition()
    // Build linear system
    A.parallelForEachIndex(){(i:size_t, j:size_t) in
        let centerPhi = fluidSdf[i, j]
        
        if (isInsideSdf(phi: centerPhi)) {
            // Accumulate contributions from the moving boundary
            let boundaryContribution =
                (1.0 - uWeights[i + 1, j]) * boundaryVel(uPos(i + 1, j)).x *
                    invH.x -
                    (1.0 - uWeights[i, j]) * boundaryVel(uPos(i, j)).x * invH.x +
                    (1.0 - vWeights[i, j + 1]) * boundaryVel(vPos(i, j + 1)).y *
                    invH.y -
                    (1.0 - vWeights[i, j]) * boundaryVel(vPos(i, j)).y * invH.y
            b[i, j] += boundaryContribution
        }
    }
}
