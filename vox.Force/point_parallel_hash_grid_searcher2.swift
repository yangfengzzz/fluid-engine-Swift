//
//  point_parallel_hash_grid_searcher2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Parallel version of hash grid-based 2-D point searcher.
///
/// This class implements parallel version of 2-D point searcher by using hash
/// grid for its internal acceleration data structure. Each point is recorded to
/// its corresponding bucket where the hashing function is 2-D grid mapping.
class PointParallelHashGridSearcher2: PointNeighborSearcher2 {
    var _gridSpacing:Float = 1.0
    var _resolution:Point2I = Point2I(1, 1)
    var _points:[Vector2F] = []
    var _keys:[size_t] = []
    var _startIndexTable:[size_t] = []
    var _endIndexTable:[size_t] = []
    var _sortedIndices:[size_t] = []
    
    func typeName() -> String {
        return "PointParallelHashGridSearcher2"
    }
    
    /// Constructs hash grid with given resolution and grid spacing.
    ///
    /// This constructor takes hash grid resolution and its grid spacing as
    /// its input parameters. The grid spacing must be 2x or greater than
    /// search radius.
    /// - Parameters:
    ///   - resolution: The resolution.
    ///   - gridSpacing: The grid spacing.
    convenience init(resolution:Size2,
                     gridSpacing:Float) {
        self.init(resolutionX: resolution.x,
                  resolutionY: resolution.y,
                  gridSpacing: gridSpacing)
    }
    
    /// Constructs hash grid with given resolution and grid spacing.
    ///
    /// This constructor takes hash grid resolution and its grid spacing as
    /// its input parameters. The grid spacing must be 2x or greater than
    /// search radius.
    /// - Parameters:
    ///   - resolutionX: The resolution x.
    ///   - resolutionY: The resolution y.
    ///   - gridSpacing: The grid spacing.
    init(resolutionX:size_t,
         resolutionY:size_t,
         gridSpacing:Float) {
        self._gridSpacing = gridSpacing
        self._resolution.x = max(resolutionX, 1)
        self._resolution.y = max(resolutionY, 1)
        
        self._startIndexTable = Array<size_t>(repeating: size_t.max, count: _resolution.x * _resolution.y)
        self._endIndexTable = Array<size_t>(repeating: size_t.max, count: _resolution.x * _resolution.y)
    }
    
    /// Copy constructor.
    init(other:PointParallelHashGridSearcher2) {
        set(other: other)
    }
    
