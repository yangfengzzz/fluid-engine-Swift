//
//  implicit_surface3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D implicit surface.
protocol ImplicitSurface3: Surface3 {
    /// Returns signed distance from the given point \p otherPoint.
    func signedDistance(otherPoint:Vector3F)->Float
    
    /// Returns signed distance from the given point \p otherPoint in local
    /// space.
    func signedDistanceLocal(otherPoint:Vector3F)->Float
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float
    
    func isInsideLocal(otherPoint:Vector3F)->Bool
}

extension ImplicitSurface3 {
    func signedDistance(otherPoint:Vector3F)->Float {
        let sd = signedDistanceLocal(otherPoint: transform.toLocal(pointInWorld: otherPoint))
        return (isNormalFlipped) ? -sd : sd
    }
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float {
        return abs(signedDistanceLocal(otherPoint: otherPoint))
    }
    
    func isInsideLocal(otherPoint:Vector3F)->Bool {
        return isInsideSdf(phi: signedDistanceLocal(otherPoint: otherPoint))
    }
}
