//
//  sph_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

let kTimeStepLimitBySpeedFactor:Float = 0.4
let kTimeStepLimitByForceFactor:Float = 0.25

/// 2-D SPH solver.
///
/// This class implements 2-D SPH solver. The main pressure solver is based on
/// equation-of-state (EOS).
///
/// M{\"u}ller et al., Particle-based fluid simulation for interactive
/// applications, SCA 2003.
/// M. Becker and M. Teschner, Weakly compressible SPH for free surface
/// flows, SCA 2007.
/// Adams and Wicke, Meshless approximation methods and applications in
/// physics based modeling and animation, Eurographics tutorials 2009.
class SphSolver2: ParticleSystemSolver2 {
    /// Exponent component of equation-of-state (or Tait's equation).
    var _eosExponent:Float = 7.0
    
    /// Negative pressure scaling factor.
    /// Zero means clamping. One means do nothing.
    var _negativePressureScale:Float = 0.0
    
    /// Viscosity coefficient.
    var _viscosityCoefficient:Float = 0.01
    
    /// Pseudo-viscosity coefficient velocity filtering.
    /// This is a minimum "safety-net" for SPH solver which is quite
    /// sensitive to the parameters.
    var _pseudoViscosityCoefficient:Float = 10.0
    
    /// Speed of sound in medium to determin the stiffness of the system.
    /// Ideally, it should be the actual speed of sound in the fluid, but in
    /// practice, use lower value to trace-off performance and compressibility.
    var _speedOfSound:Float = 100.0
    
    /// Scales the max allowed time-step.
    var _timeStepLimitScale:Float = 1.0
    
    /// Constructs a solver with empty particle set.
    init() {
        super.init(radius: 1e-3, mass: 1e-3)
        setParticleSystemData(newParticles: SphSystemData2())
        setIsUsingFixedSubTimeSteps(isUsing: false)
    }
    
    /// Constructs a solver with target density, spacing, and relative kernel radius.
    init(targetDensity:Float,
         targetSpacing:Float,
         relativeKernelRadius:Float) {
        super.init(radius: 1e-3, mass: 1e-3)
        let sphParticles = SphSystemData2()
        setParticleSystemData(newParticles: sphParticles)
        sphParticles.setTargetDensity(targetDensity: targetDensity)
        sphParticles.setTargetSpacing(spacing: targetSpacing)
        sphParticles.setRelativeKernelRadius(relativeRadius: relativeKernelRadius)
        setIsUsingFixedSubTimeSteps(isUsing: false)
    }
    
    /// Returns the exponent part of the equation-of-state.
    func eosExponent()->Float {
        return _eosExponent
    }
    
    /// Sets the exponent part of the equation-of-state.
    ///
    /// This function sets the exponent part of the equation-of-state.
    /// The value must be greater than 1.0, and smaller inputs will be clamped.
    /// Default is 7.
    func setEosExponent(newEosExponent:Float) {
        _eosExponent = max(newEosExponent, 1.0)
    }
    
    /// Returns the negative pressure scale.
    func negativePressureScale()->Float {
        return _negativePressureScale
    }
    
    /// Sets the negative pressure scale.
    ///
    /// This function sets the negative pressure scale. By setting the number
    /// between 0 and 1, the solver will scale the effect of negative pressure
    /// which can prevent the clumping of the particles near the surface. Input
    /// value outside 0 and 1 will be clamped within the range. Default is 0.
    func setNegativePressureScale(newNegativePressureScale:Float) {
        _negativePressureScale = Math.clamp(val: newNegativePressureScale,
                                            low: 0.0, high: 1.0)
    }
    
    /// Returns the viscosity coefficient.
    func viscosityCoefficient()->Float {
        return _viscosityCoefficient
    }
    
    /// Sets the viscosity coefficient.
    func setViscosityCoefficient(newViscosityCoefficient:Float) {
        _viscosityCoefficient = max(newViscosityCoefficient, 0.0)
    }
    
    /// Returns the pseudo viscosity coefficient.
    func pseudoViscosityCoefficient()->Float {
        return _pseudoViscosityCoefficient
    }
    
    /// Sets the pseudo viscosity coefficient.
    ///
    /// This function sets the pseudo viscosity coefficient which applies
    /// additional pseudo-physical damping to the system. Default is 10.
    func setPseudoViscosityCoefficient(newPseudoViscosityCoefficient:Float) {
        _pseudoViscosityCoefficient = max(newPseudoViscosityCoefficient, 0.0)
    }
    
