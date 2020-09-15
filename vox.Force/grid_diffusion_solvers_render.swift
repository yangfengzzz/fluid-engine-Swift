//
//  grid_diffusion_solvers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class GridForwardEulerDiffusionSolver3Renderable: Renderable {
    var data = Array2<Float>(width: 160, height: 120)
    
    func Solve() {
        let size = Size3(160, 120, 150)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, 75]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridForwardEulerDiffusionSolver3()
        
        diffusionSolver.solve(source: src as ScalarGrid3, diffusionCoefficient: diffusionCoeff,
                              timeIntervalInSeconds: timeStep, dest: &dst)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func Unstable() {
        let size = Size3(160, 120, 150)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, 75]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridForwardEulerDiffusionSolver3()
        
        diffusionSolver.solve(
            source: src,
            diffusionCoefficient: 10.0 * diffusionCoeff,
            timeIntervalInSeconds: timeStep,
            dest: &dst)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class GridBackwardEulerDiffusionSolver3Renderable: Renderable {
    var data = Array2<Float>(width: 160, height: 120)
    
    func Solve() {
        let size = Size3(160, 120, 150)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, 75]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver3()
        
        diffusionSolver.solve(source: src as ScalarGrid3, diffusionCoefficient: diffusionCoeff,
                              timeIntervalInSeconds: timeStep, dest: &dst)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func Stable() {
        let size = Size3(160, 120, 150)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, 75]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver3()
        
        diffusionSolver.solve(
            source: src,
            diffusionCoefficient: 10.0 * diffusionCoeff,
            timeIntervalInSeconds: timeStep,
            dest: &dst)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func SolveWithBoundaryDirichlet() {
        let size = Size3(80, 60, 75)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        let boundaryCenter = src.boundingBox().midPoint()
        let boundarySdf = CustomScalarField3(){(x:Vector3F)->Float in
            return boundaryCenter.x - x.x
        }
        
        data = Array2<Float>(width: size.x, height: size.y)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, size.z / 2]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = 100 * Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver3(boundaryType: .Dirichlet)
        
        diffusionSolver.solve(source: src, diffusionCoefficient: diffusionCoeff,
                              timeIntervalInSeconds: timeStep, dest: &dst, boundarySdf: boundarySdf)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func SolveWithBoundaryNeumann() {
        let size = Size3(80, 60, 75)
        let gridSpacing = Vector3F(1.0/Float(size.x), 1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolution: size, gridSpacing: gridSpacing)
        
        let boundaryCenter = src.boundingBox().midPoint()
        let boundarySdf = CustomScalarField3(){(x:Vector3F)->Float in
            return boundaryCenter.x - x.x
        }
        
        data = Array2<Float>(width: size.x, height: size.y)
        
        src.fill(){(x:Vector3F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j, size.z / 2]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = 100 * Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver3(boundaryType: .Neumann)
        
        diffusionSolver.solve(source: src, diffusionCoefficient: diffusionCoeff,
                              timeIntervalInSeconds: timeStep, dest: &dst, boundarySdf: boundarySdf)
        var parent_src:Grid3 = src as Grid3
        dst.swap(other: &parent_src)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

//MARK:- 2D Solver
class GridBackwardEulerDiffusionSolver2Renderable: Renderable {
    var data = Array2<Float>(width: 160, height: 120)
    
    func Solve() {
        let size = Size2(160, 120)
        let gridSpacing = Vector2F(1.0/Float(size.x), 1.0/Float(size.x))
        
        let src = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        var dst: ScalarGrid2 = CellCenteredScalarGrid2(resolution: size, gridSpacing: gridSpacing)
        
        src.fill(){(x:Vector2F)->Float in
            return (length(x - src.boundingBox().midPoint()) < 0.2) ? 1.0 : 0.0
        }
        
        data.forEachIndex(){(i:size_t, j:size_t) in
            data[i, j] = src[i, j]
        }
        
        let timeStep:Float = 0.01
        let diffusionCoeff = Math.square(of: gridSpacing.x) / timeStep / 12.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver2()
        
        diffusionSolver.solve(
            source: src,
            diffusionCoefficient: 100.0 * diffusionCoeff,
            timeIntervalInSeconds: timeStep,
            dest: &dst,
            boundarySdf: ConstantScalarField2(value: Float.greatestFiniteMagnitude),
            fluidSdf: CustomScalarField2(customFunction: {(pt:Vector2F)->Float in
                let md = src.boundingBox().midPoint()
                return pt.x - md.x
            }))
        var parent_src:Grid2 = src as Grid2
        dst.swap(other: &parent_src)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
