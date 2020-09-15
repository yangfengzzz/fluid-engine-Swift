//
//  transform3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Represents 3-D rigid body transform.
struct Transform3{
    private var _translation:Vector3F = Vector3F.zero
    private var _orientation:simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    private var _orientationMat3:matrix_float3x3 = matrix_float3x3(1)
    private var _inverseOrientationMat3:matrix_float3x3 = matrix_float3x3(1)
    
    /// Constructs identity transform.
    init(){}
    
    /// Constructs a transform with translation and orientation.
    init(translation:Vector3F, orientation:simd_quatf){
        setTranslation(translation: translation)
        setOrientation(orientation: orientation)
    }
    
    /// Returns the translation.
    var translation:Vector3F{
        return _translation
    }
    
    /// Sets the traslation.
    mutating func setTranslation(translation:Vector3F){
        _translation = translation
    }
    
    /// Returns the orientation in radians.
    var orientation:simd_quatf{
        return _orientation
    }
    
    /// Sets the orientation in radians.
    mutating func setOrientation(orientation:simd_quatf){
        _orientation = orientation
        _orientationMat3 = matrix_float3x3(orientation)
        _inverseOrientationMat3 = matrix_float3x3(orientation.inverse)
    }
    
    // MARK:- toLocal
    
    /// Transforms a point in world coordinate to the local frame.
    func toLocal(pointInWorld:Vector3F)->Vector3F{
        return _inverseOrientationMat3 * (pointInWorld - _translation)
    }
    
    /// Transforms a direction in world coordinate to the local frame.
    func toLocalDirection(dirInWorld:Vector3F)->Vector3F{
        return _inverseOrientationMat3 * dirInWorld
    }
    
    /// Transforms a ray in world coordinate to the local frame.
    func toLocal(rayInWorld:Ray3F)->Ray3F{
        return Ray3F(
            newOrigin: toLocal(pointInWorld: rayInWorld.origin),
            newDirection: toLocalDirection(dirInWorld: rayInWorld.direction))
    }
    
    /// Transforms a bounding box in world coordinate to the local frame.
    func toLocal(bboxInWorld:BoundingBox3F)->BoundingBox3F{
        var bboxInLocal = BoundingBox3F()
        for i in 0..<8 {
            let cornerInLocal = toLocal(pointInWorld: bboxInWorld.corner(idx: i))
            bboxInLocal.lowerCorner = min(bboxInLocal.lowerCorner, cornerInLocal)
            bboxInLocal.upperCorner = max(bboxInLocal.upperCorner, cornerInLocal)
        }
        return bboxInLocal
    }
    
    // MARK:- toWorld
    
    /// Transforms a point in local space to the world coordinate.
    func toWorld(pointInLocal:Vector3F)->Vector3F{
        return (_orientationMat3 * pointInLocal) + _translation
    }
    
    /// Transforms a direction in local space to the world coordinate.
    func toWorldDirection(dirInLocal:Vector3F)->Vector3F{
        return _orientationMat3 * dirInLocal
    }
    
    /// Transforms a ray in local space to the world coordinate.
    func toWorld(rayInLocal:Ray3F)->Ray3F{
        return Ray3F(
            newOrigin: toWorld(pointInLocal: rayInLocal.origin),
            newDirection: toWorldDirection(dirInLocal: rayInLocal.direction))
    }
    
    /// Transforms a bounding box in local space to the world coordinate.
    func toWorld(bboxInLocal:BoundingBox3F)->BoundingBox3F{
        var bboxInWorld = BoundingBox3F()
        for i in 0..<8 {
            let cornerInWorld = toWorld(pointInLocal: bboxInLocal.corner(idx: i))
            bboxInWorld.lowerCorner = min(bboxInWorld.lowerCorner, cornerInWorld)
            bboxInWorld.upperCorner = max(bboxInWorld.upperCorner, cornerInWorld)
        }
        return bboxInWorld
    }
}