    /// Returns the speed of sound.
    func speedOfSound()->Float {
        return _speedOfSound
    }
    
    /// Sets the speed of sound.
    ///
    /// This function sets the speed of sound which affects the stiffness of the
    /// EOS and the time-step size. Higher value will make EOS stiffer and the
    /// time-step smaller. The input value must be higher than 0.0.
    func setSpeedOfSound(newSpeedOfSound:Float) {
        _speedOfSound = max(newSpeedOfSound, Float.leastNonzeroMagnitude)
    }
    
    /// Multiplier that scales the max allowed time-step.
    ///
    /// This function returns the multiplier that scales the max allowed
    /// time-step. When the scale is 1.0, the time-step is bounded by the speed
    /// of sound and max acceleration.
    func timeStepLimitScale()->Float {
        return _timeStepLimitScale
    }
    
    /// Sets the multiplier that scales the max allowed time-step.
    ///
    /// This function sets the multiplier that scales the max allowed
    /// time-step. When the scale is 1.0, the time-step is bounded by the speed
    /// of sound and max acceleration.
    func setTimeStepLimitScale(newScale:Float) {
        _timeStepLimitScale = max(newScale, 0.0)
    }
    
    /// Returns the SPH system data.
    func sphSystemData()->SphSystemData2 {
        return particleSystemData() as! SphSystemData2
    }
    
    //! Returns the number of sub-time-steps.
    override func numberOfSubTimeSteps(
        timeIntervalInSeconds:Double)->UInt {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        let f:ArrayAccessor1<Vector2F> = particles.forces()
        
        let kernelRadius = particles.kernelRadius()
        let mass = particles.mass()
        
        var maxForceMagnitude:Float = 0.0
        for i in 0..<numberOfParticles {
            maxForceMagnitude = max(maxForceMagnitude, length(f[i]))
        }
        
        let timeStepLimitBySpeed = kTimeStepLimitBySpeedFactor * kernelRadius / _speedOfSound
        let timeStepLimitByForce = kTimeStepLimitByForceFactor * sqrt(kernelRadius * mass / maxForceMagnitude)
        
        let desiredTimeStep = _timeStepLimitScale * min(timeStepLimitBySpeed, timeStepLimitByForce)
        
        return UInt(ceil(timeIntervalInSeconds / Double(desiredTimeStep)))
    }
    
    //! Accumulates the force to the forces array in the particle system.
    override func accumulateForces(timeStepInSeconds:Double) {
        accumulateNonPressureForces(timeStepInSeconds: timeStepInSeconds)
        accumulatePressureForce(timeStepInSeconds: timeStepInSeconds)
    }
    
    //! Performs pre-processing step before the simulation.
    override func onBeginAdvanceTimeStep(timeStepInSeconds:Double) {
        let particles = sphSystemData()
        
        let timer = Date()
        particles.buildNeighborSearcher()
        particles.buildNeighborLists()
        if Renderer.arch == .GPU {
            particles.buildNeighborListsBuffer()
        }
        particles.updateDensities()
        
        logger.info("Building neighbor lists and updating densities took \(Date().timeIntervalSince(timer)) seconds)")
    }
    
    //! Performs post-processing step before the simulation.
    override func onEndAdvanceTimeStep(timeStepInSeconds:Double) {
        if Renderer.arch == .CPU {
            computePseudoViscosity(timeStepInSeconds: timeStepInSeconds)
        } else {
            computePseudoViscosity_GPU(timeStepInSeconds: timeStepInSeconds)
        }
        
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        let densities:ArrayAccessor1<Float> = particles.densities()
        
        var maxDensity:Float = 0.0
        for i in 0..<numberOfParticles {
            maxDensity = max(maxDensity, densities[i])
        }
        
        logger.info("Max density: \(maxDensity) Max density / target density ratio: \(maxDensity / particles.targetDensity())")
    }
    
    //! Accumulates the non-pressure forces to the forces array in the particle
    //! system.
    func accumulateNonPressureForces(timeStepInSeconds:Double) {
        super.accumulateForces(timeStepInSeconds: timeStepInSeconds)
        if Renderer.arch == .CPU {
            accumulateViscosityForce()
        } else {
            accumulateViscosityForce_GPU()
        }
    }
    
