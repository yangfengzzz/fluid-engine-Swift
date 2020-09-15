//
//  iterative_level_set_solvers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class LevelSetSolver2Renderable: Renderable {
    var data0 = CellCenteredScalarGrid2()
    var data1 = CellCenteredScalarGrid2()
    var flow:CustomVectorField2?
    
    func Reinitialize() {
        let size = Size2(256, 256)
        let gridSpacing = Vector2F(1.0/Float(size.x), 1.0/Float(size.x))
        
        data0 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        data1 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        
        data0.fill(){(pt:Vector2F)->Float in
            return length(pt - Vector2F(0.5, 0.75)) - 0.15
        }
        
        let flowFunc = {(pt:Vector2F)->Vector2F in
            var ret = Vector2F()
            ret.x =
                2.0 * Math.square(of: sin(kPiF * pt.x))
                * sin(kPiF * pt.y)
                * cos(kPiF * pt.y)
            ret.y =
                -2.0 * Math.square(of: sin(kPiF * pt.y))
                * sin(kPiF * pt.x)
                * cos(kPiF * pt.x)
            return ret
        }
        
        flow = CustomVectorField2(customFunction: flowFunc)
    }
    
    func NoReinitialize() {
        let size = Size2(256, 256)
        let gridSpacing = Vector2F(1.0/Float(size.x), 1.0/Float(size.x))
        
        data0 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        data1 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        
        data0.fill(){(pt:Vector2F)->Float in
            return length(pt - Vector2F(0.5, 0.75)) - 0.15
        }
        
        flow = CustomVectorField2(){(pt:Vector2F)->Vector2F in
            var ret = Vector2F()
            ret.x =
                2.0 * Math.square(of: sin(kPiF * pt.x))
                * sin(kPiF * pt.y)
                * cos(kPiF * pt.y)
            ret.y =
                -2.0 * Math.square(of: sin(kPiF * pt.y))
                * sin(kPiF * pt.x)
                * cos(kPiF * pt.x)
            return ret
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class UpwindLevelSetSolver2Renderable: Renderable {
    var sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    var temp:ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    let solver = UpwindLevelSetSolver2()
    
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

class UpwindLevelSetSolver3Renderable: Renderable {
    var sdf2 = Array2<Float>(width: 40, height: 30)
    var temp2 = Array2<Float>(width: 40, height: 30)
    var field2 = Array2<Float>(width: 40, height: 30)
    
    func ReinitializeSmall() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = UpwindLevelSetSolver3()
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
        
        let solver = UpwindLevelSetSolver3()
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

class EnoLevelSetSolver2Renderable: Renderable {
    var sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    var temp:ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
    let solver = EnoLevelSetSolver2()
    
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

class EnoLevelSetSolver3Renderable: Renderable {
    var sdf2 = Array2<Float>(width: 40, height: 30)
    var temp2 = Array2<Float>(width: 40, height: 30)
    var field2 = Array2<Float>(width: 40, height: 30)
    
    func ReinitializeSmall() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = EnoLevelSetSolver3()
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
        
        let solver = EnoLevelSetSolver3()
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
