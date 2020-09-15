//
//  collider3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Internal query result structure.
struct ColliderQueryResult3 {
    var distance:Float = 0
    var point:Vector3F = Vector3F()
    var normal:Vector3F = Vector3F()
    var velocity:Vector3F = Vector3F()
}

/// Abstract base class for generic collider object.
///
/// This class contains basic interfaces for colliders. Most of the
/// functionalities are implemented within this class, except the member
/// function Collider3::velocityAt. This class also let the subclasses to
/// provide a Surface3 instance to define collider surface using
/// Collider3::setSurface function.
protocol Collider3 : class{
    /// Callback function type for update calls.
    ///
    /// This type of callback function will take the collider pointer, current
    /// time, and time interval in seconds.
    typealias OnBeginUpdateCallback = (Collider3, Double, Double)->Void
    
    var _surface:Surface3? { get set }
    var _frictionCoeffient:Float { get set }
    var _onUpdateCallback:OnBeginUpdateCallback? { get set }
    
    /// Returns the velocity of the collider at given \p point.
    func velocityAt(point:Vector3F)->Vector3F
    
    /// Resolves collision for given point.
    /// - Parameters:
    ///   - radius: Radius of the colliding point.
    ///   - restitutionCoefficient:  Defines the restitution effect.
    ///   - position: Input and output position of the point.
    ///   - velocity: Input and output velocity of the point.
    func resolveCollision(radius:Float,
                          restitutionCoefficient:Float,
                          position:inout Vector3F,
                          velocity:inout Vector3F)
    
    /// Returns friction coefficent.
    func frictionCoefficient()->Float
    
    /// Sets the friction coefficient.
    ///
    /// This function assigns the friction coefficient to the collider. Any
    /// negative inputs will be clamped to zero.
    func setFrictionCoefficient(newFrictionCoeffient:Float)
    
    /// Returns the surface instance.
    func surface()->Surface3
    
    /// Assigns the surface instance from the subclass.
    func setSurface(newSurface:Surface3)
    
    /// Updates the collider state.
    func update(currentTimeInSeconds:Double,
                timeIntervalInSeconds:Double)
    
    /// Sets the callback function to be called when
    ///             Collider3::update function is invoked.
    ///
    /// The callback function takes current simulation time in seconds unit. Use
    /// this callback to track any motion or state changes related to this
    /// collider.
    /// - Parameter callback: The callback function.
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback)
    
    /// Outputs closest point's information.
    func getClosestPoint(surface:Surface3,
                         queryPoint:Vector3F,
                         result: inout ColliderQueryResult3)
    
    /// Returns true if given point is in the opposite side of the surface.
    func isPenetrating(colliderPoint:ColliderQueryResult3,
                       position:Vector3F,
                       radius:Float)->Bool
}

extension Collider3 {
    func resolveCollision(radius:Float,
                          restitutionCoefficient:Float,
                          position newPosition:inout Vector3F,
                          velocity newVelocity:inout Vector3F) {
        assert(_surface != nil)
        
        if (!_surface!.isValidGeometry()) {
            return
        }
        
        var colliderPoint = ColliderQueryResult3()
        
        getClosestPoint(surface: _surface!, queryPoint: newPosition, result: &colliderPoint)
        
        // Check if the new position is penetrating the surface
        if (isPenetrating(colliderPoint: colliderPoint, position: newPosition, radius: radius)) {
            // Target point is the closest non-penetrating position from the
            // new position.
            let targetNormal = colliderPoint.normal
            let targetPoint = colliderPoint.point + radius * targetNormal
            let colliderVelAtTargetPoint = colliderPoint.velocity
            
            // Get new candidate relative velocity from the target point.
            let relativeVel = newVelocity - colliderVelAtTargetPoint
            let normalDotRelativeVel = dot(targetNormal, relativeVel)
            var relativeVelN = normalDotRelativeVel * targetNormal
            var relativeVelT = relativeVel - relativeVelN
            
            // Check if the velocity is facing opposite direction of the surface
            // normal
            if (normalDotRelativeVel < 0.0) {
                // Apply restitution coefficient to the surface normal component of
                // the velocity
                let deltaRelativeVelN =
                    (-restitutionCoefficient - 1.0) * relativeVelN
                relativeVelN *= -restitutionCoefficient
                
                // Apply friction to the tangential component of the velocity
                // From Bridson et al., Robust Treatment of Collisions, Contact and
                // Friction for Cloth Animation, 3003
                // http://graphics.stanford.edu/papers/cloth-sig03/cloth.pdf
                if (length_squared(relativeVelT) > 0.0) {
                    let frictionScale = max(
                        1.0 - _frictionCoeffient * length(deltaRelativeVelN) /
                            length(relativeVelT),
                        0.0)
                    relativeVelT *= frictionScale
                }
                
                // Reassemble the components
                newVelocity =
                    relativeVelN + relativeVelT + colliderVelAtTargetPoint
            }
            
            // Geometric fix
            newPosition = targetPoint
        }
    }
    
    func frictionCoefficient()->Float {
        return _frictionCoeffient
    }
    
    func setFrictionCoefficient(newFrictionCoeffient:Float) {
        _frictionCoeffient = max(newFrictionCoeffient, 0.0)
    }
    
    func surface()->Surface3 {
        return _surface!
    }
    
    func setSurface(newSurface:Surface3) {
        _surface = newSurface
    }
    
    func getClosestPoint(surface:Surface3,
                         queryPoint:Vector3F,
                         result: inout ColliderQueryResult3) {
        result.distance = surface.closestDistance(otherPoint: queryPoint)
        result.point = surface.closestPoint(otherPoint: queryPoint)
        result.normal = surface.closestNormal(otherPoint: queryPoint)
        result.velocity = velocityAt(point: queryPoint)
    }
    
    func isPenetrating(colliderPoint:ColliderQueryResult3,
                       position:Vector3F,
                       radius:Float)->Bool {
        // If the new candidate position of the particle is inside
        // the volume defined by the surface OR the new distance to the surface is
        // less than the particle's radius, this particle is in colliding state.
        return _surface!.isInside(otherPoint: position) || colliderPoint.distance < radius
    }
    
    func update(currentTimeInSeconds:Double,
                timeIntervalInSeconds:Double) {
        assert(_surface != nil)
        
        if (!_surface!.isValidGeometry()) {
            return
        }
        
        _surface!.updateQueryEngine()
        
        if (_onUpdateCallback != nil) {
            _onUpdateCallback!(self, currentTimeInSeconds, timeIntervalInSeconds)
        }
    }
    
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback) {
         _onUpdateCallback = callback
    }
}
