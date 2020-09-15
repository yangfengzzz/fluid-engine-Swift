//
//  plane3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D plane geometry.
///
/// This class represents 3-D plane geometry which extends Surface3 by
/// overriding surface-related queries.
///
final class Plane3 : Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    /// Plane normal.
    var normal = Vector3F(0, 1, 0)
    
    /// Point that lies on the plane.
    var point = Vector3F()
    
    /// Constructs a plane that crosses (0, 0, 0) with surface normal (0, 1, 0).
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a plane that cross \p point with surface normal \p normal.
    init(normal:Vector3F,
         point:Vector3F,
         transform:Transform3  = Transform3(),
         isNormalFlipped:Bool  = false){
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        self.normal = normal
        self.point = point
    }
    
    /// Constructs a plane with three points on the surface. The normal will be
    /// set using the counter clockwise direction.
    init(point0:Vector3F,
         point1:Vector3F,
         point2:Vector3F,
         transform:Transform3  = Transform3(),
         isNormalFlipped:Bool = false){
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self.normal = normalize(cross(point1 - point0, point2 - point0))
        self.point = point0
    }
    
    /// Copy constructor.
    init(other:Plane3) {
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
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        let r = otherPoint - point
        return r - dot(normal, r) * normal + point
    }
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        return abs(dot(rayLocal.direction, normal)) > 0
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        let eps = Float.leastNonzeroMagnitude
        let dmax = Float.greatestFiniteMagnitude
        
        if (abs(dot(normal, Vector3F(1, 0, 0)) - 1.0) < eps) {
            return BoundingBox3F(point1: point - Vector3F(0, dmax, dmax),
                                 point2: point + Vector3F(0, dmax, dmax))
        } else if (abs(dot(normal, Vector3F(0, 1, 0)) - 1.0) < eps) {
            return BoundingBox3F(point1: point - Vector3F(dmax, 0, dmax),
                                 point2: point + Vector3F(dmax, 0, dmax))
        } else if (abs(dot(normal, Vector3F(0, 0, 1)) - 1.0) < eps) {
            return BoundingBox3F(point1: point - Vector3F(dmax, dmax, 0),
                                 point2: point + Vector3F(dmax, dmax, 0))
        } else {
            return BoundingBox3F(point1: Vector3F(dmax, dmax, dmax),
                                 point2: Vector3F(dmax, dmax, dmax))
        }
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        return normal
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        var intersection = SurfaceRayIntersection3()
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
    /// Front-end to create Plane3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        var _normal:Vector3F = Vector3F(0, 1, 0)
        var _point:Vector3F = Vector3F.zero
        
        /// Returns builder with plane normal.
        func withNormal(normal:Vector3F)->Builder{
            _normal = normal
            return self
        }
        
        /// Returns builder with point on the plane.
        func withPoint(point:Vector3F)->Builder{
            _point = point
            return self
        }
        
        /// Builds Plane3.
        func build()->Plane3{
            return Plane3(normal: _normal,
                          point: _point,
                          transform: _transform,
                          isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Plane3.
    static func builder()->Builder{
        return Builder()
    }
}
