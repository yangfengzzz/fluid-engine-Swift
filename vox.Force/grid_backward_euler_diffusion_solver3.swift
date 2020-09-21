//
//  grid_backward_euler_diffusion_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D grid-based backward Euler diffusion solver.
///
/// This class implements 3-D grid-based forward Euler diffusion solver using
/// second-order central differencing spatially. Since the method is following
/// the implicit time-integration (i.e. backward Euler), larger time interval or
/// diffusion coefficient can be used without breaking the result. Note, higher
/// values for those parameters will still impact the accuracy of the result.
/// To solve the backward Euler method, a linear system solver is used and
/// incomplete Cholesky conjugate gradient method is used by default.
class GridBackwardEulerDiffusionSolver3: GridDiffusionSolver3 {
    enum BoundaryType {
        case Dirichlet
        case Neumann
    }
    
    let _boundaryType:BoundaryType
    var _system = FdmLinearSystem3()
    var _systemSolver:FdmLinearSystemSolver3
    var _markers = Array3<CChar>()
    
    init(boundaryType:BoundaryType = .Neumann) {
        self._boundaryType = boundaryType
        self._systemSolver = FdmIccgSolver3(maxNumberOfIterations: 100,
                                            tolerance: Float.leastNonzeroMagnitude)
    }
    
    /// Solves diffusion equation for a scalar field.
    /// - Parameters:
    ///   - source: Input scalar field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest: Output scalar field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source: ScalarGrid3, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout ScalarGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        if Renderer.arch == .CPU {
            let pos = source.dataPosition()
            let h = source.gridSpacing()
            let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
            
            buildMarkers(size: source.dataSize(), pos: pos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            buildMatrix(size: source.dataSize(), c: c)
            buildVectors(f: source.constDataAccessor(), c: c)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                dest[i, j, k] = _system.x[i, j, k]
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    /// Solves diffusion equation for a collocated vector field.
    /// - Parameters:
    ///   - source: Input collocated vector field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest: Output collocated vector field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source: CollocatedVectorGrid3, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        if Renderer.arch == .CPU {
            let pos = source.dataPosition()
            let h = source.gridSpacing()
            let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
            
            buildMarkers(size: source.dataSize(), pos: pos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            buildMatrix(size: source.dataSize(), c: c)
            
            // u
            buildVectors(f: source.constDataAccessor(), c: c, component: 0)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                dest[i, j, k].x = _system.x[i, j, k]
            }
            
            // v
            buildVectors(f: source.constDataAccessor(), c: c, component: 1)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                dest[i, j, k].y = _system.x[i, j, k]
            }
            
            // w
            buildVectors(f: source.constDataAccessor(), c: c, component: 2)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                dest[i, j, k].z = _system.x[i, j, k]
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    /// Solves diffusion equation for a face-centered vector field.
    /// - Parameters:
    ///   - source: Input face-centered vector field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest: Output face-centered vector field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source: FaceCenteredGrid3, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        if Renderer.arch == .CPU {
            let h = source.gridSpacing()
            let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
            
