//
//  surface_to_implicit3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/24.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class surface_to_implicit3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructor() throws {
        let box = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        
        let s2i = SurfaceToImplicit3(surface: box)
        XCTAssertTrue(box === s2i.surface() as AnyObject)
        
        s2i.isNormalFlipped = true
        let s2i2 = SurfaceToImplicit3(other: s2i)
        XCTAssertTrue(box === s2i2.surface() as AnyObject)
        XCTAssertTrue(s2i2.isNormalFlipped)
    }
    
    func testClosestPoint() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        
        let s2i = SurfaceToImplicit3(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxPoint = box.closestPoint(otherPoint: pt)
        let s2iPoint = s2i.closestPoint(otherPoint: pt)
        XCTAssertEqual(boxPoint.x, s2iPoint.x)
        XCTAssertEqual(boxPoint.y, s2iPoint.y)
        XCTAssertEqual(boxPoint.z, s2iPoint.z)
    }
    
    func testClosestDistance() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        
        let s2i = SurfaceToImplicit3(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxDist = box.closestDistance(otherPoint: pt)
        let s2iDist = s2i.closestDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, s2iDist)
    }
    
    func testIntersects() {
        let box = Box3(boundingBox: BoundingBox3F(point1: [-1, 2, 3], point2: [5, 3, 7]))
        let s2i = SurfaceToImplicit3(surface: box)
        
        let result0 = s2i.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = s2i.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6), newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1)
        
        let result2 = s2i.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let box = Box3(boundingBox: BoundingBox3F(point1: [-1, 2, 3], point2: [5, 3, 7]))
        let s2i = SurfaceToImplicit3(surface: box)
        
        let result0 = s2i.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(3), result0.distance, accuracy: 1.0e-6)
        XCTAssertEqual(Vector3F(0, 3, 4), result0.point)
        
        let result1 = s2i.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6), newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.75), result1.distance, accuracy: 1.0e-6)
        XCTAssertEqual(Vector3F(0.5, 2, 6.5), result1.point)
        
        let result2 = s2i.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let box = Box3(boundingBox: BoundingBox3F(point1: [0, -3, -1], point2: [1, 2, 4]))
        let s2i = SurfaceToImplicit3(surface: box)
        
        let bbox = s2i.boundingBox()
        XCTAssertEqual(0.0, bbox.lowerCorner.x)
        XCTAssertEqual(-3.0, bbox.lowerCorner.y)
        XCTAssertEqual(-1.0, bbox.lowerCorner.z)
        XCTAssertEqual(1.0, bbox.upperCorner.x)
        XCTAssertEqual(2.0, bbox.upperCorner.y)
        XCTAssertEqual(4.0, bbox.upperCorner.z)
    }
    
    func testSignedDistance() {
        let bbox = BoundingBox3F(point1: Vector3F(1, 4, 3), point2: Vector3F(5, 6, 9))
        
        let box = Box3(boundingBox: bbox)
        let s2i = SurfaceToImplicit3(surface: box)
        
        let pt = Vector3F(-1, 7, 8)
        let boxDist = box.closestDistance(otherPoint: pt)
        var s2iDist = s2i.signedDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, s2iDist)
        
        s2i.isNormalFlipped = true
        s2iDist = s2i.signedDistance(otherPoint: pt)
        XCTAssertEqual(-boxDist, s2iDist)
    }
    
    func testClosestNormal() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let s2i = SurfaceToImplicit3(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxNormal = box.closestNormal(otherPoint: pt)
        let s2iNormal = s2i.closestNormal(otherPoint: pt)
        XCTAssertEqual(boxNormal.x, s2iNormal.x)
        XCTAssertEqual(boxNormal.y, s2iNormal.y)
        XCTAssertEqual(boxNormal.z, s2iNormal.z)
    }
    
    func testIsBounded() {
        let plane = Plane3.builder()
            .withPoint(point: [0, 0, 0])
            .withNormal(normal: [0, 1, 0])
            .build()
        let s2i = SurfaceToImplicit3.builder()
            .withSurface(surface: plane)
            .build()
        XCTAssertFalse(s2i.isBounded())
    }
    
    func testIsValidGeometry() {
        let sset = SurfaceSet3.builder().build()
        let s2i = SurfaceToImplicit3.builder()
            .withSurface(surface: sset)
            .build()
        XCTAssertFalse(s2i.isValidGeometry())
    }
    
    func testIsInside() {
        let plane = Plane3.builder()
            .withPoint(point: [0, 0, 0])
            .withNormal(normal: [0, 1, 0])
            .withTranslation(translation: [0, -1, 0])
            .build()
        let s2i = SurfaceToImplicit3.builder()
            .withSurface(surface: plane)
            .build()
        XCTAssertFalse(s2i.isInside(otherPoint: [0, -0.5, 0]))
        XCTAssertTrue(s2i.isInside(otherPoint: [0, -1.5, 0]))
    }
}
