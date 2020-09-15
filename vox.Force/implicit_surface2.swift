//
//  implicit_surface2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D implicit surface.
protocol ImplicitSurface2: Surface2 {
    /// Returns signed distance from the given point \p otherPoint.
    func signedDistance(otherPoint:Vector2F)->Float
    
    /// Returns signed distance from the given point \p otherPoint in local
    /// space.
    func signedDistanceLocal(otherPoint:Vector2F)->Float
    
    func closestDistanceLocal(otherPoint:Vector2F)->Float
    
    func isInsideLocal(otherPoint:Vector2F)->Bool
}

extension ImplicitSurface2 {
    func signedDistance(otherPoint:Vector2F)->Float {
        let sd = signedDistanceLocal(otherPoint: transform.toLocal(pointInWorld: otherPoint))
        return (isNormalFlipped) ? -sd : sd
    }
    
    func closestDistanceLocal(otherPoint:Vector2F)->Float {
        return abs(signedDistanceLocal(otherPoint: otherPoint))
    }
    
    func isInsideLocal(otherPoint:Vector2F)->Bool {
        return isInsideSdf(phi: signedDistanceLocal(otherPoint: otherPoint))
    }
}