            // u
            let uPos = source.uPosition()
            buildMarkers(size: source.uSize(), pos: uPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            buildMatrix(size: source.uSize(), c: c)
            buildVectors(f: source.uConstAccessor(), c: c)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachUIndex(){(i:size_t, j:size_t, k:size_t) in
                dest.u(i: i, j: j, k: k, val: _system.x[i, j, k])
            }
            
            // v
            let vPos = source.vPosition()
            buildMarkers(size: source.vSize(), pos: vPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            buildMatrix(size: source.vSize(), c: c)
            buildVectors(f: source.vConstAccessor(), c: c)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachVIndex(){(i:size_t, j:size_t, k:size_t) in
                dest.v(i: i, j: j, k: k, val: _system.x[i, j, k])
            }
            
            // w
            let wPos = source.wPosition()
            buildMarkers(size: source.wSize(), pos: wPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            buildMatrix(size: source.wSize(), c: c)
            buildVectors(f: source.wConstAccessor(), c: c)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachWIndex(){(i:size_t, j:size_t, k:size_t) in
                dest.w(i: i, j: j, k: k, val: _system.x[i, j, k])
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    /// Sets the linear system solver for this diffusion solver.
    func setLinearSystemSolver(solver:FdmLinearSystemSolver3) {
        _systemSolver = solver
    }
    
    func buildMarkers(size:Size3,
                      pos:(size_t, size_t, size_t)->Vector3F,
                      boundarySdf:ScalarField3,
                      fluidSdf:ScalarField3) {
        _markers.resize(size: size)
        
        _markers.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: boundarySdf.sample(x: pos(i, j, k)))) {
                _markers[i, j, k] = kBoundary
            } else if (isInsideSdf(phi: fluidSdf.sample(x: pos(i, j, k)))) {
                _markers[i, j, k] = kFluid
            } else {
                _markers[i, j, k] = kAir
            }
        }
    }
    
    func buildMatrix(size:Size3,
                     c:Vector3F) {
        _system.A.resize(size: size)
        
        let isDirichlet = (_boundaryType == .Dirichlet)
        
        // Build linear system
        _system.A.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            // Initialize
            _system.A[i, j, k].center = 1.0
            _system.A[i, j, k].right = 0.0
            _system.A[i, j, k].up = 0.0
            _system.A[i, j, k].front = 0.0
            
            if (_markers[i, j, k] == kFluid) {
                if (i + 1 < size.x) {
                    if ((isDirichlet && _markers[i + 1, j, k] != kAir)
                        || _markers[i + 1, j, k] == kFluid) {
                        _system.A[i, j, k].center += c.x
                    }
                    
                    if (_markers[i + 1, j, k] == kFluid) {
                        _system.A[i, j, k].right -=  c.x
                    }
                }
                
                if (i > 0
                    && ((isDirichlet && _markers[i - 1, j, k] != kAir)
                        || _markers[i - 1, j, k] == kFluid)) {
                    _system.A[i, j, k].center += c.x
                }
                
                if (j + 1 < size.y) {
                    if ((isDirichlet && _markers[i, j + 1, k] != kAir)
                        || _markers[i, j + 1, k] == kFluid) {
                        _system.A[i, j, k].center += c.y
                    }
                    
                    if (_markers[i, j + 1, k] == kFluid) {
                        _system.A[i, j, k].up -=  c.y
                    }
                }
                
                if (j > 0
                    && ((isDirichlet && _markers[i, j - 1, k] != kAir)
                        || _markers[i, j - 1, k] == kFluid)) {
                    _system.A[i, j, k].center += c.y
                }
                
                if (k + 1 < size.z) {
                    if ((isDirichlet && _markers[i, j, k + 1] != kAir)
                        || _markers[i, j, k + 1] == kFluid) {
                        _system.A[i, j, k].center += c.z
                    }
                    
                    if (_markers[i, j, k + 1] == kFluid) {
                        _system.A[i, j, k].front -=  c.z
                    }
                }
                
                if (k > 0
                    && ((isDirichlet && _markers[i, j, k - 1] != kAir)
                        || _markers[i, j, k - 1] == kFluid)) {
                    _system.A[i, j, k].center += c.z
                }
            }
        }
    }
    
