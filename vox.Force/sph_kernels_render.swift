//
//  sph_kernels_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class SphStdKernel3Renderable: Renderable {
    var x = Array1<Float>(size: 101)
    var y = Array1<Float>(size: 101)
    var y0 = Array1<Float>(size: 101)
    var y1 = Array1<Float>(size: 101)
    var y2 = Array1<Float>(size: 101)
    
    var renderPipelineState: MTLRenderPipelineState!
    var particleBuffer = Array1<Vector2F>(size: 101)
    var colorBuffer = Array1<Vector4F>(size: 101)
    var indexBuffer: MTLBuffer?
    
    init() {
        Operator()
        
        for i in 0...100 {
            particleBuffer[i] = float2(x[i], y[i])
        }
        
        for i in 0...100 {
            colorBuffer[i] = ColorUtils.makeJet(value: Float.random(in: -1.0...1.0))
        }
        
        let IndexSize = MemoryLayout<uint32>.stride * 101
        indexBuffer = Renderer.device.makeBuffer(length: IndexSize)!
        var Indexpointer = indexBuffer!.contents().bindMemory(to: uint32.self,
                                                              capacity: 101)
        for i in 0...100 {
            Indexpointer.pointee = uint32(i)
            Indexpointer = Indexpointer.advanced(by: 1)
        }
        
        buildPipelineStates()
    }
    
    func Operator() {
        let r:Float = 1.0
        let kernel = SphStdKernel3(kernelRadius: r)
        
        for i in 0...100 {
            let t = 2.0 * (r * Float(i) / 100.0) - r
            x[i] = t
            y[i] = kernel[x[i]]
        }
    }
    
    func Derivatives() {
        let r:Float = 1.0
        let spiky = SphSpikyKernel3(kernelRadius: r)
        
        for i in 0...100 {
            let t = 2.0 * (r * Float(i) / 100.0) - r
            x[i] = t
            y0[i] = spiky[abs(x[i])]
            y1[i] = spiky.firstDerivative(distance: abs(x[i]))
            y2[i] = spiky.secondDerivative(distance: abs(x[i]))
        }
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
        //update to GPU
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBuffer(particleBuffer._data,
                                       offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(colorBuffer._data,
                                       offset: 0, index: 1)
        
        renderEncoder?.drawIndexedPrimitives(type: .lineStrip, indexCount: 101,
                                             indexType: .uint32, indexBuffer: indexBuffer!,
                                             indexBufferOffset: 0)
        
        renderEncoder?.endEncoding()
    }
    
    func reset() {
        
    }
    
}
