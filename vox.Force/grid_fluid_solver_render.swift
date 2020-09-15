//
//  grid_fluid_solver_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class GridFluidSolver2Renderable: Renderable {
    var dataU = Array2<Float>(width: 64, height: 32)
    var dataV = Array2<Float>(width: 64, height: 32)
    var div = Array2<Float>(width: 64, height: 32)
    var pressure = Array2<Float>(width: 64, height: 32)
    
    func ApplyBoundaryConditionWithPressure() {
        let solver = GridFluidSolver2()
        solver.setGravity(newGravity: Vector2F(0, 0))
        solver.setAdvectionSolver(newSolver: nil)
        solver.setDiffusionSolver(newSolver: nil)
        
        let ppe = GridSinglePhasePressureSolver2()
        solver.setPressureSolver(newSolver: ppe)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(64, 32),
                    gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        data.velocity().fill(value: Vector2F(1.0, 0.0))
        
        let domain = data.boundingBox()
        
        let sphere = SurfaceToImplicit2(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: sphere)
        solver.setCollider(newCollider: collider)
        
        let frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        solver.update(frame: frame)
        
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = data.velocity().valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            div[i, j] = data.velocity().divergenceAtCellCenter(i: i, j: j)
            pressure[i, j] = ppe.pressure()[i, j]
        }
    }
    
    func ApplyBoundaryConditionWithVariationalPressure() {
        let solver = GridFluidSolver2()
        solver.setGravity(newGravity: Vector2F(0, 0))
        solver.setAdvectionSolver(newSolver: nil)
        solver.setDiffusionSolver(newSolver: nil)
        
        let ppe = GridFractionalSinglePhasePressureSolver2()
        solver.setPressureSolver(newSolver: ppe)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(64, 32), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        data.velocity().fill(value: Vector2F(1.0, 0.0))
        
        let domain = data.boundingBox()
        
        let sphere = SurfaceToImplicit2(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: sphere)
        solver.setCollider(newCollider: collider)
        
        let frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        solver.update(frame: frame)
        
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = data.velocity().valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            div[i, j] = data.velocity().divergenceAtCellCenter(i: i, j: j)
            pressure[i, j] = ppe.pressure()[i, j]
        }
    }
    
    func ApplyBoundaryConditionWithPressureOpen() {
        let solver = GridFluidSolver2()
        solver.setGravity(newGravity: Vector2F(0, 0))
        solver.setAdvectionSolver(newSolver: nil)
        solver.setDiffusionSolver(newSolver: nil)
        
        // Open left and right
        solver.setClosedDomainBoundaryFlag(flag: kDirectionDown | kDirectionUp)
        
        let ppe = GridSinglePhasePressureSolver2()
        solver.setPressureSolver(newSolver: ppe)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(64, 32), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        data.velocity().fill(value: Vector2F(1.0, 0.0))
        
        let domain = data.boundingBox()
        
        let sphere = SurfaceToImplicit2(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: sphere)
        solver.setCollider(newCollider: collider)
        
        let frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        solver.update(frame: frame)
        
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = data.velocity().valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            div[i, j] = data.velocity().divergenceAtCellCenter(i: i, j: j)
            pressure[i, j] = ppe.pressure()[i, j]
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
