//
//  quadtree_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class quadtree_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let quadtree = Quadtree<Vector2F>()
        XCTAssertEqual(quadtree.numberOfItems(), 0)
    }
    
    func testNearest() {
        let quadtree = Quadtree<Vector2F>()
        
        let overlapsFunc:BoxIntersectionTestFunc2<Vector2F> = {(pt:Vector2F, bbox:BoundingBox2F) in
            return bbox.contains(point: pt)
        }
        
        let distanceFunc:NearestNeighborDistanceFunc2<Vector2F> = {(a:Vector2F, b:Vector2F)->Float in
            return length(a - b)
        }
        
        // Single point
        quadtree.build(items: [Vector2F(0.2, 0.7)],
                       bound: BoundingBox2F(point1: [0, 0],
                                            point2: [0.9, 1.0]),
                       testFunc: overlapsFunc, maxDepth: 3)
        
        XCTAssertEqual(3, quadtree.maxDepth())
        XCTAssertEqual(Vector2F(0, 0), quadtree.boundingBox().lowerCorner)
        XCTAssertEqual(Vector2F(1, 1), quadtree.boundingBox().upperCorner)
        XCTAssertEqual(9, quadtree.numberOfNodes())
        
        var child = quadtree.childIndex(nodeIdx: 0, childIdx: 2)
        XCTAssertEqual(3, child)
        
        child = quadtree.childIndex(nodeIdx: child, childIdx: 0)
        XCTAssertEqual(5, child)
        
        let theNonEmptyLeafNode = child + 0
        for i in 0..<9 {
            if i == theNonEmptyLeafNode {
                XCTAssertEqual(1, quadtree.itemsAtNode(nodeIdx: i).count)
            } else {
                print(i)
                XCTAssertEqual(0, quadtree.itemsAtNode(nodeIdx: i).count)
            }
        }
        
        // Many points
        let numSamples = getNumberOfSamplePoints2()
        let points = getSamplePoints2()
        
        quadtree.build(items: points,
                       bound: BoundingBox2F(point1: [0, 0],
                                            point2: [1, 1]),
                       testFunc: overlapsFunc, maxDepth: 5)
        
        let testPt = Vector2F(0.5, 0.5)
        let nearest = quadtree.nearest(pt: testPt, distanceFunc: distanceFunc)
        var answerIdx:size_t = 0
        var bestDist = length(testPt - points[answerIdx])
        for i in 1..<numSamples {
            let dist = length(testPt - getSamplePoints2()[i])
            if (dist < bestDist) {
                bestDist = dist
                answerIdx = i
            }
        }
        
        
        XCTAssertEqual(nearest.item, quadtree.item(i: answerIdx))
    }
    
    func testBBoxIntersects() {
        let quadtree = Quadtree<Vector2F>()
        
        let overlapsFunc:BoxIntersectionTestFunc2<Vector2F> = {(pt:Vector2F, bbox:BoundingBox2F) in
            return bbox.contains(point: pt)
        }
        
        let numSamples = getNumberOfSamplePoints2()
        let points = getSamplePoints2()
        
        quadtree.build(items: points, bound: BoundingBox2F(point1: [0, 0],
                                                           point2: [1, 1]),
                       testFunc: overlapsFunc, maxDepth: 5)
        
        let testBox = BoundingBox2F(point1: [0.25, 0.15],
                                    point2: [0.5, 0.6])
        var hasOverlaps = false
        for i in 0..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints2()[i], testBox)
        }
        
        XCTAssertEqual(hasOverlaps, quadtree.intersects(box: testBox, testFunc: overlapsFunc))
        
        let testBox2 = BoundingBox2F(point1: [0.2, 0.2], point2: [0.6, 0.5])
        hasOverlaps = false
        for i in 0..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints2()[i], testBox2)
        }
        
        XCTAssertEqual(hasOverlaps, quadtree.intersects(box: testBox2, testFunc: overlapsFunc))
    }
    
    func testForEachOverlappingItems() {
        let quadtree = Quadtree<Vector2F>()
        
        let overlapsFunc:BoxIntersectionTestFunc2<Vector2F> = {(pt:Vector2F, bbox:BoundingBox2F) in
            return bbox.contains(point: pt)
        }
        
        let numSamples = getNumberOfSamplePoints2()
        let points = getSamplePoints2()
        
        quadtree.build(items: points, bound: BoundingBox2F(point1: [0, 0], point2: [1, 1]),
                       testFunc: overlapsFunc, maxDepth: 5)
        
        let testBox = BoundingBox2F(point1: [0.2, 0.2], point2: [0.6, 0.5])
        var numOverlaps = 0
        for i in 0..<numSamples {
            if overlapsFunc(getSamplePoints2()[i], testBox) {
                numOverlaps += 1
            }
        }
        
        var measured = 0
        quadtree.forEachIntersectingItem(box: testBox, testFunc: overlapsFunc) { (pt:Vector2F) in
            XCTAssertTrue(overlapsFunc(pt, testBox))
            measured += 1
        }
        
        XCTAssertEqual(numOverlaps, measured)
    }
    
    func testRayIntersects() {
        let quadtree = Quadtree<BoundingBox2F>()
        
        let overlapsFunc:BoxIntersectionTestFunc2<BoundingBox2F> = {(a:BoundingBox2F, bbox:BoundingBox2F) in
            return bbox.overlaps(other: a)
        }
        
        let intersectsFunc:RayIntersectionTestFunc2<BoundingBox2F> = {(a:BoundingBox2F, ray:Ray2F) in
            return a.intersects(ray: ray)
        }
        
        let numSamples = getNumberOfSamplePoints2()
        var i:size_t = 0
        let items:[BoundingBox2F] = (0..<numSamples/2).map { _ in
            let c = getSamplePoints2()[i]
            i += 1
            var box = BoundingBox2F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        quadtree.build(items: items, bound: BoundingBox2F(point1: [0, 0], point2: [1, 1]),
                       testFunc: overlapsFunc, maxDepth: 5)
        
        for i in 0..<numSamples/2 {
            let ray = Ray2F(newOrigin: getSampleDirs2()[i + numSamples / 2],
                            newDirection: getSampleDirs2()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = false
            for j in 0..<numSamples/2 {
                if (intersectsFunc(items[j], ray)) {
                    ansInts = true
                    break
                }
            }
            
            // quadtree search
            let octInts = quadtree.intersects(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts, octInts)
        }
    }
    
    func testClosestIntersection() {
        let quadtree = Quadtree<BoundingBox2F>()
        
        let overlapsFunc:BoxIntersectionTestFunc2<BoundingBox2F> = {(a:BoundingBox2F, bbox:BoundingBox2F) in
            return bbox.overlaps(other: a)
        }
        
        let intersectsFunc:GetRayIntersectionFunc2<BoundingBox2F> = {(a:BoundingBox2F, ray:Ray2F) in
            let bboxResult = a.closestIntersection(ray: ray)
            if (bboxResult.isIntersecting) {
                return bboxResult.tNear
            } else {
                return Float.greatestFiniteMagnitude
            }
        }
        
        let numSamples = getNumberOfSamplePoints2()
        var i:size_t = 0
        let items:[BoundingBox2F] = (0..<numSamples/2).map { _ in
            let c = getSamplePoints2()[i]
            i += 1
            var box = BoundingBox2F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        quadtree.build(items: items, bound: BoundingBox2F(point1: [0, 0], point2: [1, 1]),
                       testFunc: overlapsFunc, maxDepth: 5)
        
        for i in 0..<numSamples/2 {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i + numSamples / 2],
                            newDirection: getSampleDirs2()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = ClosestIntersectionQueryResult2<BoundingBox2F>()
            for j in 0..<numSamples/2 {
                let dist = intersectsFunc(items[j], ray)
                if (dist < ansInts.distance) {
                    ansInts.distance = dist
                    ansInts.item = quadtree.item(i: j)
                }
            }
            
            // quadtree search
            let octInts = quadtree.closestIntersection(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts.distance, octInts.distance)
            XCTAssertEqual(ansInts.item?.upperCorner, octInts.item?.upperCorner)
            XCTAssertEqual(ansInts.item?.lowerCorner, octInts.item?.lowerCorner)
        }
    }
}
