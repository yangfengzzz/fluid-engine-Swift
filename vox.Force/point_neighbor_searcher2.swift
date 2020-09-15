//
//  point_neighbor_searcher2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D neighbor point searcher.
///
/// This class provides interface for 2-D neighbor point searcher. For given
/// list of points, the class builds internal cache to accelerate the search.
/// Once built, the data structure is used to search nearby points for given
/// origin point.
///
protocol PointNeighborSearcher2 {
    
    typealias ForEachNearbyPointFunc = (size_t, Vector2F)->Void
    
    /// Returns the type name of the derived class.
    func typeName()->String
    
    /// Builds internal acceleration structure for given points list.
    func build(points:ConstArrayAccessor1<Vector2F>)
    
    /// Invokes the callback function for each nearby point around the origin
    /// within given radius.
    /// - Parameters:
    ///   - origin: The origin position.
    ///   - radius: The search radius.
    ///   - callback: The callback function.
    func forEachNearbyPoint(origin:Vector2F, radius:Float,
                            callback:ForEachNearbyPointFunc)
    
    
    /// Returns true if there are any nearby points for given origin within radius.
    /// - Parameters:
    ///   - origin: The origin.
    ///   - radius: The radius.
    func hasNearbyPoint(origin:Vector2F, radius:Float)->Bool
    
    /// Creates a new instance of the object with same properties
    ///             than original.
    func clone()->PointNeighborSearcher2
}

/// Abstract base class for 2-D point neighbor searcher builders.
protocol PointNeighborSearcherBuilder2 {
    
    /// Returns shared pointer of PointNeighborSearcher2 type.
    func buildPointNeighborSearcher()->PointNeighborSearcher2
}
