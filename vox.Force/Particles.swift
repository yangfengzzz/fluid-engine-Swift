//
//  Particles.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class Particles: Node {
    var particlesPipelineState: MTLComputePipelineState!
    var renderPipelineState: MTLRenderPipelineState!
    
    var emitters: [Emitter] = []
    
    override init() {
        super.init()
        
        buildPipelineStates()
    }
    
    private func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary(),
                let function = library.makeFunction(name: "compute") else { return }
            
            // particle update pipeline state
            particlesPipelineState = try Renderer.device.makeComputePipelineState(function: function)
            
            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_particle")
            let fragmentFunction = library.makeFunction(name: "fragment_particle")
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            descriptor.depthAttachmentPixelFormat = .depth32Float
            
            renderPipelineState = try
                Renderer.device.makeRenderPipelineState(descriptor: descriptor)
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension Particles {
    func draw(in view: MTKView){
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        
        // first command encoder
        guard let computeEncoder = Renderer.commandBuffer?.makeComputeCommandEncoder()
            else { return }
        
        for emitter in emitters {
            emitter.emit()
        }
        
        computeEncoder.setComputePipelineState(particlesPipelineState)
        let width = particlesPipelineState.threadExecutionWidth
        let threadsPerGroup = MTLSizeMake(width, 1, 1)
        for emitter in emitters {
            let threadsPerGrid = MTLSizeMake(emitter.particleCount, 1, 1)
            computeEncoder.setBuffer(emitter.particleBuffer, offset: 0, index: 0)
            computeEncoder.dispatchThreads(threadsPerGrid,
                                           threadsPerThreadgroup: threadsPerGroup)
        }
        computeEncoder.endEncoding()
        
        // update the particle emitters
        
        
        // second command encoder
        let renderEncoder =
            Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        var size = float2(Float(view.drawableSize.width),
                          Float(view.drawableSize.height))
        renderEncoder?.setVertexBytes(&size,
                                     length: MemoryLayout<float2>.stride,
                                     index: 0)
        for emitter in emitters {
            renderEncoder?.setVertexBuffer(emitter.particleBuffer,
                                          offset: 0, index: 1)
            renderEncoder?.setVertexBytes(&emitter.position,
                                         length: MemoryLayout<float2>.stride,
                                         index: 2)
            renderEncoder?.setFragmentTexture(emitter.particleTexture, index: 0)
            renderEncoder?.drawPrimitives(type: .point, vertexStart: 0,
                                         vertexCount: 1,
                                         instanceCount: emitter.currentParticles)
        }
        renderEncoder?.endEncoding()
    }
}

extension Particles {
    static func fire(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 1200
        emitter.particleTexture = Emitter.loadTexture(imageName: "fire")!
        emitter.birthRate = 5
        var descriptor = ParticleDescriptor()
        descriptor.position.x = Float(size.width) / 2 - 90
        descriptor.positionXRange = 0...180
        descriptor.direction = Float.pi / 2
        descriptor.directionRange = -0.3...0.3
        descriptor.speed = 3
        descriptor.pointSize = 80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.5...1.0
        descriptor.endScaleRange = 0...0
        descriptor.life = 180
        descriptor.lifeRange = -50...70
        descriptor.color = float4(1.0, 0.392, 0.1, 0.5)
        emitter.particleDescriptor = descriptor
        return emitter
    }
    
    static func snow(size: CGSize) -> Emitter {
        let emitter = Emitter()
        
        // 1
        emitter.particleCount = 100
        emitter.birthRate = 1
        emitter.birthDelay = 20
        
        // 2
        emitter.particleTexture = Emitter.loadTexture(imageName: "snowflake")!
        
        // 3
        var descriptor = ParticleDescriptor()
        descriptor.position.x = 0
        descriptor.positionXRange = 0...Float(size.width)
        descriptor.direction = -.pi / 2
        descriptor.speedRange =  2...6
        descriptor.pointSizeRange = 80 * 0.5...80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.2...1.0
        
        // 4
        descriptor.life = 500
        descriptor.color = [1, 1, 1, 1]
        emitter.particleDescriptor = descriptor
        return emitter
    }
}
