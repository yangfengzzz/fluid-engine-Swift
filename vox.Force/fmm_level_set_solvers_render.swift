//
//  fmm_level_set_solvers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class FmmLevelSetSolver2Renderable: Renderable {
    var sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    var temp:ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    let solver = FmmLevelSetSolver2()
    
    func constant() {
        sdf.fill(){(x:Vector2F)->Float in
            return 1.0
        }
    }
    
    func SDF() {
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
    }
    
    func scaled_SDF() {
        sdf.fill(){(x:Vector2F)->Float in
            let r = length(x - Vector2F(20, 20)) - 8.0
            return 2.0 * r
        }
    }
    
    func unit_step() {
        sdf.fill(){(x:Vector2F)->Float in
            let r = length(x - Vector2F(20, 20)) - 8.0
            return (r < 0.0) ? -0.5 : 0.5
        }
    }
    
    func Extrapolate() {
        let size = Size2(160, 120)
        let gridSpacing = Vector2F(1.0/Float(size.x), 1.0/Float(size.x))
        let maxDistance = 20.0 * gridSpacing.x
        
        sdf = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        let input = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        var output: ScalarGrid2 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(0.75, 0.5)) - 0.3
        }
        
        input.fill(){(x:Vector2F)->Float in
            if (length(x - Vector2F(0.75, 0.5)) <= 0.3) {
                let p = 10.0 * kPiF
                return 0.5 * 0.25 * sin(p * x.x) * sin(p * x.y)
            } else {
                return 0.0
            }
        }
        
        solver.extrapolate(input: input, sdf: sdf, maxDistance: maxDistance, output: &output)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class FmmLevelSetSolver3Renderable: Renderable {
    var sdf2 = Array2<Float>(width: 40, height: 30)
    var temp2 = Array2<Float>(width: 40, height: 30)
    var field2 = Array2<Float>(width: 40, height: 30)
    
    func ReinitializeSmall() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = FmmLevelSetSolver3()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                sdf2[i, j] = sdf[i, j, 10]
                temp2[i, j] = temp[i, j, 10]
            }
        }
    }
    
    func ExtrapolateSmall() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        let field = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        field.fill(){(x:Vector3F)->Float in
            if (length(x - Vector3F(20, 20, 20)) <= 8.0) {
                return 0.5 * 0.25 * sin(x.x) * sin(x.y) * sin(x.z)
            } else {
                return 0.0
            }
        }
        
        let solver = FmmLevelSetSolver3()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                field2[i, j] = field[i, j, 12]
                temp2[i, j] = temp[i, j, 12]
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
