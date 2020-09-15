//
//  sphere3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D sphere geometry.
///
/// This class represents 3-D sphere geometry which extends Surface3 by
/// overriding surface-related queries.
///
final class Sphere3 : Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    /// Center of the sphere.
    var center:Vector3F = Vector3F()
    
    /// Radius of the sphere.
    var radius:Float = 1.0
    
    /// Constructs a sphere with center at (0, 0, 0) and radius of 1.
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a sphere with \p center and \p radius.
    init(center:Vector3F,
         radiustransform:Float,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        self.center = center
        self.radius = radiustransform
    }
    
    /// Copy constructor.
    init(other:Sphere3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        self.center = other.center
        self.radius = other.radius
    }
    
    //MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        return radius * closestNormalLocal(otherPoint: otherPoint) + center
    }
    
    func closestDistanceLocal(otherPointLocal:Vector3F)->Float{
        return abs(length(center - otherPointLocal) - radius)
    }
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        let r = rayLocal.origin - center
        let b = dot(rayLocal.direction, r)
        let c = length_squared(r) - Math.square(of: radius)
        var d = b * b - c
        
        if (d > 0.0) {
            d = sqrt(d)
            var tMin = -b - d
            let tMax = -b + d
            
            if (tMin < 0.0) {
                tMin = tMax
            }
            
            if (tMin >= 0.0) {
                return true
            }
        }
        
        return false
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        let r = Vector3F(repeating: radius)
        return BoundingBox3F(point1: center - r, point2: center + r)
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        if (center.isSimilar(other: otherPoint)) {
            return Vector3F(1, 0, 0)
        } else {
            return normalize(otherPoint - center)
        }
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        var intersection = SurfaceRayIntersection3()
        let r = ray.origin - center
        let b = dot(ray.direction, r)
        let c = length_squared(r) - Math.square(of: radius)
        var d = b * b - c
        
        if (d > 0.0) {
            d = sqrt(d)
            var tMin = -b - d
            let tMax = -b + d
            
            if (tMin < 0.0) {
                tMin = tMax
            }
            
            if (tMin < 0.0) {
                intersection.isIntersecting = false
            } else {
                intersection.isIntersecting = true
                intersection.distance = tMin
                intersection.point = ray.origin + tMin * ray.direction
                intersection.normal = normalize(intersection.point - center)
            }
        } else {
            intersection.isIntersecting = false
        }
        
        return intersection
    }
    
    //MARK:- Builder
    /// Front-end to create Sphere3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        var _center:Vector3F = Vector3F.zero
        var _radius:Float = 0.0
        
        /// Returns builder with sphere center.
        func withCenter(center:Vector3F)->Builder{
            _center = center
            return self
        }
        
        /// Returns builder with sphere radius.
        func withRadius(radius:Float)->Builder{
            _radius = radius
            return self
        }
        
        /// Builds Sphere3.
        func build()->Sphere3{
            return Sphere3(center: _center,
                           radiustransform: _radius,
                           transform: _transform,
                           isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Sphere3.
    static func builder()->Builder{
        return Builder()
    }
}
