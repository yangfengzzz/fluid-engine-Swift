//
//  level_set_liquid_solver2_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class LevelSetLiquidSolver2Renderable: Renderable {
    var solver = LevelSetLiquidSolver2()
    
    func Drop() {
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 64), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func DropStopAndGo() {
        // Build solver
        solver = LevelSetLiquidSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        let grids = solver.gridSystemData()
        let domain = grids.boundingBox()
        
        // Build emitter
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0, 0.5])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15)
            .build()
        
        let surfaceSet = ImplicitSurfaceSet2.builder()
            .withExplicitSurfaces(surfaces: [plane, sphere])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: surfaceSet)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addSignedDistanceTarget(scalarGridTarget: solver.signedDistanceField())
    }
    
    func DropHighRes() {
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 128.0
        data.resize(resolution: Size2(128, 256), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func DropWithCollider() {
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 150), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
        
        // Collider setting
        let sphere = Sphere2(center: Vector2F(domain.midPoint().x, 0.75 - cos(0.0)), radiustransform: 0.2)
        let surface = SurfaceToImplicit2(surface: sphere)
        let collider = RigidBodyCollider2(surface: surface)
        solver.setCollider(newCollider: collider)
    }
    
    func DropVariational() {
        solver.setPressureSolver(newSolver: GridFractionalSinglePhasePressureSolver2())
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 150), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func DropWithColliderVariational() {
        solver.setPressureSolver(newSolver: GridFractionalSinglePhasePressureSolver2())
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 150), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
        
        // Collider setting
        let sphere = Sphere2(center: Vector2F(domain.midPoint().x, 0.75 - cos(0.0)), radiustransform: 0.2)
        let surface = SurfaceToImplicit2(surface: sphere)
        let collider = RigidBodyCollider2(surface: surface)
        solver.setCollider(newCollider: collider)
    }
    
    func ViscousDropVariational() {
        solver.setViscosityCoefficient(newValue: 1.0)
        solver.setPressureSolver(newSolver: GridFractionalSinglePhasePressureSolver2())
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 50.0
        data.resize(resolution: Size2(50, 100), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0.5)))
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func DropWithoutGlobalComp() {
        solver.setIsGlobalCompensationEnabled(isEnabled: false)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 64), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func DropWithGlobalComp() {
        solver.setIsGlobalCompensationEnabled(isEnabled: true)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 64), gridSpacing: Vector2F(dx, dx), origin: Vector2F())
        
        // Source setting
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(), radiustransform: 0.15))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
    }
    
    func RisingFloor() {
        // Build solver
        solver = LevelSetLiquidSolver2.builder()
            .withResolution(resolution: [5, 10])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        solver.setGravity(newGravity: [0, 0, 0])
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.0, 0.0])
            .withUpperCorner(pt: [1.0, 0.8])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addSignedDistanceTarget(scalarGridTarget: solver.signedDistanceField())
        
        // Build collider
        let tank = Box2.builder()
            .withLowerCorner(pt: [-1, 0])
            .withUpperCorner(pt: [2, 2])
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: tank)
            .build()
        
        collider.setOnBeginUpdateCallback(){(col:Collider2, t:Double, _:Double) in
            var surf = col.surface()
            surf.transform.setTranslation(translation: [0, Float(t)])
            col.setSurface(newSurface: surf)
            (col as! RigidBodyCollider2).linearVelocity.x = 0.0
            (col as! RigidBodyCollider2).linearVelocity.y = 1.0
        }
        
        solver.setCollider(newCollider: collider)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
