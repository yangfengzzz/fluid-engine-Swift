//
//  level_set_liquid_solver3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class LevelSetLiquidSolver3Renderable: Renderable {
    let solver = LevelSetLiquidSolver3()
    
    func SubtleSloshing() {
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 64.0
        data.resize(resolution: [ 64, 64, 8 ], gridSpacing: [ dx, dx, dx ], origin: Vector3F())
        
        // Source setting
        let surfaceSet = ImplicitSurfaceSet3()
        surfaceSet.addExplicitSurface(surface: Plane3(normal: normalize(Vector3F(0.02, 1, 0)),
                                                      point: Vector3F(0.0, 0.5, 0.0)))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector3F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
