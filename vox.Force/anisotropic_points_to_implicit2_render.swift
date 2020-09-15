//
//  anisotropic_points_to_implicit2_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class AnisotropicPointsToImplicit2Renderable: Renderable {
    var grid:ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 512, resolutionY: 512,
                                                   gridSpacingX: 1.0 / 512, gridSpacingY: 1.0 / 512)
    
    func ConvertTwo() {
        var points = Array1<Vector2F>()
        
        for _ in 0..<2 {
            points.append(other: [[Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8)]])
        }
        
        let converter = AnisotropicPointsToImplicit2(kernelRadius: 0.1)
        converter.convert(points: points.constAccessor(), output: &grid)
    }
    
    func ConvertMany() {
        var points = Array1<Vector2F>()
        
        for _ in 0..<200 {
            points.append(other: [[Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8)]])
        }
        
        let converter = AnisotropicPointsToImplicit2(kernelRadius: 0.1)
        converter.convert(points: points.constAccessor(), output: &grid)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
