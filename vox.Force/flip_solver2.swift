//
//  flip_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D Fluid-Implicit Particle (FLIP) implementation.
///
/// This class implements 2-D Fluid-Implicit Particle (FLIP) solver from the
/// SIGGRAPH paper, Zhu and Bridson 2005. By transfering delta-velocity field
/// from grid to particles, the FLIP solver achieves less viscous fluid flow
/// compared to the original PIC method.
///
/// \see Zhu, Yongning, and Robert Bridson. "Animating sand as a fluid."
///     ACM Transactions on Graphics (TOG). Vol. 24. No. 3. ACM, 2005.
class FlipSolver2: PicSolver2 {
    var _picBlendingFactor:Float = 0.0
    var _uDelta = Array2<Float>()
    var _vDelta = Array2<Float>()
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1], gridSpacing: [1, 1], gridOrigin: [0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size2,
                  gridSpacing:Vector2F,
                  gridOrigin:Vector2F) {
        super.init(resolution: resolution,
                   gridSpacing: gridSpacing,
                   gridOrigin: gridOrigin)
    }
    
    /// Returns the PIC blending factor.
    func picBlendingFactor()->Float {
        return _picBlendingFactor
    }
    
    /// Sets the PIC blending factor.
    ///
    /// This function sets the PIC blendinf factor which mixes FLIP and PIC
    /// results when transferring velocity from grids to particles in order to
    /// reduce the noise. The factor can be a value between 0 and 1, where 0
    /// means no blending and 1 means full PIC. Default is 0.
    /// - Parameter factor: The blending factor.
    func setPicBlendingFactor(factor:Float) {
        _picBlendingFactor = Math.clamp(val: factor, low: 0.0, high: 1.0)
    }
    
    /// Transfers velocity field from particles to grids.
    override func transferFromParticlesToGrids() {
        super.transferFromParticlesToGrids()
        
        // Store snapshot
        let vel = gridSystemData().velocity()
        let u = gridSystemData().velocity().uConstAccessor()
        let v = gridSystemData().velocity().vConstAccessor()
        _uDelta.resize(size: u.size())
        _vDelta.resize(size: v.size())
        
        vel.parallelForEachUIndex(){(i:size_t, j:size_t) in
            _uDelta[i, j] = u[i, j]
        }
        vel.parallelForEachVIndex(){(i:size_t, j:size_t) in
            _vDelta[i, j] = v[i, j]
        }
    }
    
    /// Transfers velocity field from grids to particles.
    override func transferFromGridsToParticles() {
        let flow = gridSystemData().velocity()
        let positions:ConstArrayAccessor1<Vector2F> = particleSystemData().positions()
        var velocities:ArrayAccessor1<Vector2F> = particleSystemData().velocities()
        let numberOfParticles = particleSystemData().numberOfParticles()
        
        // Compute delta
        flow.parallelForEachUIndex(){(i:size_t, j:size_t) in
            _uDelta[i, j] = flow.u(i: i, j: j) - _uDelta[i, j]
        }
        
        flow.parallelForEachVIndex(){(i:size_t, j:size_t) in
            _vDelta[i, j] = flow.v(i: i, j: j) - _vDelta[i, j]
        }
        
        let uSampler = LinearArraySampler2<Float, Float>(
            accessor: _uDelta.constAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler2<Float, Float>(
            accessor: _vDelta.constAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.vOrigin())
        
        let sampler = {(x:Vector2F)->Vector2F in
            let xf = x
            let u = uSampler[pt: xf]
            let v = vSampler[pt: xf]
            return Vector2F(u, v)
        }
        
        // Transfer delta to the particles
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            var flipVel = velocities[i] + sampler(positions[i])
            if (_picBlendingFactor > 0.0) {
                let picVel = flow.sample(x: positions[i])
                flipVel = Math.lerp(value0: flipVel, value1: picVel, f: _picBlendingFactor)
            }
            velocities[i] = flipVel
        }
    }
    
    //MARK:- Builder
    /// Front-end to create FlipSolver2 objects step by step.
    class Builder: GridFluidSolverBuilderBase2<Builder> {
        /// Builds FlipSolver2.
        func build()->FlipSolver2 {
            return FlipSolver2(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox FlipSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension FlipSolver2 {
    override func transferFromGridsToParticles_GPU() {
        let flow = gridSystemData().velocity()
        var resolution = Vector2<UInt32>(UInt32(flow.resolution().x),
                                         UInt32(flow.resolution().y))
        var usize = Vector2<UInt32>(UInt32(flow.uSize().x),
                                    UInt32(flow.uSize().y))
        var vsize = Vector2<UInt32>(UInt32(flow.vSize().x),
                                    UInt32(flow.vSize().y))
        let numberOfParticles = particleSystemData().numberOfParticles()
        
        // Compute delta
        flow.parallelForEachUIndex(name: "FlipSolver2::deltaU") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _uDelta.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        flow.parallelForEachVIndex(name: "FlipSolver2::deltaV") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = _vDelta.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "FlipSolver2::transferFromGridsToParticles") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particleSystemData().positions(encoder: &encoder, index_begin: index)
                        index = particleSystemData().velocities(encoder: &encoder, index_begin: index)
                        index = flow.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _uDelta.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _vDelta.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index)
                        encoder.setBytes(&usize, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+1)
                        encoder.setBytes(&vsize, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+2)
                        encoder.setBytes(&_picBlendingFactor, length: MemoryLayout<Float>.stride, index: index+3)
        }
    }
}
