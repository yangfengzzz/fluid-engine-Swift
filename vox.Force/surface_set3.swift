//
//  surface_set3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

final class SurfaceSet3:Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    fileprivate var _surfaces:[Surface3] = []
    fileprivate var _unboundedSurfaces:[Surface3] = []
    fileprivate var _bvh:Bvh3<Surface3> = Bvh3<Surface3>()
    fileprivate var _bvhInvalidated:Bool = true
    
    /// Constructs an empty surface set.
    init() {}
    
    /// Constructs with a list of other surfaces.
    init(other:[Surface3],
         transform: Transform3 = Transform3(),
         isNormalFlipped: Bool = false){
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self._surfaces = other
        for surface in self._surfaces {
            if (!surface.isBounded()) {
                self._unboundedSurfaces.append(surface)
            }
        }
        invalidateBvh()
    }
    
    /// Copy constructor.
    init(other:SurfaceSet3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        self._surfaces = other._surfaces
        self._unboundedSurfaces = other._unboundedSurfaces
        invalidateBvh()
    }
    
    /// Updates internal spatial query engine.
    func updateQueryEngine(){
        invalidateBvh()
        buildBvh()
    }
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool{
        // All surfaces should be bounded.
        for surface in _surfaces {
            if (!surface.isBounded()) {
                return false
            }
        }
        
        // Empty set is not bounded.
        return !_surfaces.isEmpty
    }
    
    /// Returns true if the surface is a valid geometry.
    func isValidGeometry()->Bool{
        // All surfaces should be valid.
        for surface in _surfaces {
            if (!surface.isValidGeometry()) {
                return false
            }
        }
        
        // Empty set is not valid.
        return !_surfaces.isEmpty
    }
    
    /// Returns the number of surfaces.
    func numberOfSurfaces()->size_t{
        return _surfaces.count
    }
    
    /// Returns the i-th surface.
    func surfaceAt(i:size_t)->Surface3{
        return _surfaces[i]
    }
    
    /// Adds a surface instance.
    func addSurface(surface:Surface3){
        _surfaces.append(surface)
        if (!surface.isBounded()) {
            _unboundedSurfaces.append(surface)
        }
        invalidateBvh()
    }
    
    // MARK:- Local Operators
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<Surface3> = {(surface:Surface3,
            pt:Vector3F) in
            return surface.closestDistance(otherPoint: pt)
        }
        
        var result = Vector3F(Float.greatestFiniteMagnitude,
                              Float.greatestFiniteMagnitude,
                              Float.greatestFiniteMagnitude)
        let queryResult = _bvh.nearest(pt: otherPoint, distanceFunc: distanceFunc)
        if (queryResult.item != nil) {
            result = queryResult.item!.closestPoint(otherPoint: otherPoint)
        }
        
        var minDist = queryResult.distance
        for surface in _unboundedSurfaces {
            let pt = surface.closestPoint(otherPoint: otherPoint)
            let dist = length(pt - otherPoint)
            if (dist < minDist) {
                minDist = dist
                result = surface.closestPoint(otherPoint: otherPoint)
            }
        }
        
        return result
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        buildBvh()
        
        return _bvh.boundingBox()
    }
    
    func closestDistanceLocal(otherPointLocal:Vector3F)->Float{
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<Surface3> = {(surface:Surface3,
            pt:Vector3F) in
            return surface.closestDistance(otherPoint: pt)
        }
        
        let queryResult = _bvh.nearest(pt: otherPointLocal, distanceFunc: distanceFunc)
        
        var minDist = queryResult.distance
        for surface in _unboundedSurfaces {
            let pt = surface.closestPoint(otherPoint: otherPointLocal)
            let dist = length(pt - otherPointLocal)
            if (dist < minDist) {
                minDist = dist
            }
        }
        
        return minDist
    }
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        buildBvh()
        
        let testFunc:RayIntersectionTestFunc3<Surface3> = {(surface:Surface3, ray:Ray3F) in
            return surface.intersects(ray: ray)
        }
        
        var result = _bvh.intersects(ray: rayLocal, testFunc: testFunc)
        for surface in _unboundedSurfaces {
            result = result || surface.intersects(ray: rayLocal)
        }
        
        return result
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<Surface3> = {(surface:Surface3,
            pt:Vector3F) in
            return surface.closestDistance(otherPoint: pt)
        }
        
        var result = Vector3F(1.0, 0.0, 0.0)
        let queryResult = _bvh.nearest(pt: otherPoint, distanceFunc: distanceFunc)
        if (queryResult.item != nil) {
            result = queryResult.item!.closestNormal(otherPoint: otherPoint)
        }
        
        var minDist = queryResult.distance
        for surface in _unboundedSurfaces {
            let pt = surface.closestPoint(otherPoint: otherPoint)
            let dist = length(pt - otherPoint)
            if (dist < minDist) {
                minDist = dist
                result = surface.closestNormal(otherPoint: otherPoint)
            }
        }
        
        return result
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        buildBvh()
        
        let testFunc:GetRayIntersectionFunc3<Surface3> = {(surface:Surface3, ray:Ray3F) in
            let result = surface.closestIntersection(ray: ray)
            return result.distance
        }
        
        let queryResult = _bvh.closestIntersection(ray: ray, testFunc: testFunc)
        var result = SurfaceRayIntersection3()
        result.distance = queryResult.distance
        result.isIntersecting = queryResult.item != nil
        if (queryResult.item != nil) {
            result.point = ray.pointAt(t: queryResult.distance)
            result.normal = queryResult.item!.closestNormal(otherPoint: result.point)
        }
        
        for surface in _unboundedSurfaces {
            let localResult = surface.closestIntersection(ray: ray)
            if (localResult.distance < result.distance) {
                result = localResult
            }
        }
        
        return result
    }
    
    func isInsideLocal(otherPointLocal:Vector3F)->Bool{
        for surface in _surfaces {
            if (surface.isInside(otherPoint: otherPointLocal)) {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func invalidateBvh(){
        _bvhInvalidated = true
    }
    
    fileprivate func buildBvh(){
        if (_bvhInvalidated) {
            var surfs:[Surface3] = []
            var bounds:[BoundingBox3F] = []
            for i in 0..<_surfaces.count {
                if (_surfaces[i].isBounded()) {
                    surfs.append(_surfaces[i])
                    bounds.append(_surfaces[i].boundingBox())
                }
            }
            _bvh.build(items: surfs, itemsBounds: bounds)
            _bvhInvalidated = false
        }
    }
    
    //MARK:- Builder
    /// Front-end to create SurfaceSet3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        private var _surfaces:[Surface3] = []
        
        /// Returns builder with other surfaces.
        func withSurfaces(others:[Surface3])->Builder{
            _surfaces = others
            return self
        }
        
        /// Builds SurfaceSet3.
        func build()->SurfaceSet3{
            return SurfaceSet3(other: _surfaces,
                               transform: _transform,
                               isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder for SurfaceSet3.
    static func builder()->Builder{
        return Builder()
    }
}
