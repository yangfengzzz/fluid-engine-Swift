//
//  list_query_engine3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class list_query_engine3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoxIntersection() {
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        let engine = ListQueryEngine3<Vector3F>()
        engine.add(items: points)
        
        let testFunc:BoxIntersectionTestFunc3<Vector3F> = {(pt:Vector3F, bbox:BoundingBox3F)->Bool in
            return bbox.contains(point: pt)
        }
        
        let testBox = BoundingBox3F(point1: [0.25, 0.15, 0.3], point2: [0.5, 0.6, 0.4])
        var numIntersections:size_t = 0
        for i in 0..<numSamples {
            if testFunc(getSamplePoints3()[i], testBox) {
                numIntersections += 1
            }
        }
        var hasIntersection = numIntersections > 0
        
        XCTAssertEqual(hasIntersection, engine.intersects(box: testBox, testFunc: testFunc))
        
        let testBox2 = BoundingBox3F(point1: [0.3, 0.2, 0.1], point2: [0.6, 0.5, 0.4])
        numIntersections = 0
        for i in 0..<numSamples {
            if testFunc(getSamplePoints3()[i], testBox2) {
                numIntersections += 1
            }
        }
        hasIntersection = numIntersections > 0
        
        XCTAssertEqual(hasIntersection, engine.intersects(box: testBox2, testFunc: testFunc))
        
        var measured:size_t = 0
        engine.forEachIntersectingItem(box: testBox2, testFunc: testFunc, visitorFunc: {(pt:Vector3F)->Void in
            XCTAssertTrue(testFunc(pt, testBox2))
            measured += 1
        })
        
        XCTAssertEqual(numIntersections, measured)
    }

    func testRayIntersection() {
        let engine =  ListQueryEngine3<BoundingBox3F>()
        
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
        
        engine.add(items: items)
        
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
            
            // engine search
            let engInts = engine.intersects(ray: ray, testFunc: intersectsFunc)
            
            XCTAssertEqual(ansInts, engInts)
        }
    }
    
    func testClosestIntersection() {
        let engine = ListQueryEngine3<BoundingBox3F>()
        
        let intersectsFunc:GetRayIntersectionFunc3<BoundingBox3F> = {(a:BoundingBox3F, ray:Ray3F)->Float in
            let bboxResult = a.closestIntersection(ray: ray)
            return bboxResult.tNear
        }
        
        let numSamples = getNumberOfSamplePoints2()
        var i:size_t = 0
        let items:[BoundingBox3F] = (0..<numSamples/2).map { _ in
            let c = getSamplePoints3()[i]
            i += 1
            var box = BoundingBox3F(point1: c, point2: c)
            box.expand(delta: 0.1)
            return box
        }
        
        engine.add(items: items)
        
        for i in 0..<numSamples/2 {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i + numSamples / 2],
                            newDirection: getSampleDirs3()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = ClosestIntersectionQueryResult3<BoundingBox3F>()
            for j in 0..<numSamples/2 {
                let dist = intersectsFunc(items[j], ray)
                if (dist < ansInts.distance) {
                    ansInts.distance = dist
                    ansInts.item = items[j]
                }
            }
            
            // engine search
            let engInts = engine.closestIntersection(ray: ray, testFunc: intersectsFunc)
            
            if (ansInts.item != nil && engInts.item != nil) {
                XCTAssertEqual(ansInts.item?.lowerCorner,
                               engInts.item?.lowerCorner)
                XCTAssertEqual(ansInts.item?.upperCorner,
                               engInts.item?.upperCorner)
            } else {
                XCTAssertEqual(nil, ansInts.item?.lowerCorner)
                XCTAssertEqual(nil, ansInts.item?.upperCorner)
                XCTAssertEqual(nil, engInts.item?.lowerCorner)
                XCTAssertEqual(nil, engInts.item?.upperCorner)
            }
            XCTAssertEqual(ansInts.distance, engInts.distance)
        }
    }
    
    func testNearestNeighbor() {
        let engine = ListQueryEngine3<Vector3F>()
        
        let distanceFunc:NearestNeighborDistanceFunc3<Vector3F> = {(a:Vector3F, b:Vector3F) in
            return length(a - b)
        }
        
        let numSamples = getNumberOfSamplePoints3()
        let points = getSamplePoints3()
        
        engine.add(items: points)
        
        let testPt = Vector3F(0.5, 0.5, 0.5)
        let closest = engine.nearest(pt: testPt, distanceFunc: distanceFunc)
        var answer = getSamplePoints3()[0]
        var bestDist = length(testPt - answer)
        for i in 1..<numSamples {
            let dist = length(testPt - getSamplePoints3()[i])
            if (dist < bestDist) {
                bestDist = dist
                answer = getSamplePoints3()[i]
            }
        }
        
        XCTAssertEqual(answer, closest.item)
    }

}
