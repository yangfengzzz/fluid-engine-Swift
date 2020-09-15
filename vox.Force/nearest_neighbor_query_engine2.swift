//
//  nearest_neighbor_query_engine2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Nearest neighbor query result.
struct NearestNeighborQueryResult2<T> {
    var item:T?  = nil
    var distance:Float = Float.greatestFiniteMagnitude
}

/// Nearest neighbor distance measure function.
typealias NearestNeighborDistanceFunc2<T> = (T, Vector2F)->Float

/// Abstract base class for 2-D nearest neigbor query engine.
protocol NearestNeighborQueryEngine2 {
    associatedtype T
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func nearest(pt:Vector2F,
                 distanceFunc:NearestNeighborDistanceFunc2<T>)->NearestNeighborQueryResult2<T>
}