    //! Accumulates the pressure force to the forces array in the particle
    //! system.
    func accumulatePressureForce(timeStepInSeconds:Double) {
        if Renderer.arch == .CPU {
            let particles = sphSystemData()
            let x:ConstArrayAccessor1<Vector2F> = particles.positions()
            let d:ConstArrayAccessor1<Float> = particles.densities()
            let p:ConstArrayAccessor1<Float> = particles.pressures()
            var f:ArrayAccessor1<Vector2F> = particles.forces()
            
            computePressure()
            accumulatePressureForce(positions: x, densities: d,
                                    pressures: p, pressureForces: &f)
        } else {
            computePressure_GPU()
            accumulatePressureForce_GPU()
        }
    }
    
    //! Computes the pressure.
    func computePressure() {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        let d:ConstArrayAccessor1<Float> = particles.densities()
        var p:ArrayAccessor1<Float> = particles.pressures()
        
        // See Equation 9 from
        // http://cg.informatik.uni-freiburg.de/publications/2007_SCA_SPH.pdf
        let targetDensity = particles.targetDensity()
        let eosScale = targetDensity * Math.square(of: _speedOfSound) / _eosExponent
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            p[i] = computePressureFromEos(
                density: d[i],
                targetDensity: targetDensity,
                eosScale: eosScale,
                eosExponent: eosExponent(),
                negativePressureScale: negativePressureScale())
        }
    }
    
    //! Accumulates the pressure force to the given \p pressureForces array.
    func accumulatePressureForce(positions:ConstArrayAccessor1<Vector2F>,
                                 densities:ConstArrayAccessor1<Float>,
                                 pressures:ConstArrayAccessor1<Float>,
                                 pressureForces: inout ArrayAccessor1<Vector2F>) {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        
        let massSquared = Math.square(of: particles.mass())
        let kernel =  SphSpikyKernel2(kernelRadius: particles.kernelRadius())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            let neighbors = particles.neighborLists()[i]
            for j in neighbors {
                let dist = length(positions[i] - positions[j])
                
                if (dist > 0.0) {
                    let dir = (positions[j] - positions[i]) / dist
                    let para = massSquared * (pressures[i] / (densities[i] * densities[i])
                        + pressures[j] / (densities[j] * densities[j]))
                    pressureForces[i] -= para * kernel.gradient(distance: dist, direction: dir)
                }
            }
        }
    }
    
    //! Accumulates the viscosity force to the forces array in the particle
    //! system.
    func accumulateViscosityForce() {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        let x:ConstArrayAccessor1<Vector2F> = particles.positions()
        let v:ArrayAccessor1<Vector2F> = particles.velocities()
        let d:ConstArrayAccessor1<Float> = particles.densities()
        var f:ArrayAccessor1<Vector2F> = particles.forces()
        
        let massSquared = Math.square(of: particles.mass())
        let kernel =  SphSpikyKernel2(kernelRadius: particles.kernelRadius())
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            let neighbors = particles.neighborLists()[i]
            for j in neighbors {
                let dist = length(x[i] - x[j])
                let para = viscosityCoefficient() * massSquared * (v[j] - v[i]) / d[j]
                f[i] += para * kernel.secondDerivative(distance: dist)
            }
        }
    }
    
    //! Computes pseudo viscosity.
    func computePseudoViscosity(timeStepInSeconds:Double) {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        let x:ArrayAccessor1<Vector2F> = particles.positions()
        var v:ArrayAccessor1<Vector2F> = particles.velocities()
        let d:ArrayAccessor1<Float> = particles.densities()
        
        let mass = particles.mass()
        let kernel =  SphSpikyKernel2(kernelRadius: particles.kernelRadius())
        
        var smoothedVelocities = Array1<Vector2F>(size: numberOfParticles)
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            var weightSum:Float = 0.0
            var smoothedVelocity = Vector2F()
            
            let neighbors = particles.neighborLists()[i]
            for j in neighbors {
                let dist = length(x[i] - x[j])
                let wj = mass / d[j] * kernel[dist]
                weightSum += wj
                smoothedVelocity += wj * v[j]
            }
            
            let wi = mass / d[i]
            weightSum += wi
            smoothedVelocity += wi * v[i]
            
            if (weightSum > 0.0) {
                smoothedVelocity /= weightSum
            }
            
            smoothedVelocities[i] = smoothedVelocity
        }
        
        var factor = Float(timeStepInSeconds) * _pseudoViscosityCoefficient
        factor = Math.clamp(val: factor, low: 0.0, high: 1.0)
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            v[i] = Math.lerp(value0: v[i], value1: smoothedVelocities[i], f: factor)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create SphSolver2 objects step by step.
    class Builder: SphSolverBuilderBase2<Builder> {
        /// Builds SphSolver2.
        func build()->SphSolver2 {
            return SphSolver2(targetDensity: _targetDensity,
                              targetSpacing: _targetSpacing,
                              relativeKernelRadius: _relativeKernelRadius)
        }
    }
    
    /// Returns builder fox SphSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

