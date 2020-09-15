//
//  volume_particle_emitter2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D volumetric particle emitter.
///
/// This class emits particles from volumetric geometry.
class VolumeParticleEmitter2: ParticleEmitter2 {
    var _isEnabled: Bool = true
    var _particles: ParticleSystemData2?
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _implicitSurface:ImplicitSurface2?
    var _bounds:BoundingBox2F
    var _spacing:Float
    var _initialVel:Vector2F
    var _linearVel:Vector2F
    var _angularVel:Float = 0.0
    var _pointsGen:PointGenerator2
    
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
        implicitSurface:ImplicitSurface2,
        maxRegion:BoundingBox2F,
        spacing:Float,
        initialVel:Vector2F = Vector2F(),
        linearVel:Vector2F = Vector2F(),
        angularVel:Float = 0.0,
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
        self._pointsGen = TrianglePointGenerator()
    }
    
    /// Sets the point generator.
    ///
    /// This function sets the point generator that defines the pattern of the
    /// point distribution within the volume.
    /// - Parameter newPointsGen: The new points generator.
    func setPointGenerator(newPointsGen:PointGenerator2) {
        _pointsGen = newPointsGen
    }
    
    /// Returns source surface.
    func surface()->ImplicitSurface2 {
        return _implicitSurface!
    }
    
    /// Sets the source surface.
    func setSurface(newSurface:ImplicitSurface2) {
        _implicitSurface = newSurface
    }
    
    /// Returns max particle gen region.
    func maxRegion()->BoundingBox2F {
        return _bounds
    }
    
    /// Sets the max particle gen region.
    func setMaxRegion(newBox newMaxRegion:BoundingBox2F) {
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
    func initialVelocity()->Vector2F {
        return _initialVel
    }
    
    /// Returns the initial velocity of the particles.
    func setInitialVelocity(newInitialVel:Vector2F) {
        _initialVel = newInitialVel
    }
    
    /// Returns the linear velocity of the emitter.
    func linearVelocity()->Vector2F {
        return _linearVel
    }
    
    /// Sets the linear velocity of the emitter.
    func setLinearVelocity(newLinearVel:Vector2F) {
        _linearVel = newLinearVel
    }
    
    /// Returns the angular velocity of the emitter.
    func angularVelocity()->Float {
        return _angularVel
    }
    
    /// Sets the linear velocity of the emitter.
    func setAngularVelocity(newAngularVel:Float) {
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
        
        var newPositions = Array1<Vector2F>()
        var newVelocities = Array1<Vector2F>()
        
        emit(particles: particles!,
             newPositions: &newPositions,
             newVelocities: &newVelocities)
        
        particles!.addParticles(newPositions: newPositions.constAccessor(),
                                newVelocities: newVelocities.constAccessor())
        
        if (_isOneShot) {
            setIsEnabled(enabled: false)
        }
    }
    
    func emit(particles:ParticleSystemData2,
              newPositions:inout Array1<Vector2F>,
              newVelocities:inout Array1<Vector2F>) {
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
            _pointsGen.forEachPoint(boundingBox: region, spacing: _spacing){(point:Vector2F) in
                let newAngleInRadian = (random() - 0.5) * kTwoPiF
                let rotationMatrix = matrix_float2x2.makeRotationMatrix(rad: newAngleInRadian)
                let randomDir = rotationMatrix * Vector2F()
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
            let neighborSearcher = PointHashGridSearcher2 (
                resolution: Size2(kDefaultHashGridResolution, kDefaultHashGridResolution),
                gridSpacing: 2.0 * _spacing)
            if (!_allowOverlapping) {
                neighborSearcher.build(points: particles.positions())
            }
            
            _pointsGen.forEachPoint(boundingBox: region, spacing: _spacing){(point:Vector2F) in
                let newAngleInRadian = (random() - 0.5) * kTwoPiF
                let rotationMatrix = matrix_float2x2.makeRotationMatrix(rad: newAngleInRadian)
                let randomDir = rotationMatrix * Vector2F()
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
    
    func velocityAt(point:Vector2F)->Vector2F {
        let r = point - _implicitSurface!.transform.translation
        return _linearVel + _angularVel * Vector2F(-r.y, r.x) + _initialVel
    }
    
    //MARK:- Builder
    /// Front-end to create VolumeParticleEmitter2 objects step by step.
    class Builder {
        var _implicitSurface:ImplicitSurface2?
        var _isBoundSet:Bool = false
        var _bounds = BoundingBox2F()
        var _spacing:Float = 0.1
        var _initialVel = Vector2F()
        var _linearVel = Vector2F()
        var _angularVel:Float = 0.0
        var _maxNumberOfParticles:size_t = size_t.max
        var _jitter:Float = 0.0
        var _isOneShot:Bool = true
        var _allowOverlapping:Bool = false
        
        /// Returns builder with implicit surface defining volume shape.
        func withImplicitSurface(implicitSurface:ImplicitSurface2)->Builder {
            _implicitSurface = implicitSurface
            if (!_isBoundSet) {
                _bounds = _implicitSurface!.boundingBox()
            }
            return self
        }
        
        /// Returns builder with surface defining volume shape.
        func withSurface(surface:Surface2)->Builder {
            _implicitSurface = SurfaceToImplicit2(surface: surface)
            if (!_isBoundSet) {
                _bounds = surface.boundingBox()
            }
            return self
        }
        
        /// Returns builder with max region.
        func withMaxRegion(bounds:BoundingBox2F)->Builder {
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
        func withInitialVelocity(initialVel:Vector2F)->Builder {
            _initialVel = initialVel
            return self
        }
        
        /// Returns builder with linear velocity.
        func withLinearVelocity(linearVel:Vector2F)->Builder {
            _linearVel = linearVel
            return self
        }
        
        /// Returns builder with angular velocity.
        func withAngularVelocity(angularVel:Float)->Builder {
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
        
        /// Builds VolumeParticleEmitter2.
        func build()->VolumeParticleEmitter2 {
            return VolumeParticleEmitter2(implicitSurface: _implicitSurface!,
                                          maxRegion: _bounds, spacing: _spacing,
                                          initialVel: _initialVel,
                                          linearVel: _linearVel,
                                          angularVel: _angularVel,
                                          maxNumberOfParticles: _maxNumberOfParticles,
                                          jitter: _jitter, isOneShot: _isOneShot,
                                          allowOverlapping: _allowOverlapping)
        }
    }
    
    /// Returns builder fox VolumeParticleEmitter2.
    static func builder()->Builder{
        return Builder()
    }
}
