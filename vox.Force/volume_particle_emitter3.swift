//
//  volume_particle_emitter3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/8/9.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D volumetric particle emitter.
///
/// This class emits particles from volumetric geometry.
class VolumeParticleEmitter3: ParticleEmitter3 {
    var _isEnabled: Bool = true
    var _particles: ParticleSystemData3?
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _implicitSurface:ImplicitSurface3?
    var _bounds:BoundingBox3F
    var _spacing:Float
    var _initialVel:Vector3F
    var _linearVel:Vector3F
    var _angularVel:Vector3F
    var _pointsGen:PointGenerator3
    
    var _maxNumberOfParticles:size_t = size_t.max
    var _numberOfEmittedParticles:size_t = 0
    
    var _jitter:Float = 0.0
    var _isOneShot:Bool = true
    var _allowOverlapping:Bool = false
    
    /// Constructs an emitter that spawns particles from given implicit surface
    /// which defines the volumetric geometry. Provided bounding box limits
    /// the particle generation region.
    /// - Parameters:
    ///   - implicitSurface:  The implicit surface.
    ///   - maxRegion: The max region.
    ///   - spacing: The spacing between particles.
    ///   - initialVel: The initial velocity of new particles.
    ///   - linearVel: The linear velocity of the emitter.
    ///   - angularVel: The angular velocity of the emitter.
    ///   - maxNumberOfParticles: The max number of particles to be emitted.
    ///   - jitter: The jitter amount between 0 and 1.
    ///   - isOneShot: True if emitter gets disabled after one shot.
    ///   - allowOverlapping: True if particles can be overlapped.
    init(
        implicitSurface:ImplicitSurface3,
        maxRegion:BoundingBox3F,
        spacing:Float,
        initialVel:Vector3F = Vector3F(),
        linearVel:Vector3F = Vector3F(),
        angularVel:Vector3F = Vector3F(),
        maxNumberOfParticles:size_t = size_t.max,
        jitter:Float = 0.0,
        isOneShot:Bool = true,
        allowOverlapping:Bool = false) {
        self._implicitSurface = implicitSurface
        self._bounds = maxRegion
        self._spacing = spacing
        self._initialVel = initialVel
        self._linearVel = linearVel
        self._angularVel = angularVel
        self._maxNumberOfParticles = maxNumberOfParticles
        self._jitter = jitter
        self._isOneShot = isOneShot
        self._allowOverlapping = allowOverlapping
        self._pointsGen = BccLatticePointGenerator()
    }
    
    /// Sets the point generator.
    ///
    /// This function sets the point generator that defines the pattern of the
    /// point distribution within the volume.
    /// - Parameter newPointsGen: The new points generator.
    func setPointGenerator(newPointsGen:PointGenerator3) {
        _pointsGen = newPointsGen
    }
    
    /// Returns source surface.
    func surface()->ImplicitSurface3 {
        return _implicitSurface!
    }
    
    /// Sets the source surface.
    func setSurface(newSurface:ImplicitSurface3) {
        _implicitSurface = newSurface
    }
    
    /// Returns max particle gen region.
    func maxRegion()->BoundingBox3F {
        return _bounds
    }
    
    /// Sets the max particle gen region.
    func setMaxRegion(newBox newMaxRegion:BoundingBox3F) {
        _bounds = newMaxRegion
    }
    
    /// Returns jitter amount.
    func jitter()->Float {
        return _jitter
    }
    
    /// Sets jitter amount between 0 and 1.
    func setJitter(newJitter:Float) {
        _jitter = Math.clamp(val: newJitter, low: 0.0, high: 1.0)
    }
    
    /// Returns true if particles should be emitted just once.
    func isOneShot()->Bool {
        return _isOneShot
    }
    
    /// Sets the flag to true if particles are emitted just once.
    ///
    /// If true is set, the emitter will generate particles only once even after
    /// multiple emit calls. If false, it will keep generating particles from
    /// the volumetric geometry. Default value is true.
    /// - Parameter newValue: True if particles should be emitted just once.
    func setIsOneShot(newValue:Bool) {
        _isOneShot = newValue
    }
    
    /// Returns trhe if particles can be overlapped.
    func allowOverlapping()->Bool {
        return _allowOverlapping
    }
    
    /// Sets the flag to true if particles can overlap each other.
    ///
    /// If true is set, the emitter will generate particles even if the new
    /// particles can find existing nearby particles within the particle
    /// spacing.
    /// - Parameter newValue: True if particles can be overlapped.
    func setAllowOverlapping(newValue:Bool) {
        _allowOverlapping = newValue
    }
    