/// Base class for SPH-based fluid solver builder.
class SphSolverBuilderBase2<DerivedBuilder> {
    var _targetDensity:Float = kWaterDensity
    var _targetSpacing:Float = 0.1
    var _relativeKernelRadius:Float = 1.8
    
    /// Returns builder with target density.
    func withTargetDensity(targetDensity:Float)->DerivedBuilder {
        _targetDensity = targetDensity
        return self as! DerivedBuilder
    }
    
    /// Returns builder with target spacing.
    func withTargetSpacing(targetSpacing:Float)->DerivedBuilder {
        _targetSpacing = targetSpacing
        return self as! DerivedBuilder
    }
    
    /// Returns builder with relative kernel radius.
    func withRelativeKernelRadius(relativeKernelRadius:Float)->DerivedBuilder {
        _relativeKernelRadius = relativeKernelRadius
        return self as! DerivedBuilder
    }
}

//MARK:- GPU Method
extension SphSolver2 {
    func computePressure_GPU() {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        // See Equation 9 from
        // http://cg.informatik.uni-freiburg.de/publications/2007_SCA_SPH.pdf
        var targetDensity = particles.targetDensity()
        var eosScale = targetDensity * Math.square(of: _speedOfSound) / _eosExponent
        var eosExp = eosExponent()
        var negativeP = negativePressureScale()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "SphSolver2::computePressure") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.densities(encoder: &encoder, index_begin: index)
                        index = particles.pressures(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&targetDensity, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&eosScale, length: MemoryLayout<Float>.stride, index: index+1)
                        encoder.setBytes(&eosExp, length: MemoryLayout<Float>.stride, index: index+2)
                        encoder.setBytes(&negativeP, length: MemoryLayout<Float>.stride, index: index+3)
        }
    }
    
    func accumulatePressureForce_GPU() {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        var massSquared = Math.square(of: particles.mass())
        var radius = particles.kernelRadius()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "SphSolver2::accumulatePressureForce") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.positions(encoder: &encoder, index_begin: index)
                        index = particles.densities(encoder: &encoder, index_begin: index)
                        index = particles.pressures(encoder: &encoder, index_begin: index)
                        index = particles.forces(encoder: &encoder, index_begin: index)
                        index = particles.loadNeighborLists(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&massSquared, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&radius, length: MemoryLayout<Float>.stride, index: index+1)
        }
    }
    
    func accumulateViscosityForce_GPU() {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        var massSquared = Math.square(of: particles.mass())
        var radius = particles.kernelRadius()
        var visCoeff = viscosityCoefficient()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "SphSolver2::accumulateViscosityForce") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.positions(encoder: &encoder, index_begin: index)
                        index = particles.velocities(encoder: &encoder, index_begin: index)
                        index = particles.densities(encoder: &encoder, index_begin: index)
                        index = particles.forces(encoder: &encoder, index_begin: index)
                        index = particles.loadNeighborLists(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&massSquared, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&radius, length: MemoryLayout<Float>.stride, index: index+1)
                        encoder.setBytes(&visCoeff, length: MemoryLayout<Float>.stride, index: index+2)
        }
    }
    
    func computePseudoViscosity_GPU(timeStepInSeconds:Double) {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        
        var mass = particles.mass()
        var radius = particles.kernelRadius()
        var factor = Float(timeStepInSeconds) * _pseudoViscosityCoefficient
        factor = Math.clamp(val: factor, low: 0.0, high: 1.0)
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "SphSolver2::computePseudoViscosity") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.positions(encoder: &encoder, index_begin: index)
                        index = particles.velocities(encoder: &encoder, index_begin: index)
                        index = particles.densities(encoder: &encoder, index_begin: index)
                        index = particles.loadNeighborLists(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: index)
                        encoder.setBytes(&radius, length: MemoryLayout<Float>.stride, index: index+1)
                        encoder.setBytes(&factor, length: MemoryLayout<Float>.stride, index: index+2)
        }
        

    }
}
