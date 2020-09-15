//
//  octree_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class octree_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let octree = Octree<Vector3F>()
        XCTAssertEqual(octree.numberOfItems(), 0)
        XCTAssertEqual(octree.numberOfNodes(), 0)
    }
    
    func testNearest() {
        let octree = Octree<Vector3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F) in
            return bbox.contains(point: pt)
        }
        
        let distanceFunc:NearestNeighborDistanceFunc3<Vector3F> = {(a:Vector3F, b:Vector3F) in
            return length(a - b)
        }
        
        // Single point
        octree.build(items: [Vector3F(0.2, 0.7, 0.3)],
                     bound: BoundingBox3F(point1: [0, 0, 0], point2: [0.9, 0.8, 1]),
                     testFunc: overlapsFunc, maxDepth: 3)
        
        XCTAssertEqual(3, octree.maxDepth())
        XCTAssertEqual(Vector3F(0, 0, 0), octree.boundingBox().lowerCorner)
        XCTAssertEqual(Vector3F(1, 1, 1), octree.boundingBox().upperCorner)
        XCTAssertEqual(17, octree.numberOfNodes())
        
        var child = octree.childIndex(nodeIdx: 0, childIdx: 2)
        XCTAssertEqual(3, child)
        
        child = octree.childIndex(nodeIdx: child, childIdx: 0)
        XCTAssertEqual(9, child)
        
        let theNonEmptyLeafNode = child + 4
        for i in 0..<17 {
            if (i == theNonEmptyLeafNode) {
                XCTAssertEqual(1, octree.itemsAtNode(nodeIdx: i).count)
            } else {
                XCTAssertEqual(0, octree.itemsAtNode(nodeIdx: i).count)
            }
        }
        
        // Many points
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        octree.build(items: points, bound: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]),
                     testFunc: overlapsFunc, maxDepth: 5)
        
        let testPt = Vector3F(0.5, 0.5, 0.5)
        let nearest = octree.nearest(pt: testPt, distanceFunc: distanceFunc)
        var answerIdx:size_t = 0
        var bestDist = length(testPt - points[answerIdx])
        for i in 1..<numSamples {
            let dist = length(testPt - getSamplePoints3()[i])
            if (dist < bestDist) {
                bestDist = dist
                answerIdx = i
            }
        }
        
        
        XCTAssertEqual(nearest.item, octree.item(i: answerIdx))
    }
    
    func testBBoxIntersects() {
        let octree = Octree<Vector3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F) in
            return bbox.contains(point: pt)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        octree.build(items: points, bound: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]),
                     testFunc: overlapsFunc, maxDepth: 5)
        
        let testBox = BoundingBox3F(point1: [0.25, 0.15, 0.3], point2: [0.5, 0.6, 0.4])
        var hasOverlaps = false
        for i in 0..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints3()[i], testBox)
        }
        
        XCTAssertEqual(hasOverlaps, octree.intersects(box: testBox, testFunc: overlapsFunc))
        
        let testBox2 = BoundingBox3F(point1: [0.3, 0.2, 0.1], point2: [0.6, 0.5, 0.4])
        hasOverlaps = false
        for i in 0..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints3()[i], testBox2)
        }
        
        XCTAssertEqual(hasOverlaps, octree.intersects(box: testBox2, testFunc: overlapsFunc))
    }
    
    func testForEachOverlappingItems() {
        let octree = Octree<Vector3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F) in
            return bbox.contains(point: pt)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        octree.build(items: points, bound: BoundingBox3F(point1: [0, 0, 0],
                                                         point2: [1, 1, 1]),
                     testFunc: overlapsFunc, maxDepth: 5)
        
        let testBox = BoundingBox3F(point1: [0.3, 0.2, 0.1],
                                    point2: [0.6, 0.5, 0.4])
        var numOverlaps = 0
        for i in 0..<numSamples {
            if overlapsFunc(getSamplePoints3()[i], testBox) {
                numOverlaps += 1
            }
        }
        
        var measured = 0
        octree.forEachIntersectingItem(box: testBox, testFunc: overlapsFunc){
            (pt:Vector3F) in
            XCTAssertTrue(overlapsFunc(pt, testBox))
            measured += 1
        }
        
        XCTAssertEqual(numOverlaps, measured)
    }
    
    func testRayIntersects() {
        let octree = Octree<BoundingBox3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<BoundingBox3F> = {(a:BoundingBox3F, bbox:BoundingBox3F) in
            return bbox.overlaps(other: a)
        }
        
        let intersectsFunc:RayIntersectionTestFunc3<BoundingBox3F> = {(a:BoundingBox3F, ray:Ray3F) in
            return a.intersects(ray: ray)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        var i:size_t = 0
        let items:[BoundingBox3F] = (0..<numSamples/2).map { _ in
            let c = getSamplePoints3()[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        octree.build(items: items, bound: BoundingBox3F(point1: [0, 0, 0],
                                                        point2: [1, 1, 1]),
                     testFunc: overlapsFunc, maxDepth: 5)
        
        for i in 0..<numSamples/2 {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i + numSamples / 2],
                            newDirection: getSampleDirs3()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = false
            for j in 0..<numSamples/2 {
                if (intersectsFunc(items[j], ray)) {
                    ansInts = true
                    break
                }
            }
            
            // octree search
            let octInts = octree.intersects(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts, octInts)
        }
    }
    
    func testClosestIntersection() {
        let octree = Octree<BoundingBox3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<BoundingBox3F> = {(a:BoundingBox3F, bbox:BoundingBox3F) in
            return bbox.overlaps(other: a)
        }
        
        let intersectsFunc:GetRayIntersectionFunc3<BoundingBox3F> = {(a:BoundingBox3F, ray:Ray3F) in
            let bboxResult = a.closestIntersection(ray: ray)
            if (bboxResult.isIntersecting) {
                return bboxResult.tNear
            } else {
                return Float.greatestFiniteMagnitude
            }
        }
        
        let numSamples = getNumberOfSamplePoints3()
        var i:size_t = 0
        let items:[BoundingBox3F] = (0..<numSamples/2).map { _ in
            let c = getSamplePoints3()[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        octree.build(items: items, bound: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]),
                     testFunc: overlapsFunc, maxDepth: 5)
        
        for i in 0..<numSamples/2 {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i + numSamples / 2],
                            newDirection: getSampleDirs3()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = ClosestIntersectionQueryResult3<BoundingBox3F>()
            for j in 0..<numSamples/2 {
                let dist = intersectsFunc(items[j], ray)
                if (dist < ansInts.distance) {
                    ansInts.distance = dist
                    ansInts.item = octree.item(i: j)
                }
            }
            
            // octree search
            let octInts = octree.closestIntersection(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts.distance, octInts.distance)
            XCTAssertEqual(ansInts.item?.lowerCorner, octInts.item?.lowerCorner)
            XCTAssertEqual(ansInts.item?.upperCorner, octInts.item?.upperCorner)
        }
    }
}
