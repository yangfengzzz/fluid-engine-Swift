//
//  particle_system_solver3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class ParticleSystemSolver3Renderable: Renderable {
    var solver = ParticleSystemSolver3()
    var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
    
    struct Particle : ZeroInit {
        init() {
            position = float3()
            color = float4(1, 0, 0, 1)
            size = 0
        }
        
        func getKernelType() -> KernelType {
            .unsupported
        }
        
        var position: float3
        var color: float4
        var size: Float
    }
    
    var renderPipelineState: MTLRenderPipelineState!
    var GPUBuffer = Array1<Particle>()
    var numberOfpoints:Int = 0
    
    init() {
        Update()
        buildPipelineStates()
    }
    
    func PerfectBounce() {
        let plane = Plane3(normal: Vector3F(0, 1, 0), point: Vector3F())
        let collider = RigidBodyCollider3(surface: plane)
        
        solver.setCollider(newCollider: collider)
        solver.setDragCoefficient(newDragCoefficient: 0.0)
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 1.0)
        
        let particles = solver.particleSystemData()
        particles.addParticle(newPosition: [0.0, 3.0, 0.0], newVelocity: [1.0, 0.0, 0.0])
    }
    
    func HalfBounce() {
        let plane = Plane3(normal: Vector3F(0, 1, 0), point: Vector3F())
        let collider = RigidBodyCollider3(surface: plane)
        
        solver.setCollider(newCollider: collider)
        solver.setDragCoefficient(newDragCoefficient: 0.0)
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.5)
        
        let particles = solver.particleSystemData()
        particles.addParticle(newPosition: [0.0, 3.0, 0.0], newVelocity: [1.0, 0.0, 0.0])
    }
    
    func HalfBounceWithFriction() {
        let plane = Plane3(normal: Vector3F(0, 1, 0), point: Vector3F())
        let collider = RigidBodyCollider3(surface: plane)
        collider.setFrictionCoefficient(newFrictionCoeffient: 0.04)
        
        solver.setCollider(newCollider: collider)
        solver.setDragCoefficient(newDragCoefficient: 0.0)
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.5)
        
        let particles = solver.particleSystemData()
        particles.addParticle(newPosition: [0.0, 3.0, 0.0], newVelocity: [1.0, 0.0, 0.0])
    }
    
    func NoBounce() {
        let plane = Plane3(normal: Vector3F(0, 1, 0), point: Vector3F())
        let collider = RigidBodyCollider3(surface: plane)
        
        solver.setCollider(newCollider: collider)
        solver.setDragCoefficient(newDragCoefficient: 0.0)
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.0)
        
        let particles = solver.particleSystemData()
        particles.addParticle(newPosition: [0.0, 3.0, 0.0], newVelocity: [1.0, 0.0, 0.0])
    }
    
    func Update() {
        let plane = Plane3.builder()
            .withNormal(normal: [0, 1, 0])
            .withPoint(point: [0, 0, 0])
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: plane)
            .build()
        
        let wind = ConstantVectorField3.builder()
            .withValue(value: [1, 0, 0])
            .build()
        
        let emitter = PointParticleEmitter3.builder()
            .withOrigin(origin: [0, 3, 0])
            .withDirection(direction: [0, 1, 0])
            .withSpeed(speed: 5)
            .withSpreadAngleInDegrees(spreadAngleInDegrees: 45.0)
            .withMaxNumberOfNewParticlesPerSecond(maxNumOfNewParticlesPerSec: 300)
            .build()
        
        solver = ParticleSystemSolver3.builder().build()
        solver.setCollider(newCollider: collider)
        solver.setEmitter(newEmitter: emitter)
        solver.setWind(newWind: wind)
        solver.setDragCoefficient(newDragCoefficient: 0.0)
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.5)
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
            vertexDescriptor.attributes[0].format = .float3
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
        let posAccessor:ConstArrayAccessor1<Vector3F> = solver.particleSystemData().positions()
        pos.resize(size: posAccessor.size())
        
        for i in 0..<posAccessor.size() {
            pos[i].position.x = posAccessor[i].x/3
            pos[i].position.y = posAccessor[i].y/3-0.6
            pos[i].position.z = posAccessor[i].z
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 360 {
            frame.advance()
            
            solver.update(frame: frame)
            
            exportStates(pos: &GPUBuffer)
            
            if solver.particleSystemData().numberOfParticles() > numberOfpoints {
                for i in numberOfpoints..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].color = ColorUtils.makeJet(value: Float.random(in: -1.0...1.0))
                }
                
                for i in numberOfpoints..<solver.particleSystemData().numberOfParticles() {
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
