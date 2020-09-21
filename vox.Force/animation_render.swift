//
//  animation_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class SineAnimation: Animation {
    var x:Float = 0.0
    
    func onUpdate(frame: Frame) {
        x = sin(Float(10.0 * frame.timeInSeconds()))
    }
}

class SineWithDecayAnimation: Animation {
    var x:Float = 0.0
    
    func onUpdate(frame: Frame) {
        let decay:Float = Float(exp(-frame.timeInSeconds()))
        x = sin(Float(10.0 * frame.timeInSeconds())) * decay
    }
}

class AnimationRenderable: Renderable {
    let sineAnim = SineWithDecayAnimation()
    var frame = Frame()
    
    var renderPipelineState: MTLRenderPipelineState!
    var particleBuffer: MTLBuffer?
    let indexBuffer: MTLBuffer?
    
    init() {
        let bufferSize = MemoryLayout<float2>.stride * 240
        particleBuffer = Renderer.device.makeBuffer(length: bufferSize)!
        var bufferpointer = particleBuffer!.contents().bindMemory(to: float2.self,
                                                                  capacity: 240)
        for _ in 0..<240 {
            bufferpointer.pointee = float2()
            bufferpointer = bufferpointer.advanced(by: 1)
        }
        
        let IndexSize = MemoryLayout<UInt32>.stride * 240
        indexBuffer = Renderer.device.makeBuffer(length: IndexSize)!
        var Indexpointer = indexBuffer!.contents().bindMemory(to: UInt32.self,
                                                              capacity: 240)
        for i in 0..<240 {
            Indexpointer.pointee = UInt32(i)
            Indexpointer = Indexpointer.advanced(by: 1)
        }
        
        buildPipelineStates()
    }
    
    func reset() {
        frame.index = 0
    }
    
    func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else { return }
            
            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_line")
            let fragmentFunction = library.makeFunction(name: "fragment_line")
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
            vertexDescriptor.layouts[0].stride = MemoryLayout<float2>.size
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            descriptor.vertexDescriptor = vertexDescriptor
            
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 120 {
            frame.advance()
            
            sineAnim.update(frame: frame)
            let pointer = particleBuffer!.contents().bindMemory(to: float2.self,
                                                                capacity: 240)
            
            let p = pointer.advanced(by: frame.index)
            p.pointee = float2(Float(frame.timeInSeconds()), sineAnim.x)
        }
        
        //update to GPU
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBuffer(particleBuffer,
                                       offset: 0, index: 0)
        
        renderEncoder?.drawIndexedPrimitives(type: .lineStrip, indexCount: frame.index,
                                             indexType: .uint32, indexBuffer: indexBuffer!,
                                             indexBufferOffset: 0)
        
        renderEncoder?.endEncoding()
    }
}
