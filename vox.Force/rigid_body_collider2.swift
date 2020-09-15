//
//  rigid_body_collider2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D rigid body collider class.
///
/// This class implements 2-D rigid body collider. The collider can only take
/// rigid body motion with linear and rotational velocities.
class RigidBodyCollider2: Collider2 {
    var _surface: Surface2?
    var _frictionCoeffient: Float = 0.0
    var _onUpdateCallback: OnBeginUpdateCallback?
    
    /// Linear velocity of the rigid body.
    var linearVelocity = Vector2F()
    /// Angular velocity of the rigid body.
    var angularVelocity:Float = 0.0
    
    /// Constructs a collider with a surface.
    init(surface:Surface2) {
        setSurface(newSurface: surface)
    }
    
    /// Constructs a collider with a surface and other parameters.
    init(surface:Surface2,
         linearVelocity linearVelocity_:Vector2F,
         angularVelocity angularVelocity_:Float) {
        self.linearVelocity = linearVelocity_
        self.angularVelocity = angularVelocity_
        setSurface(newSurface: surface)
    }
    
    /// Returns the velocity of the collider at given \p point.
    func velocityAt(point:Vector2F)->Vector2F {
        let r = point - surface().transform.translation
        return linearVelocity + angularVelocity * Vector2F(-r.y, r.x)
    }
    
    //MARK:- Builder
    /// Front-end to create RigidBodyCollider2 objects step by step.
    class Builder {
        var _surface:Surface2?
        var _linearVelocity = Vector2F(0, 0)
        var _angularVelocity:Float = 0.0
        
        /// Returns builder with surface.
        func withSurface(surface:Surface2)->Builder {
            _surface = surface
            return self
        }
        
        /// Returns builder with linear velocity.
        func withLinearVelocity(linearVelocity:Vector2F)->Builder {
            _linearVelocity = linearVelocity
            return self
        }
        
        /// Returns builder with angular velocity.
        func withAngularVelocity(angularVelocity:Float)->Builder {
            _angularVelocity = angularVelocity
            return self
        }
        
        /// Builds RigidBodyCollider2.
        func build()->RigidBodyCollider2 {
            return RigidBodyCollider2(
                surface: _surface!,
                linearVelocity: _linearVelocity,
                angularVelocity: _angularVelocity)
        }
    }
    
    /// Returns builder fox RigidBodyCollider2.
    static func builder()->Builder{
        return Builder()
    }
}
