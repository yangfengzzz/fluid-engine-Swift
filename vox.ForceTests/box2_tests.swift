//
//  box2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class box2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        var box = Box2()
        
        XCTAssertEqual(Vector2F(), box.bound.lowerCorner)
        XCTAssertEqual(Vector2F(1, 1), box.bound.upperCorner)
        
        box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        
        XCTAssertEqual(Vector2F(-1, 2), box.bound.lowerCorner)
        XCTAssertEqual(Vector2F(5, 3), box.bound.upperCorner)
        
        box = Box2(boundingBox: BoundingBox2F(point1: Vector2F(-1, 2), point2: Vector2F(5, 3)))
        
        box.isNormalFlipped = true
        XCTAssertTrue(box.isNormalFlipped)
        XCTAssertEqual(Vector2F(-1, 2), box.bound.lowerCorner)
        XCTAssertEqual(Vector2F(5, 3), box.bound.upperCorner)
    }
    
    func testClosestPoint() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        
        let result0 = box.closestPoint(otherPoint: Vector2F(-2, 4))
        XCTAssertEqual(Vector2F(-1, 3), result0)
        
        let result1 = box.closestPoint(otherPoint: Vector2F(1, 5))
        XCTAssertEqual(Vector2F(1, 3), result1)
        
        let result2 = box.closestPoint(otherPoint: Vector2F(9, 5))
        XCTAssertEqual(Vector2F(5, 3), result2)
        
        let result3 = box.closestPoint(otherPoint: Vector2F(-2, 2.4))
        XCTAssertEqual(Vector2F(-1, 2.4), result3)
        
        let result4 = box.closestPoint(otherPoint: Vector2F(1, 2.6))
        XCTAssertEqual(Vector2F(1, 3), result4)
        
        let result5 = box.closestPoint(otherPoint: Vector2F(9, 2.2))
        XCTAssertEqual(Vector2F(5, 2.2), result5)
        
        let result6 = box.closestPoint(otherPoint: Vector2F(-2, 1))
        XCTAssertEqual(Vector2F(-1, 2), result6)
        
        let result7 = box.closestPoint(otherPoint: Vector2F(1, 0))
        XCTAssertEqual(Vector2F(1, 2), result7)
        
        let result8 = box.closestPoint(otherPoint: Vector2F(9, -1))
        XCTAssertEqual(Vector2F(5, 2), result8)
    }
    
    func testClosestDistance() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        
        let result0 = box.closestDistance(otherPoint: Vector2F(-2, 4))
        XCTAssertEqual(length(Vector2F(-2, 4) - Vector2F(-1, 3)), result0)
        
        let result1 = box.closestDistance(otherPoint: Vector2F(1, 5))
        XCTAssertEqual(length(Vector2F(1, 5) - Vector2F(1, 3)), result1)
        
        let result2 = box.closestDistance(otherPoint: Vector2F(9, 5))
        XCTAssertEqual(length(Vector2F(9, 5) - Vector2F(5, 3)), result2)
        
        let result3 = box.closestDistance(otherPoint: Vector2F(-2, 2.4))
        XCTAssertEqual(length(Vector2F(-2, 2.4) - Vector2F(-1, 2.4)), result3)
        
        let result4 = box.closestDistance(otherPoint: Vector2F(1, 2.6))
        XCTAssertEqual(length(Vector2F(1, 2.6) - Vector2F(1, 3)), result4)
        
        let result5 = box.closestDistance(otherPoint: Vector2F(9, 2.2))
        XCTAssertEqual(length(Vector2F(9, 2.2) - Vector2F(5, 2.2)), result5)
        
        let result6 = box.closestDistance(otherPoint: Vector2F(-2, 1))
        XCTAssertEqual(length(Vector2F(-2, 1) - Vector2F(-1, 2)), result6)
        
        let result7 = box.closestDistance(otherPoint: Vector2F(1, 0))
        XCTAssertEqual(length(Vector2F(1, 0) - Vector2F(1, 2)), result7)
        
        let result8 = box.closestDistance(otherPoint: Vector2F(9, -1))
        XCTAssertEqual(length(Vector2F(9, -1) - Vector2F(5, 2)), result8)
    }
    
    func testIntersects() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        
        let result0 = box.intersects(ray: Ray2F(newOrigin: Vector2F(1, 4),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = box.intersects(ray: Ray2F(newOrigin: Vector2F(1, 2.5),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1)
        
        let result2 = box.intersects(ray: Ray2F(newOrigin: Vector2F(1, 1),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        
        let result0 = box.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 4),
                       newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(2), result0.distance, accuracy:1.0e-15)
        XCTAssertEqual(Vector2F(5.9604645e-08, 3), result0.point)
        
        let result1 = box.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 2.5),
                       newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.5), result1.distance, accuracy:1.0e-15)
        XCTAssertEqual(Vector2F(0.5, 2), result1.point)
        
        let result2 = box.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 1),
                       newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        let boundingBox = box.boundingBox()
        
        XCTAssertEqual(Vector2F(-1, 2), boundingBox.lowerCorner)
        XCTAssertEqual(Vector2F(5, 3), boundingBox.upperCorner)
    }
    
    func testClosestNormal() {
        let box = Box2(lowerCorner: Vector2F(-1, 2), upperCorner: Vector2F(5, 3))
        box.isNormalFlipped = true
        
        let result0 = box.closestNormal(otherPoint: Vector2F(-2, 2))
        XCTAssertEqual(Vector2F(1, -0), result0)
        
        let result1 = box.closestNormal(otherPoint: Vector2F(3, 5))
        XCTAssertEqual(Vector2F(0, -1), result1)
        
        let result2 = box.closestNormal(otherPoint: Vector2F(9, 3))
        XCTAssertEqual(Vector2F(-1, 0), result2)
        
        let result3 = box.closestNormal(otherPoint: Vector2F(4, 1))
        XCTAssertEqual(Vector2F(0, 1), result3)
    }
    
    func testBuilder() {
        let box = Box2.builder()
            .withLowerCorner(pt: [-3.0, -2.0])
            .withUpperCorner(pt: [5.0, 4.0])
            .build()
        
        XCTAssertEqual(Vector2F(-3.0, -2.0), box.bound.lowerCorner)
        XCTAssertEqual(Vector2F(5.0, 4.0), box.bound.upperCorner)
    }
}
