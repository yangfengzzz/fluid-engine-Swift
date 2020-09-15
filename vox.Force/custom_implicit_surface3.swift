//
//  custom_implicit_surface3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Custom 3-D implicit surface using arbitrary function.
class CustomImplicitSurface3: ImplicitSurface3 {
    var transform: Transform3 = Transform3()
    var isNormalFlipped: Bool = false
    
    var _func:(Vector3F)->Float
    var _domain:BoundingBox3F = BoundingBox3F()
    var _resolution:Float = 1e-3
    var _rayMarchingResolution:Float = 1e-6
    var _maxNumOfIterations:UInt = 5
    
    /// Constructs an implicit surface using the given signed-distance function.
    /// - Parameters:
    ///   - function: Custom SDF function object.
    ///   - domain: Bounding box of the SDF if exists.
    ///   - resolution: Finite differencing resolution for derivatives.
    ///   - rayMarchingResolution: Ray marching resolution for ray tests.
    ///   - numberOfIterations: Number of iterations for closest point search.
    ///   - transform: Local-to-world transform.
    ///   - isNormalFlipped: True if normal is flipped.
    init(function:@escaping (Vector3F)->Float,
         domain:BoundingBox3F = BoundingBox3F(),
         resolution:Float = 1e-3,
         rayMarchingResolution:Float = 1e-6,
         numberOfIterations:UInt = 5,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self._func = function
        self._domain = domain
        self._resolution = resolution
        self._rayMarchingResolution = rayMarchingResolution
        self._maxNumOfIterations = numberOfIterations
        
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    func closestPointLocal(otherPoint:Vector3F)->Vector3F {
        var pt = clamp(otherPoint, min: _domain.lowerCorner, max: _domain.upperCorner)
        for _ in 0..<_maxNumOfIterations {
            let sdf = signedDistanceLocal(otherPoint: pt)
            if (abs(sdf) < Float.leastNonzeroMagnitude) {
                break
            }
            let g = gradientLocal(x: pt)
            pt = pt - sdf * g
        }
        return pt
    }
    
    func intersectsLocal(ray:Ray3F)->Bool {
        let intersection = _domain.closestIntersection(ray: ray)
        
        if (intersection.isIntersecting) {
            var tStart:Float = 0
            var tEnd:Float = 0
            if (intersection.tFar == Float.greatestFiniteMagnitude) {
                tStart = 0.0
                tEnd = intersection.tNear
            } else {
                tStart = intersection.tNear
                tEnd = intersection.tFar
            }
            
            var t = tStart
            var pt = ray.pointAt(t: t)
            var prevPhi = _func(pt)
            while (t <= tEnd) {
                pt = ray.pointAt(t: t)
                let newPhi = _func(pt)
                let newPhiAbs = abs(newPhi)
                
                if (newPhi * prevPhi < 0.0) {
                    return true
                }
                
                t += max(newPhiAbs, _rayMarchingResolution)
                prevPhi = newPhi
            }
        }
        
        return false
    }
    
    func boundingBoxLocal()->BoundingBox3F {
        return _domain
    }
    
    func closestNormalLocal(otherPoint:Vector3F)->Vector3F {
        let pt = closestPointLocal(otherPoint: otherPoint)
        let g = gradientLocal(x: pt)
        if (length_squared(g) > 0.0) {
            return normalize(g)
        } else {
            return g
        }
    }
    
    func signedDistanceLocal(otherPoint:Vector3F)->Float {
        return _func(otherPoint)
    }
    
    func closestIntersectionLocal(ray:Ray3F)->SurfaceRayIntersection3 {
        var result = SurfaceRayIntersection3()
        
        let intersection = _domain.closestIntersection(ray: ray)
        
        if (intersection.isIntersecting) {
            var tStart:Float = 0
            var tEnd:Float = 0
            if (intersection.tFar == Float.greatestFiniteMagnitude) {
                tStart = 0.0
                tEnd = intersection.tNear
            } else {
                tStart = intersection.tNear
                tEnd = intersection.tFar
            }
            
            var t = tStart
            var tPrev = t
            var pt = ray.pointAt(t: t)
            var prevPhi = _func(pt)
            
            while (t <= tEnd) {
                pt = ray.pointAt(t: t)
                let newPhi = _func(pt)
                let newPhiAbs = abs(newPhi)
                
                if (newPhi * prevPhi < 0.0) {
                    let frac = prevPhi / (prevPhi - newPhi)
                    let tSub = tPrev + _rayMarchingResolution * frac
                    
                    result.isIntersecting = true
                    result.distance = tSub
                    result.point = ray.pointAt(t: tSub)
                    result.normal = gradientLocal(x: result.point)
                    if (length(result.normal) > 0.0) {
                        result.normal.normalized()
                    }
                    
                    return result
                }
                
                tPrev = t
                t += max(newPhiAbs, _rayMarchingResolution)
                prevPhi = newPhi
            }
        }
        
        return result
    }
    
    func gradientLocal(x:Vector3F)->Vector3F {
        let left = _func(x - Vector3F(0.5 * _resolution, 0.0, 0.0))
        let right = _func(x + Vector3F(0.5 * _resolution, 0.0, 0.0))
        let bottom = _func(x - Vector3F(0.0, 0.5 * _resolution, 0.0))
        let top = _func(x + Vector3F(0.0, 0.5 * _resolution, 0.0))
        let back = _func(x - Vector3F(0.0, 0.0, 0.5 * _resolution))
        let front = _func(x + Vector3F(0.0, 0.0, 0.5 * _resolution))
        
        return Vector3F((right - left) / _resolution, (top - bottom) / _resolution,
                        (front - back) / _resolution)
    }
    
    //MARK:- Builder
    class Builder: SurfaceBuilderBase3<Builder> {
        var _func:((Vector3F)->Float)?
        var _domain:BoundingBox3F = BoundingBox3F()
        var _resolution:Float = 1e-3
        var _rayMarchingResolution:Float = 1e-6
        var _maxNumOfIterations:UInt = 5
        
        /// Returns builder with custom signed-distance function
        func withSignedDistanceFunction(function:@escaping (Vector3F)->Float)->Builder {
            _func = function
            return self
        }
        
        /// Returns builder with domain.
        func withDomain(domain:BoundingBox3F)->Builder {
            _domain = domain
            return self
        }
        
        /// Returns builder with finite differencing resolution.
        func withResolution(resolution:Float)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with ray marching resolution which determines the ray
        /// intersection quality.
        func withRayMarchingResolution(rayMarchingResolution:Float)->Builder {
            _rayMarchingResolution = rayMarchingResolution
            return self
        }
        
        /// Returns builder with number of iterations for closest point/normal
        /// searches.
        func withMaxNumberOfIterations(numIter:UInt)->Builder {
            _maxNumOfIterations = numIter
            return self
        }
        
        /// Builds CustomImplicitSurface3.
        func build()->CustomImplicitSurface3 {
            return CustomImplicitSurface3(function: _func!, domain: _domain,
                                          resolution: _resolution,
                                          rayMarchingResolution: _rayMarchingResolution,
                                          numberOfIterations: _maxNumOfIterations,
                                          transform: _transform,
                                          isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox CustomImplicitSurface3.
    static func builder()->Builder{
        return Builder()
    }
}
