//
//  array_utils_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class ArrayUtilsRenderable: Renderable {
    var data = Array2<Float>(width: 128, height: 192, initVal: 0.0)
    var valid = Array2<CChar>(width: 128, height: 192, initVal: 0)
    
    func ExtralateToRegion2() {
        for j in 0..<192 {
            for i in 0..<128 {
                let pt = Vector2F(Float(i) / 128.0, Float(j) / 128.0)
                
                data[i, j] = sin(4 * kPiF * pt.x) * sin(4 * kPiF * pt.y)
                
                if (length(pt - Vector2F(0.5, 0.5)) < 0.15 ||
                    length(pt - Vector2F(0.5, 0.9)) < 0.15) {
                    valid[i, j] = 1
                } else {
                    valid[i, j] = 0
                }
            }
        }
        
        var accessor = data.accessor()
        extrapolateToRegion(input: data.constAccessor(),
                            valid: valid.constAccessor(),
                            numberOfIterations: 10,
                            output: &accessor)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
