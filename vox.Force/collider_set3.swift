//
//  collider_set3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Collection of 3-D colliders
class ColliderSet3: Collider3 {
    var _surface: Surface3?
    var _frictionCoeffient: Float = 0
    var _onUpdateCallback: OnBeginUpdateCallback?
    
    var _colliders:[Collider3] = []
    
    /// Default constructor.
    convenience init() {
        self.init(others: [])
    }
    
    /// Constructs with other colliders.
    init(others:[Collider3]) {
        setSurface(newSurface: SurfaceSet3())
        for collider in others {
            addCollider(collider: collider)
        }
    }
    
    /// Returns the velocity of the collider at given \p point.
    func velocityAt(point:Vector3F)->Vector3F {
        var closestCollider = size_t.max
        var closestDist:Float = Float.greatestFiniteMagnitude
        for i in 0..<_colliders.count {
            let dist = _colliders[i].surface().closestDistance(otherPoint: point)
            if (dist < closestDist) {
                closestDist = dist
                closestCollider = i
            }
        }
        if (closestCollider != size_t.max) {
            return _colliders[closestCollider].velocityAt(point: point)
        } else {
            return Vector3F()
        }
    }
    
    /// Adds a collider to the set.
    func addCollider(collider:Collider3) {
        let surfaceSet = surface() as! SurfaceSet3
        _colliders.append(collider)
        surfaceSet.addSurface(surface: collider.surface())
    }
    
    /// Returns number of colliders.
    func numberOfColliders()->size_t {
        return _colliders.count
    }
    
    /// Returns collider at index \p i.
    func collider(i:size_t)->Collider3 {
        return _colliders[i]
    }
    
    //MARK:- Builder
    /// Front-end to create ColliderSet3 objects step by step.
    class Builder {
        var _colliders:[Collider3] = []
        //! Returns builder with other colliders.
        func withColliders(others:[Collider3])->Builder {
            _colliders = others
            return self
        }
        
        //! Builds ColliderSet3.
        func build()->ColliderSet3 {
            return ColliderSet3(others: _colliders)
        }
    }
    
    /// Returns builder fox ColliderSet3.
    static func builder()->Builder{
        return Builder()
    }
}
