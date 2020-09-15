//
//  flip_solver2_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class FlipSolver2Renderable: Renderable {
    var solver = FlipSolver2()
    var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
    var r = Array1<Float>()
    
    struct Particle : ZeroInit {
        init() {
            position = float2()
            color = float4(1, 0, 0, 1)
            size = 0
        }
        
        func getKernelType() -> KernelType {
            .unsupported
        }
        
        var position: float2
        var color: float4
        var size: Float
    }
    
    var renderPipelineState: MTLRenderPipelineState!
    var GPUBuffer = Array1<Particle>()
    var numberOfpoints:Int = 0
    
    init() {
        DamBreakingWithCollider()
        buildPipelineStates()
    }
    
    func SteadyState() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [32, 32])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.0, 0.0])
            .withUpperCorner(pt: [1.0, 0.5])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 1.0 / 64.0)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
    }
    
    func Rotation() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [10, 10])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setGravity(newGravity: [0, 0])
        
        // Build emitter
        let box = Sphere2.builder()
            .withCenter(center: [0.5, 0.5])
            .withRadius(radius: 0.4)
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 1.0 / 20.0)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
    }
    
    func RotationUpdate() {
        var x:ArrayAccessor1<Vector2F> = solver.particleSystemData().positions()
        var v:ArrayAccessor1<Vector2F> = solver.particleSystemData().velocities()
        r.resize(size: x.size())
        for i in 0..<x.size() {
            r[i] = length(x[i] - Vector2F(0.5, 0.5))
        }
        
        solver.update(frame: frame)
        
        if (frame.index == 0) {
            x = solver.particleSystemData().positions()
            v = solver.particleSystemData().velocities()
            for i in 0..<x.size() {
                let rp = x[i] - Vector2F(0.5, 0.5)
                v[i].x = rp.y
                v[i].y = -rp.x
            }
        } else {
            for i in 0..<x.size() {
                let rp = x[i] - Vector2F(0.5, 0.5)
                if (length_squared(rp) > 0.0) {
                    let scale = r[i] / length(rp)
                    x[i] = scale * rp + Vector2F(0.5, 0.5)
                }
            }
        }
    }
    
    func DamBreaking() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [100, 100])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.0, 0.0])
            .withUpperCorner(pt: [0.2, 0.8])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 0.005)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
    }
    
    func DamBreakingWithCollider() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [100, 100])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.0, 0.0])
            .withUpperCorner(pt: [0.2, 0.8])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 0.005)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 0.0])
            .withRadius(radius: 0.15)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func DamBreakingWithColliderWithBlending() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [100, 100])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setPicBlendingFactor(factor: 0.05)
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.0, 0.0])
            .withUpperCorner(pt: [0.2, 0.8])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 0.005)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 0.0])
            .withRadius(radius: 0.15)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func RotatingTank() {
        // Build solver
        solver = FlipSolver2.builder()
            .withResolution(resolution: [32, 32])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.25, 0.25])
            .withUpperCorner(pt: [0.75, 0.50])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: 1.0 / 64.0)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
        
        // Build collider
        let tank = Box2.builder()
            .withLowerCorner(pt: [-0.25, -0.25])
            .withUpperCorner(pt: [ 0.25,  0.25])
            .withTranslation(translation: [0.5, 0.5])
            .withOrientation(orientation: 0.0)
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: tank)
            .withAngularVelocity(angularVelocity: 2.0)
            .build()
        
        collider.setOnBeginUpdateCallback(){(col:Collider2, t:Double, _:Double) in
            if (t < 1.0) {
                var surf = col.surface()
                surf.transform.setOrientation(orientation: Float(2.0 * t))
                col.setSurface(newSurface: surf)
                (col as! RigidBodyCollider2).angularVelocity = 2.0
            } else {
                (col as! RigidBodyCollider2).angularVelocity = 0.0
            }
        }
        
        solver.setCollider(newCollider: collider)
    }
    
    func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else { return }
            
            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_point")
            let fragmentFunction = library.makeFunction(name: "fragment_point")
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            descriptor.depthAttachmentPixelFormat = .depth32Float
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.layouts[0].stride = MemoryLayout<Particle>.size
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            descriptor.vertexDescriptor = vertexDescriptor
            
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func exportStates(pos:inout Array1<Particle>) {
        let posAccessor:ConstArrayAccessor1<Vector2F> = solver.particleSystemData().positions()
        if posAccessor.size() != numberOfpoints {
            pos.resize(size: posAccessor.size())
        }
        
        for i in 0..<posAccessor.size() {
            pos[i].position.x = posAccessor[i].x*2-1
            pos[i].position.y = posAccessor[i].y*2-1
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 3600 {
            frame.advance()
            
            solver.update(frame: frame)
            
            exportStates(pos: &GPUBuffer)
            
            if solver.particleSystemData().numberOfParticles() != numberOfpoints {
                for i in 0..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].color = ColorUtils.makeBlue()
                }
                
                for i in 0..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].size = 10.0
                }
                
                numberOfpoints = solver.particleSystemData().numberOfParticles()
            }
        }
        
        //update to GPU
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBuffer(GPUBuffer._data,
                                       offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .point, vertexStart: 0,
                                      vertexCount: 1,
                                      instanceCount: numberOfpoints)
        
        renderEncoder?.endEncoding()
    }
    
    func reset() {
        
    }
}
