//
//  ray3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

///
/// Class for 3-D ray.
///
struct Ray3F {
    var origin:Vector3F
    var direction:Vector3F
    
    /// Constructs an empty ray that points (1, 0, 0) from (0, 0, 0).
    init(){
        origin = Vector3F.zero
        direction = Vector3F(1, 0, 0)
    }
    
    /// Constructs a ray with given origin and riection.
    init(newOrigin:Vector3F, newDirection:Vector3F){
        origin = newOrigin
        direction = normalize(newDirection)
    }
    
    /// Copy constructor.
    init(other:Ray3F){
        origin = other.origin
        direction = other.direction
    }
    
    func pointAt(t:Float)->Vector3F{
        return origin + t * direction
    }
}

///
/// Class for 3-D ray.
///
struct Ray3D {
    var origin:Vector3D
    var direction:Vector3D
    
    /// Constructs an empty ray that points (1, 0, 0) from (0, 0, 0).
    init(){
        origin = Vector3D.zero
        direction = Vector3D(1, 0, 0)
    }
    
    /// Constructs a ray with given origin and riection.
    init(newOrigin:Vector3D, newDirection:Vector3D){
        origin = newOrigin
        direction = normalize(newDirection)
    }
    
    /// Copy constructor.
    init(other:Ray3D){
        origin = other.origin
        direction = other.direction
    }
    
    func pointAt(t:Double)->Vector3D{
        return origin + t * direction
    }
}
