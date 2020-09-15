//
//  bvh3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Bounding Volume Hierarchy (BVH) in 3D
///
/// This class implements the classic bounding volume hierarchy structure in 3D.
/// It implements IntersectionQueryEngine3 in order to support box/ray
/// intersection tests. Also, NearestNeighborQueryEngine3 is implemented to
/// provide nearest neighbor query.
///
class Bvh3<T> : IntersectionQueryEngine3&NearestNeighborQueryEngine3{
    
    /// Default constructor.
    init(){}
    
    /// Builds bounding volume hierarchy.
    func build(items:[T],
               itemsBounds:[BoundingBox3F]){
        _items = items
        _itemBounds = itemsBounds
        
        if (_items.isEmpty) {
            return
        }
        
        _nodes.removeAll()
        _bound = BoundingBox3F()
        
        for i in 0..<_items.count {
            _bound.merge(other: _itemBounds[i])
        }
        
        var itemIndices:[size_t] = Array<size_t>(0..<_items.count)
        
        _ = build(nodeIndex: 0, itemIndices: &itemIndices, nItems: _items.count, currentDepth: 0)
    }
    
    /// Clears all the contents of this instance.
    func clear(){
        _bound = BoundingBox3F()
        _items.removeAll()
        _itemBounds.removeAll()
        _nodes.removeAll()
    }
    
    /// Returns true if given \p box intersects with any of the stored items.
    func intersects(box: BoundingBox3F,
                    testFunc: BoxIntersectionTestFunc3<T>) -> Bool {
        if (!_bound.overlaps(other: box)) {
            return false
        }
        
        // prepare to traverse BVH for box
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // traverse BVH nodes for box
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                if (testFunc(_items[node_upacked.item], box)) {
                    return true
                }
                
                // grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                // get node children pointers for box
                let firstChild = _nodes[node_upacked.global_idx+1]
                let secondChild = _nodes[node_upacked.child]
                
                // advance to next child node, possibly enqueue other child
                if (!firstChild.bound.overlaps(other: box)) {
                    node = secondChild
                } else if (!secondChild.bound.overlaps(other: box)) {
                    node = firstChild
                } else {
                    // enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                }
            }
        }
        
