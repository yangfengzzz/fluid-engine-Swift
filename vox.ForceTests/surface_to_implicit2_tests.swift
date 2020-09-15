//
//  surface_to_implicit2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class surface_to_implicit2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let box = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        
        let s2i = SurfaceToImplicit2(surface: box)
        XCTAssertTrue(box === s2i.surface() as AnyObject)
        
        s2i.isNormalFlipped = true
        let s2i2 = SurfaceToImplicit2(other: s2i)
        XCTAssertTrue(box === s2i2.surface() as AnyObject)
        XCTAssertTrue(s2i2.isNormalFlipped)
    }
    
    func testClosestPoint() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        
        let s2i = SurfaceToImplicit2(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxPoint = box.closestPoint(otherPoint: pt)
        let s2iPoint = s2i.closestPoint(otherPoint: pt)
        XCTAssertEqual(boxPoint.x, s2iPoint.x)
        XCTAssertEqual(boxPoint.y, s2iPoint.y)
    }
    
    func testClosestDistance() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        
        let s2i = SurfaceToImplicit2(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxDist = box.closestDistance(otherPoint: pt)
        let s2iDist = s2i.closestDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, s2iDist)
    }
    
    func testIntersects() {
        let box = Box2(boundingBox: BoundingBox2F(point1: [-1, 2], point2: [5, 3]))
        let s2i = SurfaceToImplicit2(surface: box)
        
        let result0 = s2i.intersects(ray: Ray2F(newOrigin: Vector2F(1, 4),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = s2i.intersects(ray: Ray2F(newOrigin: Vector2F(1, 2.5),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1)
        
        let result2 = s2i.intersects(ray: Ray2F(newOrigin: Vector2F(1, 1),
                                                newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let box = Box2(boundingBox: BoundingBox2F(point1: [-1, 2], point2: [5, 3]))
        let s2i = SurfaceToImplicit2(surface: box)
        
        let result0 = s2i.closestIntersection(ray: Ray2F(newOrigin: Vector2F(1, 4),
                                                         newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(2), result0.distance)
        XCTAssertEqual(Vector2F(5.9604645e-08, 3), result0.point)
        
        let result1 = s2i.closestIntersection(ray: Ray2F(newOrigin: Vector2F(1, 2.5),
                                                         newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.5), result1.distance)
        XCTAssertEqual(Vector2F(0.5, 2), result1.point)
        
        let result2 = s2i.closestIntersection(ray: Ray2F(newOrigin: Vector2F(1, 1),
                                                         newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let box = Box2(boundingBox: BoundingBox2F(point1: [-1, 2], point2: [5, 3]))
        let s2i = SurfaceToImplicit2(surface: box)
        
        let bbox = s2i.boundingBox()
        XCTAssertEqual(-1.0, bbox.lowerCorner.x)
        XCTAssertEqual(2.0, bbox.lowerCorner.y)
        XCTAssertEqual(5.0, bbox.upperCorner.x)
        XCTAssertEqual(3.0, bbox.upperCorner.y)
    }
    
    func testSignedDistance() {
        let bbox = BoundingBox2F(point1: Vector2F(1, 4), point2: Vector2F(5, 6))
        
        let box = Box2(boundingBox: bbox)
        let s2i = SurfaceToImplicit2(surface: box)
        
        let pt = Vector2F(-1, 7)
        let boxDist = box.closestDistance(otherPoint: pt)
        var s2iDist = s2i.signedDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, s2iDist)
        
        s2i.isNormalFlipped = true
        s2iDist = s2i.signedDistance(otherPoint: pt)
        XCTAssertEqual(-boxDist, s2iDist)
    }
    
    func testClosestNormal() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let s2i = SurfaceToImplicit2(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxNormal = box.closestNormal(otherPoint: pt)
        let s2iNormal = s2i.closestNormal(otherPoint: pt)
        XCTAssertEqual(boxNormal.x, s2iNormal.x)
        XCTAssertEqual(boxNormal.y, s2iNormal.y)
    }
    
    func testIsBounded() {
        let plane = Plane2.builder()
            .withPoint(point: [0, 0])
            .withNormal(normal: [0, 1])
            .build()
        let s2i = SurfaceToImplicit2.builder()
            .withSurface(surface: plane)
            .build()
        XCTAssertFalse(s2i.isBounded())
    }
    
    func testIsValidGeometry() {
        let sset = SurfaceSet2.builder().build()
        let s2i = SurfaceToImplicit2.builder()
            .withSurface(surface: sset)
            .build()
        XCTAssertFalse(s2i.isValidGeometry())
    }
    
    func testIsInside() {
        let plane = Plane2.builder()
            .withPoint(point: [0, 0])
            .withNormal(normal: [0, 1])
            .withTranslation(translation: [0, -1])
            .build()
        let s2i = SurfaceToImplicit2.builder()
            .withSurface(surface: plane)
            .build()
        XCTAssertFalse(s2i.isInside(otherPoint: [0, -0.5]))
        XCTAssertTrue(s2i.isInside(otherPoint: [0, -1.5]))
    }
}
