//
//  grid_forward_euler_diffusion_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

let kFluid:CChar = 0
let kAir:CChar = 1
let kBoundary:CChar = 2

func laplacian(data:ConstArrayAccessor2<Float>,
               marker:Array2<CChar>,
               gridSpacing:Vector2F,
               i:size_t, j:size_t)->Float {
    let center = data[i, j]
    let ds = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    var dleft:Float = 0
    var dright:Float = 0
    var ddown:Float = 0
    var dup:Float = 0
    
    if (i > 0 && marker[i - 1, j] == kFluid) {
        dleft = center - data[i - 1, j]
    }
    if (i + 1 < ds.x && marker[i + 1, j] == kFluid) {
        dright = data[i + 1, j] - center
    }
    
    if (j > 0 && marker[i, j - 1] == kFluid) {
        ddown = center - data[i, j - 1]
    }
    if (j + 1 < ds.y && marker[i, j + 1] == kFluid) {
        dup = data[i, j + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
}

func laplacian(data:ConstArrayAccessor2<Vector2F>,
               marker:Array2<CChar>,
               gridSpacing:Vector2F,
               i:size_t, j:size_t)->Vector2F {
    let center = data[i, j]
    let ds = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    var dleft = Vector2F()
    var dright = Vector2F()
    var ddown = Vector2F()
    var dup = Vector2F()
    
    if (i > 0 && marker[i - 1, j] == kFluid) {
        dleft = center - data[i - 1, j]
    }
    if (i + 1 < ds.x && marker[i + 1, j] == kFluid) {
        dright = data[i + 1, j] - center
    }
    
    if (j > 0 && marker[i, j - 1] == kFluid) {
        ddown = center - data[i, j - 1]
    }
    if (j + 1 < ds.y && marker[i, j + 1] == kFluid) {
        dup = data[i, j + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
}

/// 2-D grid-based forward Euler diffusion solver.
///
/// This class implements 2-D grid-based forward Euler diffusion solver using
/// second-order central differencing spatially. Since the method is relying on
/// explicit time-integration (i.e. forward Euler), the diffusion coefficient is
/// limited by the time interval and grid spacing such as:
/// \f$\mu *<* \frac{h}{8\Delta t} \f$ where \f$\mu\f$, \f$h\f$, and
/// \f$\Delta t\f$ are the diffusion coefficient, grid spacing, and time
/// interval, respectively.
class GridForwardEulerDiffusionSolver2: GridDiffusionSolver2 {
    var _markers = Array2<CChar>()
    
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
            let src = source.constDataAccessor()
            let h = source.gridSpacing()
            let pos = source.dataPosition()
            
            buildMarkers(size: source.resolution(),
                         pos: pos, boundarySdf: boundarySdf,
                         fluidSdf: fluidSdf)
            
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                if (_markers[i, j] == kFluid) {
                    dest[i, j] = source[i, j]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: src, marker: _markers,
                                    gridSpacing: h, i: i, j: j)
                } else {
                    dest[i, j] = source[i, j]
                }
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
            let src = source.constDataAccessor()
            let h = source.gridSpacing()
            let pos = source.dataPosition()
            
            buildMarkers(size: source.resolution(), pos: pos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                if (_markers[i, j] == kFluid) {
                    dest[i, j] = src[i, j]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: src, marker: _markers,
                                    gridSpacing: h, i: i, j: j)
                } else {
                    dest[i, j] = src[i, j]
                }
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
            let uSrc = source.uConstAccessor()
            let vSrc = source.vConstAccessor()
            var u = dest.uAccessor()
            var v = dest.vAccessor()
            let uPos = source.uPosition()
            let vPos = source.vPosition()
            let h = source.gridSpacing()
            
            buildMarkers(size: source.uSize(), pos: uPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachUIndex(){(i:size_t, j:size_t) in
                if (_markers[i, j] == kFluid) {
                    u[i, j] = uSrc[i, j]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: uSrc, marker: _markers,
                                    gridSpacing: h, i: i, j: j)
                } else {
                    u[i, j] = uSrc[i, j]
                }
            }
            
            buildMarkers(size: source.vSize(), pos: vPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachVIndex(){(i:size_t, j:size_t) in
                if (_markers[i, j] == kFluid) {
                    v[i, j] = vSrc[i, j]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: vSrc, marker: _markers,
                                    gridSpacing: h, i: i, j: j)
                } else {
                    v[i, j] = vSrc[i, j]
                }
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    func buildMarkers(size:Size2,
                      pos:(size_t, size_t)->Vector2F ,
                      boundarySdf:ScalarField2,
                      fluidSdf:ScalarField2) {
        _markers.resize(size: size)
        
        _markers.forEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: boundarySdf.sample(x: pos(i, j)))) {
                _markers[i, j] = kBoundary
            } else if (isInsideSdf(phi: fluidSdf.sample(x: pos(i, j)))) {
                _markers[i, j] = kFluid
            } else {
                _markers[i, j] = kAir
            }
        }
    }
}

//MARK:- GPU Methods
extension GridForwardEulerDiffusionSolver2 {
    func solve_GPU(source: ScalarGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout ScalarGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
        var h = source.gridSpacing()
        let pos = source.dataPosition()
        
        buildMarkers(size: source.resolution(),
                     pos: pos, boundarySdf: boundarySdf,
                     fluidSdf: fluidSdf)
        
        source.parallelForEachDataPointIndex(name: "GridForwardEulerDiffusionSolver2::solve_scalar") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector2F>.stride, index: index+2)
        }
    }
    
    func solve_GPU(source: CollocatedVectorGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
        var h = source.gridSpacing()
        let pos = source.dataPosition()
        
        buildMarkers(size: source.resolution(),
                     pos: pos, boundarySdf: boundarySdf,
                     fluidSdf: fluidSdf)
        
        source.parallelForEachDataPointIndex(name: "GridForwardEulerDiffusionSolver2::solve_collocated") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector2F>.stride, index: index+2)
        }
    }
    
    func solve_GPU(source: FaceCenteredGrid2, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid2,
                   boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField2 = ConstantScalarField2(value: -Float.greatestFiniteMagnitude)) {
        let uPos = source.uPosition()
        let vPos = source.vPosition()
        var h = source.gridSpacing()
        
        buildMarkers(size: source.uSize(), pos: uPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        
        source.parallelForEachUIndex(name: "GridForwardEulerDiffusionSolver2::solve_face") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector2F>.stride, index: index+2)
        }
        
        buildMarkers(size: source.vSize(), pos: vPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        
        source.parallelForEachVIndex(name: "GridForwardEulerDiffusionSolver2::solve_face") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadVBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector2F>.stride, index: index+2)
        }
    }
}
