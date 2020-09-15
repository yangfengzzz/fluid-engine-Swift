//
//  triangle3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

final class Triangle3 : Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    typealias Vector3FArray3 = (Vector3F, Vector3F, Vector3F)
    typealias Vector2FArray3 = (Vector2F, Vector2F, Vector2F)
    
    /// Three points.
    var points:Vector3FArray3 = (Vector3F(), Vector3F(), Vector3F())
    
    /// Three normals.
    var normals:Vector3FArray3 = (Vector3F(), Vector3F(), Vector3F())
    
    /// Three UV coordinates.
    var uvs:Vector2FArray3 = (Vector2F(), Vector2F(), Vector2F())
    
    /// Constructs an empty triangle.
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs a triangle with given \p points, \p normals, and \p uvs.
    init(points:Vector3FArray3,
         normals:Vector3FArray3,
         uvs:Vector2FArray3,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self.points = points
        self.normals = normals
        self.uvs = uvs
    }
    
    /// Copy constructor.
    init(other:Triangle3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        self.points = other.points
        self.normals = other.normals
        self.uvs = other.uvs
    }
    
    // MARK:- Helper Function
    /// Returns the area of this triangle.
    func area()->Float{
        return 0.5 * length(cross(points.1 - points.0, points.2 - points.0))
    }
    
    /// Returns barycentric coordinates for the given point \p pt.
    func getBarycentricCoords(pt:Vector3F,
                              b0:inout Float,
                              b1:inout Float,
                              b2:inout Float){
        let q01 = cross(points.1 - points.0, pt - points.0)
        let q12 = cross(points.2 - points.1, pt - points.1)
        let q02 = cross(points.0 - points.2, pt - points.2)
        
        let a = area()
        b0 = 0.5 * length(q12) / a
        b1 = 0.5 * length(q02) / a
        b2 = 0.5 * length(q01) / a
    }
    
    /// Returns the face normal of the triangle.
    func faceNormal()->Vector3F{
        let ret = cross(points.1 - points.0, points.2 - points.0)
        return normalize(ret)
    }
    
    /// Set Triangle3::normals to the face normal.
    func setNormalsToFaceNormal(){
        let normal = faceNormal()
        
        normals.0 = normal
        normals.1 = normal
        normals.2 = normal
    }
    
    
    func closestPointOnLine(v0:Vector3F,
                            v1:Vector3F,
                            pt:Vector3F)->Vector3F{
        let lenSquared = length_squared(v1 - v0)
        if (lenSquared < Float.leastNonzeroMagnitude) {
            return v0
        }
        
        let t = dot(pt - v0, v1 - v0) / lenSquared
        if (t < 0.0) {
            return v0
        } else if (t > 1.0) {
            return v1
        }
        
        return v0 + t * (v1 - v0)
    }
    
    func closestNormalOnLine(v0:Vector3F, v1:Vector3F,
                             n0:Vector3F, n1:Vector3F,
                             pt:Vector3F)->Vector3F{
        let lenSquared = length_squared(v1 - v0)
        if (lenSquared < Float.leastNonzeroMagnitude) {
            return n0
        }
        
        let t = dot(pt - v0, v1 - v0) / lenSquared
        if (t < 0.0) {
            return n0
        } else if (t > 1.0) {
            return n1
        }
        
        return normalize(n0 + t * (n1 - n0))
    }
    
    // MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        let n = faceNormal()
        let nd = dot(n, n)
        let d = dot(n, points.0)
        let t = (d - dot(n, otherPoint)) / nd
        
        let q = t * n + otherPoint
        
        let q01 = cross(points.1 - points.0, q - points.0)
        if dot(n, q01) < 0 {
            return closestPointOnLine(v0: points.0, v1: points.1, pt: q)
        }
        
        let q12 = cross(points.2 - points.1, q - points.1)
        if dot(n, q12) < 0 {
            return closestPointOnLine(v0: points.1, v1: points.2, pt: q)
        }
        
        let q02 = cross(points.0 - points.2, q - points.2)
        if dot(n, q02) < 0 {
            return closestPointOnLine(v0: points.0, v1: points.2, pt: q)
        }
        
        let a = area()
        let b0 = 0.5 * length(q12) / a
        let b1 = 0.5 * length(q02) / a
        let b2 = 0.5 * length(q01) / a
        
        var result = b0 * points.0
        result += b1 * points.1
        result += b2 * points.2
        return result
    }
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        let n = faceNormal()
        let nd = dot(n, rayLocal.direction)
        
        if (nd < Float.leastNonzeroMagnitude) {
            return false
        }
        
        let d = dot(n, points.0)
        let t = (d - dot(n, rayLocal.origin)) / nd
        
        if (t < 0.0) {
            return false
        }
        
        let q = rayLocal.pointAt(t: t)
        
        let q01 = cross(points.1 - points.0, q - points.0)
        if dot(n, q01) <= 0.0 {
            return false
        }
        
        let q12 = cross(points.2 - points.1, q - points.1)
        if dot(n, q12) <= 0.0 {
            return false
        }
        
        let q02 = cross(points.0 - points.2, q - points.2)
        if dot(n, q02) <= 0.0 {
            return false
        }
        
        return true
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        var box = BoundingBox3F(point1: points.0, point2: points.1)
        box.merge(point: points.2)
        return box
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        let n = faceNormal()
        let nd = dot(n, n)
        let d = dot(n, points.0)
        let t = (d - dot(n, otherPoint)) / nd
        
        let q = t * n + otherPoint
        
        let q01 = cross(points.1 - points.0, q - points.0)
        if dot(n, q01) < 0 {
            return closestNormalOnLine(v0: points.0, v1: points.1,
                                       n0: normals.0, n1: normals.1,
                                       pt: q)
        }
        
        let q12 = cross(points.2 - points.1, q - points.1)
        if dot(n, q12) < 0 {
            return closestNormalOnLine(v0: points.1, v1: points.2,
                                       n0: normals.1, n1: normals.2,
                                       pt: q)
        }
        
        let q02 = cross(points.0 - points.2, q - points.2)
        if dot(n, q02) < 0 {
            return closestNormalOnLine(v0: points.0, v1: points.2,
                                       n0: normals.0, n1: normals.2,
                                       pt: q)
        }
        
        let a = area()
        let b0 = 0.5 * length(q12) / a
        let b1 = 0.5 * length(q02) / a
        let b2 = 0.5 * length(q01) / a
        
        var result = b0 * normals.0
        result += b1 * normals.1
        result += b2 * normals.2
        
        return normalize(result)
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        var intersection = SurfaceRayIntersection3()
        let n = faceNormal()
        let nd = dot(n, ray.direction)
        
        if (nd < Float.leastNonzeroMagnitude) {
            intersection.isIntersecting = false
            return intersection
        }
        
        let d = dot(n, points.0)
        let t = (d - dot(n, ray.origin)) / nd
        
        if (t < 0.0) {
            intersection.isIntersecting = false
            return intersection
        }
        
        let q = ray.pointAt(t: t)
        
        let q01 = cross(points.1 - points.0, q - points.0)
        if dot(n, q01) <= 0.0 {
            intersection.isIntersecting = false
            return intersection
        }
        
        let q12 = cross(points.2 - points.1, q - points.1)
        if dot(n, q12) <= 0.0 {
            intersection.isIntersecting = false
            return intersection
        }
        
        let q02 = cross(points.0 - points.2, q - points.2)
        if dot(n, q02) <= 0.0 {
            intersection.isIntersecting = false
            return intersection
        }
        
        let a = area()
        let b0 = 0.5 * length(q12) / a
        let b1 = 0.5 * length(q02) / a
        let b2 = 0.5 * length(q01) / a
        
        var normal = b0 * normals.0
        normal += b1 * normals.1
        normal += b2 * normals.2
        
        intersection.isIntersecting = true
        intersection.distance = t
        intersection.point = q
        intersection.normal = normalize(normal)
        
        return intersection
    }
    
    //MARK:- Builder
    /// Front-end to create Triangle3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        /// Three points.
        var _points:Vector3FArray3 = (Vector3F(), Vector3F(), Vector3F())
        
        /// Three normals.
        var _normals:Vector3FArray3 = (Vector3F(), Vector3F(), Vector3F())
        
        /// Three UV coordinates.
        var _uvs:Vector2FArray3 = (Vector2F(), Vector2F(), Vector2F())
        
        /// Returns builder with points.
        func withPoints(points:Vector3FArray3)->Builder{
            _points = points
            return self
        }
        
        /// Returns builder with normals.
        func withNormals(normals:Vector3FArray3)->Builder{
            _normals = normals
            return self
        }
        
        /// Returns builder with uvs.
        func withUvs(uvs:Vector2FArray3)->Builder{
            _uvs = uvs
            return self
        }
        
        /// Builds Triangle3.
        func build()->Triangle3{
            return Triangle3(points: _points,
                             normals: _normals,
                             uvs: _uvs,
                             transform: _transform,
                             isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox Triangle3.
    static func builder()->Builder{
        return Builder()
    }
}
