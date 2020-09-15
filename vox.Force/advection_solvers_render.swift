//
//  advection_solvers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class SemiLagrangian2Renderable: Renderable {
    let src = CellCenteredVectorGrid2(resolutionX: 200, resolutionY: 200,
                                      gridSpacingX: 1.0/200.0, gridSpacingY: 1.0/200.0)
    var dst:CollocatedVectorGrid2 = CellCenteredVectorGrid2(resolutionX: 200, resolutionY: 200,
                                                            gridSpacingX: 1.0/200.0, gridSpacingY: 1.0/200.0)
    let sdf = CellCenteredScalarGrid2(resolutionX: 200, resolutionY: 200,
                                      gridSpacingX: 1.0/200.0, gridSpacingY: 1.0/200.0)
    let sdf2 = CellCenteredScalarGrid2(resolutionX: 200, resolutionY: 200,
                                       gridSpacingX: 1.0/200.0, gridSpacingY: 1.0/200.0)
    var data:Array3<Float>
    
    init() {
        data = Array3<Float>(width: 3, height: src.resolution().x, depth: src.resolution().y)
    }
    
    func Boundary() {
        src.fill(){(pt:Vector2F)->Vector2F in
            return [0.5 * (sin(15 * pt.x) + 1.0),
                    0.5 * (sin(15 * pt.y) + 1.0)]
        }
        
        let flow = ConstantVectorField2(value: Vector2F(1.0, 1.0))
        let boundarySdf = CustomScalarField2(){(pt:Vector2F)->Float in
            return length(Vector2F(0.5, 0.5) - pt) - 0.25
        }
        
        data.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (i < 2) {
                data[i, j, k] = src[j, k][i]
            }
        }
        
        let solver = SemiLagrangian2()
        solver.advect(input: src, flow: flow, dt: 0.1,
                      output: &dst, boundarySdf: boundarySdf)
        
        data.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (i < 2) {
                data[i, j, k] = dst[j, k][i]
            }
        }
    }
    
    func Zalesak() {
        let box = Box2(lowerCorner: Vector2F(0.5 - 0.025, 0.6),
                       upperCorner: Vector2F(0.5 + 0.025, 0.85))
        
        sdf.fill(){(pt:Vector2F)->Float in
            let disk = length(pt - Vector2F(0.5, 0.75)) - 0.15
            var slot = box.closestDistance(otherPoint: pt)
            if (!box.boundingBox().contains(point: pt)) {
                slot *= -1.0
            }
            return max(disk, slot)
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
