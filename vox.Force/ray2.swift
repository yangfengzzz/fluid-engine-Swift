//
//  ray2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

///
/// Class for 2-D ray.
///
struct Ray2F {
    var origin:Vector2F
    var direction:Vector2F
    
    /// Constructs an empty ray that points (1, 0) from (0, 0).
    init(){
        origin = Vector2F.zero
        direction = Vector2F(1, 0)
    }
    
    /// Constructs a ray with given origin and riection.
    init(newOrigin:Vector2F, newDirection:Vector2F){
        origin = newOrigin
        direction = normalize(newDirection)
    }
    
    /// Copy constructor.
    init(other:Ray2F){
        origin = other.origin
        direction = other.direction
    }
    
    func pointAt(t:Float)->Vector2F{
        return origin + t * direction
    }
}

///
/// Class for 2-D ray.
///
struct Ray2D {
    var origin:Vector2D
    var direction:Vector2D
    
    /// Constructs an empty ray that points (1, 0) from (0, 0).
    init(){
        origin = Vector2D.zero
        direction = Vector2D(1, 0)
    }
    
    /// Constructs a ray with given origin and riection.
    init(newOrigin:Vector2D, newDirection:Vector2D){
        origin = newOrigin
        direction = normalize(newDirection)
    }
    
    /// Copy constructor.
    init(other:Ray2D){
        origin = other.origin
        direction = other.direction
    }
    
    func pointAt(t:Double)->Vector2D{
        return origin + t * direction
    }
}