    func buildVectors(f:ConstArrayAccessor3<Float>,
                      c:Vector3F) {
        let size = f.size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        
        // Build linear system
        _system.x.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _system.b[i, j, k] = f[i, j, k]
            _system.x[i, j, k] = f[i, j, k]
            
            if (_boundaryType == .Dirichlet && _markers[i, j, k] == kFluid) {
                if (i + 1 < size.x && _markers[i + 1, j, k] == kBoundary) {
                    _system.b[i, j, k] += c.x * f[i + 1, j, k]
                }
                
                if (i > 0 && _markers[i - 1, j, k] == kBoundary) {
                    _system.b[i, j, k] += c.x * f[i - 1, j, k]
                }
                
                if (j + 1 < size.y && _markers[i, j + 1, k] == kBoundary) {
                    _system.b[i, j, k] += c.y * f[i, j + 1, k]
                }
                
                if (j > 0 && _markers[i, j - 1, k] == kBoundary) {
                    _system.b[i, j, k] += c.y * f[i, j - 1, k]
                }
                
                if (k + 1 < size.z && _markers[i, j, k + 1] == kBoundary) {
                    _system.b[i, j, k] += c.z * f[i, j, k + 1]
                }
                
                if (k > 0 && _markers[i, j, k - 1] == kBoundary) {
                    _system.b[i, j, k] += c.z * f[i, j, k - 1]
                }
            }
        }
    }
    
    func buildVectors(f:ConstArrayAccessor3<Vector3F>,
                      c:Vector3F,
                      component:size_t) {
        let size = f.size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        
        // Build linear system
        _system.x.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _system.b[i, j, k] = f[i, j, k][component]
            _system.x[i, j, k] = f[i, j, k][component]
            
            if (_boundaryType == .Dirichlet && _markers[i, j, k] == kFluid) {
                if (i + 1 < size.x && _markers[i + 1, j, k] == kBoundary) {
                    _system.b[i, j, k] += c.x * f[i + 1, j, k][component]
                }
                
                if (i > 0 && _markers[i - 1, j, k] == kBoundary) {
                    _system.b[i, j, k] += c.x * f[i - 1, j, k][component]
                }
                
                if (j + 1 < size.y && _markers[i, j + 1, k] == kBoundary) {
                    _system.b[i, j, k] += c.y * f[i, j + 1, k][component]
                }
                
                if (j > 0 && _markers[i, j - 1, k] == kBoundary) {
                    _system.b[i, j, k] += c.y * f[i, j - 1, k][component]
                }
                
                if (k + 1 < size.z && _markers[i, j, k + 1] == kBoundary) {
                    _system.b[i, j, k] += c.z * f[i, j, k + 1][component]
                }
                
                if (k > 0 && _markers[i, j, k - 1] == kBoundary) {
                    _system.b[i, j, k] += c.z * f[i, j, k - 1][component]
                }
            }
        }
    }
}

