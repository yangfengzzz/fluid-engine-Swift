//
//  intersection_query_engine2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Closest intersection query result.
struct ClosestIntersectionQueryResult2<T> {
    var item:T? = nil
    var distance:Float = Float.greatestFiniteMagnitude
}

///Closest intersection distance measure function.
typealias ClosestIntersectionDistanceFunc2<T> = (T, Vector2D)->Float
/// Box-item intersection test function.
typealias BoxIntersectionTestFunc2<T> = (T, BoundingBox2F)->Bool
/// Ray-item intersection test function.
typealias RayIntersectionTestFunc2<T> = (T, Ray2F)->Bool
/// Ray-item closest intersection evaluation function.
typealias GetRayIntersectionFunc2<T> = (T, Ray2F)->Float
/// Visitor function which is invoked for each intersecting item.
typealias IntersectionVisitorFunc2<T> = (T)->Void

/// Abstract base class for 2-D intersection test query engine.
protocol IntersectionQueryEngine2 {
    associatedtype T
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box:BoundingBox2F,
                    testFunc:BoxIntersectionTestFunc2<T>)->Bool
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray:Ray2F,
                    testFunc:RayIntersectionTestFunc2<T>)->Bool
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box:BoundingBox2F,
                                 testFunc:BoxIntersectionTestFunc2<T>,
                                 visitorFunc:IntersectionVisitorFunc2<T>)
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray:Ray2F,
                                 testFunc:RayIntersectionTestFunc2<T>,
                                 visitorFunc:IntersectionVisitorFunc2<T>)
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray:Ray2F,
                             testFunc:GetRayIntersectionFunc2<T>)->ClosestIntersectionQueryResult2<T>
}
