//
//  point_simple_list_searcher2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Simple ad-hoc 2-D point searcher.
///
/// This class implements 2-D point searcher simply by looking up every point in
/// the list. Thus, this class is not ideal for searches involing large number
/// of points, but only for small set of items.
class PointSimpleListSearcher2: PointNeighborSearcher2 {
    var _points:[Vector2F] = []
    
    func typeName() -> String {
        return "PointSimpleListSearcher2"
    }
    
    /// Default constructor.
    init() {}
    
    /// Copy constructor.
    init(other:PointSimpleListSearcher2) {
        set(other: other)
    }
    
    /// Builds internal structure for given points list.
    ///
    /// For this class, this function simply copies the given point list to the
    /// internal list.
    /// - Parameter points: The points to search.
    func build(points:ConstArrayAccessor1<Vector2F>) {
        _points = Array<Vector2F>(repeating: Vector2F(), count: points.size())
        for i in 0..<points.size() {
            _points[i] = points[i]
        }
    }
    
    /// Invokes the callback function for each nearby point around the origin
    /// within given radius.
    /// - Parameters:
    ///   - origin: The origin position.
    ///   - radius: The search radius.
    ///   - callback: The callback function.
    func forEachNearbyPoint(origin:Vector2F,
                            radius:Float,
                            callback:ForEachNearbyPointFunc) {
        let radiusSquared = radius * radius
        for i in 0..<_points.count {
            let r = _points[i] - origin
            let distanceSquared = dot(r, r)
            if (distanceSquared <= radiusSquared) {
                callback(i, _points[i])
            }
        }
    }
    
    /// Returns true if there are any nearby points for given origin within
    /// radius.
    /// - Parameters:
    ///   - origin: The origin.
    ///   - radius: The radius.
    /// - Returns: True if has nearby point, false otherwise.
    func hasNearbyPoint(origin:Vector2F,
                        radius:Float)->Bool {
        let radiusSquared = radius * radius
        for i in 0..<_points.count {
            let r = _points[i] - origin
            let distanceSquared = dot(r, r)
            if (distanceSquared <= radiusSquared) {
                return true
            }
        }
        
        return false
    }
    
    /// Creates a new instance of the object with same properties
    ///             than original.
    /// - Returns: Copy of this object.
    func clone()->PointNeighborSearcher2 {
        PointSimpleListSearcher2(other: self)
    }
    
    /// Copy from the other instance.
    func set(other:PointSimpleListSearcher2) {
        _points = other._points
    }
    
    //MARK:- Builder
    /// Front-end to create PointSimpleListSearcher2 objects step by step.
    class Builder: PointNeighborSearcherBuilder2 {
        /// Builds PointSimpleListSearcher2 instance.
        func build()->PointSimpleListSearcher2 {
            return PointSimpleListSearcher2()
        }
        
        /// Returns shared pointer of PointNeighborSearcher3 type.
        func buildPointNeighborSearcher()->PointNeighborSearcher2 {
            return build()
        }
    }
    
    /// Returns builder fox PointSimpleListSearcher2.
    static func builder()->Builder{
        return Builder()
    }
}
