//
//  box3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D box geometry.
///
/// This class represents 3-D box geometry which extends Surface3 by overriding
/// surface-related queries. This box implementation is an axis-aligned box
/// that wraps lower-level primitive type, BoundingBox3F.
///
final class Box3 : Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    /// Bounding box of this box.
    var bound:BoundingBox3F = BoundingBox3F(point1: Vector3F(),
                                            point2: Vector3F(1.0, 1.0, 1.0))
    
    /// Constructs (0, 0, 0) x (1, 1, 1) box.
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a box with given \p lowerCorner and \p upperCorner.
    init(lowerCorner:Vector3F,
         upperCorner:Vector3F,
         transform:Transform3  = Transform3(),
         isNormalFlipped:Bool  = false){
        self.bound = BoundingBox3F(point1: lowerCorner,
                                   point2: upperCorner)
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a box with BoundingBox3F instance.
    init(boundingBox:BoundingBox3F,
         transform:Transform3  = Transform3(),
         isNormalFlipped:Bool  = false){
        self.bound = boundingBox
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Copy constructor.
    init(other:Box3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        
        self.bound = other.bound
    }
    
    //MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        if (bound.contains(point: otherPoint)) {
            let planes:[Plane3] = [Plane3(normal: Vector3F(1, 0, 0), point: bound.upperCorner),
                                   Plane3(normal: Vector3F(0, 1, 0), point: bound.upperCorner),
                                   Plane3(normal: Vector3F(0, 0, 1), point: bound.upperCorner),
                                   Plane3(normal: Vector3F(-1, 0, 0), point: bound.lowerCorner),
                                   Plane3(normal: Vector3F(0, -1, 0), point: bound.lowerCorner),
                                   Plane3(normal: Vector3F(0, 0, -1), point: bound.lowerCorner)]
            
            var result = planes[0].closestPoint(otherPoint: otherPoint)
            var distanceSquared = length_squared(result - otherPoint)
            
            for i in 1..<6 {
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
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        return bound.intersects(ray: rayLocal)
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        return bound
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        let planes:[Plane3] = [Plane3(normal: Vector3F(1, 0, 0), point: bound.upperCorner),
                               Plane3(normal: Vector3F(0, 1, 0), point: bound.upperCorner),
                               Plane3(normal: Vector3F(0, 0, 1), point: bound.upperCorner),
                               Plane3(normal: Vector3F(-1, 0, 0), point: bound.lowerCorner),
                               Plane3(normal: Vector3F(0, -1, 0), point: bound.lowerCorner),
                               Plane3(normal: Vector3F(0, 0, -1), point: bound.lowerCorner)]
        
        if (bound.contains(point: otherPoint)) {
            var closestNormal = planes[0].normal
            let closestPoint = planes[0].closestPoint(otherPoint: otherPoint)
            var minDistanceSquared = length_squared(closestPoint - otherPoint)
            
            for i in 1..<6 {
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
            
            for i in 1..<6 {
                let cosineAngle = dot(planes[i].normal, closestPointToInputPoint)
                
                if (cosineAngle > maxCosineAngle) {
                    closestNormal = planes[i].normal
                    maxCosineAngle = cosineAngle
                }
            }
            
            return closestNormal
        }
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        var intersection = SurfaceRayIntersection3()
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
    /// Front-end to create Box3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        var _lowerCorner:Vector3F = Vector3F.zero
        var _upperCorner:Vector3F = Vector3F(1, 1, 1)
        
        /// Returns builder with lower corner set.
        func withLowerCorner(pt:Vector3F)->Builder{
            _lowerCorner = pt
            return self
        }
        
        /// Returns builder with upper corner set.
        func withUpperCorner(pt:Vector3F)->Builder{
            _upperCorner = pt
            return self
        }
        
        /// Returns builder with bounding box.
        func withBoundingBox(bbox:BoundingBox3F)->Builder{
            _lowerCorner = bbox.lowerCorner
            _upperCorner = bbox.upperCorner
            return self
        }
        
        /// Builds Box3.
        func build()->Box3{
            return Box3(lowerCorner: _lowerCorner,
                        upperCorner: _upperCorner,
                        transform: _transform,
                        isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Box3.
    static func builder()->Builder{
        return Builder()
    }
}
