//
//  point_simple_list_searcher3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Simple ad-hoc 3-D point searcher.
///
/// This class implements 3-D point searcher simply by looking up every point in
/// the list. Thus, this class is not ideal for searches involing large number
/// of points, but only for small set of items.
class PointSimpleListSearcher3: PointNeighborSearcher3 {
    var _points:[Vector3F] = []
    
    func typeName() -> String {
        return "PointSimpleListSearcher3"
    }
    
    /// Default constructor.
    init() {}
    
    /// Copy constructor.
    init(other:PointSimpleListSearcher3) {
        set(other: other)
    }
    
    /// Builds internal structure for given points list.
    ///
    /// For this class, this function simply copies the given point list to the
    /// internal list.
    /// - Parameter points: The points to search.
    func build(points:ConstArrayAccessor1<Vector3F>) {
        _points = Array<Vector3F>(repeating: Vector3F(), count: points.size())
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
    func forEachNearbyPoint(origin:Vector3F,
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
    func hasNearbyPoint(origin:Vector3F,
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
    func clone()->PointNeighborSearcher3 {
        PointSimpleListSearcher3(other: self)
    }
    
    /// Copy from the other instance.
    func set(other:PointSimpleListSearcher3) {
        _points = other._points
    }
    
    //MARK:- Builder
    /// Front-end to create PointSimpleListSearcher3 objects step by step.
    class Builder: PointNeighborSearcherBuilder3 {
        /// Builds PointSimpleListSearcher3 instance.
        func build()->PointSimpleListSearcher3 {
            return PointSimpleListSearcher3()
        }
        
        /// Returns shared pointer of PointNeighborSearcher3 type.
        func buildPointNeighborSearcher()->PointNeighborSearcher3 {
            return build()
        }
    }
    
    /// Returns builder fox PointSimpleListSearcher3.
    static func builder()->Builder{
        return Builder()
    }
}
