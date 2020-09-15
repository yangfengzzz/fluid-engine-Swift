//
//  point_hash_grid_searcher3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Hash grid-based 3-D point searcher.
///
/// This class implements 3-D point searcher by using hash grid for its internal
/// acceleration data structure. Each point is recorded to its corresponding
/// bucket where the hashing function is 3-D grid mapping.
class PointHashGridSearcher3: PointNeighborSearcher3 {
    var _gridSpacing:Float = 1.0
    var _resolution = Point3I(1, 1, 1)
    var _points:[Vector3F] = []
    var _buckets:[[size_t]] = [[]]
    
    func typeName() -> String {
        return "PointHashGridSearcher3"
    }
    
    /// Constructs hash grid with given resolution and grid spacing.
    ///
    /// This constructor takes hash grid resolution and its grid spacing as
    /// its input parameters. The grid spacing must be 3x or greater than
    /// search radius.
    /// - Parameters:
    ///   - resolution: The resolution.
    ///   - gridSpacing: The grid spacing.
    convenience init(resolution:Size3,
                     gridSpacing:Float) {
        self.init(resolutionX: resolution.x,
                  resolutionY: resolution.y,
                  resolutionZ: resolution.z,
                  gridSpacing: gridSpacing)
    }
    
    /// Constructs hash grid with given resolution and grid spacing.
    ///
    /// This constructor takes hash grid resolution and its grid spacing as
    /// its input parameters. The grid spacing must be 3x or greater than
    /// search radius.
    /// - Parameters:
    ///   - resolutionX: The resolution x.
    ///   - resolutionY: The resolution y.
    ///   - resolutionZ: The resolution z.
    ///   - gridSpacing: The grid spacing.
    init(resolutionX:size_t,
         resolutionY:size_t,
         resolutionZ:size_t,
         gridSpacing:Float) {
        self._gridSpacing = gridSpacing
        self._resolution.x = max(size_t(resolutionX), 1)
        self._resolution.y = max(size_t(resolutionY), 1)
        self._resolution.z = max(size_t(resolutionZ), 1)
    }
    
    /// Copy constructor.
    init(other:PointHashGridSearcher3) {
        set(other: other)
    }
    