        return false
    }
    
    /// Returns true if given \p ray intersects with any of the stored items.
    func intersects(ray: Ray3F,
                    testFunc: RayIntersectionTestFunc3<T>) -> Bool {
        if (!_bound.intersects(ray: ray)) {
            return false
        }
        
        // prepare to traverse BVH for ray
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // traverse BVH nodes for ray
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                if (testFunc(_items[node_upacked.item], ray)) {
                    return true
                }
                
                // grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                // get node children pointers for ray
                var firstChild:Node
                var secondChild:Node
                if (ray.direction[Int(node_upacked.flags)] > 0.0) {
                    firstChild = _nodes[node_upacked.global_idx+1]
                    secondChild = _nodes[node_upacked.child]
                } else {
                    firstChild = _nodes[node_upacked.child]
                    secondChild = _nodes[node_upacked.global_idx+1]
                }
                
                // advance to next child node, possibly enqueue other child
                if (!firstChild.bound.intersects(ray: ray)) {
                    node = secondChild
                } else if (!secondChild.bound.intersects(ray: ray)) {
                    node = firstChild
                } else {
                    // enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                }
            }
        }
        
        return false
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(box: BoundingBox3F, testFunc: BoxIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        if (!_bound.overlaps(other: box)) {
            return
        }
        
        // prepare to traverse BVH for box
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // traverse BVH nodes for box
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                if (testFunc(_items[node_upacked.item], box)) {
                    visitorFunc(_items[node_upacked.item])
                }
                
                // grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                // get node children pointers for box
                let firstChild:Node = _nodes[node_upacked.global_idx + 1]
                let secondChild:Node = _nodes[node_upacked.child]
                
                // advance to next child node, possibly enqueue other child
                if (!firstChild.bound.overlaps(other: box)) {
                    node = secondChild
                } else if (!secondChild.bound.overlaps(other: box)) {
                    node = firstChild
                } else {
                    // enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                }
            }
        }
    }
    
    /// Invokes \p visitorFunc for every intersecting items.
    func forEachIntersectingItem(ray: Ray3F, testFunc: RayIntersectionTestFunc3<T>,
                                 visitorFunc: IntersectionVisitorFunc3<T>) {
        if (!_bound.intersects(ray: ray)) {
            return
        }
        
        // prepare to traverse BVH for ray
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // traverse BVH nodes for ray
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                if (testFunc(_items[node_upacked.item], ray)) {
                    visitorFunc(_items[node_upacked.item])
                }
                
                // grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                // get node children pointers for ray
                var firstChild:Node
                var secondChild:Node
                if (ray.direction[Int(node_upacked.flags)] > 0.0) {
                    firstChild = _nodes[node_upacked.global_idx + 1]
                    secondChild = _nodes[node_upacked.child]
                } else {
                    firstChild = _nodes[node_upacked.child]
                    secondChild = _nodes[node_upacked.global_idx + 1]
                }
                
                // advance to next child node, possibly enqueue other child
                if (!firstChild.bound.intersects(ray: ray)) {
                    node = secondChild
                } else if (!secondChild.bound.intersects(ray: ray)) {
                    node = firstChild
                } else {
                    // enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                }
            }
        }
    }
    
    /// Returns the closest intersection for given \p ray.
    func closestIntersection(ray: Ray3F,
                             testFunc: GetRayIntersectionFunc3<T>) -> ClosestIntersectionQueryResult3<T> {
        var best = ClosestIntersectionQueryResult3<T>()
        best.distance = Float.greatestFiniteMagnitude
        best.item = nil
        
        if (!_bound.intersects(ray: ray)) {
            return best
        }
        
        // prepare to traverse BVH for ray
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // traverse BVH nodes for ray
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                let dist = testFunc(_items[node_upacked.item], ray)
                if (dist < best.distance) {
                    best.distance = dist
                    best.item = _items[node_upacked.item]
                }
                
                // grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                // get node children pointers for ray
                var firstChild:Node
                var secondChild:Node
                if (ray.direction[Int(node_upacked.flags)] > 0.0) {
                    firstChild = _nodes[node_upacked.global_idx + 1]
                    secondChild = _nodes[node_upacked.child]
                } else {
                    firstChild = _nodes[node_upacked.child]
                    secondChild = _nodes[node_upacked.global_idx + 1]
                }
                
                // advance to next child node, possibly enqueue other child
                if (!firstChild.bound.intersects(ray: ray)) {
                    node = secondChild
                } else if (!secondChild.bound.intersects(ray: ray)) {
                    node = firstChild
                } else {
                    // enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                }
            }
        }
        
        return best
    }
    
    /// Returns the nearest neighbor for given point and distance measure function.
    func nearest(pt: Vector3F, distanceFunc: NearestNeighborDistanceFunc3<T>) -> NearestNeighborQueryResult3<T> {
        var best = NearestNeighborQueryResult3<T>()
        best.distance = Float.greatestFiniteMagnitude
        best.item = nil
        
        // Prepare to traverse BVH
        let kMaxTreeDepth = 8 * MemoryLayout<size_t>.size
        let todo = UnsafeMutablePointer<Node>.allocate(capacity: kMaxTreeDepth)
        var todoPos:size_t = 0
        
        // Traverse BVH nodes
        var node:Node? = _nodes.first
        while (node != nil) {
            guard let node_upacked = node else {
                fatalError()
            }
            
            if (node_upacked.isLeaf()) {
                let dist = distanceFunc(_items[node_upacked.item], pt)
                if (dist < best.distance) {
                    best.distance = dist
                    best.item = _items[node_upacked.item]
                }
                
                // Grab next node to process from todo stack
                if (todoPos > 0) {
                    // Dequeue
                    todoPos -= 1
                    node = todo[todoPos]
                } else {
                    break
                }
            } else {
                let bestDistSqr = best.distance * best.distance
                
                let left = _nodes[node_upacked.global_idx + 1]
                let right = _nodes[node_upacked.child]
                
                // If pt is inside the box, then the closestLeft and Right will be
                // identical to pt. This will make distMinLeftSqr and
                // distMinRightSqr zero, meaning that such a box will have higher
                // priority.
                let closestLeft = left.bound.clamp(pt: pt)
                let closestRight = right.bound.clamp(pt: pt)
                
                let distMinLeftSqr = length_squared(closestLeft - pt)
                let distMinRightSqr = length_squared(closestRight - pt)
                
                let shouldVisitLeft = distMinLeftSqr < bestDistSqr
                let shouldVisitRight = distMinRightSqr < bestDistSqr
                
                var firstChild:Node
                var secondChild:Node
                if (shouldVisitLeft && shouldVisitRight) {
                    if (distMinLeftSqr < distMinRightSqr) {
                        firstChild = left
                        secondChild = right
                    } else {
                        firstChild = right
                        secondChild = left
                    }
                    
                    // Enqueue secondChild in todo stack
                    todo[todoPos] = secondChild
                    todoPos += 1
                    node = firstChild
                } else if (shouldVisitLeft) {
                    node = left
                } else if (shouldVisitRight) {
                    node = right
                } else {
                    if (todoPos > 0) {
                        // Dequeue
                        todoPos -= 1
                        node = todo[todoPos]
                    } else {
                        break
                    }
                }
            }
        }
        
        return best
    }
    
    /// Returns bounding box of every items.
    func boundingBox()->BoundingBox3F{
        return _bound
    }
    
    /// Returns the number of items.
    func numberOfItems()->size_t{
        return _items.count
    }
    
    /// Returns the item at \p i.
    func item(i:size_t)->T{
        return _items[i]
    }
    
    /// Returns the number of nodes.
    func numberOfNodes()->size_t{
        return _nodes.count
    }
    
    /// Returns the children indices of \p i-th node.
    func children(i:size_t)->(size_t, size_t){
        if (isLeaf(i: i)) {
            return (size_t.max, size_t.max)
        } else {
            return (i + 1, _nodes[i].child)
        }
    }
    
    /// Returns true if \p i-th node is a leaf node.
    func isLeaf(i:size_t)->Bool{
        return _nodes[i].isLeaf()
    }
    
    /// Returns bounding box of \p i-th node.
    func nodeBound(i:size_t)->BoundingBox3F{
        return _nodes[i].bound
    }
    
    /// Returns item of \p i-th node.
    func itemOfNode(i:size_t)->size_t{
        return _nodes[i].item
    }
    
    // MARK:- Private
    private struct Node {
        var flags:UInt8 = 0
        var bound:BoundingBox3F = BoundingBox3F()
        
        var child:size_t = size_t.max
        var item:size_t = size_t.max
        
        var global_idx:size_t
        
        init(idx:size_t) {
            global_idx = idx
        }
        
        mutating func initLeaf(it:size_t, b:BoundingBox3F){
            flags = 3
            item = it
            bound = b
        }
        
        mutating func initInternal(axis:UInt8, c:size_t, b:BoundingBox3F){
            flags = axis
            child = c
            bound = b
        }
        
        func isLeaf()->Bool{
            return flags == 3
        }
    }
    
    private var _bound:BoundingBox3F = BoundingBox3F()
    private var _items:[T] = []
    private var _itemBounds:[BoundingBox3F] = []
    private var _nodes:[Node] = []
    
    private func build(nodeIndex:size_t, itemIndices:UnsafeMutablePointer<size_t>, nItems:size_t,
                       currentDepth:size_t)->size_t{
        // add a node
        _nodes.append(Node(idx: _nodes.count))
        
        // initialize leaf node if termination criteria met
        if (nItems == 1) {
            _nodes[nodeIndex].initLeaf(it: itemIndices.pointee,
                                       b: _itemBounds[itemIndices.pointee])
            return currentDepth + 1
        }
        
        // find the mid-point of the bounding box to use as a qsplit pivot
        var nodeBound = BoundingBox3F()
        for i in 0..<nItems {
            nodeBound.merge(other: _itemBounds[itemIndices.advanced(by: i).pointee])
        }
        
        let d = nodeBound.upperCorner - nodeBound.lowerCorner
        
        // choose which axis to split along
        var axis:Int
        if (d.x > d.y) {
            axis = 0
        } else {
            axis = 1
        }
        
        let pivot = 0.5 * (nodeBound.upperCorner[axis] + nodeBound.lowerCorner[axis])
        
        // classify primitives with respect to split
        let midPoint = qsplit(itemIndices: itemIndices, numItems: nItems, pivot: pivot, axis: UInt8(axis))
        
        // recursively initialize children _nodes
        let d0 = build(nodeIndex: nodeIndex + 1,
                       itemIndices: itemIndices,
                       nItems: midPoint,
                       currentDepth: currentDepth + 1)
        _nodes[nodeIndex].initInternal(axis: UInt8(axis), c: _nodes.count, b: nodeBound)
        let d1 = build(nodeIndex: _nodes[nodeIndex].child,
                       itemIndices: itemIndices.advanced(by: midPoint),
                       nItems: nItems - midPoint,
                       currentDepth: currentDepth + 1)
        
        return max(d0, d1)
    }
    
    private func qsplit(itemIndices: UnsafeMutablePointer<size_t>, numItems:size_t, pivot:Float,
                        axis:UInt8)->size_t{
        var centroid:Float = 0
        var ret:size_t = 0
        for i in 0..<numItems {
            let b = _itemBounds[itemIndices.advanced(by: i).pointee]
            centroid = 0.5 * (b.lowerCorner[Int(axis)] + b.upperCorner[Int(axis)])
            if (centroid < pivot) {
                let temp = itemIndices.advanced(by: ret).pointee
                itemIndices.advanced(by: ret).pointee = itemIndices.advanced(by: i).pointee
                itemIndices.advanced(by: i).pointee = temp
                
                ret += 1
            }
        }
        if (ret == 0 || ret == numItems) {
            ret = numItems >> 1
        }
        return ret
    }
}
