//
//  apic_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D Affine Particle-in-Cell (APIC) implementation
///
/// This class implements 3-D Affine Particle-in-Cell (APIC) solver from the
/// SIGGRAPH paper, Jiang 2015.
///
/// \see Jiang, Chenfanfu, et al. "The affine particle-in-cell method."
///      ACM Transactions on Graphics (TOG) 34.4 (2015): 51.
class ApicSolver3: PicSolver3 {
    var _cX = Array1<Vector3F>()
    var _cY = Array1<Vector3F>()
    var _cZ = Array1<Vector3F>()
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1, 1], gridSpacing: [1, 1, 1], gridOrigin: [0, 0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size3,
                  gridSpacing:Vector3F,
                  gridOrigin:Vector3F) {
        super.init(resolution: resolution, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
    }
    
    /// Transfers velocity field from particles to grids.
    override func transferFromParticlesToGrids() {
        let flow = gridSystemData().velocity()
        let particles = particleSystemData()
        let positions:ConstArrayAccessor1<Vector3F> = particles.positions()
        let velocities:ConstArrayAccessor1<Vector3F> = particles.velocities()
        let numberOfParticles = particles.numberOfParticles()
        let hh = flow.gridSpacing() / 3.0
        let bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        _cZ.resize(size: numberOfParticles)
        
        // Clear velocity to zero
        flow.fill(value: Vector3F())
        
        // Weighted-average velocity
        var u = flow.uAccessor()
        var v = flow.vAccessor()
        var w = flow.wAccessor()
        let uPos = flow.uPosition()
        let vPos = flow.vPosition()
        let wPos = flow.wPosition()
        var uWeight = Array3<Float>(size: u.size())
        var vWeight = Array3<Float>(size: v.size())
        var wWeight = Array3<Float>(size: w.size())
        _uMarkers.resize(size: u.size())
        _vMarkers.resize(size: v.size())
        _wMarkers.resize(size: w.size())
        _uMarkers.set(value: 0)
        _vMarkers.set(value: 0)
        _wMarkers.set(value: 0)
        let uSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.uConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.vConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.vOrigin())
        let wSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.wConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.wOrigin())
        
        for i in 0..<numberOfParticles {
            var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
            var weights = Array<Float>(repeating: 0, count: 8)
            
            var uPosClamped = positions[i]
            uPosClamped.y = Math.clamp(
                val: uPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            uPosClamped.z = Math.clamp(
                val: uPosClamped.z,
                low: bbox.lowerCorner.z + hh.z,
                high: bbox.upperCorner.z - hh.z)
            uSampler.getCoordinatesAndWeights(pt: uPosClamped, indices: &indices, weights: &weights)
            for j in 0..<8 {
                let gridPos = uPos(indices[j].x, indices[j].y, indices[j].z)
                let apicTerm = dot(_cX[i], gridPos - uPosClamped)
                u[indices[j]] += weights[j] * (velocities[i].x + apicTerm)
                uWeight[indices[j]] += weights[j]
                _uMarkers[indices[j]] = 1
            }
            
            var vPosClamped = positions[i]
            vPosClamped.x = Math.clamp(
                val: vPosClamped.x,
                low: bbox.lowerCorner.x + hh.x,
                high: bbox.upperCorner.x - hh.x)
            vPosClamped.z = Math.clamp(
                val: vPosClamped.z,
                low: bbox.lowerCorner.z + hh.z,
                high: bbox.upperCorner.z - hh.z)
            vSampler.getCoordinatesAndWeights(pt: vPosClamped, indices: &indices, weights: &weights)
            for j in 0..<8 {
                let gridPos = vPos(indices[j].x, indices[j].y, indices[j].z)
                let apicTerm = dot(_cY[i], gridPos - vPosClamped)
                v[indices[j]] += weights[j] * (velocities[i].y + apicTerm)
                vWeight[indices[j]] += weights[j]
                _vMarkers[indices[j]] = 1
            }
            
            var wPosClamped = positions[i]
            wPosClamped.x = Math.clamp(
                val: wPosClamped.x,
                low: bbox.lowerCorner.x + hh.x,
                high: bbox.upperCorner.x - hh.x)
            wPosClamped.y = Math.clamp(
                val: wPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            wSampler.getCoordinatesAndWeights(pt: wPosClamped, indices: &indices, weights: &weights)
            for j in 0..<8 {
                let gridPos = wPos(indices[j].x, indices[j].y, indices[j].z)
                let apicTerm = dot(_cZ[i], gridPos - wPosClamped)
                w[indices[j]] += weights[j] * (velocities[i].z + apicTerm)
                wWeight[indices[j]] += weights[j]
                _wMarkers[indices[j]] = 1
            }
        }
        
        uWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (uWeight[i, j, k] > 0.0) {
                u[i, j, k] /= uWeight[i, j, k]
            }
        }
        vWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (vWeight[i, j, k] > 0.0) {
                v[i, j, k] /= vWeight[i, j, k]
            }
        }
        wWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (wWeight[i, j, k] > 0.0) {
                w[i, j, k] /= wWeight[i, j, k]
            }
        }
    }
    
    /// Transfers velocity field from grids to particles.
    override func transferFromGridsToParticles() {
        let flow = gridSystemData().velocity()
        let particles = particleSystemData()
        let positions:ConstArrayAccessor1<Vector3F> = particles.positions()
        var velocities:ArrayAccessor1<Vector3F> = particles.velocities()
        let numberOfParticles = particles.numberOfParticles()
        let hh = flow.gridSpacing() / 3.0
        let bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        _cZ.resize(size: numberOfParticles)
        _cX.set(value: Vector3F())
        _cY.set(value: Vector3F())
        _cZ.set(value: Vector3F())
        
        let u = flow.uAccessor()
        let v = flow.vAccessor()
        let w = flow.wAccessor()
        let uSampler = LinearArraySampler3<Float, Float>(
            accessor: ConstArrayAccessor3<Float>(other: u),
            gridSpacing: flow.gridSpacing(), gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler3<Float, Float>(
            accessor: ConstArrayAccessor3<Float>(other: v),
            gridSpacing: flow.gridSpacing(), gridOrigin: flow.vOrigin())
        let wSampler = LinearArraySampler3<Float, Float>(
            accessor: ConstArrayAccessor3<Float>(other: w),
            gridSpacing: flow.gridSpacing(), gridOrigin: flow.wOrigin())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            velocities[i] = flow.sample(x: positions[i])
            
            var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
            var gradWeights = Array<Vector3F>(repeating: Vector3F(), count: 8)
            
            // x
            var uPosClamped = positions[i]
            uPosClamped.y = Math.clamp(
                val: uPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            uPosClamped.z = Math.clamp(
                val: uPosClamped.z,
                low: bbox.lowerCorner.z + hh.z,
                high: bbox.upperCorner.z - hh.z)
            uSampler.getCoordinatesAndGradientWeights(
                pt: uPosClamped, indices: &indices, weights: &gradWeights)
            for j in 0..<8 {
                _cX[i] += gradWeights[j] * u[indices[j]]
            }
            
            // y
            var vPosClamped = positions[i]
            vPosClamped.x = Math.clamp(
                val: vPosClamped.x,
                low: bbox.lowerCorner.x + hh.x,
                high: bbox.upperCorner.x - hh.x)
            vPosClamped.z = Math.clamp(
                val: vPosClamped.z,
                low: bbox.lowerCorner.z + hh.z,
                high: bbox.upperCorner.z - hh.z)
            vSampler.getCoordinatesAndGradientWeights(
                pt: vPosClamped, indices: &indices, weights: &gradWeights)
            for j in 0..<8 {
                _cY[i] += gradWeights[j] * v[indices[j]]
            }
            
            // z
            var wPosClamped = positions[i]
            wPosClamped.x = Math.clamp(
                val: wPosClamped.x,
                low: bbox.lowerCorner.x + hh.x,
                high: bbox.upperCorner.x - hh.x)
            wPosClamped.y = Math.clamp(
                val: wPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            wSampler.getCoordinatesAndGradientWeights(
                pt: wPosClamped, indices: &indices, weights: &gradWeights)
            for j in 0..<8 {
                _cZ[i] += gradWeights[j] * w[indices[j]]
            }
        }
    }
    
    //MARK:- Builder
    /// Front-end to create ApicSolver3 objects step by step.
    class Builder: GridFluidSolverBuilderBase3<Builder> {
        /// Builds ApicSolver3.
        func build()->ApicSolver3 {
            return ApicSolver3(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox ApicSolver3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension ApicSolver3 {
    override func transferFromGridsToParticles_GPU() {
        let flow = gridSystemData().velocity()
        var resolution = Vector3<UInt32>(UInt32(flow.resolution().x),
                                         UInt32(flow.resolution().y),
                                         UInt32(flow.resolution().z))
        let particles = particleSystemData()
        let numberOfParticles = particles.numberOfParticles()
        var hh = flow.gridSpacing() / 2.0
        var bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        _cZ.resize(size: numberOfParticles)
        _cX.set(value: Vector3F())
        _cY.set(value: Vector3F())
        _cZ.set(value: Vector3F())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "ApicSolver3::transferFromGridsToParticles") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.positions(encoder: &encoder, index_begin: index)
                        index = particles.velocities(encoder: &encoder, index_begin: index)
                        index = flow.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _cX.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _cY.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _cZ.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index)
                        encoder.setBytes(&hh, length: MemoryLayout<Vector3F>.stride, index: index+1)
                        encoder.setBytes(&bbox.lowerCorner, length: MemoryLayout<Vector3F>.stride, index: index+2)
                        encoder.setBytes(&bbox.upperCorner, length: MemoryLayout<Vector3F>.stride, index: index+3)
        }
    }
}
