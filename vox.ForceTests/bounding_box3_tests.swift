//
//  bounding_box3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class bounding_box3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        var box = BoundingBox3D()
        
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.x)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.y)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.z)
        
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.x)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.y)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.z)
        
        box = BoundingBox3D(point1: Vector3D(-2.0, 3.0, 5.0), point2: Vector3D(4.0, -2.0, 1.0))
        
        XCTAssertEqual(-2.0, box.lowerCorner.x)
        XCTAssertEqual(-2.0, box.lowerCorner.y)
        XCTAssertEqual(1.0, box.lowerCorner.z)
        
        XCTAssertEqual(4.0, box.upperCorner.x)
        XCTAssertEqual(3.0, box.upperCorner.y)
        XCTAssertEqual(5.0, box.upperCorner.z)
        
        box = BoundingBox3D(point1: Vector3D(-2.0, 3.0, 5.0), point2: Vector3D(4.0, -2.0, 1.0))
        let box2 = BoundingBox3D(other: box)
        
        XCTAssertEqual(-2.0, box2.lowerCorner.x)
        XCTAssertEqual(-2.0, box2.lowerCorner.y)
        XCTAssertEqual(1.0, box2.lowerCorner.z)
        
        XCTAssertEqual(4.0, box2.upperCorner.x)
        XCTAssertEqual(3.0, box2.upperCorner.y)
        XCTAssertEqual(5.0, box2.upperCorner.z)
    }
    
    func testBasicGetters() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, 3.0, 5.0), point2: Vector3D(4.0, -2.0, 1.0))
        
        XCTAssertEqual(6.0, box.width())
        XCTAssertEqual(5.0, box.height())
        XCTAssertEqual(4.0, box.depth())
        XCTAssertEqual(6.0, box.length(axis: 0))
        XCTAssertEqual(5.0, box.length(axis: 1))
        XCTAssertEqual(4.0, box.length(axis: 2))
    }
    
    func testOverlaps() {
        // x-axis is not overlapping
        var box1 = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        var box2 = BoundingBox3D(point1: Vector3D(5.0, 1.0, 3.0), point2: Vector3D(8.0, 2.0, 4.0))
        XCTAssertFalse(box1.overlaps(other: box2))
        
        // y-axis is not overlapping
        box1 = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        box2 = BoundingBox3D(point1: Vector3D(3.0, 4.0, 3.0), point2: Vector3D(8.0, 6.0, 4.0))
        XCTAssertFalse(box1.overlaps(other: box2))
        
        // z-axis is not overlapping
        box1 = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        box2 = BoundingBox3D(point1: Vector3D(3.0, 1.0, 6.0), point2: Vector3D(8.0, 2.0, 9.0))
        XCTAssertFalse(box1.overlaps(other: box2))
        
        // overlapping
        box1 = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        box2 = BoundingBox3D(point1: Vector3D(3.0, 1.0, 3.0), point2: Vector3D(8.0, 2.0, 7.0))
        XCTAssertTrue(box1.overlaps(other: box2))
    }
    
    func testContains() {
        // Not containing (x-axis is out)
        var box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        var point = Vector3D(-3.0, 0.0, 4.0)
        XCTAssertFalse(box.contains(point: point))
        
        // Not containing (y-axis is out)
        box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        point = Vector3D(2.0, 3.5, 4.0)
        XCTAssertFalse(box.contains(point: point))
        
        // Not containing (z-axis is out)
        box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        point = Vector3D(2.0, 0.0, 0.0)
        XCTAssertFalse(box.contains(point: point))
        
        // Containing
        box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        point = Vector3D(2.0, 0.0, 4.0)
        XCTAssertTrue(box.contains(point: point))
    }
    
    func testIntersects() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        
        let ray1 = Ray3D(newOrigin: Vector3D(-3, 0, 2), newDirection: normalize(Vector3D(2, 1, 1)))
        XCTAssertTrue(box.intersects(ray: ray1))
        
        let ray2 = Ray3D(newOrigin: Vector3D(3, -1, 3), newDirection: normalize(Vector3D(-1, 2, -3)))
        XCTAssertTrue(box.intersects(ray: ray2))
        
        let ray3 = Ray3D(newOrigin: Vector3D(1, -5, 1), newDirection: normalize(Vector3D(2, 1, 2)))
        XCTAssertFalse(box.intersects(ray: ray3))
    }
    
    func testClosestIntersection() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, -1.0), point2: Vector3D(1.0, 0.0, 1.0))
        
        let ray1 = Ray3D(newOrigin: Vector3D(-4, -3, 0), newDirection: normalize(Vector3D(1, 1, 0)))
        let intersection1 = box.closestIntersection(ray: ray1)
        XCTAssertTrue(intersection1.isIntersecting)
        XCTAssertEqual(length(Vector3D(2, 2, 0)), intersection1.tNear, accuracy:1.0e-15)
        XCTAssertEqual(length(Vector3D(3, 3, 0)), intersection1.tFar)
        
        let ray2 = Ray3D(newOrigin: Vector3D(0, -1, 0), newDirection: normalize(Vector3D(-2, 1, 1)))
        let intersection2 = box.closestIntersection(ray: ray2)
        XCTAssertTrue(intersection2.isIntersecting)
        XCTAssertEqual(length(Vector3D(2, 1, 1)), intersection2.tNear)
    }
    
    func testMidPoint() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        let midPoint = box.midPoint()
        
        XCTAssertEqual(1.0, midPoint.x)
        XCTAssertEqual(0.5, midPoint.y)
        XCTAssertEqual(3.0, midPoint.z)
    }
    
    func testDiagonalLength() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        XCTAssertEqual(sqrt(6.0 * 6.0 + 5.0 * 5.0 + 4.0 * 4.0),
                       box.diagonalLength())
    }
    
    func testDiagonalLengthSquared() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        XCTAssertEqual(6.0 * 6.0 + 5.0 * 5.0 + 4.0 * 4.0,
                       box.diagonalLengthSquared())
    }
    
    func testReset() {
        var box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        box.reset()
        
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.x)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.y)
        XCTAssertEqual(Double.greatestFiniteMagnitude, box.lowerCorner.z)
        
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.x)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.y)
        XCTAssertEqual(-Double.greatestFiniteMagnitude, box.upperCorner.z)
    }
    
    func testMerge() {
        // Merge with point
        var box =  BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        let point = Vector3D(5.0, 1.0, -1.0)
        
        box.merge(point: point)
        
        XCTAssertEqual(-2.0, box.lowerCorner.x)
        XCTAssertEqual(-2.0, box.lowerCorner.y)
        XCTAssertEqual(-1.0, box.lowerCorner.z)
        
        XCTAssertEqual(5.0, box.upperCorner.x)
        XCTAssertEqual(3.0, box.upperCorner.y)
        XCTAssertEqual(5.0, box.upperCorner.z)
        
        // Merge with other box
        var box1 = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        let box2 = BoundingBox3D(point1: Vector3D(3.0, 1.0, 3.0), point2: Vector3D(8.0, 2.0, 7.0))
        
        box1.merge(other: box2)
        
        XCTAssertEqual(-2.0, box1.lowerCorner.x)
        XCTAssertEqual(-2.0, box1.lowerCorner.y)
        XCTAssertEqual(1.0, box1.lowerCorner.z)
        
        XCTAssertEqual(8.0, box1.upperCorner.x)
        XCTAssertEqual(3.0, box1.upperCorner.y)
        XCTAssertEqual(7.0, box1.upperCorner.z)
    }
    
    func testExpand() {
        var box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        box.expand(delta: 3.0)
        
        XCTAssertEqual(-5.0, box.lowerCorner.x)
        XCTAssertEqual(-5.0, box.lowerCorner.y)
        XCTAssertEqual(-2.0, box.lowerCorner.z)
        
        XCTAssertEqual(7.0, box.upperCorner.x)
        XCTAssertEqual(6.0, box.upperCorner.y)
        XCTAssertEqual(8.0, box.upperCorner.z)
    }
    
    func testCorner() {
        let box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        
        XCTAssertEqual(Vector3D(-2.0, -2.0, 1.0), box.corner(idx: 0))
        XCTAssertEqual(Vector3D(4.0, -2.0, 1.0), box.corner(idx: 1))
        XCTAssertEqual(Vector3D(-2.0, 3.0, 1.0), box.corner(idx: 2))
        XCTAssertEqual(Vector3D(4.0, 3.0, 1.0), box.corner(idx: 3))
        XCTAssertEqual(Vector3D(-2.0, -2.0, 5.0), box.corner(idx: 4))
        XCTAssertEqual(Vector3D(4.0, -2.0, 5.0), box.corner(idx: 5))
        XCTAssertEqual(Vector3D(-2.0, 3.0, 5.0), box.corner(idx: 6))
        XCTAssertEqual(Vector3D(4.0, 3.0, 5.0), box.corner(idx: 7))
    }
    
    func testIsEmpty() {
        var box = BoundingBox3D(point1: Vector3D(-2.0, -2.0, 1.0), point2: Vector3D(4.0, 3.0, 5.0))
        XCTAssertFalse(box.isEmpty())
        
        box.lowerCorner = Vector3D(5.0, 1.0, 3.0)
        XCTAssertTrue(box.isEmpty())
        
        box.lowerCorner = Vector3D(2.0, 4.0, 3.0)
        XCTAssertTrue(box.isEmpty())
        
        box.lowerCorner = Vector3D(2.0, 1.0, 6.0)
        XCTAssertTrue(box.isEmpty())
        
        box.lowerCorner = Vector3D(4.0, 1.0, 3.0)
        XCTAssertTrue(box.isEmpty())
    }
    
}
