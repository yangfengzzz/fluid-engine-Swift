//
//  list_query_engine2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class list_query_engine2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoxIntersection() {
        let numSamples = getNumberOfSamplePoints2()
        let points = getSamplePoints2()
        
        let engine = ListQueryEngine2<Vector2F>()
        engine.add(items: points)
        
        let testFunc:BoxIntersectionTestFunc2<Vector2F> = {(pt:Vector2F, bbox:BoundingBox2F)->Bool in
            return bbox.contains(point: pt)
        }
        
        let testBox = BoundingBox2F(point1: [0.25, 0.2], point2: [0.5, 0.4])
        var numIntersections:size_t = 0
        for i in 0..<numSamples {
            if testFunc(getSamplePoints2()[i], testBox) {
                numIntersections += 1
            }
        }
        var hasIntersection = numIntersections > 0
        
        XCTAssertEqual(hasIntersection, engine.intersects(box: testBox, testFunc: testFunc))
        
        let testBox2 = BoundingBox2F(point1: [0.2, 0.2], point2: [0.6, 0.5])
        numIntersections = 0
        for i in 0..<numSamples {
            if testFunc(getSamplePoints2()[i], testBox2) {
                numIntersections += 1
            }
        }
        hasIntersection = numIntersections > 0
        
        XCTAssertEqual(hasIntersection, engine.intersects(box: testBox2, testFunc: testFunc))
        
        var measured:size_t = 0
        engine.forEachIntersectingItem(box: testBox2, testFunc: testFunc, visitorFunc: {(pt:Vector2F)->Void in
            XCTAssertTrue(testFunc(pt, testBox2))
            measured += 1
        })
        
        XCTAssertEqual(numIntersections, measured)
    }

    func testRayIntersection() {
        let engine =  ListQueryEngine2<BoundingBox2F>()
        
        let intersectsFunc:RayIntersectionTestFunc2<BoundingBox2F> = {(a:BoundingBox2F, ray:Ray2F)->Bool in
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
        
        engine.add(items: items)
        
        for i in 0..<numSamples/2 {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i + numSamples / 2],
                            newDirection: getSampleDirs2()[i + numSamples / 2])
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
        let engine = ListQueryEngine2<BoundingBox2F>()
        
        let intersectsFunc:GetRayIntersectionFunc2<BoundingBox2F> = {(a:BoundingBox2F, ray:Ray2F)->Float in
            let bboxResult = a.closestIntersection(ray: ray)
            return bboxResult.tNear
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
        
        engine.add(items: items)
        
        for i in 0..<numSamples/2 {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i + numSamples / 2],
                            newDirection: getSampleDirs2()[i + numSamples / 2])
            // ad-hoc search
            var ansInts = ClosestIntersectionQueryResult2<BoundingBox2F>()
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
        let engine = ListQueryEngine2<Vector2F>()
        
        let distanceFunc:NearestNeighborDistanceFunc2<Vector2F> = {(a:Vector2F, b:Vector2F) in
            return length(a - b)
        }
        
        let numSamples = getNumberOfSamplePoints2()
        let points = getSamplePoints2()
        
        engine.add(items: points)
        
        let testPt = Vector2F(0.5, 0.5)
        let closest = engine.nearest(pt: testPt, distanceFunc: distanceFunc)
        var answer = getSamplePoints2()[0]
        var bestDist = length(testPt - answer)
        for i in 1..<numSamples {
            let dist = length(testPt - getSamplePoints2()[i])
            if (dist < bestDist) {
                bestDist = dist
                answer = getSamplePoints2()[i]
            }
        }
        
        XCTAssertEqual(answer, closest.item)
    }
}
