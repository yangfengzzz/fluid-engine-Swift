//
//  grid_boundary_condition_solvers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class GridBlockedBoundaryConditionSolver2Renderable: Renderable {
    var dataU = Array2<Float>(width: 10, height: 10)
    var dataV = Array2<Float>(width: 10, height: 10)
    var dataM = Array2<Float>(width: 10, height: 10)
    
    func ConstrainVelocitySmall() {
        let solver = GridBlockedBoundaryConditionSolver2()
        let collider = RigidBodyCollider2(surface: Plane2(normal: normalize(Vector2F(1, 1)),
                                                          point: Vector2F()))
        let gridSize = Size2(10, 10)
        let gridSpacing = Vector2F(1.0, 1.0)
        let gridOrigin = Vector2F(-5.0, -5.0)
        
        solver.updateCollider(newCollider: collider, gridSize: gridSize,
                              gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var velocity = FaceCenteredGrid2(resolution: gridSize,
                                         gridSpacing: gridSpacing, origin: gridOrigin)
        velocity.fill(value: Vector2F(1.0, 1.0))
        
        solver.constrainVelocity(velocity: &velocity)
        
        // Output
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = velocity.valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            dataM[i, j] = Float(solver.marker()[i, j])
        }
    }
    
    func ConstrainVelocity() {
        let dx:Float = 1.0 / 32.0
        var velocity = FaceCenteredGrid2(resolution: Size2(64, 32),
                                         gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        velocity.fill(value: Vector2F(1.0, 0.0))
        let domain = velocity.boundingBox()
        
        // Collider setting
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.upperCorner, radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.lowerCorner, radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: surfaceSet)
        collider.linearVelocity = Vector2F(-1.0, 0.0)
        
        // Solver setting
        let solver = GridBlockedBoundaryConditionSolver2()
        solver.updateCollider(
            newCollider: collider,
            gridSize: velocity.resolution(),
            gridSpacing: velocity.gridSpacing(),
            gridOrigin: velocity.origin())
        solver.setClosedDomainBoundaryFlag(
            flag: kDirectionRight | kDirectionDown | kDirectionUp)
        
        // Constrain velocity
        solver.constrainVelocity(velocity: &velocity, extrapolationDepth: 5)
        
        // Output
        dataU = Array2<Float>(width: 64, height: 32)
        dataV = Array2<Float>(width: 64, height: 32)
        dataM = Array2<Float>(width: 64, height: 32)
        
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = velocity.valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            dataM[i, j] = Float(solver.marker()[i, j])
        }
    }
    
    func ConstrainVelocityWithFriction() {
        let dx:Float = 1.0 / 32.0
        var velocity = FaceCenteredGrid2(resolution: Size2(64, 32),
                                         gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        velocity.fill(value: Vector2F(1.0, 0.0))
        let domain = velocity.boundingBox()
        
        // Collider setting
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.upperCorner, radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.lowerCorner, radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: surfaceSet)
        collider.linearVelocity = Vector2F(-1.0, 0.0)
        collider.setFrictionCoefficient(newFrictionCoeffient: 1.0)
        
        // Solver setting
        let solver = GridBlockedBoundaryConditionSolver2()
        solver.updateCollider(
            newCollider: collider,
            gridSize: velocity.resolution(),
            gridSpacing: velocity.gridSpacing(),
            gridOrigin: velocity.origin())
        solver.setClosedDomainBoundaryFlag(
            flag: kDirectionRight | kDirectionDown | kDirectionUp)
        
        // Constrain velocity
        solver.constrainVelocity(velocity: &velocity, extrapolationDepth: 5)
        
        // Output
        dataU = Array2<Float>(width: 64, height: 32)
        dataV = Array2<Float>(width: 64, height: 32)
        dataM = Array2<Float>(width: 64, height: 32)
        
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = velocity.valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
            dataM[i, j] = Float(solver.marker()[i, j])
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class GridFractionalBoundaryConditionSolver2Renderable: Renderable {
    var dataU = Array2<Float>(width: 64, height: 32)
    var dataV = Array2<Float>(width: 64, height: 32)
    
    func ConstrainVelocity() {
        let dx:Float = 1.0 / 32.0
        var velocity = FaceCenteredGrid2(resolution: Size2(64, 32),
                                         gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        velocity.fill(value: Vector2F(1.0, 0.0))
        let domain = velocity.boundingBox()
        
        // Collider setting
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.upperCorner, radiustransform: 0.25))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.lowerCorner, radiustransform: 0.25))
        let collider = RigidBodyCollider2(surface: surfaceSet)
        collider.linearVelocity = Vector2F(-1.0, 0.0)
        
        // Solver setting
        let solver = GridFractionalBoundaryConditionSolver2()
        solver.updateCollider(
            newCollider: collider,
            gridSize: velocity.resolution(),
            gridSpacing: velocity.gridSpacing(),
            gridOrigin: velocity.origin())
        solver.setClosedDomainBoundaryFlag(
            flag: kDirectionRight | kDirectionDown | kDirectionUp)
        
        // Constrain velocity
        solver.constrainVelocity(velocity: &velocity, extrapolationDepth: 5)
        
        // Output
        dataU.forEachIndex(){(i:size_t, j:size_t) in
            let vel = velocity.valueAtCellCenter(i: i, j: j)
            dataU[i, j] = vel.x
            dataV[i, j] = vel.y
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
