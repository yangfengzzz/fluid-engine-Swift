//
//  box2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D box geometry.
///
/// This class represents 2-D box geometry which extends Surface2 by overriding
/// surface-related queries. This box implementation is an axis-aligned box
/// that wraps lower-level primitive type, BoundingBox2F.
///
final class Box2 : Surface2{
    var transform: Transform2 = Transform2()
    
    var isNormalFlipped: Bool = false
    
    /// Bounding box of this box.
    var bound:BoundingBox2F = BoundingBox2F(point1: Vector2F(),
                                            point2: Vector2F(1.0, 1.0))
    
    /// Constructs (0, 0) x (1, 1) box.
    init(transform:Transform2 = Transform2(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a box with given \p lowerCorner and \p upperCorner.
    init(lowerCorner:Vector2F,
         upperCorner:Vector2F,
         transform:Transform2  = Transform2(),
         isNormalFlipped:Bool  = false){
        self.bound = BoundingBox2F(point1: lowerCorner,
                                   point2: upperCorner)
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a box with BoundingBox2F instance.
    init(boundingBox:BoundingBox2F,
         transform:Transform2  = Transform2(),
         isNormalFlipped:Bool  = false){
        self.bound = boundingBox
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Copy constructor.
    init(other:Box2) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        
        self.bound = other.bound
    }
    
    //MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector2F) -> Vector2F {
        if (bound.contains(point: otherPoint)) {
            let planes:[Plane2] = [Plane2(normal: Vector2F(1, 0), point: bound.upperCorner),
                                   Plane2(normal: Vector2F(0, 1), point: bound.upperCorner),
                                   Plane2(normal: Vector2F(-1, 0), point: bound.lowerCorner),
                                   Plane2(normal: Vector2F(0, -1), point: bound.lowerCorner)]
            
            var result = planes[0].closestPoint(otherPoint: otherPoint)
            var distanceSquared = length_squared(result - otherPoint)
            
            for i in 1..<4 {
                let localResult = planes[i].closestPoint(otherPoint: otherPoint)
                let localDistanceSquared = length_squared(localResult - otherPoint)
                
                if (localDistanceSquared < distanceSquared) {
                    result = localResult
                    distanceSquared = localDistanceSquared
                }
            }
            
            return result
        } else {
            return otherPoint.clamped(lowerBound: bound.lowerCorner, upperBound: bound.upperCorner)
        }
    }
    
    func intersectsLocal(rayLocal:Ray2F)->Bool{
        return bound.intersects(ray: rayLocal)
    }
    
    func boundingBoxLocal() -> BoundingBox2F {
        return bound
    }
    
    func closestNormalLocal(otherPoint: Vector2F) -> Vector2F {
        let planes:[Plane2] = [Plane2(normal: Vector2F(1, 0), point: bound.upperCorner),
                               Plane2(normal: Vector2F(0, 1), point: bound.upperCorner),
                               Plane2(normal: Vector2F(-1, 0), point: bound.lowerCorner),
                               Plane2(normal: Vector2F(0, -1), point: bound.lowerCorner)]
        
        if (bound.contains(point: otherPoint)) {
            var closestNormal = planes[0].normal
            let closestPoint = planes[0].closestPoint(otherPoint: otherPoint)
            var minDistanceSquared = length_squared(closestPoint - otherPoint)
            
            for i in 1..<4 {
                let localClosestPoint = planes[i].closestPoint(otherPoint: otherPoint)
                let localDistanceSquared = length_squared(localClosestPoint - otherPoint)
                
                if (localDistanceSquared < minDistanceSquared) {
                    closestNormal = planes[i].normal
                    minDistanceSquared = localDistanceSquared
                }
            }
            
            return closestNormal
        } else {
            let closestPoint = otherPoint.clamped(lowerBound: bound.lowerCorner,
                                                  upperBound: bound.upperCorner)
            let closestPointToInputPoint = otherPoint - closestPoint
            var closestNormal = planes[0].normal
            var maxCosineAngle = dot(closestNormal, closestPointToInputPoint)
            
            for i in 1..<4 {
                let cosineAngle = dot(planes[i].normal, closestPointToInputPoint)
                
                if (cosineAngle > maxCosineAngle) {
                    closestNormal = planes[i].normal
                    maxCosineAngle = cosineAngle
                }
            }
            
            return closestNormal
        }
    }
    
    func closestIntersectionLocal(ray: Ray2F) -> SurfaceRayIntersection2 {
        var intersection = SurfaceRayIntersection2()
        let bbRayIntersection = bound.closestIntersection(ray: ray)
        intersection.isIntersecting = bbRayIntersection.isIntersecting
        if (intersection.isIntersecting) {
            intersection.distance = bbRayIntersection.tNear
            intersection.point = ray.pointAt(t: bbRayIntersection.tNear)
            intersection.normal = closestNormalLocal(otherPoint: intersection.point)//wrong
        }
        return intersection
    }
    
    //MARK:- Builder
    /// Front-end to create Box2 objects step by step.
    class Builder : SurfaceBuilderBase2<Builder>{
        var _lowerCorner:Vector2F = Vector2F.zero
        var _upperCorner:Vector2F = Vector2F(1, 1)
        
        /// Returns builder with lower corner set.
        func withLowerCorner(pt:Vector2F)->Builder{
            _lowerCorner = pt
            return self
        }
        
        /// Returns builder with upper corner set.
        func withUpperCorner(pt:Vector2F)->Builder{
            _upperCorner = pt
            return self
        }
        
        /// Returns builder with bounding box.
        func withBoundingBox(bbox:BoundingBox2F)->Builder{
            _lowerCorner = bbox.lowerCorner
            _upperCorner = bbox.upperCorner
            return self
        }
        
        /// Builds Box2.
        func build()->Box2{
            return Box2(lowerCorner: _lowerCorner,
                        upperCorner: _upperCorner,
                        transform: _transform,
                        isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Box2.
    static func builder()->Builder{
        return Builder()
    }
}
