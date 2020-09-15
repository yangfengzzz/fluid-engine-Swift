//
//  grid_single_phase_pressure_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D single-phase pressure solver.
///
/// This class implements 3-D single-phase pressure solver. This solver encodes
/// the boundaries like Lego blocks -- if a grid cell center is inside or
/// outside the boundaries, it is either marked as occupied or not.
/// In addition, this class solves single-phase flow, solving the pressure for
/// selected fluid region only and treat other area as an atmosphere region.
/// Thus, the pressure outside the fluid will be set to a constant value and
/// velocity field won't be altered. This solver also computes the fluid
/// boundary in block-like manner If a grid cell is inside or outside the
/// fluid, it is marked as either fluid or atmosphere. Thus, this solver in
/// general, does not compute subgrid structure.
class GridSinglePhasePressureSolver3: GridPressureSolver3 {
    var _system = FdmLinearSystem3()
    var _systemSolver:FdmLinearSystemSolver3?
    
    var _mgSystem = FdmMgLinearSystem3()
    var _mgSystemSolver:FdmMgSolver3?
    
    var _markers:[Array3<CChar>] = []
    
    /// Default constructor.
    init() {
        self._systemSolver = FdmIccgSolver3(maxNumberOfIterations: 100,
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
               boundaryVelocity: VectorField3 = ConstantVectorField3(value: [0, 0, 0]),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        let pos = input.cellCenterPosition()
        if Renderer.arch == .CPU {
            buildMarkers(size: input.resolution(), pos: pos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        } else {
            buildMarkers_GPU(size: input.resolution(), pos: pos,
                             boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
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
    /// GridBlockedBoundaryConditionSolver3 will be returned since this pressure
    /// solver encodes boundaries like pixelated Lego blocks.
    /// - Returns: The best boundary condition solver for this solver.
    func suggestedBoundaryConditionSolver()->GridBoundaryConditionSolver3 {
        return GridBlockedBoundaryConditionSolver3()
    }
    
    /// Returns the linear system solver
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
    
    func buildMarkers(size:Size3,
                      pos:(size_t, size_t, size_t)->Vector3F,
                      boundarySdf:ScalarField3,
                      fluidSdf:ScalarField3) {
        // Build levels
        var maxLevels = 1
        if (_mgSystemSolver != nil) {
            maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
        }
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: size,
                                          maxNumberOfLevels: maxLevels,
                                          levels: &_markers)
        
        // Build top-level markers
        _markers.withUnsafeMutableBufferPointer { _markersPtr in
            _markersPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let pt = pos(i, j, k)
                if (isInsideSdf(phi: boundarySdf.sample(x: pt))) {
                    _markersPtr[0][i, j, k] = kBoundary
                } else if (isInsideSdf(phi: fluidSdf.sample(x: pt))) {
                    _markersPtr[0][i, j, k] = kFluid
                } else {
                    _markersPtr[0][i, j, k] = kAir
                }
            }
        }
        
        // Build sub-level markers
        for l in 1..<_markers.count {
            let finer = _markers[l - 1]
            var coarser = _markers[l]
            let n = coarser.size()
            
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y,
                             beginIndexZ: 0, endIndexZ: n.z){(
                                iBegin:size_t, iEnd:size_t,
                                jBegin:size_t, jEnd:size_t,
                                kBegin:size_t, kEnd:size_t) in
                                var kIndices = Array<size_t>(repeating: 0, count: 4)
                                for k in kBegin..<kEnd {
                                    kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k
                                    kIndices[1] = 2 * k
                                    kIndices[2] = 2 * k + 1
                                    kIndices[3] = (k + 1 < n.z) ? 2 * k + 2 : 2 * k + 1
                                    
                                    var jIndices = Array<size_t>(repeating: 0, count: 4)
                                    for j in jBegin..<jEnd {
                                        jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j
                                        jIndices[1] = 2 * j
                                        jIndices[2] = 2 * j + 1
                                        jIndices[3] = (j + 1 < n.y) ? 2 * j + 2 : 2 * j + 1
                                        
                                        var iIndices = Array<size_t>(repeating: 0, count: 4)
                                        for i in iBegin..<iEnd {
                                            iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i
                                            iIndices[1] = 2 * i
                                            iIndices[2] = 2 * i + 1
                                            iIndices[3] = (i + 1 < n.x) ? 2 * i + 2 : 2 * i + 1
                                            
                                            var cnt = Array<Int>(repeating: 0, count: 3)
                                            for z in 0..<4 {
                                                for y in 0..<4 {
                                                    for x in 0..<4 {
                                                        let f = finer[iIndices[x], jIndices[y],
                                                                      kIndices[z]]
                                                        if (f == kBoundary) {
                                                            cnt[Int(kBoundary)] += 1
                                                        } else if (f == kFluid) {
                                                            cnt[Int(kFluid)] += 1
                                                        } else {
                                                            cnt[Int(kAir)] += 1
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            coarser[i, j, k] = CChar(Math.argmax3(x: cnt[0], y: cnt[1], z: cnt[2]))
                                        }
                                    }
                                }
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
            buildSingleSystem(A: &A, b: &b, markers: _markers[0], input: finer)
            _system.A = A
            _system.b = b
        } else {
            var A = FdmMatrix3(size: _mgSystem.A.levels[0].size())
            var b = FdmVector3(size: _mgSystem.b.levels[0].size())
            buildSingleSystem(A: &A, b: &b, markers: _markers[0], input: finer)
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
            buildSingleSystem(A: &A, b: &b, markers: _markers[l], input: coarser)
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
            if (_markers[0][i, j, k] == kFluid) {
                if (i + 1 < size.x && _markers[0][i + 1, j, k] != kBoundary) {
                    u0[i + 1, j, k] =
                        u[i + 1, j, k] + invH.x * (x[i + 1, j, k] - x[i, j, k])
                }
                if (j + 1 < size.y && _markers[0][i, j + 1, k] != kBoundary) {
                    v0[i, j + 1, k] =
                        v[i, j + 1, k] + invH.y * (x[i, j + 1, k] - x[i, j, k])
                }
                if (k + 1 < size.z && _markers[0][i, j, k + 1] != kBoundary) {
                    w0[i, j, k + 1] =
                        w[i, j, k + 1] + invH.z * (x[i, j, k + 1] - x[i, j, k])
                }
            }
        }
    }
}

func buildSingleSystem(A:inout FdmMatrix3, b:inout FdmVector3,
                       markers:Array3<CChar>,
                       input:FaceCenteredGrid3) {
    if Renderer.arch == .CPU {
        let size = input.resolution()
        let invH = 1.0 / input.gridSpacing()
        let invHSqr = invH * invH
        
        A.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            // initialize
            A[i, j, k].center = 0.0
            A[i, j, k].right = 0.0
            A[i, j, k].up = 0.0
            A[i, j, k].front = 0.0
            b[i, j, k] = 0.0
            
            if (markers[i, j, k] == kFluid) {
                b[i, j, k] = input.divergenceAtCellCenter(i: i, j: j, k: k)
                
                if (i + 1 < size.x && markers[i + 1, j, k] != kBoundary) {
                    A[i, j, k].center += invHSqr.x
                    if (markers[i + 1, j, k] == kFluid) {
                        A[i, j, k].right -= invHSqr.x
                    }
                }
                
                if (i > 0 && markers[i - 1, j, k] != kBoundary) {
                    A[i, j, k].center += invHSqr.x
                }
                
                if (j + 1 < size.y && markers[i, j + 1, k] != kBoundary) {
                    A[i, j, k].center += invHSqr.y
                    if (markers[i, j + 1, k] == kFluid) {
                        A[i, j, k].up -= invHSqr.y
                    }
                }
                
                if (j > 0 && markers[i, j - 1, k] != kBoundary) {
                    A[i, j, k].center += invHSqr.y
                }
                
                if (k + 1 < size.z && markers[i, j, k + 1] != kBoundary) {
                    A[i, j, k].center += invHSqr.z
                    if (markers[i, j, k + 1] == kFluid) {
                        A[i, j, k].front -= invHSqr.z
                    }
                }
                
                if (k > 0 && markers[i, j, k - 1] != kBoundary) {
                    A[i, j, k].center += invHSqr.z
                }
            } else {
                A[i, j, k].center = 1.0
            }
        }
    } else {
        buildSingleSystem_GPU(A: &A, b: &b, markers: markers, input: input)
    }
}

//MARK:- GPU Methods
extension GridSinglePhasePressureSolver3 {
    func applyPressureGradient_GPU(input:FaceCenteredGrid3,
                                   output:inout FaceCenteredGrid3) {
        var x = pressure()
        var invH = 1.0 / input.gridSpacing()
        
        x.parallelForEachIndex(name: "GridSinglePhasePressureSolver3::applyPressureGradient") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers[0].loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = output.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&invH, length: MemoryLayout<Vector3F>.stride, index: index)
        }
    }
    
    func buildMarkers_GPU(size:Size3,
                          pos:(size_t, size_t, size_t)->Vector3F,
                          boundarySdf:ScalarField3,
                          fluidSdf:ScalarField3) {
        // Build levels
        var maxLevels = 1
        if (_mgSystemSolver != nil) {
            maxLevels = _mgSystemSolver!.params().maxNumberOfLevels
        }
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: size,
                                          maxNumberOfLevels: maxLevels,
                                          levels: &_markers)
        
        // Build top-level markers
        _markers.withUnsafeMutableBufferPointer { _markersPtr in
            _markersPtr[0].parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let pt = pos(i, j, k)
                if (isInsideSdf(phi: boundarySdf.sample(x: pt))) {
                    _markersPtr[0][i, j, k] = kBoundary
                } else if (isInsideSdf(phi: fluidSdf.sample(x: pt))) {
                    _markersPtr[0][i, j, k] = kFluid
                } else {
                    _markersPtr[0][i, j, k] = kAir
                }
            }
        }
        
        // Build sub-level markers
        for l in 1..<_markers.count {
            let finer = _markers[l - 1]
            let coarser = _markers[l]
            let n = coarser.size()
            
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y,
                             beginIndexZ: 0, endIndexZ: n.z,
                             name: "GridSinglePhasePressureSolver3::buildMarkers") {
                                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                                index = finer.loadGPUBuffer(encoder: &encoder, index_begin: index)
                                index = coarser.loadGPUBuffer(encoder: &encoder, index_begin: index)
            }
        }
    }
}

func buildSingleSystem_GPU(A:inout FdmMatrix3, b:inout FdmVector3,
                           markers:Array3<CChar>,
                           input:FaceCenteredGrid3) {
    let invH = 1.0 / input.gridSpacing()
    var invHSqr = invH * invH
    
    A.parallelForEachIndex(name: "GridSinglePhasePressureSolver3::buildSingleSystem") {
        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
        index = b.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
        index = input.loadGPUBuffer(encoder: &encoder, index_begin: index)
        encoder.setBytes(&invHSqr, length: MemoryLayout<Vector3F>.stride, index: index)
    }
}
