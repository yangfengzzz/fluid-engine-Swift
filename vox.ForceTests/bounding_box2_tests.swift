//
//  bounding_box2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class bounding_box2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        var box = BoundingBox2D()
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.x)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.y)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.x)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.y)
        
        box = BoundingBox2D(point1: Vector2D(-2.0, 3.0), point2: Vector2D(4.0, -2.0))
        XCTAssertEqual(-2.0, box.lowerCorner.x)
        XCTAssertEqual(-2.0, box.lowerCorner.y)
        XCTAssertEqual(4.0, box.upperCorner.x)
        XCTAssertEqual(3.0, box.upperCorner.y)
        
        box = BoundingBox2D(point1: Vector2D(-2.0, 3.0), point2: Vector2D(4.0, -2.0))
        let box2 = BoundingBox2D(other: box)
        XCTAssertEqual(-2.0, box2.lowerCorner.x)
        XCTAssertEqual(-2.0, box2.lowerCorner.y)
        XCTAssertEqual(4.0, box2.upperCorner.x)
        XCTAssertEqual(3.0, box2.upperCorner.y)
    }
    
    func testBasicGetters() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, 3.0),
                                point2: Vector2D(4.0, -2.0))
        
        XCTAssertEqual(6.0, box.width())
        XCTAssertEqual(5.0, box.height())
        XCTAssertEqual(6.0, box.length(axis: 0))
        XCTAssertEqual(5.0, box.length(axis: 1))
    }
    
    func testOverlaps() {
        // x-axis is not overlapping
        var box1 = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        var box2 = BoundingBox2D(point1: Vector2D(5.0, 1.0), point2: Vector2D(8.0, 2.0))
        XCTAssertFalse(box1.overlaps(other: box2))
        
        // y-axis is not overlapping
        box1 = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        box2 = BoundingBox2D(point1: Vector2D(3.0, 4.0), point2: Vector2D(8.0, 6.0))
        XCTAssertFalse(box1.overlaps(other: box2))
        
        // overlapping
        box1 = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        box2 = BoundingBox2D(point1: Vector2D(3.0, 1.0), point2: Vector2D(8.0, 2.0))
        XCTAssertTrue(box1.overlaps(other: box2))
    }
    
    func testContains() {
        // Not containing (x-axis is out)
        var box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        var point = Vector2D(-3.0, 0.0)
        XCTAssertFalse(box.contains(point: point))
        
        // Not containing (y-axis is out)
        box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        point = Vector2D(2.0, 3.5)
        XCTAssertFalse(box.contains(point: point))
        
        // Containing
        box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        point = Vector2D(2.0, 0.0)
        XCTAssertTrue(box.contains(point: point))
    }
    
    func testIntersects() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        
        let ray1 = Ray2D(newOrigin: Vector2D(-3, 0), newDirection: normalize(Vector2D(2, 1)))
        XCTAssertTrue(box.intersects(ray: ray1))
        
        let ray2 = Ray2D(newOrigin: Vector2D(3, -1), newDirection: normalize(Vector2D(-1, 2)))
        XCTAssertTrue(box.intersects(ray: ray2))
        
        let ray3 = Ray2D(newOrigin: Vector2D(1, -5), newDirection: normalize(Vector2D(2, 1)))
        XCTAssertFalse(box.intersects(ray: ray3))
    }
    
    func testClosestIntersection() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(1.0, 0.0))
        
        let ray1 = Ray2D(newOrigin: Vector2D(-4, -3), newDirection: normalize(Vector2D(1, 1)))
        let intersection1 = box.closestIntersection(ray: ray1)
        XCTAssertTrue(intersection1.isIntersecting)
        XCTAssertEqual(length(Vector2D(2, 2)), intersection1.tNear, accuracy:1.0e-15)
        XCTAssertEqual(length(Vector2D(3, 3)), intersection1.tFar)
        
        let ray2 = Ray2D(newOrigin: Vector2D(0, -1), newDirection: normalize(Vector2D(-2, 1)))
        let intersection2 = box.closestIntersection(ray: ray2)
        XCTAssertTrue(intersection2.isIntersecting)
        XCTAssertEqual(length(Vector2D(2, 1)), intersection2.tNear, accuracy:1.0e-15)
    }
    
    func testMidPoint() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        let midPoint = box.midPoint()
        
        XCTAssertEqual(1.0, midPoint.x)
        XCTAssertEqual(0.5, midPoint.y)
    }
    
    func testDiagonalLength() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        let diagLen = box.diagonalLength()
        
        XCTAssertEqual(sqrt(6.0 * 6.0 + 5.0 * 5.0), diagLen)
    }
    
    func testDiagonalLengthSquared() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        let diagLenSqr = box.diagonalLengthSquared()
        
        XCTAssertEqual(6.0 * 6.0 + 5.0 * 5.0, diagLenSqr)
    }
    
    func testReset() {
        var box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        box.reset()
        
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.x)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.y)
        
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.x)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.y)
    }
    
    func testMerge() {
        // Merge with point
        var box =  BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        let point = Vector2D(5.0, 1.0)
        
        box.merge(point: point)
        XCTAssertEqual(-2.0, box.lowerCorner.x)
        XCTAssertEqual(-2.0, box.lowerCorner.y)
        XCTAssertEqual(5.0, box.upperCorner.x)
        XCTAssertEqual(3.0, box.upperCorner.y)
        
        
        // Merge with other box
        var box1 = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        let box2 = BoundingBox2D(point1: Vector2D(3.0, 1.0), point2: Vector2D(8.0, 2.0))
        
        box1.merge(other: box2)
        XCTAssertEqual(-2.0, box1.lowerCorner.x)
        XCTAssertEqual(-2.0, box1.lowerCorner.y)
        XCTAssertEqual(8.0, box1.upperCorner.x)
        XCTAssertEqual(3.0, box1.upperCorner.y)
    }
    
    func testExpand() {
        var box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        box.expand(delta: 3.0)
        
        XCTAssertEqual(-5.0, box.lowerCorner.x)
        XCTAssertEqual(-5.0, box.lowerCorner.y)
        XCTAssertEqual(7.0, box.upperCorner.x)
        XCTAssertEqual(6.0, box.upperCorner.y)
    }
    
    func testCorner() {
        let box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        XCTAssertEqual(Vector2D(-2.0, -2.0), box.corner(idx: 0))
        XCTAssertEqual(Vector2D(4.0, -2.0), box.corner(idx: 1))
        XCTAssertEqual(Vector2D(-2.0, 3.0), box.corner(idx: 2))
        XCTAssertEqual(Vector2D(4.0, 3.0), box.corner(idx: 3))
    }
    
    func testIsEmpty() {
        var box = BoundingBox2D(point1: Vector2D(-2.0, -2.0), point2: Vector2D(4.0, 3.0))
        XCTAssertFalse(box.isEmpty())
        
        box.lowerCorner = Vector2D(5.0, 1.0)
        XCTAssertTrue(box.isEmpty())
        
        box.lowerCorner = Vector2D(2.0, 4.0)
        XCTAssertTrue(box.isEmpty())
        
        box.lowerCorner = Vector2D(4.0, 1.0)
        XCTAssertTrue(box.isEmpty())
    }
    
}
