//
//  pci_sph_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D PCISPH solver.
///
/// This class implements 3-D predictive-corrective SPH solver. The main
/// pressure solver is based on Solenthaler and Pajarola's 2009 SIGGRAPH paper.
///
/// Solenthaler and Pajarola, Predictive-corrective incompressible SPH,
/// ACM transactions on graphics (TOG). Vol. 28. No. 3. ACM, 2009.
class PciSphSolver3: SphSolver3 {
    var _maxDensityErrorRatio:Float = 0.01
    var _maxNumberOfIterations:UInt = 5
    
    var _tempPositions = ParticleSystemData3.VectorData()
    var _tempVelocities = ParticleSystemData3.VectorData()
    var _pressureForces = ParticleSystemData3.VectorData()
    var _densityErrors = ParticleSystemData3.ScalarData()
    
    // Constructs a solver with empty particle set.
    override init() {
        super.init()
        setTimeStepLimitScale(newScale: kDefaultTimeStepLimitScale)
    }
    
    /// Constructs a solver with target density, spacing, and relative kernel radius.
    override init(targetDensity:Float,
                  targetSpacing:Float,
                  relativeKernelRadius:Float) {
        super.init(targetDensity: targetDensity,
                   targetSpacing: targetSpacing,
                   relativeKernelRadius: relativeKernelRadius)
        setTimeStepLimitScale(newScale: kDefaultTimeStepLimitScale)
    }
    
    /// Returns max allowed density error ratio.
    func maxDensityErrorRatio()->Float {
        return _maxDensityErrorRatio
    }
    
    /// Sets max allowed density error ratio.
    ///
    /// This function sets the max allowed density error ratio during the PCISPH
    /// iteration. Default is 0.01 (1%). The input value should be positive.
    func setMaxDensityErrorRatio(ratio:Float) {
        _maxDensityErrorRatio = max(ratio, 0.0)
    }
    
    /// Returns max number of iterations.
    func maxNumberOfIterations()->UInt {
        return _maxNumberOfIterations
    }
    
    /// Sets max number of PCISPH iterations.
    ///
    /// This function sets the max number of PCISPH iterations. Default is 5.
    func setMaxNumberOfIterations(n:UInt) {
        _maxNumberOfIterations = n
    }
    
    /// Accumulates the pressure force to the forces array in the particle
    /// system.
    override func accumulatePressureForce(timeStepInSeconds timeIntervalInSeconds:Double) {
        if Renderer.arch == .GPU {
            accumulatePressureForce_GPU(timeStepInSeconds: timeIntervalInSeconds)
        } else {
            let particles = sphSystemData()
            let numberOfParticles = particles.numberOfParticles()
            let delta = computeDelta(timeStepInSeconds: timeIntervalInSeconds)
            let targetDensity = particles.targetDensity()
            let mass = particles.mass()
            
            var p:ArrayAccessor1<Float> = particles.pressures()
            let d:ArrayAccessor1<Float> = particles.densities()
            let x:ConstArrayAccessor1<Vector3F> = particles.positions()
            let v:ArrayAccessor1<Vector3F> = particles.velocities()
            var f:ArrayAccessor1<Vector3F> = particles.forces()
            
            // Predicted density ds
            var ds = Array1<Float>(size: numberOfParticles, initVal: 0.0)
            
            let kernel = SphStdKernel3(kernelRadius: particles.kernelRadius())
            
            // Initialize buffers
            parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                p[i] = 0.0
                _pressureForces[i] = Vector3F()
                _densityErrors[i] = 0.0
                ds[i] = d[i]
            }
            
            var maxNumIter:UInt = 0
            var maxDensityError:Float = 0.0
            var densityErrorRatio:Float = 0.0
            
            for k in 0..<_maxNumberOfIterations {
                // Predict velocity and position
                parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                    _tempVelocities[i]
                        = v[i]
                        + Float(timeIntervalInSeconds) / mass
                        * (f[i] + _pressureForces[i])
                    _tempPositions[i]
                        = x[i] + Float(timeIntervalInSeconds) * _tempVelocities[i]
                }
                
                // Resolve collisions
                var tempP = _tempPositions.accessor()
                var tempV = _tempVelocities.accessor()
                super.resolveCollision(newPositions: &tempP,
                                       newVelocities: &tempV)
                
                // Compute pressure from density error
                parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                    var weightSum:Float = 0.0
                    let neighbors = particles.neighborLists()[i]
                    
                    for j in neighbors {
                        let dist = length(_tempPositions[j] - _tempPositions[i])
                        weightSum += kernel[dist]
                    }
                    weightSum += kernel[0]
                    
                    let density = mass * weightSum
                    var densityError = (density - targetDensity)
                    var pressure = delta * densityError
                    
                    if (pressure < 0.0) {
                        pressure *= negativePressureScale()
                        densityError *= negativePressureScale()
                    }
                    
                    p[i] += pressure
                    ds[i] = density
                    _densityErrors[i] = densityError
                }
                
