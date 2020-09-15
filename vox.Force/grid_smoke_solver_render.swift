//
//  grid_smoke_solver_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class GridSmokeSolver2Renderable: Renderable {
    var solver = GridSmokeSolver2()
    
    func Rising() {
        // Build solver
        solver = GridSmokeSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withGridSpacing(gridSpacing: 1.0 / 32.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.3, 0.0])
            .withUpperCorner(pt: [0.7, 0.4])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0.0, maxValue: 1.0)
    }
    
    func RisingWithCollider() {
        // Build solver
        solver = GridSmokeSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withGridSpacing(gridSpacing: 1.0 / 32.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.3, 0.0])
            .withUpperCorner(pt: [0.7, 0.4])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0.0, maxValue: 1.0)
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 1.0])
            .withRadius(radius: 0.1)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func MovingEmitterWithCollider() {
        // Build solver
        solver = GridSmokeSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withGridSpacing(gridSpacing: 1.0 / 32.0)
            .build()
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.3, 0.0])
            .withUpperCorner(pt: [0.7, 0.1])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .withIsOneShot(isOneShot: false)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.setOnBeginUpdateCallback(){(t:Float, dt:Float) in
            box.bound.lowerCorner.x = 0.1 * sin(kPiF * t) + 0.3
            box.bound.upperCorner.x = 0.1 * sin(kPiF * t) + 0.7
        }
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 1.0])
            .withRadius(radius: 0.1)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func RisingWithColliderNonVariational() {
        // Build solver
        solver = GridSmokeSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withGridSpacing(gridSpacing: 1.0 / 32.0)
            .build()
        
        solver.setPressureSolver(newSolver: GridSinglePhasePressureSolver2())
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.3, 0.0])
            .withUpperCorner(pt: [0.7, 0.4])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0.0, maxValue: 1.0)
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 1.0])
            .withRadius(radius: 0.1)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func RisingWithColliderAndDiffusion() {
        // Build solver
        solver = GridSmokeSolver2.builder()
            .withResolution(resolution: [32, 64])
            .withGridSpacing(gridSpacing: 1.0 / 32.0)
            .build()
        
        // Parameter setting
        solver.setViscosityCoefficient(newValue: 0.01)
        solver.setSmokeDiffusionCoefficient(newValue: 0.01)
        solver.setTemperatureDiffusionCoefficient(newValue: 0.01)
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.3, 0.0])
            .withUpperCorner(pt: [0.7, 0.4])
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: box)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0.0, maxValue: 1.0)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0.0, maxValue: 1.0)
        
        // Build collider
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 1.0])
            .withRadius(radius: 0.1)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class GridSmokeSolver3Renderable: Renderable {
    var solver = GridSmokeSolver3()
    
    func Rising() {
        let resolutionX:size_t = 50
        
        // Build solver
        solver = GridSmokeSolver3.builder()
            .withResolution(resolution: [resolutionX, 6 * resolutionX / 5, resolutionX / 2])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setBuoyancyTemperatureFactor(newValue: 2.0)
        
        // Build emitter
        let box = Box3.builder()
            .withLowerCorner(pt: [0.05, 0.1, 0.225])
            .withUpperCorner(pt: [0.1, 0.15, 0.275])
            .build()
        
        let emitter = VolumeGridEmitter3.builder()
            .withSourceRegion(sourceRegion: box)
            .withIsOneShot(isOneShot: false)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0, maxValue: 1)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0, maxValue: 1)
        emitter.addTarget(vectorGridTarget: solver.velocity()){
            (sdf:Float, pt:Vector3F, oldVal:Vector3F)->Vector3F in
            if (sdf < 0.05) {
                return Vector3F(0.5, oldVal.y, oldVal.z)
            } else {
                return Vector3F(oldVal)
            }
        }
    }
    
    func RisingWithCollider() {
        let resolutionX:size_t = 50
        
        // Build solver
        solver = GridSmokeSolver3.builder()
            .withResolution(resolution: [resolutionX, 2 * resolutionX, resolutionX])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setAdvectionSolver(newSolver: CubicSemiLagrangian3())
        
        let grids = solver.gridSystemData()
        let domain = grids.boundingBox()
        
        // Build emitter
        let box = Box3.builder()
            .withLowerCorner(pt: [0.45, -1, 0.45])
            .withUpperCorner(pt: [0.55, 0.05, 0.55])
            .build()
        
        let emitter = VolumeGridEmitter3.builder()
            .withSourceRegion(sourceRegion: box)
            .withIsOneShot(isOneShot: false)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0, maxValue: 1)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0, maxValue: 1)
        
        // Build collider
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.3, 0.5])
            .withRadius(radius: 0.075 * domain.width())
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func RisingWithColliderLinear() {
        let resolutionX:size_t = 50
        
        // Build solver
        solver = GridSmokeSolver3.builder()
            .withResolution(resolution: [resolutionX, 2 * resolutionX, resolutionX])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setAdvectionSolver(newSolver: SemiLagrangian3())
        
        let grids = solver.gridSystemData()
        let domain = grids.boundingBox()
        
        // Build emitter
        let box = Box3.builder()
            .withLowerCorner(pt: [0.45, -1, 0.45])
            .withUpperCorner(pt: [0.55, 0.05, 0.55])
            .build()
        
        let emitter = VolumeGridEmitter3.builder()
            .withSourceRegion(sourceRegion: box)
            .withIsOneShot(isOneShot: false)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.smokeDensity(),
                                      minValue: 0, maxValue: 1)
        emitter.addStepFunctionTarget(scalarGridTarget: solver.temperature(),
                                      minValue: 0, maxValue: 1)
        
        // Build collider
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.3, 0.5])
            .withRadius(radius: 0.075 * domain.width())
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
