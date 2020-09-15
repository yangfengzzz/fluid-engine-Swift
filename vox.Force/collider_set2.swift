//
//  collider_set2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Collection of 2-D colliders
class ColliderSet2: Collider2 {
    var _surface: Surface2?
    var _frictionCoeffient: Float = 0
    var _onUpdateCallback: OnBeginUpdateCallback?
    
    var _colliders:[Collider2] = []
    
    /// Default constructor.
    convenience init() {
        self.init(others: [])
    }
    
    /// Constructs with other colliders.
    init(others:[Collider2]) {
        setSurface(newSurface: SurfaceSet2())
        for collider in others {
            addCollider(collider: collider)
        }
    }
    
    /// Returns the velocity of the collider at given \p point.
    func velocityAt(point:Vector2F)->Vector2F {
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
            return Vector2F()
        }
    }
    
    /// Adds a collider to the set.
    func addCollider(collider:Collider2) {
        let surfaceSet = surface() as! SurfaceSet2
        _colliders.append(collider)
        surfaceSet.addSurface(surface: collider.surface())
    }
    
    /// Returns number of colliders.
    func numberOfColliders()->size_t {
        return _colliders.count
    }
    
    /// Returns collider at index \p i.
    func collider(i:size_t)->Collider2 {
        return _colliders[i]
    }
    
    //MARK:- Builder
    /// Front-end to create ColliderSet2 objects step by step.
    class Builder {
        var _colliders:[Collider2] = []
        //! Returns builder with other colliders.
        func withColliders(others:[Collider2])->Builder {
            _colliders = others
            return self
        }
        
        //! Builds ColliderSet2.
        func build()->ColliderSet2 {
            return ColliderSet2(others: _colliders)
        }
    }
    
    /// Returns builder fox ColliderSet2.
    static func builder()->Builder{
        return Builder()
    }
}
