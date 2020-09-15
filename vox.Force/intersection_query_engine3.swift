//
//  intersection_query_engine3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Closest intersection query result.
struct ClosestIntersectionQueryResult3<T> {
    var item:T? = nil
    var distance:Float = Float.greatestFiniteMagnitude
}

///Closest intersection distance measure function.
typealias ClosestIntersectionDistanceFunc3<T> = (T, Vector3F)->Float
/// Box-item intersection test function.
typealias BoxIntersectionTestFunc3<T> = (T, BoundingBox3F)->Bool
/// Ray-item intersection test function.
typealias RayIntersectionTestFunc3<T> = (T, Ray3F)->Bool
/// Ray-item closest intersection evaluation function.
typealias GetRayIntersectionFunc3<T> = (T, Ray3F)->Float
/// Visitor function which is invoked for each intersecting item.
typealias IntersectionVisitorFunc3<T> = (T)->Void

/// Abstract base class for 3-D intersection test query engine.
protocol IntersectionQueryEngine3 {
    associatedtype T
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box:BoundingBox3F,
                    testFunc:BoxIntersectionTestFunc3<T>)->Bool
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray:Ray3F,
                    testFunc:RayIntersectionTestFunc3<T>)->Bool
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box:BoundingBox3F,
                                 testFunc:BoxIntersectionTestFunc3<T>,
                                 visitorFunc:IntersectionVisitorFunc3<T>)
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray:Ray3F,
                                 testFunc:RayIntersectionTestFunc3<T>,
                                 visitorFunc:IntersectionVisitorFunc3<T>)
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray:Ray3F,
                             testFunc:GetRayIntersectionFunc3<T>)->ClosestIntersectionQueryResult3<T>
}