    /// Returns max number of particles to be emitted.
    func maxNumberOfParticles()->size_t {
        return _maxNumberOfParticles
    }
    
    /// Sets the max number of particles to be emitted.
    func setMaxNumberOfParticles(newMaxNumberOfParticles:size_t) {
        _maxNumberOfParticles = newMaxNumberOfParticles
    }
    
    /// Returns the spacing between particles.
    func spacing()->Float {
        return _spacing
    }
    
    /// Sets the spacing between particles.
    func setSpacing(newSpacing:Float) {
        _spacing = newSpacing
    }
    
    /// Sets the initial velocity of the particles.
    func initialVelocity()->Vector3F {
        return _initialVel
    }
    
    /// Returns the initial velocity of the particles.
    func setInitialVelocity(newInitialVel:Vector3F) {
        _initialVel = newInitialVel
    }
    
    /// Returns the linear velocity of the emitter.
    func linearVelocity()->Vector3F {
        return _linearVel
    }
    
    /// Sets the linear velocity of the emitter.
    func setLinearVelocity(newLinearVel:Vector3F) {
        _linearVel = newLinearVel
    }
    
    /// Returns the angular velocity of the emitter.
    func angularVelocity()->Vector3F {
        return _angularVel
    }
    
    /// Sets the linear velocity of the emitter.
    func setAngularVelocity(newAngularVel:Vector3F) {
        _angularVel = newAngularVel
    }
    
    /// Emits particles to the particle system data.
    /// - Parameters:
    ///   - currentTimeInSeconds: Current simulation time.
    ///   - timeIntervalInSeconds: The time-step interval.
    func onUpdate(currentTimeInSeconds:Double,
                  timeIntervalInSeconds:Double) {
        let particles = target()
        
        if (particles == nil) {
            return
        }
        
        if (!isEnabled()) {
            return
        }
        
        var newPositions = Array1<Vector3F>()
        var newVelocities = Array1<Vector3F>()
        
        emit(particles: particles!,
             newPositions: &newPositions,
             newVelocities: &newVelocities)
        
        particles!.addParticles(newPositions: newPositions.constAccessor(),
                                newVelocities: newVelocities.constAccessor())
        
        if (_isOneShot) {
            setIsEnabled(enabled: false)
        }
    }
    
    func emit(particles:ParticleSystemData3,
              newPositions:inout Array1<Vector3F>,
              newVelocities:inout Array1<Vector3F>) {
        if (_implicitSurface == nil) {
            return
        }
        
        _implicitSurface!.updateQueryEngine()
        
        var region = _bounds
        if (_implicitSurface!.isBounded()) {
            let surfaceBBox = _implicitSurface!.boundingBox()
            region.lowerCorner = max(region.lowerCorner, surfaceBBox.lowerCorner)
            region.upperCorner = min(region.upperCorner, surfaceBBox.upperCorner)
        }
        
        // Reserving more space for jittering
        let j = jitter()
        let maxJitterDist = 0.5 * j * _spacing
        var numNewParticles:size_t = 0
        
        if (_allowOverlapping || _isOneShot) {
            _pointsGen.forEachPoint(boundingBox: region, spacing: _spacing){(point:Vector3F) in
                let randomDir = uniformSampleSphere(u1: random(), u2: random())
                let offset = maxJitterDist * randomDir
                let candidate = point + offset
                if (_implicitSurface!.signedDistance(otherPoint: candidate) <= 0.0) {
                    if (_numberOfEmittedParticles < _maxNumberOfParticles) {
                        let tmp = [candidate]
                        newPositions.append(other: tmp)
                        _numberOfEmittedParticles += 1
                        numNewParticles += 1
                    } else {
                        return false
                    }
                }
                
                return true
            }
        } else {
            // Use serial hash grid searcher for continuous update.
            let neighborSearcher = PointHashGridSearcher3 (
                resolution: Size3(kDefaultHashGridResolution,
                                  kDefaultHashGridResolution,
                                  kDefaultHashGridResolution),
                gridSpacing: 2.0 * _spacing)
            if (!_allowOverlapping) {
                neighborSearcher.build(points: particles.positions())
            }
            
            _pointsGen.forEachPoint(boundingBox: region, spacing: _spacing){(point:Vector3F) in
                let randomDir = uniformSampleSphere(u1: random(), u2: random())
                let offset = maxJitterDist * randomDir
                let candidate = point + offset
                if (_implicitSurface!.isInside(otherPoint: candidate) &&
                    (!_allowOverlapping &&
                        !neighborSearcher.hasNearbyPoint(origin: candidate, radius: _spacing))) {
                    if (_numberOfEmittedParticles < _maxNumberOfParticles) {
                        let tmp = [candidate]
                        newPositions.append(other: tmp)
                        neighborSearcher.add(point: candidate)
                        _numberOfEmittedParticles += 1
                        numNewParticles += 1
                    } else {
                        return false
                    }
                }
                
                return true
            }
        }
        
        logger.info("Number of newly generated particles: \(numNewParticles)")
        logger.info("Number of total generated particles: \(_numberOfEmittedParticles)")
        
        newVelocities.resize(size: newPositions.size())
        newVelocities.parallelForEachIndex(){(i:size_t) in
            newVelocities[i] = velocityAt(point: newPositions[i])
        }
    }
    
