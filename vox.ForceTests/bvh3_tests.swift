//
//  bvh3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class bvh3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructors() {
        let bvh = Bvh3<Vector3F>()
        XCTAssertEqual(bvh.numberOfItems(), 0)
    }

    func testBasicGetters() {
        let bvh = Bvh3<Vector3F>()
        let points:[Vector3F] = [Vector3F(0, 0, 0), Vector3F(1, 1, 1)]
        var i:size_t = 0
        var rootBounds:BoundingBox3F = BoundingBox3F()
        let bounds:[BoundingBox3F] = (0..<2).map { _ in
            let c = points[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            rootBounds.merge(other: box)
            return box
        }
        
        bvh.build(items: points, itemsBounds: bounds)
        
        XCTAssertEqual(2, bvh.numberOfItems())
        XCTAssertEqual(points[0], bvh.item(i: 0))
        XCTAssertEqual(points[1], bvh.item(i: 1))
        XCTAssertEqual(3, bvh.numberOfNodes())
        XCTAssertEqual(1, bvh.children(i: 0).0)
        XCTAssertEqual(2, bvh.children(i: 0).1)
        XCTAssertFalse(bvh.isLeaf(i: 0))
        XCTAssertTrue(bvh.isLeaf(i: 1))
        XCTAssertTrue(bvh.isLeaf(i: 2))
        XCTAssertEqual(rootBounds.lowerCorner, bvh.nodeBound(i: 0).lowerCorner)
        XCTAssertEqual(rootBounds.upperCorner, bvh.nodeBound(i: 0).upperCorner)
        XCTAssertEqual(bounds[0].lowerCorner, bvh.nodeBound(i: 1).lowerCorner)
        XCTAssertEqual(bounds[0].upperCorner, bvh.nodeBound(i: 1).upperCorner)
        XCTAssertEqual(bounds[1].lowerCorner, bvh.nodeBound(i: 2).lowerCorner)
        XCTAssertEqual(bounds[1].upperCorner, bvh.nodeBound(i: 2).upperCorner)
    }
    
    func testNearest() {
        let bvh = Bvh3<Vector3F>()
        
        let distanceFunc:NearestNeighborDistanceFunc3<Vector3F> = {(a:Vector3F, b:Vector3F)->Float in
            return length(a - b)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
                
        var i:size_t = 0
        let bounds:[BoundingBox3F] = (0..<points.count).map { _ in
            let c = points[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        bvh.build(items: points, itemsBounds: bounds)
        
        let testPt = Vector3F(0.5, 0.5, 0.5)
        let nearest = bvh.nearest(pt: testPt, distanceFunc: distanceFunc)
        var answerIdx:size_t = 0
        var bestDist = length(testPt - points[answerIdx])
        for i in 1..<numSamples {
            let dist = length(testPt - getSamplePoints3()[i])
            if (dist < bestDist) {
                bestDist = dist
                answerIdx = i
            }
        }
        
        XCTAssertEqual(points[answerIdx], nearest.item!)
    }

    func testBBoxIntersects() {
        let bvh = Bvh3<Vector3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F)->Bool in
            var box = BoundingBox3F(point1: pt, point2: pt)
            box.expand(delta: 0.1)
            return bbox.overlaps(other: box)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        var i:size_t = 0
        let bounds:[BoundingBox3F] = (0..<points.count).map { _ in
            let c = points[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        bvh.build(items: points, itemsBounds: bounds)
        
        let testBox = BoundingBox3F(point1: [0.25, 0.15, 0.3], point2: [0.5, 0.6, 0.4])
        var hasOverlaps = false
        for i in 1..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints3()[i], testBox)
        }
        
        XCTAssertEqual(hasOverlaps, bvh.intersects(box: testBox, testFunc: overlapsFunc))
        
        let testBox2 = BoundingBox3F(point1: [0.3, 0.2, 0.1], point2: [0.6, 0.5, 0.4])
        hasOverlaps = false
        for i in 1..<numSamples {
            hasOverlaps = hasOverlaps || overlapsFunc(getSamplePoints3()[i], testBox2)
        }
        
        XCTAssertEqual(hasOverlaps, bvh.intersects(box: testBox2, testFunc: overlapsFunc))
    }
    
    func testRayIntersects() {
        let bvh = Bvh3<BoundingBox3F>()
        
        let intersectsFunc:RayIntersectionTestFunc3<BoundingBox3F> = {(a:BoundingBox3F, ray:Ray3F)->Bool in
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
        
        bvh.build(items: items, itemsBounds: items)
        
        for i in 0..<numSamples/2 {
            let ray = Ray3F(newOrigin: getSampleDirs3()[i + numSamples / 2],
                            newDirection: getSampleDirs3()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = false
            for j in 0..<numSamples/2 {
                if (intersectsFunc(items[j], ray)) {
                    ansInts = true
                    break
                }
            }
            
            // bvh search
            let octInts = bvh.intersects(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts, octInts)
        }
    }
    
    func testClosestIntersection() {
        let bvh = Bvh3<BoundingBox3F>()
        
        let intersectsFunc:GetRayIntersectionFunc3<BoundingBox3F> = {(a:BoundingBox3F, ray:Ray3F)->Float in
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
        
        bvh.build(items: items, itemsBounds: items)
        
        for i in 0..<numSamples/2 {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i + numSamples / 2],
                            newDirection: getSampleDirs3()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = ClosestIntersectionQueryResult3<BoundingBox3F>()
            for j in 0..<numSamples/2 {
                let dist = intersectsFunc(items[j], ray)
                if (dist < ansInts.distance) {
                    ansInts.distance = dist
                    ansInts.item = bvh.item(i: j)
                }
            }
            
            // bvh search
            let bvhInts = bvh.closestIntersection(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts.distance, bvhInts.distance)
            XCTAssertEqual(ansInts.item?.lowerCorner, bvhInts.item?.lowerCorner)
            XCTAssertEqual(ansInts.item?.upperCorner, bvhInts.item?.upperCorner)
        }
    }
    
    func testForEachOverlappingItems() {
        let bvh = Bvh3<Vector3F>()
        
        let overlapsFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F) in
            return bbox.contains(point: pt)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        var i:size_t = 0
        let bounds:[BoundingBox3F] = (0..<points.count).map { _ in
            let c = points[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        bvh.build(items: points, itemsBounds: bounds)
        
        let testBox = BoundingBox3F(point1: [0.3, 0.2, 0.1], point2: [0.6, 0.5, 0.4])
        var numOverlaps:size_t = 0
        for i in 0..<numSamples {
            if overlapsFunc(getSamplePoints3()[i], testBox) == true {
                numOverlaps += 1
            }
        }
        
        var measured:size_t = 0
        bvh.forEachIntersectingItem(box: testBox, testFunc: overlapsFunc, visitorFunc: {(pt:Vector3F)->Void in
            XCTAssertTrue(overlapsFunc(pt, testBox))
            measured += 1
        })
        
        XCTAssertEqual(numOverlaps, measured)
    }
}