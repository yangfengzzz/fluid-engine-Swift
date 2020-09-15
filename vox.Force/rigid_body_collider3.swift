//
//  rigid_body_collider3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/8/9.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D rigid body collider class.
///
/// This class implements 3-D rigid body collider. The collider can only take
/// rigid body motion with linear and rotational velocities.
class RigidBodyCollider3: Collider3 {
    var _surface: Surface3?
    var _frictionCoeffient: Float = 0.0
    var _onUpdateCallback: OnBeginUpdateCallback?
    
    /// Linear velocity of the rigid body.
    var linearVelocity = Vector3F()
    /// Angular velocity of the rigid body.
    var angularVelocity = Vector3F()
    
    /// Constructs a collider with a surface.
    init(surface:Surface3) {
        setSurface(newSurface: surface)
    }
    
    /// Constructs a collider with a surface and other parameters.
    init(surface:Surface3,
         linearVelocity linearVelocity_:Vector3F,
         angularVelocity angularVelocity_:Vector3F) {
        self.linearVelocity = linearVelocity_
        self.angularVelocity = angularVelocity_
        setSurface(newSurface: surface)
    }
    
    /// Returns the velocity of the collider at given \p point.
    func velocityAt(point:Vector3F)->Vector3F {
        let r = point - surface().transform.translation
        return linearVelocity + cross(angularVelocity, r)
    }
    
    //MARK:- Builder
    /// Front-end to create RigidBodyCollider3 objects step by step.
    class Builder {
        var _surface:Surface3?
        var _linearVelocity = Vector3F(0, 0, 0)
        var _angularVelocity = Vector3F(0, 0, 0)
        
        /// Returns builder with surface.
        func withSurface(surface:Surface3)->Builder {
            _surface = surface
            return self
        }
        
        /// Returns builder with linear velocity.
        func withLinearVelocity(linearVelocity:Vector3F)->Builder {
            _linearVelocity = linearVelocity
            return self
        }
        
        /// Returns builder with angular velocity.
        func withAngularVelocity(angularVelocity:Vector3F)->Builder {
            _angularVelocity = angularVelocity
            return self
        }
        
        /// Builds RigidBodyCollider3.
        func build()->RigidBodyCollider3 {
            return RigidBodyCollider3(
                surface: _surface!,
                linearVelocity: _linearVelocity,
                angularVelocity: _angularVelocity)
        }
    }
    
    /// Returns builder fox RigidBodyCollider3.
    static func builder()->Builder{
        return Builder()
    }
}