    func random()->Float {
        return Float.random(in: 0.0...1.0)
    }
    
    func velocityAt(point:Vector3F)->Vector3F {
        let r = point - _implicitSurface!.transform.translation
        return _linearVel + cross(_angularVel, r) + _initialVel
    }
    
    //MARK:- Builder
    /// Front-end to create VolumeParticleEmitter3 objects step by step.
    class Builder {
        var _implicitSurface:ImplicitSurface3?
        var _isBoundSet:Bool = false
        var _bounds = BoundingBox3F()
        var _spacing:Float = 0.1
        var _initialVel = Vector3F()
        var _linearVel = Vector3F()
        var _angularVel = Vector3F()
        var _maxNumberOfParticles:size_t = size_t.max
        var _jitter:Float = 0.0
        var _isOneShot:Bool = true
        var _allowOverlapping:Bool = false
        
        /// Returns builder with implicit surface defining volume shape.
        func withImplicitSurface(implicitSurface:ImplicitSurface3)->Builder {
            _implicitSurface = implicitSurface
            if (!_isBoundSet) {
                _bounds = _implicitSurface!.boundingBox()
            }
            return self
        }
        
        /// Returns builder with surface defining volume shape.
        func withSurface(surface:Surface3)->Builder {
            _implicitSurface = SurfaceToImplicit3(surface: surface)
            if (!_isBoundSet) {
                _bounds = surface.boundingBox()
            }
            return self
        }
        
        /// Returns builder with max region.
        func withMaxRegion(bounds:BoundingBox3F)->Builder {
            _bounds = bounds
            _isBoundSet = true
            return self
        }
        
        /// Returns builder with spacing.
        func withSpacing(spacing:Float)->Builder {
            _spacing = spacing
            return self
        }
        
        /// Returns builder with initial velocity.
        func withInitialVelocity(initialVel:Vector3F)->Builder {
            _initialVel = initialVel
            return self
        }
        
        /// Returns builder with linear velocity.
        func withLinearVelocity(linearVel:Vector3F)->Builder {
            _linearVel = linearVel
            return self
        }
        
        /// Returns builder with angular velocity.
        func withAngularVelocity(angularVel:Vector3F)->Builder {
            _angularVel = angularVel
            return self
        }
        
        /// Returns builder with max number of particles.
        func withMaxNumberOfParticles(maxNumberOfParticles:size_t)->Builder {
            _maxNumberOfParticles = maxNumberOfParticles
            return self
        }
        
        /// Returns builder with jitter amount.
        func withJitter(jitter:Float)->Builder {
            _jitter = jitter
            return self
        }
        
        /// Returns builder with one-shot flag.
        func withIsOneShot(isOneShot:Bool)->Builder {
            _isOneShot = isOneShot
            return self
        }
        
        /// Returns builder with overlapping flag.
        func withAllowOverlapping(allowOverlapping:Bool)->Builder {
            _allowOverlapping = allowOverlapping
            return self
        }
        
        /// Builds VolumeParticleEmitter3.
        func build()->VolumeParticleEmitter3 {
            return VolumeParticleEmitter3(implicitSurface: _implicitSurface!,
                                          maxRegion: _bounds, spacing: _spacing,
                                          initialVel: _initialVel,
                                          linearVel: _linearVel,
                                          angularVel: _angularVel,
                                          maxNumberOfParticles: _maxNumberOfParticles,
                                          jitter: _jitter, isOneShot: _isOneShot,
                                          allowOverlapping: _allowOverlapping)
        }
    }
    
    /// Returns builder fox VolumeParticleEmitter3.
    static func builder()->Builder{
        return Builder()
    }
}