    /// Builds internal acceleration structure for given points list.
    ///
    /// This function builds the hash grid for given points in parallel.
    /// - Parameter points: The points to be added.
    func build(points:ConstArrayAccessor1<Vector2F>) {
        _points = []
        _keys = []
        _startIndexTable = []
        _endIndexTable = []
        _sortedIndices = []
        
        // Allocate memory chuncks
        let numberOfPoints = points.size()
        var tempKeys = Array<size_t>(repeating: 0, count: numberOfPoints)
        _startIndexTable = Array<size_t>(repeating: size_t.max, count: _resolution.x * _resolution.y)
        _endIndexTable = Array<size_t>(repeating: size_t.max, count: _resolution.x * _resolution.y)
        _keys = Array<size_t>(repeating: 0, count: numberOfPoints)
        _sortedIndices = Array<size_t>(repeating: 0, count: numberOfPoints)
        _points = Array<Vector2F>(repeating: Vector2F(), count: numberOfPoints)
        
        if (numberOfPoints == 0) {
            return
        }
        
        // Initialize indices array and generate hash key for each point
        _sortedIndices.withUnsafeMutableBufferPointer { _sortedIndicesPtr in
            _points.withUnsafeMutableBufferPointer { _pointsPtr in
                tempKeys.withUnsafeMutableBufferPointer { tempKeysPtr in
                    parallelFor(beginIndex: 0, endIndex: numberOfPoints){(i:size_t) in
                        _sortedIndicesPtr[i] = i
                        _pointsPtr[i] = points[i]
                        tempKeysPtr[i] = getHashKeyFromPosition(position: points[i])
                    }
                }
            }
        }
        
        // Sort indices based on hash key
        _sortedIndices.sort { (indexA:Int, indexB:Int) -> Bool in
            return tempKeys[indexA] < tempKeys[indexB]
        }
        
        // Re-order point and key arrays
        _points.withUnsafeMutableBufferPointer { _pointsPtr in
            _keys.withUnsafeMutableBufferPointer { _keysPtr in
                parallelFor(beginIndex: 0, endIndex: numberOfPoints){(i:size_t) in
                    _pointsPtr[i] = points[_sortedIndices[i]]
                    _keysPtr[i] = tempKeys[_sortedIndices[i]]
                }
            }
        }
        
        // Now _points and _keys are sorted by points' hash key values.
        // Let's fill in start/end index table with _keys.
        
        // Assume that _keys array looks like:
        // [5|8|8|10|10|10]
        // Then _startIndexTable and _endIndexTable should be like:
        // [.....|0|...|1|..|3|..]
        // [.....|1|...|3|..|6|..]
        //       ^5    ^8   ^10
        // So that _endIndexTable[i] - _startIndexTable[i] is the number points
        // in i-th table bucket.
        
        _startIndexTable[_keys[0]] = 0
        _endIndexTable[_keys[numberOfPoints - 1]] = numberOfPoints
        
        _startIndexTable.withUnsafeMutableBufferPointer { _startIndexTablePtr in
            _endIndexTable.withUnsafeMutableBufferPointer { _endIndexTablePtr in
                parallelFor(beginIndex: 1, endIndex: numberOfPoints){(i:size_t) in
                    if (_keys[i] > _keys[i - 1]) {
                        _startIndexTablePtr[_keys[i]] = i
                        _endIndexTablePtr[_keys[i - 1]] = i
                    }
                }
            }
        }
        
        var sumNumberOfPointsPerBucket:size_t = 0
        var maxNumberOfPointsPerBucket:size_t = 0
        var numberOfNonEmptyBucket:size_t = 0
        for i in 0..<_startIndexTable.count {
            if (_startIndexTable[i] != size_t.max) {
                let numberOfPointsInBucket = _endIndexTable[i] - _startIndexTable[i]
                sumNumberOfPointsPerBucket += numberOfPointsInBucket
                maxNumberOfPointsPerBucket = max(maxNumberOfPointsPerBucket, numberOfPointsInBucket)
                numberOfNonEmptyBucket += 1
            }
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
        var nearbyKeys = Array<size_t>(repeating: 0, count: 4)
        getNearbyKeys(position: origin, bucketIndices: &nearbyKeys)
        
        let queryRadiusSquared = radius * radius
        
        for i in 0..<4 {
            let nearbyKey = nearbyKeys[i]
            let start = _startIndexTable[nearbyKey]
            let end = _endIndexTable[nearbyKey]
            
            // Empty bucket -- continue to next bucket
            if (start == size_t.max) {
                continue
            }
            
            for j in start..<end {
                let direction = _points[j] - origin
                let distanceSquared = length_squared(direction)
                if (distanceSquared <= queryRadiusSquared) {
                    callback(_sortedIndices[j], _points[j])
                }
            }
        }
    }
    
    /// Returns true if there are any nearby points for given origin within
    /// radius.
    /// - Parameters:
    ///   - origin: The origin.
    ///   - radius: The radius.
    /// - Returns: True if has nearby point, false otherwise.
    func hasNearbyPoint(origin:Vector2F, radius:Float)->Bool {
        var nearbyKeys = Array<size_t>(repeating: 0, count: 4)
        getNearbyKeys(position: origin, bucketIndices: &nearbyKeys)
        
        let queryRadiusSquared = radius * radius
        
        for i in 0..<4 {
            let nearbyKey = nearbyKeys[i]
            let start = _startIndexTable[nearbyKey]
            let end = _endIndexTable[nearbyKey]
            
            // Empty bucket -- continue to next bucket
            if (start == size_t.max) {
                continue
            }
            
            for j in start..<end {
                let direction = _points[j] - origin
                let distanceSquared = length_squared(direction)
                if (distanceSquared <= queryRadiusSquared) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Returns the hash key list.
    ///
    /// The hash key list maps sorted point index i to its hash key value.
    /// The sorting order is based on the key value itself.
    /// - Returns: The hash key list.
    func keys()->[size_t] {
        return _keys
    }
    
    /// Returns the start index table.
    ///
    /// The start index table maps the hash grid bucket index to starting index
    /// of the sorted point list.
    /// - Returns: The start index table.
    func startIndexTable()->[size_t] {
        return _startIndexTable
    }
    
    /// Returns the end index table.
    ///
    /// The end index table maps the hash grid bucket index to starting index
    /// of the sorted point list.
    /// - Returns: The end index table.
    func endIndexTable()->[size_t] {
        return _endIndexTable
    }
    
    /// Returns the sorted indices of the points.
    ///
    /// When the hash grid is built, it sorts the points in hash key order. But
    /// rather than sorting the original points, this class keeps the shuffled
    /// indices of the points. The list this function returns maps sorted index
    /// i to original index j.
    /// - Returns: The sorted indices of the points.
    func sortedIndices()->[size_t] {
        return _sortedIndices
    }
    
    /// Returns the hash value for given 2-D bucket index.
    /// - Parameter bucketIndex: The bucket index.
    /// - Returns: The hash key from bucket index.
    func getHashKeyFromBucketIndex(bucketIndex:Point2I)->size_t {
        var wrappedIndex = bucketIndex
        wrappedIndex.x = bucketIndex.x % _resolution.x
        wrappedIndex.y = bucketIndex.y % _resolution.y
        if (wrappedIndex.x < 0) {
            wrappedIndex.x += _resolution.x
        }
        if (wrappedIndex.y < 0) {
            wrappedIndex.y += _resolution.y
        }
        return wrappedIndex.y*_resolution.x + wrappedIndex.x
    }
    
    /// Gets the bucket index from a point.
    /// - Parameter position: The position of the point.
    /// - Returns: The bucket index.
    func getBucketIndex(position:Vector2F)->Point2I {
        var bucketIndex = Point2I()
        bucketIndex.x = ssize_t(floor(position.x / _gridSpacing))
        bucketIndex.y = ssize_t(floor(position.y / _gridSpacing))
        return bucketIndex
    }
    
    /// Creates a new instance of the object with same properties
    ///             than original.
    /// - Returns: Copy of this object.
    func clone()->PointNeighborSearcher2 {
        return PointParallelHashGridSearcher2(other: self)
    }
    
    /// Copy from the other instance.
    func set(other:PointParallelHashGridSearcher2) {
        _gridSpacing = other._gridSpacing
        _resolution = other._resolution
        _points = other._points
        _keys = other._keys
        _startIndexTable = other._startIndexTable
        _endIndexTable = other._endIndexTable
        _sortedIndices = other._sortedIndices
    }
    
    func getHashKeyFromPosition(position:Vector2F)->size_t {
        let bucketIndex = getBucketIndex(position: position)
        
        return getHashKeyFromBucketIndex(bucketIndex: bucketIndex)
    }
    
    func getNearbyKeys(position:Vector2F, bucketIndices nearbyKeys:inout [size_t]) {
        let originIndex = getBucketIndex(position: position)
        var nearbyBucketIndices = Array<Point2I>(repeating: Point2I(), count: 4)
        
        for i in 0..<4 {
            nearbyBucketIndices[i] = originIndex
        }
        
        if ((Float(originIndex.x) + 0.5) * _gridSpacing <= position.x) {
            nearbyBucketIndices[2].x += 1
            nearbyBucketIndices[3].x += 1
        } else {
            nearbyBucketIndices[2].x -= 1
            nearbyBucketIndices[3].x -= 1
        }
        
        if ((Float(originIndex.y) + 0.5) * _gridSpacing <= position.y) {
            nearbyBucketIndices[1].y += 1
            nearbyBucketIndices[3].y += 1
        } else {
            nearbyBucketIndices[1].y -= 1
            nearbyBucketIndices[3].y -= 1
        }
        
        for i in 0..<4 {
            nearbyKeys[i] = getHashKeyFromBucketIndex(bucketIndex: nearbyBucketIndices[i])
        }
    }
    
    //MARK:- Builder
    /// Front-end to create PointParallelHashGridSearcher2 objects step by step.
    class Builder: PointNeighborSearcherBuilder2 {
        var _resolution = Size2(64, 64)
        var _gridSpacing:Float  = 1.0
        /// Returns builder with resolution.
        func withResolution(resolution:Size2)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacing:Float)->Builder {
            _gridSpacing = gridSpacing
            return self
        }
        
        /// Builds PointParallelHashGridSearcher2 instance.
        func build()->PointParallelHashGridSearcher2 {
            return PointParallelHashGridSearcher2(resolution: _resolution,
                                                  gridSpacing: _gridSpacing)
        }
        
        /// Returns shared pointer of PointNeighborSearcher2 type.
        func buildPointNeighborSearcher()->PointNeighborSearcher2 {
            return build()
        }
    }
    
    /// Returns builder fox PointParallelHashGridSearcher2.
    static func builder()->Builder{
        return Builder()
    }
}
