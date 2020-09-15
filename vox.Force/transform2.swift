//
//  transform2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Represents 2-D rigid body transform.
struct Transform2{
    private var _translation:Vector2F = Vector2F.zero
    private var _orientation:Float = 0
    private var _cosAngle:Float = 1
    private var _sinAngle:Float = 0
    
    /// Constructs identity transform.
    init(){}
    
    /// Constructs a transform with translation and orientation.
    init(translation:Vector2F, orientation:Float){
        _translation = translation
        _orientation = orientation
        _cosAngle = cos(orientation)
        _sinAngle = sin(orientation)
    }
    
    /// Returns the translation.
    var translation:Vector2F{
        return _translation
    }
    
    /// Sets the traslation.
    mutating func setTranslation(translation:Vector2F){
        _translation = translation
    }
    
    /// Returns the orientation in radians.
    var orientation:Float{
        return _orientation
    }
    
    /// Sets the orientation in radians.
    mutating func setOrientation(orientation:Float){
        _orientation = orientation
        _cosAngle = cos(orientation)
        _sinAngle = sin(orientation)
    }
    
    // MARK:- toLocal
    
    /// Transforms a point in world coordinate to the local frame.
    func toLocal(pointInWorld:Vector2F)->Vector2F{
        // Convert to the local frame
        let xmt = pointInWorld - _translation
        return Vector2F(
                        _cosAngle * xmt.x + _sinAngle * xmt.y,
                        -_sinAngle * xmt.x + _cosAngle * xmt.y)
    }
    
    /// Transforms a direction in world coordinate to the local frame.
    func toLocalDirection(dirInWorld:Vector2F)->Vector2F{
        // Convert to the local frame
        return Vector2F(
                        _cosAngle * dirInWorld.x + _sinAngle * dirInWorld.y,
                        -_sinAngle * dirInWorld.x + _cosAngle * dirInWorld.y)
    }
    
    /// Transforms a ray in world coordinate to the local frame.
    func toLocal(rayInWorld:Ray2F)->Ray2F{
        return Ray2F(
            newOrigin: toLocal(pointInWorld: rayInWorld.origin),
            newDirection: toLocalDirection(dirInWorld: rayInWorld.direction))
    }
    
    /// Transforms a bounding box in world coordinate to the local frame.
    func toLocal(bboxInWorld:BoundingBox2F)->BoundingBox2F{
        var bboxInLocal = BoundingBox2F()
        for i in 0..<4 {
            let cornerInLocal = toLocal(pointInWorld: bboxInWorld.corner(idx: i))
            bboxInLocal.lowerCorner = min(bboxInLocal.lowerCorner, cornerInLocal)
            bboxInLocal.upperCorner = max(bboxInLocal.upperCorner, cornerInLocal)
        }
        return bboxInLocal
    }
    
    // MARK:- toWorld
    
    /// Transforms a point in local space to the world coordinate.
    func toWorld(pointInLocal:Vector2F)->Vector2F{
        // Convert to the world frame
        return Vector2F(
                        _cosAngle * pointInLocal.x - _sinAngle * pointInLocal.y
                        + _translation.x,
                        _sinAngle * pointInLocal.x + _cosAngle * pointInLocal.y
                        + _translation.y)
    }
    
    /// Transforms a direction in local space to the world coordinate.
    func toWorldDirection(dirInLocal:Vector2F)->Vector2F{
        // Convert to the world frame
        return Vector2F(
                        _cosAngle * dirInLocal.x - _sinAngle * dirInLocal.y,
                        _sinAngle * dirInLocal.x + _cosAngle * dirInLocal.y)
    }
    
    /// Transforms a ray in local space to the world coordinate.
    func toWorld(rayInLocal:Ray2F)->Ray2F{
        return Ray2F(
            newOrigin: toWorld(pointInLocal: rayInLocal.origin),
            newDirection: toWorldDirection(dirInLocal: rayInLocal.direction))
    }
    
    /// Transforms a bounding box in local space to the world coordinate.
    func toWorld(bboxInLocal:BoundingBox2F)->BoundingBox2F{
        var bboxInWorld = BoundingBox2F()
        for i in 0..<4 {
            let cornerInWorld = toWorld(pointInLocal: bboxInLocal.corner(idx: i))
            bboxInWorld.lowerCorner = min(bboxInWorld.lowerCorner, cornerInWorld)
            bboxInWorld.upperCorner = max(bboxInWorld.upperCorner, cornerInWorld)
        }
        return bboxInWorld
    }
}
