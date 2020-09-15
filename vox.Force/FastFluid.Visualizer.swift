//
//  FastFluid.Visualizer.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

extension FastFluid {
    class Visualizer {
        let vertexData: [Float] = [
            -1,  1, 0, 0,
            -1, -1, 0, 1,
            1, -1, 1, 1,
            1, -1, 1, 1,
            1,  1, 1, 0,
            -1,  1, 0, 0
        ]
        
        private let vertexBuffer: MTLBuffer
        private let pipelineState: MTLRenderPipelineState
        
        init?() {            
            guard let vertexBuffer = Renderer.device.makeBuffer(bytes: vertexData,
                                                                length: vertexData.count * MemoryLayout<Float>.size,
                                                                options: [.storageModeShared]) else {
                                                                    return nil
            }
            self.vertexBuffer = vertexBuffer
            
            // create render pipeline
            guard let vertexProgram = Renderer.library.makeFunction(name: "fluid_vertex_function") else {
                return nil
            }
            
            guard let fragmentProgram = Renderer.library.makeFunction(name: "fluid_fragment_function") else {
                return nil
            }
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.label = "Fullscreen Quad Pipeline"
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
            pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            do {
                self.pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            } catch {
                print("Failed to createRenderPipelineState: \(error)")
                return nil
            }
        }
        
        func encode(texture: MTLTexture, in view: MTKView) {
            if let renderPassDescriptor = view.currentRenderPassDescriptor,
                let renderEncoder = Renderer.commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                renderEncoder.setFragmentTexture(texture, index: 0)
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                renderEncoder.endEncoding()
            }
        }
    }
}
