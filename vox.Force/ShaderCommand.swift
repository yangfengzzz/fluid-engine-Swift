//
//  ShaderCommand.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

protocol ShaderCommand {
    static var functionName: String { get }
}

enum ShaderCommandError: Error {
    case failedToCreateFunction
}

extension ShaderCommand {
    static func makePiplelineState(device: MTLDevice, library: MTLLibrary) throws -> MTLComputePipelineState {
        guard let function = library.makeFunction(name: functionName) else {
            throw ShaderCommandError.failedToCreateFunction
        }
        return try device.makeComputePipelineState(function: function)
    }
}
