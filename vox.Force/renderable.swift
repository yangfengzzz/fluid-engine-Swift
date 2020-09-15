//
//  renderable.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

protocol Renderable {
    func buildPipelineStates()
    
    func draw(in view: MTKView)
    
    func reset()
}