//MARK:- GPU Methods
extension GridBackwardEulerDiffusionSolver3 {
    func solve_GPU(source: ScalarGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout ScalarGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        let pos = source.dataPosition()
        let h = source.gridSpacing()
        let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
        
        buildMarkers(size: source.dataSize(), pos: pos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        buildMatrix_GPU(size: source.dataSize(), c: c)
        var source = source
        buildVectors_GPU(f: &source, c: c)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver3::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func solve_GPU(source: CollocatedVectorGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        let pos = source.dataPosition()
        let h = source.gridSpacing()
        let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
        
        buildMarkers(size: source.dataSize(), pos: pos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        buildMatrix_GPU(size: source.dataSize(), c: c)
        var source = source
        
        // u
        buildVectors_GPU(f: &source, c: c, component: 0)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver3::assignX") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        // v
        buildVectors_GPU(f: &source, c: c, component: 1)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver3::assignY") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        // w
        buildVectors_GPU(f: &source, c: c, component: 2)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver3::assignZ") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func solve_GPU(source: FaceCenteredGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        let h = source.gridSpacing()
        let c = timeIntervalInSeconds * diffusionCoefficient / (h * h)
        var source = source
        
        // u
        let uPos = source.uPosition()
        buildMarkers(size: source.uSize(), pos: uPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        buildMatrix_GPU(size: source.uSize(), c: c)
        buildVectors_GPU(f: &source, c: c, component: 0)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachUIndex(name: "GridBackwardEulerDiffusionSolver3::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        // v
        let vPos = source.vPosition()
        buildMarkers(size: source.vSize(), pos: vPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        buildMatrix_GPU(size: source.vSize(), c: c)
        buildVectors_GPU(f: &source, c: c, component: 1)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachVIndex(name: "GridBackwardEulerDiffusionSolver3::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadVBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        // w
        let wPos = source.wPosition()
        buildMarkers(size: source.wSize(), pos: wPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        buildMatrix_GPU(size: source.wSize(), c: c)
        buildVectors_GPU(f: &source, c: c, component: 2)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachWIndex(name: "GridBackwardEulerDiffusionSolver3::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadWBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func buildMatrix_GPU(size:Size3,
                         c:Vector3F) {
        _system.A.resize(size: size)
        
        var isDirichlet = (_boundaryType == .Dirichlet)
        _system.A.parallelForEachIndex(name: "GridBackwardEulerDiffusionSolver3::buildMatrix") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
        }
    }
    
    func buildVectors_GPU(f:inout ScalarGrid3,
                          c:Vector3F) {
        let size = f.constDataAccessor().size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        var isDirichlet = (_boundaryType == .Dirichlet)
        
        let n = _system.x.size()
        parallelFor(beginIndexX: 0, endIndexX: n.x,
                    beginIndexY: 0, endIndexY: n.y,
                    beginIndexZ: 0, endIndexZ: n.z,
                    name: "GridBackwardEulerDiffusionSolver3::buildVectors_scalar") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = f.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
        }
    }
    
    func buildVectors_GPU(f:inout CollocatedVectorGrid3,
                          c:Vector3F,
                          component:size_t) {
        let size = f.constDataAccessor().size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        var isDirichlet = (_boundaryType == .Dirichlet)
        
        let n = _system.x.size()
        parallelFor(beginIndexX: 0, endIndexX: n.x,
                    beginIndexY: 0, endIndexY: n.y,
                    beginIndexZ: 0, endIndexZ: n.z,
                    name: "GridBackwardEulerDiffusionSolver3::buildVectors_collocated") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = f.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            var component:UInt32 = UInt32(component)
            encoder.setBytes(&component, length: MemoryLayout<UInt32>.stride, index: index+2)
        }
    }
    
    func buildVectors_GPU(f:inout FaceCenteredGrid3,
                          c:Vector3F,
                          component:size_t) {
        var isDirichlet = (_boundaryType == .Dirichlet)
        var c = c
        
        if component == 0 {
            let size = f.uConstAccessor().size()
            
            _system.x.resize(size: size, initVal: 0.0)
            _system.b.resize(size: size, initVal: 0.0)
            
            let n = _system.x.size()
            parallelFor(beginIndexX: 0, endIndexX: n.x,
                        beginIndexY: 0, endIndexY: n.y,
                        beginIndexZ: 0, endIndexZ: n.z,
                        name: "GridBackwardEulerDiffusionSolver3::buildVectors_face") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = f.loadUBuffer(encoder: &encoder, index_begin: index)
                encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
                encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            }
        } else if component == 1 {
            let size = f.vConstAccessor().size()
            
            _system.x.resize(size: size, initVal: 0.0)
            _system.b.resize(size: size, initVal: 0.0)
            
            let n = _system.x.size()
            parallelFor(beginIndexX: 0, endIndexX: n.x,
                        beginIndexY: 0, endIndexY: n.y,
                        beginIndexZ: 0, endIndexZ: n.z,
                        name: "GridBackwardEulerDiffusionSolver3::buildVectors_face") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = f.loadVBuffer(encoder: &encoder, index_begin: index)
                encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
                encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            }
        } else {
            let size = f.wConstAccessor().size()
            
            _system.x.resize(size: size, initVal: 0.0)
            _system.b.resize(size: size, initVal: 0.0)
            
            let n = _system.x.size()
            parallelFor(beginIndexX: 0, endIndexX: n.x,
                        beginIndexY: 0, endIndexY: n.y,
                        beginIndexZ: 0, endIndexZ: n.z,
                        name: "GridBackwardEulerDiffusionSolver3::buildVectors_face") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = f.loadWBuffer(encoder: &encoder, index_begin: index)
                encoder.setBytes(&c, length: MemoryLayout<Vector3F>.stride, index: index)
                encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            }
        }
    }
}
