//
//  implicit_surface_set2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class implicit_surface_set2_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructor() throws {
        let sset = ImplicitSurfaceSet2()
        XCTAssertEqual(0, sset.numberOfSurfaces())
        
        sset.isNormalFlipped = true
        let box = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        sset.addExplicitSurface(surface: box)
        
        let sset2 = ImplicitSurfaceSet2(other: sset)
        XCTAssertEqual(1, sset2.numberOfSurfaces())
        XCTAssertTrue(sset2.isNormalFlipped)
        
        let sset3 = ImplicitSurfaceSet2(surfaces: [box])
        XCTAssertEqual(1, sset3.numberOfSurfaces())
    }
    
    func testNumberOfSurfaces() {
        let sset = ImplicitSurfaceSet2()
        
        let box = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        sset.addExplicitSurface(surface: box)
        
        XCTAssertEqual(1, sset.numberOfSurfaces())
    }
    
    func testSurfaceAt() {
        let sset = ImplicitSurfaceSet2()
        
        let box1 = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        let box2 = Box2(boundingBox: BoundingBox2F(point1: [3, 4], point2: [5, 6]))
        sset.addExplicitSurface(surface: box1)
        sset.addExplicitSurface(surface: box2)
        
        let implicitSurfaceAt0 = sset.surfaceAt(i: 0) as! SurfaceToImplicit2
        let implicitSurfaceAt1 = sset.surfaceAt(i: 1) as! SurfaceToImplicit2
        
        XCTAssertTrue(box1 === implicitSurfaceAt0.surface() as AnyObject)
        XCTAssertTrue(box2 === implicitSurfaceAt1.surface() as AnyObject)
    }
    
    func testAddSurface() {
        let sset = ImplicitSurfaceSet2()
        
        let box1 = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        let box2 = Box2(boundingBox: BoundingBox2F(point1: [3, 4], point2: [5, 6]))
        let implicitBox = SurfaceToImplicit2(surface: box2)
        
        sset.addExplicitSurface(surface: box1)
        sset.addSurface(surface: implicitBox)
        
        XCTAssertEqual(2, sset.numberOfSurfaces())
        
        let implicitSurfaceAt0 = sset.surfaceAt(i: 0) as! SurfaceToImplicit2
        let implicitSurfaceAt1 = sset.surfaceAt(i: 1) as! SurfaceToImplicit2
        
        XCTAssertTrue(box1 === implicitSurfaceAt0.surface() as AnyObject)
        XCTAssertTrue(implicitBox === implicitSurfaceAt1)
    }
    
    func testClosestPoint() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet2()
        let emptyPoint = sset.closestPoint(otherPoint: [1.0, 2.0])
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.x)
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.y)
        
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxPoint = box.closestPoint(otherPoint: pt)
        let setPoint = sset.closestPoint(otherPoint: pt)
        XCTAssertEqual(boxPoint.x, setPoint.x)
        XCTAssertEqual(boxPoint.y, setPoint.y)
    }
    
    func testClosestDistance() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet2()
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxDist = box.closestDistance(otherPoint: pt)
        let setDist = sset.closestDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, setDist)
    }
    
    func testIntersects() {
        let sset = ImplicitSurfaceSet2()
        let box = Box2(boundingBox: BoundingBox2F(point1: [-1, 2], point2: [5, 3]))
        sset.addExplicitSurface(surface: box)
        
        let result0 = sset.intersects(ray: Ray2F(newOrigin: Vector2F(1, 4),
                                                 newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = sset.intersects(ray: Ray2F(newOrigin: Vector2F(1, 2.5),
                                                 newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1)
        
        let result2 = sset.intersects(ray: Ray2F(newOrigin: Vector2F(1, 1),
                                                 newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let sset = ImplicitSurfaceSet2()
        let box = Box2(boundingBox: BoundingBox2F(point1: [-1, 2], point2: [5, 3]))
        sset.addExplicitSurface(surface: box)
        
        let result0 = sset.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 4), newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(2), result0.distance)
        XCTAssertEqual(Vector2F(5.9604645e-08, 3), result0.point)
        
        let result1 = sset.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 2.5), newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.5), result1.distance)
        XCTAssertEqual(Vector2F(0.5, 2), result1.point)
        
        let result2 = sset.closestIntersection(
            ray: Ray2F(newOrigin: Vector2F(1, 1), newDirection: normalize(Vector2F(-1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let sset = ImplicitSurfaceSet2()
        
        let box1 = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        let box2 = Box2(boundingBox: BoundingBox2F(point1: [3, 4], point2: [5, 6]))
        sset.addExplicitSurface(surface: box1)
        sset.addExplicitSurface(surface: box2)
        
        let bbox = sset.boundingBox()
        XCTAssertEqual(0.0, bbox.lowerCorner.x)
        XCTAssertEqual(0.0, bbox.lowerCorner.y)
        XCTAssertEqual(5.0, bbox.upperCorner.x)
        XCTAssertEqual(6.0, bbox.upperCorner.y)
    }
    
    func testSignedDistance() {
        let bbox = BoundingBox2F(point1: Vector2F(1, 4), point2: Vector2F(5, 6))
        
        let box = Box2(boundingBox: bbox)
        let implicitBox = SurfaceToImplicit2(surface: box)
        
        let sset = ImplicitSurfaceSet2()
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector2F(-1, 7)
        let boxDist = implicitBox.signedDistance(otherPoint: pt)
        let setDist = sset.signedDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, setDist)
    }
    
    func testClosestNormal() {
        let bbox = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let box = Box2(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet2()
        _ = sset.closestNormal(otherPoint: [1.0, 2.0])
        // No expected value -- just see if it doesn't crash
        
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector2F(0.5, 2.5)
        let boxNormal = box.closestNormal(otherPoint: pt)
        let setNormal = sset.closestNormal(otherPoint: pt)
        XCTAssertEqual(boxNormal.x, setNormal.x)
        XCTAssertEqual(boxNormal.y, setNormal.y)
    }
    
    func testMixedBoundTypes() {
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0.0, 0.25 * domain.height()])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = ImplicitSurfaceSet2.builder()
            .withExplicitSurfaces(surfaces: [plane, sphere])
            .build()
        
        XCTAssertFalse(surfaceSet.isBounded())
        
        let cp = surfaceSet.closestPoint(otherPoint: Vector2F(0.5, 0.4))
        let answer = Vector2F(0.5, 0.5)
        
        XCTAssertEqual(answer.x, cp.x, accuracy: 1e-9)
        XCTAssertEqual(answer.y, cp.y, accuracy: 1e-9)
    }
    
    func testIsValidGeometry() {
        let surfaceSet = ImplicitSurfaceSet2.builder().build()
        
        XCTAssertFalse(surfaceSet.isValidGeometry())
        
        let box = Box2(boundingBox: BoundingBox2F(point1: [0, 0], point2: [1, 2]))
        let surfaceSet2 = ImplicitSurfaceSet2.builder().build()
        surfaceSet2.addExplicitSurface(surface: box)
        
        XCTAssertTrue(surfaceSet2.isValidGeometry())
        
        surfaceSet2.addSurface(surface: surfaceSet)
        
        XCTAssertFalse(surfaceSet2.isValidGeometry())
    }
    
    func testIsInside() {
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        let offset = Vector2F(1, 2)
        
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0, 0.25 * domain.height()])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = ImplicitSurfaceSet2.builder()
            .withExplicitSurfaces(surfaces: [plane, sphere])
            .withTransform(transform: Transform2(translation: offset, orientation: 0.0))
            .build()
        
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector2F(0.5, 0.25) + offset))
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector2F(0.5, 1.0) + offset))
        XCTAssertFalse(surfaceSet.isInside(otherPoint: Vector2F(0.5, 1.5) + offset))
    }
    
    func testUpdateQueryEngine() {
        let sphere = Sphere2.builder()
            .withCenter(center: [-1.0, 1.0])
            .withRadius(radius: 0.5)
            .build()
        
        let surfaceSet = ImplicitSurfaceSet2.builder()
            .withExplicitSurfaces(surfaces: [sphere])
            .withTransform(transform: Transform2(translation: [1.0, 2.0], orientation: 0.0))
            .build()
        
        let bbox1 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox2F(point1: [-0.5, 2.5], point2: [0.5, 3.5]).lowerCorner, bbox1.lowerCorner)
        XCTAssertEqual(BoundingBox2F(point1: [-0.5, 2.5], point2: [0.5, 3.5]).upperCorner, bbox1.upperCorner)
        
        surfaceSet.transform = Transform2(translation: [3.0, -4.0], orientation: 0.0)
        surfaceSet.updateQueryEngine()
        let bbox2 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox2F(point1: [1.5, -3.5], point2: [2.5, -2.5]).lowerCorner, bbox2.lowerCorner)
        XCTAssertEqual(BoundingBox2F(point1: [1.5, -3.5], point2: [2.5, -2.5]).upperCorner, bbox2.upperCorner)
        
        sphere.transform = Transform2(translation: [-6.0, 9.0], orientation: 0.0)
        surfaceSet.updateQueryEngine()
        let bbox3 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox2F(point1: [-4.5, 5.5], point2: [-3.5, 6.5]).lowerCorner, bbox3.lowerCorner)
        XCTAssertEqual(BoundingBox2F(point1: [-4.5, 5.5], point2: [-3.5, 6.5]).upperCorner, bbox3.upperCorner)
        
        // Plane is unbounded. Total bbox should ignore it.
        let plane = Plane2.builder()
            .withNormal(normal: [1.0, 0.0])
            .build()
        surfaceSet.addExplicitSurface(surface: plane)
        surfaceSet.updateQueryEngine()
        let bbox4 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox2F(point1: [-4.5, 5.5], point2: [-3.5, 6.5]).lowerCorner, bbox4.lowerCorner)
        XCTAssertEqual(BoundingBox2F(point1: [-4.5, 5.5], point2: [-3.5, 6.5]).upperCorner, bbox4.upperCorner)
    }
}
