//
//  RayMarching.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class RayMarching: Node {
    var pipelineState: MTLComputePipelineState!
    var timerBuffer: MTLBuffer!
    var timer: Float = 0
    
    override init() {
        super.init()
        initializeMetal()
    }
    
    func initializeMetal() {
        do {
            guard let kernel = Renderer.library.makeFunction(name: "marching") else {
                fatalError()
            }
            pipelineState = try Renderer.device.makeComputePipelineState(function: kernel)
        } catch {
            print(error)
        }
        timerBuffer = Renderer.device!.makeBuffer(length: MemoryLayout<Float>.size, options: [])
    }
    
    func update() {
        timer += 0.01
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
    }
    
    public func draw(in view: MTKView) {
        update()
        guard let commandEncoder = Renderer.commandBuffer?.makeComputeCommandEncoder() else { fatalError() }
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(view.currentDrawable?.texture, index: 0)
        commandEncoder.setBuffer(timerBuffer, offset: 0, index: 0)
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width),
                                         Int(view.drawableSize.height), 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
    }
}
