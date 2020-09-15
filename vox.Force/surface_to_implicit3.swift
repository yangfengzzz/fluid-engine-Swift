//
//  surface_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D implicit surface wrapper for generic Surface3 instance.
///
/// This class represents 3-D implicit surface that converts Surface3 instance
/// to an ImplicitSurface3 object. The conversion is made by evaluating closest
/// point and normal from a given point for the given (explicit) surface. Thus,
/// this conversion won't work for every single surfaces. Use this class only
/// for the basic primitives such as Sphere3 or Box3.
class SurfaceToImplicit3: ImplicitSurface3 {
    var transform: Transform3 = Transform3()
    var isNormalFlipped: Bool = false
    
    var _surface:Surface3
    
    /// Constructs an instance with generic Surface3 instance.
    init(surface:Surface3,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self._surface = surface
        
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Copy constructor.
    init(other:SurfaceToImplicit3) {
        self._surface = other._surface
        
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
    }
    
    /// Updates internal spatial query engine.
    func updateQueryEngine() {
        _surface.updateQueryEngine()
    }
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool {
        return _surface.isBounded()
    }
    
    /// Returns true if the surface is a valid geometry.
    func isValidGeometry()->Bool {
        return _surface.isValidGeometry()
    }
    
    /// Returns the raw surface instance.
    func surface()->Surface3 {
        return _surface
    }
    
    func closestPointLocal(otherPoint:Vector3F)->Vector3F {
        return _surface.closestPoint(otherPoint: otherPoint)
    }
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float {
        return _surface.closestDistance(otherPoint: otherPoint)
    }
    
    func intersectsLocal(ray:Ray3F)->Bool {
        return _surface.intersects(ray: ray)
    }
    
    func boundingBoxLocal()->BoundingBox3F {
        return _surface.boundingBox()
    }
    
    func closestNormalLocal(otherPoint:Vector3F)->Vector3F {
        return _surface.closestNormal(otherPoint: otherPoint)
    }
    
    func signedDistanceLocal(otherPoint:Vector3F)->Float {
        let x = _surface.closestPoint(otherPoint: otherPoint)
        let inside = _surface.isInside(otherPoint: otherPoint)
        return (inside) ? -length(x - otherPoint) : length(x - otherPoint)
    }
    
    func closestIntersectionLocal(ray:Ray3F)->SurfaceRayIntersection3 {
        return _surface.closestIntersection(ray: ray)
    }
    
    func isInsideLocal(otherPoint:Vector3F)->Bool {
        return _surface.isInside(otherPoint: otherPoint)
    }
    
    //MARK:- Builder
    class Builder: SurfaceBuilderBase3<Builder> {
        var _surface:Surface3?
        /// Returns builder with surface.
        func withSurface(surface:Surface3)->Builder {
            _surface = surface
            return self
        }
        
        /// Builds SurfaceToImplicit3.
        func build()->SurfaceToImplicit3 {
            return SurfaceToImplicit3(surface: _surface!,
                                      transform: _transform,
                                      isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox SurfaceToImplicit3.
    static func builder()->Builder{
        return Builder()
    }
}
