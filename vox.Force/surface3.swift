//
//  surface3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Struct that represents ray-surface intersection point.
struct SurfaceRayIntersection3 {
    var isIntersecting = false
    var distance = Float.greatestFiniteMagnitude
    var point = Vector3F()
    var normal = Vector3F()
}

/// Abstract base class for 3-D surface.
protocol Surface3 {
    /// Local-to-world transform.
    var transform:Transform3 {get set}
    
    /// Flips normal.
    var isNormalFlipped:Bool {get set}
    
    // MARK:- Global Opeator
    /// Returns the closest point from the given point \p otherPoint to the surface.
    func closestPoint(otherPoint:Vector3F)->Vector3F
    
    /// Returns the bounding box of this surface object.
    func boundingBox()->BoundingBox3F
    
    /// Returns true if the given \p ray intersects with this surface object.
    func intersects(ray:Ray3F)->Bool
    
    /// Returns the closest distance from the given point \p otherPoint to the
    /// point on the surface.
    func closestDistance(otherPoint:Vector3F)->Float
    
    /// Returns the closest intersection point for given \p ray.
    func closestIntersection(ray:Ray3F)->SurfaceRayIntersection3
    
    /// Returns the normal to the closest point on the surface from the given
    /// point \p otherPoint.
    func closestNormal(otherPoint:Vector3F)->Vector3F
    
    /// Updates internal spatial query engine.
    func updateQueryEngine()
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool
    
    /// Returns true if the surface is a valid geometry.
    func isValidGeometry()->Bool
    
    /// Returns true if \p otherPoint is inside the volume defined by the surface.
    func isInside(otherPoint:Vector3F)->Bool
    
    // MARK:- Local Opeator
    /// Returns the closest point from the given point \p otherPoint to the
    /// surface in local frame.
    func closestPointLocal(otherPoint:Vector3F) -> Vector3F
    
    /// Returns the bounding box of this surface object in local frame.
    func boundingBoxLocal() -> BoundingBox3F
    
    /// Returns the closest intersection point for given \p ray in local frame.
    func closestIntersectionLocal(ray:Ray3F) -> SurfaceRayIntersection3
    
    /// Returns the normal to the closest point on the surface from the given
    /// point \p otherPoint in local frame.
    func closestNormalLocal(otherPoint:Vector3F) -> Vector3F
    
    /// Returns true if the given \p ray intersects with this surface object
    /// in local frame.
    func intersectsLocal(rayLocal:Ray3F)->Bool
    
    /// Returns the closest distance from the given point \p otherPoint to the
    /// point on the surface in local frame.
    func closestDistanceLocal(otherPointLocal:Vector3F)->Float
    
    /// Returns true if \p otherPoint is inside by given \p depth the volume
    /// defined by the surface in local frame.
    func isInsideLocal(otherPointLocal:Vector3F)->Bool
}


extension Surface3 {    
    // MARK:- Global Opeator
    /// Returns the closest point from the given point \p otherPoint to the surface.
    func closestPoint(otherPoint:Vector3F)->Vector3F{
        return transform.toWorld(pointInLocal:
            closestPointLocal(otherPoint:
                transform.toLocal(pointInWorld:
                    otherPoint)))
    }
    
    /// Returns the bounding box of this surface object.
    func boundingBox()->BoundingBox3F{
        return transform.toWorld(bboxInLocal: boundingBoxLocal())
    }
    
    /// Returns true if the given \p ray intersects with this surface object.
    func intersects(ray:Ray3F)->Bool{
        return intersectsLocal(rayLocal: transform.toLocal(rayInWorld: ray))
    }
    
    /// Returns the closest distance from the given point \p otherPoint to the
    /// point on the surface.
    func closestDistance(otherPoint:Vector3F)->Float{
        return closestDistanceLocal(otherPointLocal: transform.toLocal(pointInWorld: otherPoint))
    }
    
    /// Returns the closest intersection point for given \p ray.
    func closestIntersection(ray:Ray3F)->SurfaceRayIntersection3{
        var result = closestIntersectionLocal(ray: transform.toLocal(rayInWorld: ray))
        result.point = transform.toWorld(pointInLocal: result.point)
        result.normal = transform.toWorldDirection(dirInLocal: result.normal)
        result.normal *= (isNormalFlipped) ? -1.0 : 1.0
        return result
    }
    
    /// Returns the normal to the closest point on the surface from the given
    /// point \p otherPoint.
    func closestNormal(otherPoint:Vector3F)->Vector3F{
        var result = transform.toWorldDirection(
            dirInLocal: closestNormalLocal(otherPoint:
                transform.toLocal(pointInWorld:
                    otherPoint)))
        result *= (isNormalFlipped) ? -1.0 : 1.0
        return result
    }
    
    /// Updates internal spatial query engine.
    func updateQueryEngine(){}
    
    /// Returns true if bounding box can be defined.
    func isBounded()->Bool{
        return true
    }
    
    /// Returns true if the surface is a valid geometry.
    func isValidGeometry()->Bool{
        return true
    }
    
    /// Returns true if \p otherPoint is inside the volume defined by the surface.
    func isInside(otherPoint:Vector3F)->Bool{
        return isNormalFlipped == !isInsideLocal(otherPointLocal:
            transform.toLocal(pointInWorld:
                otherPoint))
    }
    
    // MARK:- Local Opeator
    
    /// Returns true if the given \p ray intersects with this surface object
    /// in local frame.
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        let result = closestIntersectionLocal(ray: rayLocal)
        return result.isIntersecting
    }
    
    /// Returns the closest distance from the given point \p otherPoint to the
    /// point on the surface in local frame.
    func closestDistanceLocal(otherPointLocal:Vector3F)->Float{
        return length(otherPointLocal - closestPointLocal(otherPoint: otherPointLocal))
    }
    
    /// Returns true if \p otherPoint is inside by given \p depth the volume
    /// defined by the surface in local frame.
    func isInsideLocal(otherPointLocal:Vector3F)->Bool{
        let cpLocal = closestPointLocal(otherPoint: otherPointLocal)
        let normalLocal = closestNormalLocal(otherPoint: otherPointLocal)
        return dot(otherPointLocal - cpLocal, normalLocal) < 0.0
    }
}

/// Base class for 3-D surface builder.
class SurfaceBuilderBase3<DerivedBuilder>{
    var _transform:Transform3 = Transform3()
    var _isNormalFlipped:Bool = false
    
    /// Returns builder with flipped normal flag.
    func withIsNormalFlipped(isNormalFlipped:Bool)->DerivedBuilder{
        _isNormalFlipped = isNormalFlipped
        return self as! DerivedBuilder
    }
    
    /// Returns builder with translation.
    func withTranslation(translation:Vector3F)->DerivedBuilder{
        _transform.setTranslation(translation: translation)
        return self as! DerivedBuilder
    }
    
    /// Returns builder with orientation.
    func withOrientation(orientation:simd_quatf)->DerivedBuilder{
        _transform.setOrientation(orientation: orientation)
        return self as! DerivedBuilder
    }
    
    /// Returns builder with transform.
    func withTransform(transform:Transform3)->DerivedBuilder{
        _transform = transform
        return self as! DerivedBuilder
    }
}