                // Compute pressure gradient force
                _pressureForces.set(value: Vector3F())
                var pForce = _pressureForces.accessor()
                super.accumulatePressureForce(positions: x,
                                              densities: ds.constAccessor(),
                                              pressures: ConstArrayAccessor1<Float>(other: p),
                                              pressureForces: &pForce)
                
                // Compute max density error
                maxDensityError = 0.0
                for i in 0..<numberOfParticles {
                    maxDensityError = Math.absmax(between: maxDensityError,
                                                  and: _densityErrors[i])
                }
                
                densityErrorRatio = maxDensityError / targetDensity
                maxNumIter = k + 1
                
                if (abs(densityErrorRatio) < _maxDensityErrorRatio) {
                    break
                }
            }
            
            logger.info("Number of PCI iterations: \(maxNumIter)")
            logger.info("Max density error after PCI iteration: \(maxDensityError)")
            if (abs(densityErrorRatio) > _maxDensityErrorRatio) {
                logger.warning("Max density error ratio is greater than the threshold!")
                logger.warning("Ratio: \(densityErrorRatio) Threshold: \(_maxDensityErrorRatio)")
            }
            
            // Accumulate pressure force
            parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                f[i] += _pressureForces[i]
            }
        }
    }
    
    /// Performs pre-processing step before the simulation.
    override func onBeginAdvanceTimeStep(timeStepInSeconds:Double) {
        super.onBeginAdvanceTimeStep(timeStepInSeconds: timeStepInSeconds)
        
        // Allocate temp buffers
        let numberOfParticles = particleSystemData().numberOfParticles()
        _tempPositions.resize(size: numberOfParticles)
        _tempVelocities.resize(size: numberOfParticles)
        _pressureForces.resize(size: numberOfParticles)
        _densityErrors.resize(size: numberOfParticles)
    }
    
    func computeDelta(timeStepInSeconds:Double)->Float {
        let particles = sphSystemData()
        let kernelRadius = particles.kernelRadius()
        
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let origin = Vector3F()
        var sampleBound = BoundingBox3F(point1: origin, point2: origin)
        sampleBound.expand(delta: 1.5 * kernelRadius)
        
        pointsGenerator.generate(boundingBox: sampleBound,
                                 spacing: particles.targetSpacing(),
                                 points: &points)
        
        let kernel = SphSpikyKernel3(kernelRadius: kernelRadius)
        
        var denom:Float = 0
        var denom1 = Vector3F()
        var denom3:Float = 0
        
        for i in 0..<points.size() {
            let point = points[i]
            let distanceSquared = length_squared(point)
            
            if (distanceSquared < kernelRadius * kernelRadius) {
                let distance = sqrt(distanceSquared)
                let direction = (distance > 0.0) ? point / distance : Vector3F()
                
                // grad(Wij)
                let gradWij = kernel.gradient(distance: distance,
                                              direction: direction)
                denom1 += gradWij
                denom3 += dot(gradWij, gradWij)
            }
        }
        
        denom += -dot(denom1, denom1) - denom3
        
        return (abs(denom) > 0.0) ?
            -1 / (computeBeta(timeStepInSeconds: timeStepInSeconds) * denom) : 0
    }
    
    func computeBeta(timeStepInSeconds:Double)->Float {
        let particles = sphSystemData()
        return 3.0 * Math.square(of: particles.mass() * Float(timeStepInSeconds)
            / particles.targetDensity())
    }
    
    //MARK:- Builder
    /// Front-end to create PciSphSolver3 objects step by step.
    class Builder: SphSolverBuilderBase3<Builder> {
        /// Builds PciSphSolver3.
        func build()->PciSphSolver3 {
            return PciSphSolver3(
                targetDensity: _targetDensity,
                targetSpacing: _targetSpacing,
                relativeKernelRadius: _relativeKernelRadius)
        }
    }
    
    /// Returns builder fox PciSphSolver3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension PciSphSolver3 {
    func accumulatePressureForce_GPU(timeStepInSeconds timeIntervalInSeconds:Double) {
        let particles = sphSystemData()
        let numberOfParticles = particles.numberOfParticles()
        var delta = computeDelta(timeStepInSeconds: timeIntervalInSeconds)
        var targetDensity = particles.targetDensity()
        var mass = particles.mass()
        var radius = particles.kernelRadius()
        var timeIntervalInSeconds:Float = Float(timeIntervalInSeconds)
        var negScale:Float = negativePressureScale()
        
        // Predicted density ds
        let ds = Array1<Float>(size: numberOfParticles, initVal: 0.0)
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "PciSphSolver3::accumulatePressureForce1") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.pressures(encoder: &encoder, index_begin: index)
                        index = _pressureForces.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = _densityErrors.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = ds.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        index = particles.densities(encoder: &encoder, index_begin: index)
        }
        
        var maxNumIter:UInt = 0
        var maxDensityError:Float = 0.0
        var densityErrorRatio:Float = 0.0
        
        for k in 0..<_maxNumberOfIterations {
            // Predict velocity and position
            parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                        name: "PciSphSolver3::accumulatePressureForce2") {
                            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                            index = _tempVelocities.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            index = particles.velocities(encoder: &encoder, index_begin: index)
                            index = particles.forces(encoder: &encoder, index_begin: index)
                            index = _pressureForces.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            index = _tempPositions.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            index = particles.positions(encoder: &encoder, index_begin: index)
                            encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index)
                            encoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: index+1)
            }
            
            // Resolve collisions
            var tempP = _tempPositions.accessor()
            var tempV = _tempVelocities.accessor()
            super.resolveCollision(newPositions: &tempP,
                                   newVelocities: &tempV)
            
            // Compute pressure from density error
            parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                        name: "PciSphSolver3::accumulatePressureForce3") {
                            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                            index = particles.loadNeighborLists(encoder: &encoder, index_begin: index)
                            index = _tempPositions.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            index = particles.pressures(encoder: &encoder, index_begin: index)
                            index = ds.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            index = _densityErrors.loadGPUBuffer(encoder: &encoder, index_begin: index)
                            encoder.setBytes(&radius, length: MemoryLayout<Float>.stride, index: index)
                            encoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: index+1)
                            encoder.setBytes(&targetDensity, length: MemoryLayout<Float>.stride, index: index+2)
                            encoder.setBytes(&delta, length: MemoryLayout<Float>.stride, index: index+3)
                            encoder.setBytes(&negScale, length: MemoryLayout<Float>.stride, index: index+4)
            }
            
            // Compute pressure gradient force
            _pressureForces.set(value: Vector3F())
            super.accumulatePressureForce_GPU()
            
            // Compute max density error
            maxDensityError = 0.0
            for i in 0..<numberOfParticles {
                maxDensityError = Math.absmax(between: maxDensityError,
                                              and: _densityErrors[i])
            }
            
            densityErrorRatio = maxDensityError / targetDensity
            maxNumIter = k + 1
            
            if (abs(densityErrorRatio) < _maxDensityErrorRatio) {
                break
            }
        }
        
        logger.info("Number of PCI iterations: \(maxNumIter)")
        logger.info("Max density error after PCI iteration: \(maxDensityError)")
        if (abs(densityErrorRatio) > _maxDensityErrorRatio) {
            logger.warning("Max density error ratio is greater than the threshold!")
            logger.warning("Ratio: \(densityErrorRatio) Threshold: \(_maxDensityErrorRatio)")
        }
        
        // Accumulate pressure force
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "PciSphSolver3::accumulatePressureForce4") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = particles.forces(encoder: &encoder, index_begin: index)
                        index = _pressureForces.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
    }
}