    /// Builds internal acceleration structure for given points list.
    func build(points:ConstArrayAccessor1<Vector3F>) {
        _buckets = []
        _points = []
        
        // Allocate memory chuncks
        _buckets = Array<[size_t]>(repeating: [], count: _resolution.x * _resolution.y * _resolution.z)
        _points = Array<Vector3F>(repeating: Vector3F(), count: points.size())
        
        if (points.size() == 0) {
            return
        }
        
        // Put points into buckets
        for i in 0..<points.size() {
            _points[i] = points[i]
            let key = getHashKeyFromPosition(position: points[i])
            _buckets[key].append(i)
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
        if (_buckets.isEmpty) {
            return
        }
        
        var nearbyKeys = Array<size_t>(repeating: 0, count: 8)
        getNearbyKeys(position: origin, bucketIndices: &nearbyKeys)
        
        let queryRadiusSquared = radius * radius
        
        for i in 0..<8 {
            let bucket = _buckets[nearbyKeys[i]]
            let numberOfPointsInBucket = bucket.count
            
            for j in 0..<numberOfPointsInBucket {
                let pointIndex = bucket[j]
                let rSquared = length_squared(_points[pointIndex] - origin)
                if (rSquared <= queryRadiusSquared) {
                    callback(pointIndex, _points[pointIndex])
                }
            }
        }
    }
    
    /// Returns true if there are any nearby points for given origin within radius.
    /// - Parameters:
    ///   - origin: The origin.
    ///   - radius: The radius.
    /// - Returns: True if has nearby point, false otherwise.
    func hasNearbyPoint(origin:Vector3F, radius:Float)->Bool {
        if (_buckets.isEmpty) {
            return false
        }
        
        var nearbyKeys = Array<size_t>(repeating: 0, count: 8)
        getNearbyKeys(position: origin, bucketIndices: &nearbyKeys)
        
        let queryRadiusSquared = radius * radius
        
        for i in 0..<8 {
            let bucket = _buckets[nearbyKeys[i]]
            let numberOfPointsInBucket = bucket.count
            
            for j in 0..<numberOfPointsInBucket {
                let pointIndex = bucket[j]
                let rSquared = length_squared(_points[pointIndex] - origin)
                if (rSquared <= queryRadiusSquared) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Adds a single point to the hash grid.
    ///
    /// This function adds a single point to the hash grid for future queries.
    /// It can be used for a hash grid that is already built by calling function
    /// PointHashGridSearcher3::build.
    /// - Parameter point: The point to be added.
    func add(point:Vector3F) {
        if (_buckets.isEmpty) {
            let arr = Array1<Vector3F>(lst: [point])
            build(points: arr.constAccessor())
        } else {
            let i = _points.count
            _points.append(point)
            let key = getHashKeyFromPosition(position: point)
            _buckets[key].append(i)
        }
    }
    
    /// Returns the internal bucket.
    ///
    /// A bucket is a list of point indices that has same hash value. This
    /// function returns the (immutable) internal bucket structure.
    /// - Returns: List of buckets.
    func buckets()->[[size_t]] {
        return _buckets
    }
    
    /// Returns the hash value for given 3-D bucket index.
    /// - Parameter bucketIndex: The bucket index.
    /// - Returns: The hash key from bucket index.
    func getHashKeyFromBucketIndex(bucketIndex:Point3I)->size_t {
        var wrappedIndex = bucketIndex
        wrappedIndex.x = bucketIndex.x % _resolution.x;
        wrappedIndex.y = bucketIndex.y % _resolution.y;
        wrappedIndex.z = bucketIndex.z % _resolution.z;
        if (wrappedIndex.x < 0) {
            wrappedIndex.x += _resolution.x;
        }
        if (wrappedIndex.y < 0) {
            wrappedIndex.y += _resolution.y;
        }
        if (wrappedIndex.z < 0) {
            wrappedIndex.z += _resolution.z;
        }
        return (wrappedIndex.z * _resolution.y + wrappedIndex.y) * _resolution.x + wrappedIndex.x
    }
    
    /// Gets the bucket index from a point.
    /// - Parameter position: The position of the point.
    /// - Returns: The bucket index.
    func getBucketIndex(position:Vector3F)->Point3I {
        var bucketIndex = Point3I()
        bucketIndex.x = ssize_t(floor(position.x / _gridSpacing))
        bucketIndex.y = ssize_t(floor(position.y / _gridSpacing))
        bucketIndex.z = ssize_t(floor(position.z / _gridSpacing))
        return bucketIndex
    }
    
    /// Creates a new instance of the object with same properties than original.
    /// - Returns: Copy of this object.
    func clone()->PointNeighborSearcher3 {
        return PointHashGridSearcher3(other: self)
    }
    
    /// Copy from the other instance.
    func set(other:PointHashGridSearcher3) {
        _gridSpacing = other._gridSpacing
        _resolution = other._resolution
        _points = other._points
        _buckets = other._buckets
    }
    
    func getHashKeyFromPosition(position:Vector3F)->size_t {
        let bucketIndex = getBucketIndex(position: position)
        
        return getHashKeyFromBucketIndex(bucketIndex: bucketIndex)
    }
    
    func getNearbyKeys(position:Vector3F, bucketIndices nearbyKeys:inout [size_t]) {
        let originIndex = getBucketIndex(position: position)
        var nearbyBucketIndices = Array<Point3I>(repeating: Point3I(), count: 8)
        
        for i in 0..<8 {
            nearbyBucketIndices[i] = originIndex
        }
        
        if ((Float(originIndex.x) + 0.5) * _gridSpacing <= position.x) {
            nearbyBucketIndices[4].x += 1;
            nearbyBucketIndices[5].x += 1;
            nearbyBucketIndices[6].x += 1;
            nearbyBucketIndices[7].x += 1;
        } else {
            nearbyBucketIndices[4].x -= 1;
            nearbyBucketIndices[5].x -= 1;
            nearbyBucketIndices[6].x -= 1;
            nearbyBucketIndices[7].x -= 1;
        }
        
        if ((Float(originIndex.y) + 0.5) * _gridSpacing <= position.y) {
            nearbyBucketIndices[2].y += 1;
            nearbyBucketIndices[3].y += 1;
            nearbyBucketIndices[6].y += 1;
            nearbyBucketIndices[7].y += 1;
        } else {
            nearbyBucketIndices[2].y -= 1;
            nearbyBucketIndices[3].y -= 1;
            nearbyBucketIndices[6].y -= 1;
            nearbyBucketIndices[7].y -= 1;
        }
        
        if ((Float(originIndex.z) + 0.5) * _gridSpacing <= position.z) {
            nearbyBucketIndices[1].z += 1;
            nearbyBucketIndices[3].z += 1;
            nearbyBucketIndices[5].z += 1;
            nearbyBucketIndices[7].z += 1;
        } else {
            nearbyBucketIndices[1].z -= 1;
            nearbyBucketIndices[3].z -= 1;
            nearbyBucketIndices[5].z -= 1;
            nearbyBucketIndices[7].z -= 1;
        }
        
        for i in 0..<8 {
            nearbyKeys[i] = getHashKeyFromBucketIndex(bucketIndex: nearbyBucketIndices[i])
        }
    }
    
    //MARK:- Builder
    class Builder: PointNeighborSearcherBuilder3 {
        var _resolution = Size3(64, 64, 64)
        var _gridSpacing:Float = 1.0
        
        /// Returns builder with resolution.
        func withResolution(resolution:Size3)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacing:Float)->Builder {
            _gridSpacing = gridSpacing
            return self
        }
        
        /// Builds PointHashGridSearcher3 instance.
        func build()->PointHashGridSearcher3 {
            return PointHashGridSearcher3(resolution: _resolution,
                                          gridSpacing: _gridSpacing)
        }
        
        /// Returns shared pointer of PointNeighborSearcher3 type.
        func buildPointNeighborSearcher()->PointNeighborSearcher3 {
            return build()
        }
    }
    
    /// Returns builder fox PointHashGridSearcher3.
    static func builder()->Builder{
        return Builder()
    }
}
