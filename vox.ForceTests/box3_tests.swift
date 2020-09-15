//
//  box3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class box3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        var box = Box3()
        
        XCTAssertFalse(box.isNormalFlipped)
        XCTAssertEqual(Vector3F(), box.bound.lowerCorner)
        XCTAssertEqual(Vector3F(1, 1, 1), box.bound.upperCorner)
        
        box = Box3(lowerCorner: Vector3F(-1, 2, 1), upperCorner: Vector3F(5, 3, 4))
        
        XCTAssertFalse(box.isNormalFlipped)
        XCTAssertEqual(Vector3F(-1, 2, 1), box.bound.lowerCorner)
        XCTAssertEqual(Vector3F(5, 3, 4), box.bound.upperCorner)
        
        box = Box3(boundingBox: BoundingBox3F(point1: Vector3F(-1, 2, 1), point2: Vector3F(5, 3, 4)))
        
        box.isNormalFlipped = true
        XCTAssertTrue(box.isNormalFlipped)
        XCTAssertEqual(Vector3F(-1, 2, 1), box.bound.lowerCorner)
        XCTAssertEqual(Vector3F(5, 3, 4), box.bound.upperCorner)
    }
    
    func testClosestPoint() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 1), upperCorner: Vector3F(5, 3, 4))
        
        let result0 = box.closestPoint(otherPoint: Vector3F(-2, 4, 5))
        XCTAssertEqual(Vector3F(-1, 3, 4), result0)
        
        let result1 = box.closestPoint(otherPoint: Vector3F(1, 5, 0))
        XCTAssertEqual(Vector3F(1, 3, 1), result1)
        
        let result2 = box.closestPoint(otherPoint: Vector3F(9, 5, 7))
        XCTAssertEqual(Vector3F(5, 3, 4), result2)
        
        let result3 = box.closestPoint(otherPoint: Vector3F(-2, 2.4, 3))
        XCTAssertEqual(Vector3F(-1, 2.4, 3), result3)
        
        let result4 = box.closestPoint(otherPoint: Vector3F(1, 2.6, 1.1))
        XCTAssertEqual(Vector3F(1, 2.6, 1), result4)
        
        let result5 = box.closestPoint(otherPoint: Vector3F(9, 2.2, -1))
        XCTAssertEqual(Vector3F(5, 2.2, 1), result5)
        
        let result6 = box.closestPoint(otherPoint: Vector3F(-2, 1, 1.1))
        XCTAssertEqual(Vector3F(-1, 2, 1.1), result6)
        
        let result7 = box.closestPoint(otherPoint: Vector3F(1, 0, 3.5))
        XCTAssertEqual(Vector3F(1, 2, 3.5), result7)
        
        let result8 = box.closestPoint(otherPoint: Vector3F(9, -1, -3))
        XCTAssertEqual(Vector3F(5, 2, 1), result8)
    }
    
    func testClosestDistance() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 1), upperCorner: Vector3F(5, 3, 4))
        
        let result0 = box.closestDistance(otherPoint: Vector3F(-2, 4, 5))
        XCTAssertEqual(length(Vector3F(-1, 3, 4) - Vector3F(-2, 4, 5)),
                       result0)
        
        let result1 = box.closestDistance(otherPoint: Vector3F(1, 5, 0))
        XCTAssertEqual(length(Vector3F(1, 3, 1) - Vector3F(1, 5, 0)),
                       result1)
        
        let result2 = box.closestDistance(otherPoint: Vector3F(9, 5, 7))
        XCTAssertEqual(length(Vector3F(5, 3, 4) - Vector3F(9, 5, 7)),
                       result2)
        
        let result3 = box.closestDistance(otherPoint: Vector3F(-2, 2.4, 3))
        XCTAssertEqual(length(Vector3F(-1, 2.4, 3) - Vector3F(-2, 2.4, 3)),
                       result3)
        
        let result4 = box.closestDistance(otherPoint: Vector3F(1, 2.6, 1.1))
        XCTAssertEqual(length(Vector3F(1, 2.6, 1) - Vector3F(1, 2.6, 1.1)),
                       result4)
        
        let result5 = box.closestDistance(otherPoint: Vector3F(9, 2.2, -1))
        XCTAssertEqual(length(Vector3F(5, 2.2, 1) - Vector3F(9, 2.2, -1)),
                       result5)
        
        let result6 = box.closestDistance(otherPoint: Vector3F(-2, 1, 1.1))
        XCTAssertEqual(length(Vector3F(-1, 2, 1.1) - Vector3F(-2, 1, 1.1)),
                       result6)
        
        let result7 = box.closestDistance(otherPoint: Vector3F(1, 0, 3.5))
        XCTAssertEqual(length(Vector3F(1, 2, 3.5) - Vector3F(1, 0, 3.5)),
                       result7)
        
        let result8 = box.closestDistance(otherPoint: Vector3F(9, -1, -3))
        XCTAssertEqual(length(Vector3F(5, 2, 1) - Vector3F(9, -1, -3)),
                       result8)
    }
    
    func testIntersects() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 3), upperCorner: Vector3F(5, 3, 7))
        
        let result0 = box.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5),
                       newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = box.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6),
                       newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1)
        
        let result2 = box.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2),
                       newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 3), upperCorner: Vector3F(5, 3, 7))
        
        let result0 = box.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5),
                       newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(3), result0.distance, accuracy:1.0e-6)
        XCTAssertEqual(Vector3F(0, 3, 4), result0.point)
        
        let result1 = box.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6),
                       newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.75), result1.distance, accuracy:1.0e-7)
        XCTAssertEqual(Vector3F(0.5, 2, 6.5), result1.point)
        
        let result2 = box.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2),
                       newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 3), upperCorner: Vector3F(5, 3, 7))
        let boundingBox = box.boundingBox()
        
        XCTAssertEqual(Vector3F(-1, 2, 3), boundingBox.lowerCorner)
        XCTAssertEqual(Vector3F(5, 3, 7), boundingBox.upperCorner)
    }
    
    func testClosestNormal() {
        let box = Box3(lowerCorner: Vector3F(-1, 2, 1), upperCorner: Vector3F(5, 3, 4))
        box.isNormalFlipped = true
        
        let result0 = box.closestNormal(otherPoint: Vector3F(-2, 2, 3))
        XCTAssertEqual(Vector3F(1, 0, 0), result0)
        
        let result1 = box.closestNormal(otherPoint: Vector3F(3, 5, 2))
        XCTAssertEqual(Vector3F(0, -1, 0), result1)
        
        let result2 = box.closestNormal(otherPoint: Vector3F(9, 3, 4))
        XCTAssertEqual(Vector3F(-1, 0, 0), result2)
        
        let result3 = box.closestNormal(otherPoint: Vector3F(4, 1, 1))
        XCTAssertEqual(Vector3F(0, 1, 0), result3)
        
        let result4 = box.closestNormal(otherPoint: Vector3F(4, 2.5, -1))
        XCTAssertEqual(Vector3F(0, 0, 1), result4)
        
        let result5 = box.closestNormal(otherPoint: Vector3F(4, 2, 9))
        XCTAssertEqual(Vector3F(0, 0, -1), result5)
    }
}
