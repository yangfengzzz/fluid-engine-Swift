//
//  SubtractGradient.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

// Texture0: p
// Texture1: w
// Texture2: target
// Buffer0: halfrdx

struct SubtractGradient: ShaderCommand {
    static let functionName: String = "subtractGradient"
    
    private let pipelineState: MTLComputePipelineState
    private let halfrdx: Float = 0.5
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        self.pipelineState = try type(of: self).makePiplelineState(device: device,
                                                                   library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer,
                pressure: MTLTexture,
                w: MTLTexture,
                target: MTLTexture) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var halfrdx = self.halfrdx
        
        let config = DispatchConfig(width: pressure.width, height: pressure.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setBytes(&halfrdx, length: MemoryLayout<Float>.size, index: 0)
        encoder.setTexture(pressure, index: 0)
        encoder.setTexture(w, index: 1)
        encoder.setTexture(target, index: 2)
        encoder.dispatchThreadgroups(config.threadgroupCount,
                                     threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
