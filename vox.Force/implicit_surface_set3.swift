//
//  implicit_surface_set3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D implicit surface set.
///
/// This class represents 3-D implicit surface set which extends
/// ImplicitSurface3 by overriding implicit surface-related quries. This is
/// class can hold a collection of other implicit surface instances.
class ImplicitSurfaceSet3: ImplicitSurface3 {
    var transform: Transform3 = Transform3()
    var isNormalFlipped: Bool = false
    
    var _surfaces:[ImplicitSurface3] = []
    var _unboundedSurfaces:[ImplicitSurface3] = []
    var _bvh = Bvh3<ImplicitSurface3>()
    var _bvhInvalidated:Bool = true
    
    /// Constructs an empty implicit surface set.
    init() {}
    
    /// Constructs an implicit surface set using list of other surfaces.
    init(surfaces:[ImplicitSurface3],
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        self._surfaces = surfaces
        
        for surface in _surfaces {
            if (!surface.isBounded()) {
                _unboundedSurfaces.append(surface)
            }
        }
        invalidateBvh()
    }
    
    /// Constructs an implicit surface set using list of other surfaces.
    init(surfaces:[Surface3],
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        for surface in surfaces {
            addExplicitSurface(surface: surface)
        }
    }
    
    /// Copy constructor.
    init(other:ImplicitSurfaceSet3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        
        self._surfaces = other._surfaces
        self._unboundedSurfaces = other._unboundedSurfaces
    }
    
    /// Updates internal spatial query engine.
    func updateQueryEngine() {
        invalidateBvh()
        buildBvh()
    }
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool {
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
    func isValidGeometry()->Bool {
        // All surfaces should be valid.
        for surface in _surfaces {
            if (!surface.isValidGeometry()) {
                return false
            }
        }
        
        // Empty set is not valid.
        return !_surfaces.isEmpty
    }
    
    /// Returns the number of implicit surfaces.
    func numberOfSurfaces()->size_t {
        return _surfaces.count
    }
    
    /// Returns the i-th implicit surface.
    func surfaceAt(i:size_t)->ImplicitSurface3 {
        return _surfaces[i]
    }
    
    /// Adds an explicit surface instance.
    func addExplicitSurface(surface:Surface3) {
        addSurface(surface: SurfaceToImplicit3(surface: surface))
    }
    
    /// Adds an implicit surface instance.
    func addSurface(surface:ImplicitSurface3) {
        _surfaces.append(surface)
        if (!surface.isBounded()) {
            _unboundedSurfaces.append(surface)
        }
        invalidateBvh()
    }
    
    func closestPointLocal(otherPoint:Vector3F)->Vector3F {
        buildBvh()
        
        let distanceFunc = {(surface:Surface3,
            pt:Vector3F)->Float in
            return surface.closestDistance(otherPoint: pt)
        }
        
        var result = Vector3F(Float.greatestFiniteMagnitude,
                              Float.greatestFiniteMagnitude,
                              Float.greatestFiniteMagnitude)
        let queryResult = _bvh.nearest(pt: otherPoint,
                                       distanceFunc: distanceFunc)
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
    
    func boundingBoxLocal()->BoundingBox3F {
        buildBvh()
        
        return _bvh.boundingBox()
    }
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float {
        buildBvh()
        
        let distanceFunc = {(surface:Surface3,
            pt:Vector3F)->Float in
            return surface.closestDistance(otherPoint: pt)
        }
        
        let queryResult = _bvh.nearest(pt: otherPoint,
                                       distanceFunc: distanceFunc)
        
        var minDist = queryResult.distance
        for surface in _unboundedSurfaces {
            let pt = surface.closestPoint(otherPoint: otherPoint)
            let dist = length(pt - otherPoint)
            if (dist < minDist) {
                minDist = dist
            }
        }
        
        return minDist
    }
    
    func intersectsLocal(ray:Ray3F)->Bool {
        buildBvh()
        
        let testFunc = {(surface:Surface3, ray:Ray3F)->Bool in
            return surface.intersects(ray: ray)
        }
        
        var result = _bvh.intersects(ray: ray,
                                     testFunc: testFunc)
        for surface in _unboundedSurfaces {
            result = surface.intersects(ray: ray) || result
        }
        
        return result
    }
    
    func closestNormalLocal(otherPoint:Vector3F)->Vector3F {
        buildBvh()
        
        let distanceFunc = {(surface:Surface3,
            pt:Vector3F)->Float in
            return surface.closestDistance(otherPoint: pt)
        }
        
        var result = Vector3F(1.0, 0.0, 0.0)
        let queryResult = _bvh.nearest(pt: otherPoint,
                                       distanceFunc: distanceFunc)
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
    
    func closestIntersectionLocal(ray:Ray3F)->SurfaceRayIntersection3 {
        buildBvh()
        
        let testFunc = {(surface:Surface3, ray:Ray3F)->Float in
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
    
    func isInsideLocal(otherPoint:Vector3F)->Bool {
        for surface in _surfaces {
            if (surface.isInside(otherPoint: otherPoint)) {
                return true
            }
        }
        
        return false
    }
    
    func signedDistanceLocal(otherPoint:Vector3F)->Float {
        var sdf = Float.greatestFiniteMagnitude
        for surface in _surfaces {
            sdf = min(sdf, surface.signedDistance(otherPoint: otherPoint))
        }
        
        return sdf
    }
    
    func invalidateBvh() {
        _bvhInvalidated = true
    }
    
    func buildBvh() {
        if (_bvhInvalidated) {
            var surfs:[ImplicitSurface3] = []
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
    class Builder: SurfaceBuilderBase3<Builder> {
        var _surfaces:[ImplicitSurface3] = []
        
        /// Returns builder with surfaces.
        func withSurfaces(surfaces:[ImplicitSurface3])->Builder {
            _surfaces = surfaces
            return self
        }
        
        /// Returns builder with explicit surfaces.
        func withExplicitSurfaces(surfaces:[Surface3])->Builder {
            _surfaces = []
            for surface in surfaces {
                _surfaces.append(SurfaceToImplicit3(surface: surface))
            }
            
            return self
        }
        
        /// Builds ImplicitSurfaceSet3.
        func build()->ImplicitSurfaceSet3 {
            return ImplicitSurfaceSet3(surfaces: _surfaces, transform: _transform,
                                       isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox ImplicitSurfaceSet3.
    static func builder()->Builder{
        return Builder()
    }
}
