//
//  grid_backward_euler_diffusion_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D grid-based backward Euler diffusion solver.
///
/// This class implements 2-D grid-based forward Euler diffusion solver using
/// second-order central differencing spatially. Since the method is following
/// the implicit time-integration (i.e. backward Euler), larger time interval or
/// diffusion coefficient can be used without breaking the result. Note, higher
/// values for those parameters will still impact the accuracy of the result.
/// To solve the backward Euler method, a linear system solver is used and
/// incomplete Cholesky conjugate gradient method is used by default.
class GridBackwardEulerDiffusionSolver2: GridDiffusionSolver2 {
    enum BoundaryType {
        case Dirichlet
        case Neumann
    }
    
    let _boundaryType:BoundaryType
    var _system = FdmLinearSystem2()
    var _systemSolver:FdmLinearSystemSolver2
    var _markers = Array2<CChar>()
    
    init(boundaryType:BoundaryType = .Neumann) {
        self._boundaryType = boundaryType
        self._systemSolver = FdmIccgSolver2(maxNumberOfIterations: 100,
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
    func solve(source: ScalarGrid2, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout ScalarGrid2,
               boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                dest[i, j] = _system.x[i, j]
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
    func solve(source: CollocatedVectorGrid2, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid2,
               boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                dest[i, j].x = _system.x[i, j]
            }
            
            // v
            buildVectors(f: source.constDataAccessor(), c: c, component: 1)
            
            // Solve the system
            _ = _systemSolver.solve(system: &_system)
            
            // Assign the solution
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                dest[i, j].y = _system.x[i, j]
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
    func solve(source: FaceCenteredGrid2, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid2,
               boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
            source.parallelForEachUIndex(){(i:size_t, j:size_t) in
                dest.u(i: i, j: j, val: _system.x[i, j])
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
            source.parallelForEachVIndex(){(i:size_t, j:size_t) in
                dest.v(i: i, j: j, val: _system.x[i, j])
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    /// Sets the linear system solver for this diffusion solver.
    func setLinearSystemSolver(solver:FdmLinearSystemSolver2) {
        _systemSolver = solver
    }
    
    func buildMarkers(size:Size2,
                      pos:(size_t, size_t)->Vector2F,
                      boundarySdf:ScalarField2,
                      fluidSdf:ScalarField2) {
        _markers.resize(size: size)
        
        _markers.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: boundarySdf.sample(x: pos(i, j)))) {
                _markers[i, j] = kBoundary
            } else if (isInsideSdf(phi: fluidSdf.sample(x: pos(i, j)))) {
                _markers[i, j] = kFluid
            } else {
                _markers[i, j] = kAir
            }
        }
    }
    
    func buildMatrix(size:Size2,
                     c:Vector2F) {
        _system.A.resize(size: size)
        
        let isDirichlet = (_boundaryType == .Dirichlet)
        
        // Build linear system
        _system.A.parallelForEachIndex(){(i:size_t, j:size_t) in
            // Initialize
            _system.A[i, j].center = 1.0
            _system.A[i, j].right = 0.0
            _system.A[i, j].up = 0.0
            
            if (_markers[i, j] == kFluid) {
                if (i + 1 < size.x) {
                    if ((isDirichlet && _markers[i + 1, j] != kAir)
                        || _markers[i + 1, j] == kFluid) {
                        _system.A[i, j].center += c.x
                    }
                    
                    if (_markers[i + 1, j] == kFluid) {
                        _system.A[i, j].right -=  c.x
                    }
                }
                
                if (i > 0
                    && ((isDirichlet && _markers[i - 1, j] != kAir)
                        || _markers[i - 1, j] == kFluid)) {
                    _system.A[i, j].center += c.x
                }
                
                if (j + 1 < size.y) {
                    if ((isDirichlet && _markers[i, j + 1] != kAir)
                        || _markers[i, j + 1] == kFluid) {
                        _system.A[i, j].center += c.y
                    }
                    
                    if (_markers[i, j + 1] == kFluid) {
                        _system.A[i, j].up -=  c.y
                    }
                }
                
                if (j > 0
                    && ((isDirichlet && _markers[i, j - 1] != kAir)
                        || _markers[i, j - 1] == kFluid)) {
                    _system.A[i, j].center += c.y
                }
            }
        }
    }
    
    func buildVectors(f:ConstArrayAccessor2<Float>,
                      c:Vector2F) {
        let size = f.size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        
        // Build linear system
        _system.x.parallelForEachIndex(){(i:size_t, j:size_t) in
            _system.b[i, j] = f[i, j]
            _system.x[i, j] = f[i, j]
            
            if (_boundaryType == .Dirichlet && _markers[i, j] == kFluid) {
                if (i + 1 < size.x && _markers[i + 1, j] == kBoundary) {
                    _system.b[i, j] += c.x * f[i + 1, j]
                }
                
                if (i > 0 && _markers[i - 1, j] == kBoundary) {
                    _system.b[i, j] += c.x * f[i - 1, j]
                }
                
                if (j + 1 < size.y && _markers[i, j + 1] == kBoundary) {
                    _system.b[i, j] += c.y * f[i, j + 1]
                }
                
                if (j > 0 && _markers[i, j - 1] == kBoundary) {
                    _system.b[i, j] += c.y * f[i, j - 1]
                }
            }
        }
    }
    
    func buildVectors(f:ConstArrayAccessor2<Vector2F>,
                      c:Vector2F,
                      component:size_t) {
        let size = f.size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        
        // Build linear system
        _system.x.parallelForEachIndex(){(i:size_t, j:size_t) in
            _system.b[i, j] = f[i, j][component]
            _system.x[i, j] = f[i, j][component]
            
            if (_boundaryType == .Dirichlet && _markers[i, j] == kFluid) {
                if (i + 1 < size.x && _markers[i + 1, j] == kBoundary) {
                    _system.b[i, j] += c.x * f[i + 1, j][component]
                }
                
                if (i > 0 && _markers[i - 1, j] == kBoundary) {
                    _system.b[i, j] += c.x * f[i - 1, j][component]
                }
                
                if (j + 1 < size.y && _markers[i, j + 1] == kBoundary) {
                    _system.b[i, j] += c.y * f[i, j + 1][component]
                }
                
                if (j > 0 && _markers[i, j - 1] == kBoundary) {
                    _system.b[i, j] += c.y * f[i, j - 1][component]
                }
            }
        }
    }
}

//MARK:- GPU Methods
extension GridBackwardEulerDiffusionSolver2 {
    func solve_GPU(source: ScalarGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout ScalarGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver2::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func solve_GPU(source: CollocatedVectorGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver2::assignX") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        // v
        buildVectors_GPU(f: &source, c: c, component: 1)
        
        // Solve the system
        _ = _systemSolver.solve(system: &_system)
        
        // Assign the solution
        source.parallelForEachDataPointIndex(name: "GridBackwardEulerDiffusionSolver2::assignY") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func solve_GPU(source: FaceCenteredGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
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
        source.parallelForEachUIndex(name: "GridBackwardEulerDiffusionSolver2::assign") {
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
        source.parallelForEachVIndex(name: "GridBackwardEulerDiffusionSolver2::assign") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = dest.loadVBuffer(encoder: &encoder, index_begin: index)
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
    
    func buildMatrix_GPU(size:Size2,
                         c:Vector2F) {
        _system.A.resize(size: size)
        
        var isDirichlet = (_boundaryType == .Dirichlet)
        _system.A.parallelForEachIndex(name: "GridBackwardEulerDiffusionSolver2::buildMatrix") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector2F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
        }
    }
    
    func buildVectors_GPU(f:inout ScalarGrid2,
                          c:Vector2F) {
        let size = f.constDataAccessor().size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        var isDirichlet = (_boundaryType == .Dirichlet)
        
        let n = _system.x.size()
        parallelFor(beginIndexX: 0, endIndexX: n.x, beginIndexY: 0, endIndexY: n.y,
                    name: "GridBackwardEulerDiffusionSolver2::buildVectors_scalar") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = f.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector2F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
        }
    }
    
    func buildVectors_GPU(f:inout CollocatedVectorGrid2,
                          c:Vector2F,
                          component:size_t) {
        let size = f.constDataAccessor().size()
        
        _system.x.resize(size: size, initVal: 0.0)
        _system.b.resize(size: size, initVal: 0.0)
        var isDirichlet = (_boundaryType == .Dirichlet)
        
        let n = _system.x.size()
        parallelFor(beginIndexX: 0, endIndexX: n.x, beginIndexY: 0, endIndexY: n.y,
                    name: "GridBackwardEulerDiffusionSolver2::buildVectors_collocated") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = f.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var c = c
            encoder.setBytes(&c, length: MemoryLayout<Vector2F>.stride, index: index)
            encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            var component:UInt32 = UInt32(component)
            encoder.setBytes(&component, length: MemoryLayout<UInt32>.stride, index: index+2)
        }
    }
    
    func buildVectors_GPU(f:inout FaceCenteredGrid2,
                          c:Vector2F,
                          component:size_t) {
        var isDirichlet = (_boundaryType == .Dirichlet)
        
        if component == 0 {
            let size = f.uConstAccessor().size()
            
            _system.x.resize(size: size, initVal: 0.0)
            _system.b.resize(size: size, initVal: 0.0)
            
            let n = _system.x.size()
            parallelFor(beginIndexX: 0, endIndexX: n.x, beginIndexY: 0, endIndexY: n.y,
                        name: "GridBackwardEulerDiffusionSolver2::buildVectors_face") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = f.loadUBuffer(encoder: &encoder, index_begin: index)
                var c = c
                encoder.setBytes(&c, length: MemoryLayout<Vector2F>.stride, index: index)
                encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            }
        } else {
            let size = f.vConstAccessor().size()
            
            _system.x.resize(size: size, initVal: 0.0)
            _system.b.resize(size: size, initVal: 0.0)
            
            let n = _system.x.size()
            parallelFor(beginIndexX: 0, endIndexX: n.x, beginIndexY: 0, endIndexY: n.y,
                        name: "GridBackwardEulerDiffusionSolver2::buildVectors_face") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                index = _system.x.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _system.b.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
                index = f.loadVBuffer(encoder: &encoder, index_begin: index)
                var c = c
                encoder.setBytes(&c, length: MemoryLayout<Vector2F>.stride, index: index)
                encoder.setBytes(&isDirichlet, length: MemoryLayout<Bool>.stride, index: index+1)
            }
        }
    }
}
