//
//  plane2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D plane geometry.
/// This class represents 2-D plane geometry which extends Surface2 by
/// overriding surface-related queries.
///
final class Plane2:Surface2{
    var transform: Transform2 = Transform2()
    
    var isNormalFlipped: Bool = false
    
    /// Plane normal.
    var normal = Vector2F(0, 1)
    
    /// Point that lies on the plane.
    var point = Vector2F()
    
    /// Constructs a plane that crosses (0, 0) with surface normal (0, 1).
    init(transform:Transform2 = Transform2(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a plane that cross \p point with surface normal \p normal.
    init(normal:Vector2F,
         point:Vector2F,
         transform:Transform2 = Transform2(),
         isNormalFlipped:Bool = false){
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self.normal = normal
        self.point = point
    }
    
    /// Copy constructor.
    init(other:Plane2) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        
        self.normal = other.normal
        self.point = other.point
    }
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool{
        return false
    }
    
    //MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector2F) -> Vector2F {
        let r = otherPoint - point
        return r - dot(normal, r) * normal + point
    }
    
    func intersectsLocal(rayLocal:Ray2F)->Bool{
        return abs(dot(rayLocal.direction, normal)) > 0
    }
    
    func boundingBoxLocal() -> BoundingBox2F {
        if (abs(dot(normal, Vector2F(1, 0)) - 1.0) < Float.leastNonzeroMagnitude) {
            return BoundingBox2F(point1: point - Vector2F(0, Float.greatestFiniteMagnitude),
                                 point2: point + Vector2F(0, Float.greatestFiniteMagnitude))
        } else if (abs(dot(normal, Vector2F(0, 1)) - 1.0) < Float.leastNonzeroMagnitude) {
            return BoundingBox2F(point1: point - Vector2F(Float.greatestFiniteMagnitude, 0),
                                 point2: point + Vector2F(Float.greatestFiniteMagnitude, 0))
        } else {
            return BoundingBox2F(point1: Vector2F(repeating: Float.greatestFiniteMagnitude),
                                 point2: Vector2F(repeating: Float.greatestFiniteMagnitude))
        }
    }
    
    func closestNormalLocal(otherPoint: Vector2F) -> Vector2F {
        return normal
    }
    
    func closestIntersectionLocal(ray: Ray2F) -> SurfaceRayIntersection2 {
        var intersection = SurfaceRayIntersection2()
        let dDotN = dot(ray.direction, normal)
        
        // Check if not parallel
        if (abs(dDotN) > 0) {
            let t = dot(normal, point - ray.origin) / dDotN
            if (t >= 0.0) {
                intersection.isIntersecting = true
                intersection.distance = t
                intersection.point = ray.pointAt(t: t)
                intersection.normal = normal
            }
        }
        
        return intersection
    }
    
    //MARK:- Builder
    /// Front-end to create Plane2 objects step by step.
    class Builder : SurfaceBuilderBase2<Builder>{
        var _normal:Vector2F = Vector2F(0, 1)
        var _point:Vector2F = Vector2F.zero
        
        /// Returns builder with plane normal.
        func withNormal(normal:Vector2F)->Builder{
            _normal = normal
            return self
        }
        
        /// Returns builder with point on the plane.
        func withPoint(point:Vector2F)->Builder{
            _point = point
            return self
        }
        
        /// Builds Plane2.
        func build()->Plane2{
            return Plane2(normal: _normal, point: _point,
                          transform: _transform,
                          isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Plane2.
    static func builder()->Builder{
        return Builder()
    }
}
