//
//  particle_system_solver2_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class ParticleSystemSolver2Renderable: Renderable {
    let solver = ParticleSystemSolver2()
    var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
    
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
        let plane = Plane2(normal: Vector2F(0, 1), point: Vector2F())
        let collider = RigidBodyCollider2(surface: plane)
        let wind = ConstantVectorField2(value: Vector2F(1, 0))
        
        solver.setCollider(newCollider: collider)
        solver.setWind(newWind: wind)
        
        let emitter = PointParticleEmitter2(origin: Vector2F(0, 3), direction: Vector2F(0, 1),
                                            speed: 5.0, spreadAngleInDegrees: 45.0)
        emitter.setMaxNumberOfNewParticlesPerSecond(rate: 100)
        solver.setEmitter(newEmitter: emitter)
        
        buildPipelineStates()
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
        pos.resize(size: posAccessor.size())
        
        for i in 0..<posAccessor.size() {
            pos[i].position.x = posAccessor[i].x/10
            pos[i].position.y = posAccessor[i].y/4-0.6
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 3600 {
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
