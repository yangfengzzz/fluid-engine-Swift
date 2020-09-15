//
//  cylinder3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/20.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation


/// This class represents 3-D cylinder geometry which extends Surface3 by
/// overriding surface-related queries. The cylinder is aligned with the y-axis.
final class Cylinder3: Surface3 {
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    /// Center of the cylinder.
    var center:Vector3F = Vector3F()
    
    /// Radius of the cylinder.
    var radius:Float = 1.0
    
    /// Height of the cylinder.
    var height:Float = 1.0
    
    /// Constructs a cylinder with
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    init(center:Vector3F,
         radius:Float,
         height:Float,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self.center = center
        self.radius = radius
        self.height = height
    }
    
    /// Copy constructor.
    init(other:Cylinder3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        self.center = other.center
        self.radius = other.radius
        self.height = other.height
    }
    
    //MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector3F)->Vector3F {
        let r:Vector3F = otherPoint - center
        let rr = Vector2F(sqrt(r.x * r.x + r.z * r.z), r.y)
        let box = Box2(lowerCorner: Vector2F(-radius, -0.5 * height),
                       upperCorner: Vector2F(radius, 0.5 * height))
        
        let cp:Vector2F = box.closestPoint(otherPoint: rr)
        let angle:Float = atan2(r.z, r.x)
        return Vector3F(cp.x * cos(angle), cp.y, cp.x * sin(angle)) + center
    }
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float {
        let r:Vector3F = otherPoint - center
        let rr = Vector2F(sqrt(r.x * r.x + r.z * r.z), r.y)
        let box = Box2(lowerCorner: Vector2F(-radius, -0.5 * height),
                       upperCorner: Vector2F(radius, 0.5 * height))
        
        return box.closestDistance(otherPoint: rr)
    }
    
    func intersectsLocal(ray:Ray3F)->Bool {
        // Calculate intersection with infinite cylinder
        // (dx^2 + dz^2)t^2 + 2(ox.dx + oz.dz)t + ox^2 + oz^2 - r^2 = 0
        var d:Vector3F = ray.direction
        d.y = 0.0
        var o:Vector3F = ray.origin - center
        o.y = 0.0
        let A:Float = length_squared(d)
        let B:Float = dot(d, o)
        let C:Float = length_squared(o) - Math.square(of: radius)
        
        let bbox = boundingBox()
        let upperPlane = Plane3(normal: Vector3F(0, 1, 0), point: bbox.upperCorner)
        let lowerPlane = Plane3(normal: Vector3F(0, -1, 0), point: bbox.lowerCorner)
        
        let upperIntersection = upperPlane.closestIntersection(ray: ray)
        let lowerIntersection = lowerPlane.closestIntersection(ray: ray)
        
        // In case the ray does not intersect with infinite cylinder
        if (A < Float.leastNonzeroMagnitude || B * B - A * C < 0.0) {
            // Check if the ray is inside the infinite cylinder
            let r = ray.origin - center
            let rr = Vector2F(r.x, r.z)
            if (length_squared(rr) <= Math.square(of: radius)) {
                if (upperIntersection.isIntersecting ||
                    lowerIntersection.isIntersecting) {
                    return true
                }
            }
            
            return false
        }
        
        let t1:Float = (-B + sqrt(B * B - A * C)) / A
        let t2:Float = (-B - sqrt(B * B - A * C)) / A
        var tCylinder:Float = t2
        
        if t2 < 0.0 {
            tCylinder = t1
        }
        
        let pointOnCylinder = ray.pointAt(t: tCylinder)
        
        if (pointOnCylinder.y >= center.y - 0.5 * height &&
            pointOnCylinder.y <= center.y + 0.5 * height) {
            return true
        }
        
        if (upperIntersection.isIntersecting) {
            var r = upperIntersection.point - center
            r.y = 0.0
            if (length_squared(r) <= Math.square(of: radius)) {
                return true
            }
        }
        
        if (lowerIntersection.isIntersecting) {
            var r = lowerIntersection.point - center
            r.y = 0.0
            if (length_squared(r) <= Math.square(of: radius)) {
                return true
            }
        }
        
        return false
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        return BoundingBox3F(point1: center - Vector3F(radius, 0.5 * height, radius),
                             point2: center + Vector3F(radius, 0.5 * height, radius))
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        let r:Vector3F = otherPoint - center
        let rr = Vector2F(sqrt(r.x * r.x + r.z * r.z), r.y)
        let box = Box2(lowerCorner: Vector2F(-radius, -0.5 * height),
                       upperCorner: Vector2F(radius, 0.5 * height))
        
        let cn:Vector2F = box.closestNormal(otherPoint: rr)
        if (cn.y > 0) {
            return Vector3F(0, 1, 0)
        } else if (cn.y < 0) {
            return Vector3F(0, -1, 0)
        } else {
            return normalize(Vector3F(r.x, 0, r.z))
        }
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        var intersection = SurfaceRayIntersection3()
        
        // Calculate intersection with infinite cylinder
        // (dx^2 + dz^2)t^2 + 2(ox.dx + oz.dz)t + ox^2 + oz^2 - r^2 = 0
        var d = ray.direction
        d.y = 0.0
        var o = ray.origin - center
        o.y = 0.0
        let A = length_squared(d)
        let B = dot(d, o)
        let C = length_squared(o) - Math.square(of: radius)
        
        let bbox = boundingBox()
        let upperPlane = Plane3(normal: Vector3F(0, 1, 0), point: bbox.upperCorner)
        let lowerPlane = Plane3(normal: Vector3F(0, -1, 0), point: bbox.lowerCorner)
        
        var upperIntersection = upperPlane.closestIntersection(ray: ray)
        var lowerIntersection = lowerPlane.closestIntersection(ray: ray)
        
        intersection.distance = Float.greatestFiniteMagnitude
        intersection.isIntersecting = false
        
        // In case the ray does not intersect with infinite cylinder
        if (A < Float.leastNonzeroMagnitude || B * B - A * C < 0.0) {
            // Check if the ray is inside the infinite cylinder
            let r = ray.origin - center
            let rr = Vector2F(r.x, r.z)
            if (length_squared(rr) <= Math.square(of: radius)) {
                if (upperIntersection.isIntersecting) {
                    intersection = upperIntersection
                }
                if (lowerIntersection.isIntersecting &&
                    lowerIntersection.distance < intersection.distance) {
                    intersection = lowerIntersection
                }
            }
            
            return intersection
        }
        
        let t1:Float = (-B + sqrt(B * B - A * C)) / A
        let t2:Float = (-B - sqrt(B * B - A * C)) / A
        var tCylinder = t2
        
        if (t2 < 0.0) {
            tCylinder = t1
        }
        
        let pointOnCylinder = ray.pointAt(t: tCylinder)
        
        if (pointOnCylinder.y >= center.y - 0.5 * height &&
            pointOnCylinder.y <= center.y + 0.5 * height) {
            intersection.isIntersecting = true
            intersection.distance = tCylinder
            intersection.point = pointOnCylinder
            intersection.normal = pointOnCylinder - center
            intersection.normal.y = 0.0
            intersection.normal.normalized()
        }
        
        if (upperIntersection.isIntersecting) {
            var r = upperIntersection.point - center
            r.y = 0.0
            if (length_squared(r) > Math.square(of: radius)) {
                upperIntersection.isIntersecting = false
            } else if (upperIntersection.distance < intersection.distance) {
                intersection = upperIntersection
            }
        }
        
        if (lowerIntersection.isIntersecting) {
            var r = lowerIntersection.point - center
            r.y = 0.0
            if (length_squared(r) > Math.square(of: radius)) {
                lowerIntersection.isIntersecting = false
            } else if (lowerIntersection.distance < intersection.distance) {
                intersection = lowerIntersection
            }
        }
        
        return intersection
    }
    
    //MARK:- Builder
    ///  Front-end to create Cylinder3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        var _center = Vector3F(0, 0, 0)
        var _radius:Float = 1.0
        var _height:Float = 1.0
        
        /// Returns builder with center.
        func withCenter(center:Vector3F)->Builder {
            _center = center
            return self
        }
        
        /// Returns builder with radius.
        func withRadius(radius:Float)->Builder {
            _radius = radius
            return self
        }
        
        /// Returns builder with height.
        func withHeight(height:Float)->Builder {
            _height = height
            return self
        }
        
        /// Builds Cylinder3.
        func build()->Cylinder3{
            return Cylinder3(center: _center,
                             radius: _radius,
                             height: _height,
                             transform: _transform,
                             isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Cylinder3.
    static func builder()->Builder{
        return Builder()
    }
}
