//
//  apic_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D Affine Particle-in-Cell (APIC) implementation
///
/// This class implements 2-D Affine Particle-in-Cell (APIC) solver from the
/// SIGGRAPH paper, Jiang 2015.
///
/// \see Jiang, Chenfanfu, et al. "The affine particle-in-cell method."
///      ACM Transactions on Graphics (TOG) 34.4 (2015): 51.
class ApicSolver2: PicSolver2 {
    var _cX = Array1<Vector2F>()
    var _cY = Array1<Vector2F>()
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1], gridSpacing: [1, 1], gridOrigin: [0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size2,
                  gridSpacing:Vector2F,
                  gridOrigin:Vector2F) {
        super.init(resolution: resolution, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
    }
    
    /// Transfers velocity field from particles to grids.
    override func transferFromParticlesToGrids() {
        let flow = gridSystemData().velocity()
        let particles = particleSystemData()
        let positions:ConstArrayAccessor1<Vector2F> = particles.positions()
        let velocities:ConstArrayAccessor1<Vector2F> = particles.velocities()
        let numberOfParticles = particles.numberOfParticles()
        let hh = flow.gridSpacing() / 2.0
        let bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        
        // Clear velocity to zero
        flow.fill(value: Vector2F())
        
        // Weighted-average velocity
        var u = flow.uAccessor()
        var v = flow.vAccessor()
        let uPos = flow.uPosition()
        let vPos = flow.vPosition()
        var uWeight = Array2<Float>(size: u.size())
        var vWeight = Array2<Float>(size: v.size())
        _uMarkers.resize(size: u.size())
        _vMarkers.resize(size: v.size())
        _uMarkers.set(value: 0)
        _vMarkers.set(value: 0)
        let uSampler = LinearArraySampler2<Float, Float>(
            accessor: flow.uConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler2<Float, Float>(
            accessor: flow.vConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.vOrigin())
        
        for i in 0..<numberOfParticles {
            var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
            var weights = Array<Float>(repeating: 0, count: 4)
            
            var uPosClamped = positions[i]
            uPosClamped.y = Math.clamp(
                val: uPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            uSampler.getCoordinatesAndWeights(pt: uPosClamped, indices: &indices, weights: &weights)
            for j in 0..<4 {
                let gridPos = uPos(indices[j].x, indices[j].y)
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
            vSampler.getCoordinatesAndWeights(pt: vPosClamped, indices: &indices, weights: &weights)
            for j in 0..<4 {
                let gridPos = vPos(indices[j].x, indices[j].y)
                let apicTerm = dot(_cY[i], gridPos - vPosClamped)
                v[indices[j]] += weights[j] * (velocities[i].y + apicTerm)
                vWeight[indices[j]] += weights[j]
                _vMarkers[indices[j]] = 1
            }
        }
        
        uWeight.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (uWeight[i, j] > 0.0) {
                u[i, j] /= uWeight[i, j]
            }
        }
        vWeight.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (vWeight[i, j] > 0.0) {
                v[i, j] /= vWeight[i, j]
            }
        }
    }
    
    /// Transfers velocity field from grids to particles.
    override func transferFromGridsToParticles() {
        let flow = gridSystemData().velocity()
        let particles = particleSystemData()
        let positions:ConstArrayAccessor1<Vector2F> = particles.positions()
        var velocities:ArrayAccessor1<Vector2F> = particles.velocities()
        let numberOfParticles = particles.numberOfParticles()
        let hh = flow.gridSpacing() / 2.0
        let bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        _cX.set(value: Vector2F())
        _cY.set(value: Vector2F())
        
        let u = flow.uAccessor()
        let v = flow.vAccessor()
        let uSampler = LinearArraySampler2<Float, Float>(
            accessor: ConstArrayAccessor2<Float>(other: u),
            gridSpacing: flow.gridSpacing(), gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler2<Float, Float>(
            accessor: ConstArrayAccessor2<Float>(other: v),
            gridSpacing: flow.gridSpacing(), gridOrigin: flow.vOrigin())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            velocities[i] = flow.sample(x: positions[i])
            
            var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
            var gradWeights = Array<Vector2F>(repeating: Vector2F(), count: 4)
            
            // x
            var uPosClamped = positions[i]
            uPosClamped.y = Math.clamp(
                val: uPosClamped.y,
                low: bbox.lowerCorner.y + hh.y,
                high: bbox.upperCorner.y - hh.y)
            uSampler.getCoordinatesAndGradientWeights(
                pt: uPosClamped, indices: &indices, weights: &gradWeights)
            for j in 0..<4 {
                _cX[i] += gradWeights[j] * u[indices[j]]
            }
            
            // y
            var vPosClamped = positions[i]
            vPosClamped.x = Math.clamp(
                val: vPosClamped.x,
                low: bbox.lowerCorner.x + hh.x,
                high: bbox.upperCorner.x - hh.x)
            vSampler.getCoordinatesAndGradientWeights(
                pt: vPosClamped, indices: &indices, weights: &gradWeights)
            for j in 0..<4 {
                _cY[i] += gradWeights[j] * v[indices[j]]
            }
        }
    }
    
    //MARK:- Builder
    /// Front-end to create ApicSolver2 objects step by step.
    class Builder: GridFluidSolverBuilderBase2<Builder> {
        /// Builds ApicSolver2.
        func build()->ApicSolver2 {
            return ApicSolver2(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox ApicSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension ApicSolver2 {
    override func transferFromGridsToParticles_GPU() {
        let flow = gridSystemData().velocity()
        var resolution = Vector2<UInt32>(UInt32(flow.resolution().x),
                                         UInt32(flow.resolution().y))
        let particles = particleSystemData()
        let numberOfParticles = particles.numberOfParticles()
        var hh = flow.gridSpacing() / 2.0
        var bbox = flow.boundingBox()
        
        // Allocate buffers
        _cX.resize(size: numberOfParticles)
        _cY.resize(size: numberOfParticles)
        _cX.set(value: Vector2F())
        _cY.set(value: Vector2F())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "ApicSolver2::transferFromGridsToParticles") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.positions(encoder: &encoder, index_begin: index)
                        index = particles.velocities(encoder: &encoder, index_begin: index)
                        index = flow.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _cX.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _cY.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index)
                        encoder.setBytes(&hh, length: MemoryLayout<Vector2F>.stride, index: index+1)
                        encoder.setBytes(&bbox.lowerCorner, length: MemoryLayout<Vector2F>.stride, index: index+2)
                        encoder.setBytes(&bbox.upperCorner, length: MemoryLayout<Vector2F>.stride, index: index+3)
        }
    }
}
