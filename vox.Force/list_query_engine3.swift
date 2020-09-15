//
//  list_query_engine3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Ad-hoc list-based 3-D intersection/nearest-neighbor query engine.
class ListQueryEngine3<T> : IntersectionQueryEngine3&NearestNeighborQueryEngine3{
    
    /// Adds an item to the container.
    func add(item:T){
        _items.append(item)
    }
    
    /// Adds items to the container.
    func add(items:[T]){
        _items.append(contentsOf: items)
    }
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box: BoundingBox3F, testFunc: BoxIntersectionTestFunc3<T>) -> Bool {
        for item in _items{
            if testFunc(item, box) {
                return true
            }
        }
        return false
    }
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray: Ray3F, testFunc: RayIntersectionTestFunc3<T>) -> Bool {
        for item in _items{
            if testFunc(item, ray) {
                return true
            }
        }
        return false
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box: BoundingBox3F, testFunc: BoxIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        for item in _items{
            if testFunc(item, box) {
                visitorFunc(item)
            }
        }
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray: Ray3F, testFunc: RayIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        for item in _items{
            if testFunc(item, ray) {
                visitorFunc(item)
            }
        }
    }
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray: Ray3F, testFunc: GetRayIntersectionFunc3<T>)
        -> ClosestIntersectionQueryResult3<T> {
        var best = ClosestIntersectionQueryResult3<T>()
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
    func nearest(pt: Vector3F, distanceFunc: NearestNeighborDistanceFunc3<T>)
        -> NearestNeighborQueryResult3<T> {
        var best = NearestNeighborQueryResult3<T>()
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
