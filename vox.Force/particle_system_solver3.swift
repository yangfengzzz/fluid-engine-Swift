//
//  particle_system_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Basic 3-D particle system solver.
///
/// This class implements basic particle system solver. It includes gravity,
/// air drag, and collision. But it does not compute particle-to-particle
/// interaction. Thus, this solver is suitable for performing simple spray-like
/// simulations with low computational cost. This class can be further extend
/// to add more sophisticated simulations, such as SPH, to handle
/// particle-to-particle intersection.
class ParticleSystemSolver3: PhysicsAnimation {
    var _dragCoefficient:Float = 1e-4
    var _restitutionCoefficient:Float = 0.0
    var _gravity = Vector3F(0.0, kGravity, 0.0)
    
    var _particleSystemData:ParticleSystemData3
    var _newPositions = ParticleSystemData3.VectorData()
    var _newVelocities = ParticleSystemData3.VectorData()
    var _collider:Collider3?
    var _emitter:ParticleEmitter3?
    var _wind:VectorField3
    
    /// Constructs an empty solver.
    override convenience init() {
        self.init(radius: 1e-3, mass: 1e-3)
    }
    
    /// Constructs a solver with particle parameters.
    init(radius:Float,
         mass:Float) {
        self._particleSystemData = ParticleSystemData3()
        self._particleSystemData.setRadius(newRadius: radius)
        self._particleSystemData.setMass(newMass: mass)
        self._wind = ConstantVectorField3(value: Vector3F())
        super.init()
    }
    
    /// Returns the drag coefficient.
    func dragCoefficient()->Float {
        return _dragCoefficient
    }
    
    /// Sets the drag coefficient.
    ///
    /// The drag coefficient controls the amount of air-drag. The coefficient
    /// should be a positive number and 0 means no drag force.
    /// - Parameter newDragCoefficient: newDragCoefficient The new drag coefficient.
    func setDragCoefficient(newDragCoefficient:Float) {
        _dragCoefficient = max(newDragCoefficient, 0.0)
    }
    
    /// Returns the restitution coefficient.
    func restitutionCoefficient()->Float {
        return _restitutionCoefficient
    }
    
    /// Sets the restitution coefficient.
    ///
    /// The restitution coefficient controls the bouncy-ness of a particle when
    /// it hits a collider surface. The range of the coefficient should be 0 to
    /// 1 -- 0 means no bounce back and 1 means perfect reflection.
    /// - Parameter newRestitutionCoefficient: The new restitution coefficient.
    func setRestitutionCoefficient(newRestitutionCoefficient:Float) {
        _restitutionCoefficient = Math.clamp(val: newRestitutionCoefficient,
                                             low: 0.0, high: 1.0)
    }
    
    /// Returns the gravity.
    func gravity()->Vector3F {
        return _gravity
    }
    
    /// Sets the gravity.
    func setGravity(newGravity:Vector3F) {
        _gravity = newGravity
    }
    
    /// Returns the particle system data.
    ///
    /// This function returns the particle system data. The data is created when
    /// this solver is constructed and also owned by the solver.
    /// - Returns: The particle system data.
    func particleSystemData()->ParticleSystemData3 {
        return _particleSystemData
    }
    
    /// Returns the collider.
    func collider()->Collider3? {
        return _collider
    }
    
    /// Sets the collider.
    func setCollider(newCollider:Collider3) {
        _collider = newCollider
    }
    
    /// Returns the emitter.
    func emitter()->ParticleEmitter3? {
        return _emitter
    }
    
    /// Sets the emitter.
    func setEmitter(newEmitter:ParticleEmitter3) {
        _emitter = newEmitter
        newEmitter.setTarget(particles: _particleSystemData)
    }
    
    /// Returns the wind field.
    func wind()->VectorField3 {
        return _wind
    }
    
    /// Sets the wind.
    ///
    /// Wind can be applied to the particle system by setting a vector field to
    /// the solver.
    /// - Parameter newWind: The new wind.
    func setWind(newWind:VectorField3) {
        _wind = newWind
    }
    
