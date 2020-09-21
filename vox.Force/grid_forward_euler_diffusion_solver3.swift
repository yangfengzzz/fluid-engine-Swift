//
//  grid_forward_euler_diffusion_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/38.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

func laplacian(data:ConstArrayAccessor3<Float>,
               marker:Array3<CChar>,
               gridSpacing:Vector3F,
               i:size_t, j:size_t, k:size_t)->Float {
    let center = data[i, j, k]
    let ds = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    var dleft = Float()
    var dright = Float()
    var ddown = Float()
    var dup = Float()
    var dback = Float()
    var dfront = Float()
    
    if (i > 0 && marker[i - 1, j, k] == kFluid) {
        dleft = center - data[i - 1, j, k]
    }
    if (i + 1 < ds.x && marker[i + 1, j, k] == kFluid) {
        dright = data[i + 1, j, k] - center
    }
    
    if (j > 0 && marker[i, j - 1, k] == kFluid) {
        ddown = center - data[i, j - 1, k]
    }
    if (j + 1 < ds.y && marker[i, j + 1, k] == kFluid) {
        dup = data[i, j + 1, k] - center
    }
    
    if (k > 0 && marker[i, j, k - 1] == kFluid) {
        dback = center - data[i, j, k - 1]
    }
    if (k + 1 < ds.z && marker[i, j, k + 1] == kFluid) {
        dfront = data[i, j, k + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
        + (dfront - dback) / Math.square(of: gridSpacing.z)
}

func laplacian(data:ConstArrayAccessor3<Vector3F>,
               marker:Array3<CChar>,
               gridSpacing:Vector3F,
               i:size_t, j:size_t, k:size_t)->Vector3F {
    let center = data[i, j, k]
    let ds = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    var dleft:Vector3F = Vector3F()
    var dright:Vector3F = Vector3F()
    var ddown:Vector3F = Vector3F()
    var dup:Vector3F = Vector3F()
    var dback:Vector3F = Vector3F()
    var dfront:Vector3F = Vector3F()
    
    if (i > 0 && marker[i - 1, j, k] == kFluid) {
        dleft = center - data[i - 1, j, k]
    }
    if (i + 1 < ds.x && marker[i + 1, j, k] == kFluid) {
        dright = data[i + 1, j, k] - center
    }
    
    if (j > 0 && marker[i, j - 1, k] == kFluid) {
        ddown = center - data[i, j - 1, k]
    }
    if (j + 1 < ds.y && marker[i, j + 1, k] == kFluid) {
        dup = data[i, j + 1, k] - center
    }
    
    if (k > 0 && marker[i, j, k - 1] == kFluid) {
        dback = center - data[i, j, k - 1]
    }
    if (k + 1 < ds.z && marker[i, j, k + 1] == kFluid) {
        dfront = data[i, j, k + 1] - center
    }
    
    var result = (dright - dleft) / Math.square(of: gridSpacing.x)
    result += (dup - ddown) / Math.square(of: gridSpacing.y)
    return result + (dfront - dback) / Math.square(of: gridSpacing.z)
}

/// 3-D grid-based forward Euler diffusion solver.
///
/// This class implements 3-D grid-based forward Euler diffusion solver using
/// second-order central differencing spatially. Since the method is relying on
/// explicit time-integration (i.e. forward Euler), the diffusion coefficient is
/// limited by the time interval and grid spacing such as:
/// \f$\mu *<* \frac{h}{12\Delta t} \f$ where \f$\mu\f$, \f$h\f$, and
/// \f$\Delta t\f$ are the diffusion coefficient, grid spacing, and time
/// interval, respectively.
class GridForwardEulerDiffusionSolver3: GridDiffusionSolver3 {
    var _markers = Array3<CChar>()
    
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
            let src = source.constDataAccessor()
            let h = source.gridSpacing()
            let pos = source.dataPosition()
            
            buildMarkers(size: source.resolution(),
                         pos: pos, boundarySdf: boundarySdf,
                         fluidSdf: fluidSdf)
            
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                if (_markers[i, j, k] == kFluid) {
                    dest[i, j, k] = source[i, j, k]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: src, marker: _markers,
                                    gridSpacing: h, i: i, j: j, k: k)
                } else {
                    dest[i, j, k] = source[i, j, k]
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
    func solve(source: CollocatedVectorGrid3, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        if Renderer.arch == .CPU {
            let src = source.constDataAccessor()
            let h = source.gridSpacing()
            let pos = source.dataPosition()
            
            buildMarkers(size: source.resolution(), pos: pos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                if (_markers[i, j, k] == kFluid) {
                    dest[i, j, k] = src[i, j, k]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian(data: src, marker: _markers,
                                    gridSpacing: h, i: i, j: j, k: k)
                } else {
                    dest[i, j, k] = src[i, j, k]
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
    func solve(source: FaceCenteredGrid3, diffusionCoefficient: Float,
               timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid3,
               boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
               fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        if Renderer.arch == .CPU {
            let uSrc = source.uConstAccessor()
            let vSrc = source.vConstAccessor()
            let wSrc = source.wConstAccessor()
            var u = dest.uAccessor()
            var v = dest.vAccessor()
            var w = dest.wAccessor()
            let uPos = source.uPosition()
            let vPos = source.vPosition()
            let wPos = source.wPosition()
            let h = source.gridSpacing()
            
            buildMarkers(size: source.uSize(), pos: uPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachUIndex(){(i:size_t, j:size_t, k:size_t) in
                if (!isInsideSdf(phi: boundarySdf.sample(x: uPos(i, j, k)))) {
                    u[i, j, k] = uSrc[i, j, k]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian3(data: uSrc, gridSpacing: h, i: i, j: j, k: k)
                }
            }
            
            buildMarkers(size: source.vSize(), pos: vPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachVIndex(){(i:size_t, j:size_t, k:size_t) in
                if (!isInsideSdf(phi: boundarySdf.sample(x: vPos(i, j, k)))) {
                    v[i, j, k] = vSrc[i, j, k]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian3(data: vSrc, gridSpacing: h, i: i, j: j, k: k)
                }
            }
            
            buildMarkers(size: source.wSize(), pos: wPos,
                         boundarySdf: boundarySdf, fluidSdf: fluidSdf)
            
            source.parallelForEachWIndex(){(i:size_t, j:size_t, k:size_t) in
                if (!isInsideSdf(phi: boundarySdf.sample(x: wPos(i, j, k)))) {
                    w[i, j, k] = wSrc[i, j, k]
                        + diffusionCoefficient
                        * timeIntervalInSeconds
                        * laplacian3(data: wSrc, gridSpacing: h, i: i, j: j, k: k)
                }
            }
        } else {
            solve_GPU(source: source, diffusionCoefficient: diffusionCoefficient,
                      timeIntervalInSeconds: timeIntervalInSeconds,
                      dest: &dest, boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        }
    }
    
    func buildMarkers(size:Size3,
                      pos:(size_t, size_t, size_t)->Vector3F ,
                      boundarySdf:ScalarField3,
                      fluidSdf:ScalarField3) {
        _markers.resize(size: size)
        
        _markers.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: boundarySdf.sample(x: pos(i, j, k)))) {
                _markers[i, j, k] = kBoundary
            } else if (isInsideSdf(phi: fluidSdf.sample(x: pos(i, j, k)))) {
                _markers[i, j, k] = kFluid
            } else {
                _markers[i, j, k] = kAir
            }
        }
    }
}

//MARK:- GPU Methods
extension GridForwardEulerDiffusionSolver3 {
    func solve_GPU(source: ScalarGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout ScalarGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        var h = source.gridSpacing()
        let pos = source.dataPosition()
        
        buildMarkers(size: source.resolution(),
                     pos: pos, boundarySdf: boundarySdf,
                     fluidSdf: fluidSdf)
        
        source.parallelForEachDataPointIndex(name: "GridForwardEulerDiffusionSolver3::solve_scalar") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
    }
    
    func solve_GPU(source: CollocatedVectorGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout CollocatedVectorGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        var h = source.gridSpacing()
        let pos = source.dataPosition()
        
        buildMarkers(size: source.resolution(),
                     pos: pos, boundarySdf: boundarySdf,
                     fluidSdf: fluidSdf)
        
        source.parallelForEachDataPointIndex(name: "GridForwardEulerDiffusionSolver3::solve_collocated") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadGPUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
    }
    
    func solve_GPU(source: FaceCenteredGrid3, diffusionCoefficient: Float,
                   timeIntervalInSeconds: Float, dest: inout FaceCenteredGrid3,
                   boundarySdf: ScalarField3 = ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                   fluidSdf: ScalarField3 = ConstantScalarField3(value: -Float.greatestFiniteMagnitude)) {
        let uPos = source.uPosition()
        let vPos = source.vPosition()
        let wPos = source.wPosition()
        var h = source.gridSpacing()
        
        buildMarkers(size: source.uSize(), pos: uPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        
        source.parallelForEachUIndex(name: "GridForwardEulerDiffusionSolver3::solve_face") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadUBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
        
        buildMarkers(size: source.vSize(), pos: vPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        
        source.parallelForEachVIndex(name: "GridForwardEulerDiffusionSolver3::solve_face") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadVBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
        
        buildMarkers(size: source.wSize(), pos: wPos,
                     boundarySdf: boundarySdf, fluidSdf: fluidSdf)
        
        source.parallelForEachWIndex(name: "GridForwardEulerDiffusionSolver3::solve_face") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _markers.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = dest.loadWBuffer(encoder: &encoder, index_begin: index)
            var diffusionCoefficient = diffusionCoefficient
            encoder.setBytes(&diffusionCoefficient, length: MemoryLayout<Float>.stride, index: index)
            var timeIntervalInSeconds = timeIntervalInSeconds
            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
            encoder.setBytes(&h, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
    }
}
