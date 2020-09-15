//
//  list_query_engine2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Ad-hoc list-based 2-D intersection/nearest-neighbor query engine.
class ListQueryEngine2<T> : IntersectionQueryEngine2&NearestNeighborQueryEngine2{
    
    /// Adds an item to the container.
    func add(item:T){
        _items.append(item)
    }
    
    /// Adds items to the container.
    func add(items:[T]){
        _items.append(contentsOf: items)
    }
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box: BoundingBox2F, testFunc: BoxIntersectionTestFunc2<T>) -> Bool {
        for item in _items{
            if testFunc(item, box) {
                return true
            }
        }
        return false
    }
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray: Ray2F, testFunc: RayIntersectionTestFunc2<T>) -> Bool {
        for item in _items{
            if testFunc(item, ray) {
                return true
            }
        }
        return false
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box: BoundingBox2F, testFunc: BoxIntersectionTestFunc2<T>,
                                 visitorFunc: IntersectionVisitorFunc2<T>) {
        for item in _items{
            if testFunc(item, box) {
                visitorFunc(item)
            }
        }
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray: Ray2F, testFunc: RayIntersectionTestFunc2<T>,
                                 visitorFunc: IntersectionVisitorFunc2<T>) {
        for item in _items{
            if testFunc(item, ray) {
                visitorFunc(item)
            }
        }
    }
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray: Ray2F, testFunc: GetRayIntersectionFunc2<T>)
        -> ClosestIntersectionQueryResult2<T> {
        var best = ClosestIntersectionQueryResult2<T>()
        for item in _items{
            let dist = testFunc(item, ray)
            if dist < best.distance {
                best.distance = dist
                best.item = item
            }
        }
        
        return best
    }
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func nearest(pt: Vector2F, distanceFunc: NearestNeighborDistanceFunc2<T>)
        -> NearestNeighborQueryResult2<T> {
        var best = NearestNeighborQueryResult2<T>()
        for item in _items{
            let dist = distanceFunc(item, pt)
            if dist < best.distance {
                best.distance = dist
                best.item = item
            }
        }
        
        return best
    }
    
    // MARK:- Private
    private var _items:[T] = []
}