    /// Initializes the simulator.
    override func onInitialize() {
        // When initializing the solver, update the collider and emitter state as
        // well since they also affects the initial condition of the simulation.
        var timer = Date()
        updateCollider(timeStepInSeconds: 0.0)
        logger.info("Update collider took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        updateEmitter(timeStepInSeconds: 0.0)
        logger.info("Update emitter took \(Date().timeIntervalSince(timer)) seconds")
    }
    
    /// Called to advane a single time-step.
    override func onAdvanceTimeStep(timeIntervalInSeconds timeStepInSeconds:Double) {
        beginAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
        
        var timer = Date()
        accumulateForces(timeStepInSeconds: timeStepInSeconds)
        logger.info("Accumulating forces took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        if Renderer.arch == .CPU {
            timeIntegration(timeStepInSeconds: timeStepInSeconds)
        }else {
            timeIntegration_GPU(timeStepInSeconds: timeStepInSeconds)
        }
        logger.info("Time integration took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        resolveCollision()
        logger.info("Resolving collision took \(Date().timeIntervalSince(timer)) seconds")
        
        if Renderer.arch == .CPU {
            endAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
        }else {
            endAdvanceTimeStep_GPU(timeStepInSeconds: timeStepInSeconds)
        }
    }
    
    /// Accumulates forces applied to the particles.
    func accumulateForces(timeStepInSeconds:Double) {
        // Add external forces
        if Renderer.arch == .CPU {
            accumulateExternalForces()
        } else {
            accumulateExternalForces_GPU()
        }
    }
    
    /// Called when a time-step is about to begin.
    func onBeginAdvanceTimeStep(timeStepInSeconds:Double) {
    }
    
    /// Called after a time-step is completed.
    func onEndAdvanceTimeStep(timeStepInSeconds:Double) {
    }
    
    /// Resolves any collisions occured by the particles.
    func resolveCollision() {
        var nP = _newPositions.accessor()
        var nV = _newVelocities.accessor()
        
        resolveCollision(newPositions: &nP,
                         newVelocities: &nV)
    }
    
    /// Resolves any collisions occured by the particles where the particle
    /// state is given by the position and velocity arrays.
    func resolveCollision(newPositions: inout ArrayAccessor1<Vector3F>,
                          newVelocities: inout ArrayAccessor1<Vector3F>) {
        if (_collider != nil) {
            let numberOfParticles = _particleSystemData.numberOfParticles()
            let radius = _particleSystemData.radius()
            
            parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                _collider!.resolveCollision(
                    radius: radius,
                    restitutionCoefficient: _restitutionCoefficient,
                    position: &newPositions[i],
                    velocity: &newVelocities[i])
            }
        }
    }
    
    /// Assign a new particle system data.
    func setParticleSystemData(newParticles:ParticleSystemData3) {
        _particleSystemData = newParticles
    }
    
    func beginAdvanceTimeStep(timeStepInSeconds:Double) {
        // Clear forces
        var forces:ArrayAccessor1<Vector3F> = _particleSystemData.forces()
        for i in 0..<forces.size() {
            forces[i] = Vector3F()
        }
        
        // Update collider and emitter
        var timer = Date()
        updateCollider(timeStepInSeconds: timeStepInSeconds)
        logger.info("Update collider took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        updateEmitter(timeStepInSeconds: timeStepInSeconds)
        logger.info("Update emitter took \(Date().timeIntervalSince(timer)) seconds")
        
        // Allocate buffers
        let n = _particleSystemData.numberOfParticles()
        _newPositions.resize(size: n)
        _newVelocities.resize(size: n)
        
        onBeginAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
    }
    
    func endAdvanceTimeStep(timeStepInSeconds:Double) {
        // Update data
        let n = _particleSystemData.numberOfParticles()
        var positions:ArrayAccessor1<Vector3F> = _particleSystemData.positions()
        var velocities:ArrayAccessor1<Vector3F> = _particleSystemData.velocities()
        parallelFor(beginIndex: 0, endIndex: n){(i:size_t) in
            positions[i] = _newPositions[i]
            velocities[i] = _newVelocities[i]
        }
        
        onEndAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
    }
    
    func accumulateExternalForces() {
        let n = _particleSystemData.numberOfParticles()
        var forces:ArrayAccessor1<Vector3F> = _particleSystemData.forces()
        let velocities:ArrayAccessor1<Vector3F> = _particleSystemData.velocities()
        let positions:ArrayAccessor1<Vector3F> = _particleSystemData.positions()
        let mass = _particleSystemData.mass()
        
        parallelFor(beginIndex: 0, endIndex: n){(i:size_t) in
            // Gravity
            var force = mass * _gravity
            
            // Wind forces
            let relativeVel = velocities[i] - _wind.sample(x: positions[i])
            force += -_dragCoefficient * relativeVel
            
            forces[i] += force
        }
    }
    
    func timeIntegration(timeStepInSeconds:Double) {
        let n = _particleSystemData.numberOfParticles()
        let forces:ArrayAccessor1<Vector3F> = _particleSystemData.forces()
        let velocities:ArrayAccessor1<Vector3F> = _particleSystemData.velocities()
        let positions:ArrayAccessor1<Vector3F> = _particleSystemData.positions()
        let mass = _particleSystemData.mass()
        
        parallelFor(beginIndex: 0, endIndex: n){(i:size_t) in
            // Integrate velocity first
            _newVelocities[i] = velocities[i] + Float(timeStepInSeconds) * forces[i] / mass
            
            // Integrate position.
            _newPositions[i] = positions[i] + Float(timeStepInSeconds) * _newVelocities[i]
        }
    }
    
    func updateCollider(timeStepInSeconds:Double) {
        if (_collider != nil) {
            _collider!.update(currentTimeInSeconds: currentTimeInSeconds(),
                              timeIntervalInSeconds: timeStepInSeconds)
        }
    }
    
    func updateEmitter(timeStepInSeconds:Double) {
        if (_emitter != nil) {
            _emitter!.update(currentTimeInSeconds: currentTimeInSeconds(),
                             timeIntervalInSeconds: timeStepInSeconds)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create ParticleSystemSolver3 objects step by step.
    class Builder: ParticleSystemSolverBuilderBase3<Builder> {
        /// Builds ParticleSystemSolver3.
        func build()->ParticleSystemSolver3 {
            return ParticleSystemSolver3(radius: _radius, mass: _mass)
        }
    }
    
    /// Returns builder fox ParticleSystemSolver3.
    static func builder()->Builder{
        return Builder()
    }
}

/// Base class for particle-based solver builder.
class ParticleSystemSolverBuilderBase3<DerivedBuilder> {
    var _radius:Float = 1e-3
    var _mass:Float = 1e-3
    
    /// Returns builder with particle radius.
    func withRadius(radius:Float)->DerivedBuilder {
        _radius = radius
        return self as! DerivedBuilder
    }
    
    /// Returns builder with mass per particle.
    func withMass(mass:Float)->DerivedBuilder {
        _mass = mass
        return self as! DerivedBuilder
    }
}

//MARK:- GPU Method
extension ParticleSystemSolver3 {
    func accumulateExternalForces_GPU() {
        let _wind_const = _wind as? ConstantVectorField3
        guard _wind_const != nil else {
            fatalError()
        }
        
        let n = _particleSystemData.numberOfParticles()
        var mass = _particleSystemData.mass()
        
        parallelFor(beginIndex: 0, endIndex: n,
                    name: "ParticleSystemSolver3::accumulateExternalForces") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = _particleSystemData.forces(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.velocities(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.positions(encoder: &encoder, index_begin: index)
                        index = _wind_const!.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&_dragCoefficient, length: MemoryLayout<Float>.stride, index: index+1)
                        encoder.setBytes(&_gravity, length: MemoryLayout<Vector3F>.stride, index: index+2)
        }
    }
    
    func timeIntegration_GPU(timeStepInSeconds:Double) {
        let n = _particleSystemData.numberOfParticles()
        var timeStepInSeconds:Float = Float(timeStepInSeconds)
        var mass = _particleSystemData.mass()
        parallelFor(beginIndex: 0, endIndex: n,
                    name: "ParticleSystemSolver3::timeIntegration") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = _newVelocities.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _newPositions.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.forces(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.velocities(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.positions(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&timeStepInSeconds, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: index+1)
        }
    }
    
    func endAdvanceTimeStep_GPU(timeStepInSeconds:Double) {
        let n = _particleSystemData.numberOfParticles()
        parallelFor(beginIndex: 0, endIndex: n,
                    name: "ParticleSystemSolver3::endAdvanceTimeStep") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = _newVelocities.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _newPositions.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.velocities(encoder: &encoder, index_begin: index)
                        index = _particleSystemData.positions(encoder: &encoder, index_begin: index)
        }
        
        onEndAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
    }
}
