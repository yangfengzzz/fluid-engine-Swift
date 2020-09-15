//
//  octree.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Generic octree data structure.
///
/// This class is a generic octree representation to store arbitrary spatial
/// data. The octree supports closest neighbor search, overlapping test, and
/// ray intersection test.
/// 
class Octree<T>:IntersectionQueryEngine3&NearestNeighborQueryEngine3{
    
    /// Default constructor.
    init(){}
    
    /// Builds an octree with given list of items, bounding box of the items,
    /// overlapping test function, and max depth of the tree.
    func build(items:[T], bound:BoundingBox3F,
               testFunc:BoxIntersectionTestFunc3<T>, maxDepth:size_t){
        // Reset items
        _maxDepth = maxDepth
        _items = items
        _nodes.removeAll()
        
        // Normalize bounding box
        _bbox = bound
        let maxEdgeLen = reduce_max(SIMD3<Float>(_bbox.width(), _bbox.height(), _bbox.depth()))
        _bbox.upperCorner =
            _bbox.lowerCorner + Vector3F(maxEdgeLen, maxEdgeLen, maxEdgeLen)
        
        // Build
        _nodes.append(Node())
        _nodes[0].items.append(contentsOf: 0..<_items.count)
        
        build(nodeIdx: 0, depth: 1,
              bound: _bbox, testFunc: testFunc)
    }
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func clear(){
        _maxDepth = 1
        _items.removeAll()
        _nodes.removeAll()
        _bbox = BoundingBox3F()
    }
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box: BoundingBox3F, testFunc: BoxIntersectionTestFunc3<T>) -> Bool {
        return intersects(box: box, testFunc: testFunc, nodeIdx: 0, bound: _bbox)
    }
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray: Ray3F, testFunc: RayIntersectionTestFunc3<T>) -> Bool {
        return intersects(ray: ray, testFunc: testFunc, nodeIdx: 0, bound: _bbox)
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box: BoundingBox3F, testFunc: BoxIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        forEachIntersectingItem(box: box, testFunc: testFunc, visitorFunc: visitorFunc,
                                nodeIdx: 0, bound: _bbox)
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray: Ray3F, testFunc: RayIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        forEachIntersectingItem(ray: ray, testFunc: testFunc, visitorFunc: visitorFunc,
                                nodeIdx: 0, bound: _bbox)
    }
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray: Ray3F, testFunc: GetRayIntersectionFunc3<T>) -> ClosestIntersectionQueryResult3<T> {
        var best = ClosestIntersectionQueryResult3<T>()
        best.distance = Float.greatestFiniteMagnitude
        best.item = nil
        
        return closestIntersection(ray: ray, testFunc: testFunc,
                                   nodeIdx: 0, bound: _bbox, best: &best)
    }
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func nearest(pt: Vector3F, distanceFunc: NearestNeighborDistanceFunc3<T>) -> NearestNeighborQueryResult3<T> {
        var best = NearestNeighborQueryResult3<T>()
        best.distance = Float.greatestFiniteMagnitude
        best.item = nil
        
        // Prepare to traverse octree
        var todo = Stack<(Node, BoundingBox3F)>()
        
        // Traverse octree nodes
        var node:Node? = _nodes.first
        var bound = _bbox
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                for itemIdx in node_upacked.items {
                    let d = distanceFunc(_items[itemIdx], pt)
                    if (d < best.distance) {
                        best.distance = d
                        best.item = _items[itemIdx]
                    }
                }
                
                // Grab next node to process from todo stack
                if (todo.isEmpty) {
                    break
                } else {
                    node = todo.top!.0
                    bound = todo.top!.1
                    _ = todo.pop()
                }
            } else {
                let bestDistSqr = best.distance * best.distance
                
                typealias NodeDistBox = (Node, Float, BoundingBox3F)
                let empty_NodeDistBox = (Node(), Float(0.0), BoundingBox3F())
                var childDistSqrPairs:[NodeDistBox] = Array<NodeDistBox>(repeating: empty_NodeDistBox,
                                                                         count: 8)
                
                let midPoint = bound.midPoint()
                for i in 0..<8 {
                    let child = _nodes[node_upacked.firstChild + i]
                    let childBound = BoundingBox3F(point1: bound.corner(idx: i), point2: midPoint)
                    let cp = childBound.clamp(pt: pt)
                    let distMinSqr = length_squared(cp - pt)
                    
                    childDistSqrPairs[i] = (child, distMinSqr, childBound)
                }
                
                childDistSqrPairs.sort(by: {(a:NodeDistBox, b:NodeDistBox) in
                    return a.1 > b.1
                })
                
                for i in 0..<8 {
                    let childPair = childDistSqrPairs[i]
                    if (childPair.1 < bestDistSqr) {
                        todo.push((childPair.0, childPair.2))
                    }
                }
                
                if (todo.isEmpty) {
                    break
                }
                
                node = todo.top!.0
                bound = todo.top!.1
                _ = todo.pop()
            }
        }
        
        return best
    }
    
    /// Returns the number of items.
    func numberOfItems()->size_t{
        return _items.count
    }
    
    /// Returns the item at \p i.
    func item(i:size_t)->T{
        return _items[i]
    }
    
    /// Returns the number of quadtree nodes.
    func numberOfNodes()->size_t{
        return _nodes.count
    }
    
    /// Returns the list of the items for given noide index.
    func itemsAtNode(nodeIdx:size_t)->[size_t]{
        return _nodes[nodeIdx].items
    }
    
    /// Returns a child's index for given node.
    ///
    /// For a given node, its children is stored continuously, such that if the
    /// node's first child's index is i, then i + 1, i + 2, ... , i + 7 are the
    /// indices for its children. The order of octant is x-major.
    ///
    /// - Parameters:
    ///   - nodeIdx: The node index.
    ///   - childIdx: The child index (0 to 7).
    /// - Returns:  Index of the selected child.
    ///
    func childIndex(nodeIdx:size_t, childIdx:size_t)->size_t{
        return _nodes[nodeIdx].firstChild + childIdx
    }
    
    /// Returns the bounding box of this quadtree.
    func boundingBox()->BoundingBox3F{
        return _bbox
    }
    
    /// Returns the maximum depth of the tree.
    func maxDepth()->size_t{
        return _maxDepth
    }
    
    // MARK:- Private
    private struct Node{
        var firstChild:size_t = size_t.max
        var items:[size_t] = []
        
        func isLeaf()->Bool{
            return firstChild == size_t.max
        }
    }
    
    private var _maxDepth:size_t = 1
    private var _bbox:BoundingBox3F = BoundingBox3F()
    private var _items:[T] = []
    private var _nodes:[Node] = []
    
    private func build( nodeIdx:size_t, depth:size_t,
                        bound:BoundingBox3F,
                        testFunc:BoxIntersectionTestFunc3<T>){
        if (depth < _maxDepth && !_nodes[nodeIdx].items.isEmpty) {
            let firstChild = _nodes.count
            _nodes[nodeIdx].firstChild = _nodes.count
            _nodes.append(contentsOf: Array<Node>(repeating: Node(), count: 8))
            
            var bboxPerNode = Array<BoundingBox3F>(repeating: BoundingBox3F(), count: 8)
            
            for i in 0..<8 {
                bboxPerNode[i] = BoundingBox3F(point1: bound.corner(idx: i),
                                               point2: bound.midPoint())
            }
            
            let currentItems = _nodes[nodeIdx].items
            for i in 0..<currentItems.count {
                let currentItem = currentItems[i]
                for j in 0..<8 {
                    if (testFunc(_items[currentItem], bboxPerNode[j])) {
                        _nodes[firstChild + j].items.append(currentItem)
                    }
                }
            }
            
            // Remove non-leaf data
            _nodes[nodeIdx].items.removeAll()
            
            // Refine
            for i in 0..<8 {
                build(nodeIdx: firstChild + i, depth: depth + 1,
                      bound: bboxPerNode[i], testFunc: testFunc)
            }
        }
    }
    
    private func intersects(box:BoundingBox3F,
                            testFunc:BoxIntersectionTestFunc3<T>, nodeIdx:size_t,
                            bound:BoundingBox3F)->Bool{
        if (!box.overlaps(other: bound)) {
            return false
        }
        
        let node = _nodes[nodeIdx]
        
        if (node.items.count > 0) {
            for itemIdx in node.items {
                if (testFunc(_items[itemIdx], box)) {
                    return true
                }
            }
        }
        
        if (node.firstChild != size_t.max) {
            for i in 0..<8 {
                if (intersects(box: box, testFunc: testFunc, nodeIdx: node.firstChild + i,
                               bound: BoundingBox3F(point1: bound.corner(idx: i),
                                                    point2: bound.midPoint()))) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func intersects(ray:Ray3F,
                            testFunc:RayIntersectionTestFunc3<T>, nodeIdx:size_t,
                            bound:BoundingBox3F)->Bool{
        if (!bound.intersects(ray: ray)) {
            return false
        }
        
        let node = _nodes[nodeIdx]
        
        if (node.items.count > 0) {
            for itemIdx in node.items {
                if (testFunc(_items[itemIdx], ray)) {
                    return true
                }
            }
        }
        
        if (node.firstChild != size_t.max) {
            for i in 0..<8 {
                if (intersects(ray: ray, testFunc: testFunc, nodeIdx: node.firstChild + i,
                               bound: BoundingBox3F(point1: bound.corner(idx: i),
                                                    point2: bound.midPoint()))) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func forEachIntersectingItem(box:BoundingBox3F,
                                         testFunc:BoxIntersectionTestFunc3<T>,
                                         visitorFunc:IntersectionVisitorFunc3<T>,
                                         nodeIdx:size_t,
                                         bound:BoundingBox3F){
        if (!box.overlaps(other: bound)) {
            return
        }
        
        let node = _nodes[nodeIdx]
        
        if (node.items.count > 0) {
            for itemIdx in node.items {
                if (testFunc(_items[itemIdx], box)) {
                    visitorFunc(_items[itemIdx])
                }
            }
        }
        
        if (node.firstChild != size_t.max) {
            for i in 0..<8 {
                forEachIntersectingItem(
                    box: box, testFunc: testFunc, visitorFunc: visitorFunc,
                    nodeIdx: node.firstChild + i,
                    bound: BoundingBox3F(point1: bound.corner(idx: i),
                                         point2: bound.midPoint()))
            }
        }
    }
    
    private func forEachIntersectingItem(ray:Ray3F,
                                         testFunc:RayIntersectionTestFunc3<T>,
                                         visitorFunc:IntersectionVisitorFunc3<T>,
                                         nodeIdx:size_t,
                                         bound:BoundingBox3F){
        if (!bound.intersects(ray: ray)) {
            return
        }
        
        let node = _nodes[nodeIdx]
        
        if (node.items.count > 0) {
            for itemIdx in node.items {
                if (testFunc(_items[itemIdx], ray)) {
                    visitorFunc(_items[itemIdx])
                }
            }
        }
        
        if (node.firstChild != size_t.max) {
            for i in 0..<8 {
                forEachIntersectingItem(
                    ray: ray, testFunc: testFunc, visitorFunc: visitorFunc, nodeIdx: node.firstChild + i,
                    bound: BoundingBox3F(point1: bound.corner(idx: i),
                                         point2: bound.midPoint()))
            }
        }
    }
    
    private func closestIntersection(ray:Ray3F, testFunc:GetRayIntersectionFunc3<T>,
                                     nodeIdx:size_t, bound: BoundingBox3F,
                                     best: inout ClosestIntersectionQueryResult3<T>)->ClosestIntersectionQueryResult3<T>{
        if (!bound.intersects(ray: ray)) {
            return best
        }
        
        let node = _nodes[nodeIdx]
        
        if (node.items.count > 0) {
            for itemIdx in node.items {
                let dist = testFunc(_items[itemIdx], ray)
                if (dist < best.distance) {
                    best.distance = dist
                    best.item = _items[itemIdx]
                }
            }
        }
        
        if (node.firstChild != size_t.max) {
            for i in 0..<8 {
                best = closestIntersection(
                    ray: ray, testFunc: testFunc, nodeIdx: node.firstChild + i,
                    bound: BoundingBox3F(point1: bound.corner(idx: i),
                                         point2: bound.midPoint()),
                    best: &best)
            }
        }
        
        return best
    }
}
