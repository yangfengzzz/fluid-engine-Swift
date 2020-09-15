//
//  surface_to_implicit2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D implicit surface wrapper for generic Surface2 instance.
///
/// This class represents 2-D implicit surface that converts Surface2 instance
/// to an ImplicitSurface2 object. The conversion is made by evaluating closest
/// point and normal from a given point for the given (explicit) surface. Thus,
/// this conversion won't work for every single surfaces. Use this class only
/// for the basic primitives such as Sphere2 or Box2.
class SurfaceToImplicit2: ImplicitSurface2 {    
    var transform: Transform2 = Transform2()
    var isNormalFlipped: Bool = false
    
    var _surface:Surface2
    
    /// Constructs an instance with generic Surface2 instance.
    init(surface:Surface2,
         transform:Transform2 = Transform2(),
         isNormalFlipped:Bool = false) {
        self._surface = surface
        
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Copy constructor.
    init(other:SurfaceToImplicit2) {
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
    func surface()->Surface2 {
        return _surface
    }
    
    func closestPointLocal(otherPoint:Vector2F)->Vector2F {
        return _surface.closestPoint(otherPoint: otherPoint)
    }
    
    func closestDistanceLocal(otherPoint:Vector2F)->Float {
        return _surface.closestDistance(otherPoint: otherPoint)
    }
    
    func intersectsLocal(ray:Ray2F)->Bool {
        return _surface.intersects(ray: ray)
    }
    
    func boundingBoxLocal()->BoundingBox2F {
        return _surface.boundingBox()
    }
    
    func closestNormalLocal(otherPoint:Vector2F)->Vector2F {
        return _surface.closestNormal(otherPoint: otherPoint)
    }
    
    func signedDistanceLocal(otherPoint:Vector2F)->Float {
        let x = _surface.closestPoint(otherPoint: otherPoint)
        let inside = _surface.isInside(otherPoint: otherPoint)
        return (inside) ? -length(x - otherPoint) : length(x - otherPoint)
    }
    
    func closestIntersectionLocal(ray:Ray2F)->SurfaceRayIntersection2 {
        return _surface.closestIntersection(ray: ray)
    }
    
    func isInsideLocal(otherPoint:Vector2F)->Bool {
        return _surface.isInside(otherPoint: otherPoint)
    }
    
    //MARK:- Builder
    class Builder: SurfaceBuilderBase2<Builder> {
        var _surface:Surface2?
        /// Returns builder with surface.
        func withSurface(surface:Surface2)->Builder {
            _surface = surface
            return self
        }
        
        /// Builds SurfaceToImplicit2.
        func build()->SurfaceToImplicit2 {
            return SurfaceToImplicit2(surface: _surface!,
                                      transform: _transform,
                                      isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox SurfaceToImplicit2.
    static func builder()->Builder{
        return Builder()
    }
}
