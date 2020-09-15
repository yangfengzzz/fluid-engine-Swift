//
//  AddForce.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

struct AddForce: ShaderCommand {
    struct TouchEvent {
        let delta: SIMD2<Float>
        let center: SIMD2<Float>
    }
    
    static let functionName: String = "addForce"
    private var radius: Float = 100
    
    private let pipelineState: MTLComputePipelineState
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        pipelineState = try type(of: self).makePiplelineState(device: device,
                                                              library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer,
                texture: Slab,
                touchEvents: [FastFluid.TouchEvent]) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var touches: [TouchEvent] = touchEvents.map { touchEvent in
            let delta = touchEvent.delta
            let center = touchEvent.point
            return TouchEvent(delta: SIMD2<Float>(10 * Float(delta.x), Float(10 * delta.y)),
                              center: SIMD2<Float>(Float(center.x), Float(center.y)))
        }
        
        var numberOfTouches = touchEvents.count
        var radius = self.radius
        
        let config = DispatchConfig(width: texture.source.width,
                                    height: texture.source.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(texture.source, index: 0)
        encoder.setTexture(texture.dest, index: 1)
        encoder.setBytes(&touches, length: touches.count * MemoryLayout<TouchEvent>.stride, index: 0)
        encoder.setBytes(&numberOfTouches, length: 1 * MemoryLayout<Int>.size, index: 1)
        encoder.setBytes(&radius, length: 1 * MemoryLayout<Float>.size, index: 2)
        encoder.dispatchThreadgroups(config.threadgroupCount,
                                     threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
