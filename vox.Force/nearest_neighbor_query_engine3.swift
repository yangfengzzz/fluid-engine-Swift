//
//  nearest_neighbor_query_engine3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Nearest neighbor query result.
struct NearestNeighborQueryResult3<T> {
    var item:T?  = nil
    var distance:Float = Float.greatestFiniteMagnitude
}

/// Nearest neighbor distance measure function.
typealias NearestNeighborDistanceFunc3<T> = (T, Vector3F)->Float

/// Abstract base class for 3-D nearest neigbor query engine.
protocol NearestNeighborQueryEngine3 {
    associatedtype T
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func nearest(pt:Vector3F,
                 distanceFunc:NearestNeighborDistanceFunc3<T>)->NearestNeighborQueryResult3<T>
}
