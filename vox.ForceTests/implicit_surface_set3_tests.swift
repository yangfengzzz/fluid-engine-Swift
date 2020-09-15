//
//  implicit_surface_set3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class implicit_surface_set3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructor() throws {
        let sset = ImplicitSurfaceSet3()
        XCTAssertEqual(0, sset.numberOfSurfaces())
        
        sset.isNormalFlipped = true
        let box = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        sset.addExplicitSurface(surface: box)
        
        let sset2 = ImplicitSurfaceSet3(other: sset)
        XCTAssertEqual(1, sset2.numberOfSurfaces())
        XCTAssertTrue(sset2.isNormalFlipped)
        
        let sset3 = ImplicitSurfaceSet3(surfaces: [box])
        XCTAssertEqual(1, sset3.numberOfSurfaces())
    }
    
    func testNumberOfSurfaces() {
        let sset = ImplicitSurfaceSet3()
        
        let box = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        sset.addExplicitSurface(surface: box)
        
        XCTAssertEqual(1, sset.numberOfSurfaces())
    }
    
    func testSurfaceAt() {
        let sset = ImplicitSurfaceSet3()
        
        let box1 = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        let box2 = Box3(boundingBox: BoundingBox3F(point1: [3, 4, 5], point2: [5, 6, 7]))
        sset.addExplicitSurface(surface: box1)
        sset.addExplicitSurface(surface: box2)
        
        let implicitSurfaceAt0 = sset.surfaceAt(i: 0) as! SurfaceToImplicit3
        let implicitSurfaceAt1 = sset.surfaceAt(i: 1) as! SurfaceToImplicit3
        
        XCTAssertTrue(box1 === implicitSurfaceAt0.surface() as AnyObject)
        XCTAssertTrue(box2 === implicitSurfaceAt1.surface() as AnyObject)
    }
    
    func testAddSurface() {
        let sset = ImplicitSurfaceSet3()
        
        let box1 = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        let box2 = Box3(boundingBox: BoundingBox3F(point1: [3, 4, 5], point2: [5, 6, 7]))
        let implicitBox = SurfaceToImplicit3(surface: box2)
        
        sset.addExplicitSurface(surface: box1)
        sset.addSurface(surface: implicitBox)
        
        XCTAssertEqual(2, sset.numberOfSurfaces())
        
        let implicitSurfaceAt0 = sset.surfaceAt(i: 0) as! SurfaceToImplicit3
        let implicitSurfaceAt1 = sset.surfaceAt(i: 1) as! SurfaceToImplicit3
        
        XCTAssertTrue(box1 === implicitSurfaceAt0.surface() as AnyObject)
        XCTAssertTrue(implicitBox === implicitSurfaceAt1)
    }
    
    func testClosestPoint() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet3()
        let emptyPoint = sset.closestPoint(otherPoint: [1.0, 2.0, 3.0])
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.x)
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.y)
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.z)
        
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxPoint = box.closestPoint(otherPoint: pt)
        let setPoint = sset.closestPoint(otherPoint: pt)
        XCTAssertEqual(boxPoint.x, setPoint.x)
        XCTAssertEqual(boxPoint.y, setPoint.y)
        XCTAssertEqual(boxPoint.z, setPoint.z)
    }
    
    func testClosestDistance() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet3()
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxDist = box.closestDistance(otherPoint: pt)
        let setDist = sset.closestDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, setDist)
    }
    
    func testIntersects() {
        let sset = ImplicitSurfaceSet3()
        let box = Box3(boundingBox: BoundingBox3F(point1: [-1, 2, 3], point2: [5, 3, 7]))
        sset.addExplicitSurface(surface: box)
        
        let result0 = sset.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0)
        
        let result1 = sset.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6), newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1)
        
        let result2 = sset.intersects(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2)
    }
    
    func testClosestIntersection() {
        let sset = ImplicitSurfaceSet3()
        let box = Box3(boundingBox: BoundingBox3F(point1: [-1, 2, 3], point2: [5, 3, 7]))
        sset.addExplicitSurface(surface: box)
        
        let result0 = sset.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 4, 5), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertTrue(result0.isIntersecting)
        XCTAssertEqual(sqrt(3), result0.distance, accuracy: 1.0e-6)
        XCTAssertEqual(Vector3F(0, 3, 4), result0.point)
        
        let result1 = sset.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 2.5, 6), newDirection: normalize(Vector3F(-1, -1, 1))))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(sqrt(0.75), result1.distance, accuracy: 1.0e-6)
        XCTAssertEqual(Vector3F(0.5, 2, 6.5), result1.point)
        
        let result2 = sset.closestIntersection(
            ray: Ray3F(newOrigin: Vector3F(1, 1, 2), newDirection: normalize(Vector3F(-1, -1, -1))))
        XCTAssertFalse(result2.isIntersecting)
    }
    
    func testBoundingBox() {
        let sset = ImplicitSurfaceSet3()
        
        let box1 = Box3(boundingBox: BoundingBox3F(point1: [0, -3, -1], point2: [1, 2, 4]))
        let box2 = Box3(boundingBox: BoundingBox3F(point1: [3, 4, 2], point2: [5, 6, 9]))
        sset.addExplicitSurface(surface: box1)
        sset.addExplicitSurface(surface: box2)
        
        let bbox = sset.boundingBox()
        XCTAssertEqual(0.0, bbox.lowerCorner.x)
        XCTAssertEqual(-3.0, bbox.lowerCorner.y)
        XCTAssertEqual(-1.0, bbox.lowerCorner.z)
        XCTAssertEqual(5.0, bbox.upperCorner.x)
        XCTAssertEqual(6.0, bbox.upperCorner.y)
        XCTAssertEqual(9.0, bbox.upperCorner.z)
    }
    
    func testSignedDistance() {
        let bbox = BoundingBox3F(point1: Vector3F(1, 4, 3), point2: Vector3F(5, 6, 9))
        
        let box = Box3(boundingBox: bbox)
        let implicitBox = SurfaceToImplicit3(surface: box)
        
        let sset = ImplicitSurfaceSet3()
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector3F(-1, 7, 8)
        let boxDist = implicitBox.signedDistance(otherPoint: pt)
        let setDist = sset.signedDistance(otherPoint: pt)
        XCTAssertEqual(boxDist, setDist)
    }
    
    func testClosestNormal() {
        let bbox = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 3))
        
        let box = Box3(boundingBox: bbox)
        box.isNormalFlipped = true
        
        let sset = ImplicitSurfaceSet3()
        _ = sset.closestNormal(otherPoint: [1.0, 2.0, 3.0])
        // No expected value -- just see if it doesn't crash
        sset.addExplicitSurface(surface: box)
        
        let pt = Vector3F(0.5, 2.5, -1.0)
        let boxNormal = box.closestNormal(otherPoint: pt)
        let setNormal = sset.closestNormal(otherPoint: pt)
        XCTAssertEqual(boxNormal.x, setNormal.x)
        XCTAssertEqual(boxNormal.y, setNormal.y)
        XCTAssertEqual(boxNormal.z, setNormal.z)
    }
    
    func testMixedBoundTypes() {
        let domain = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 1))
        
        let plane = Plane3.builder()
            .withNormal(normal: [0, 1, 0])
            .withPoint(point: [0, 0.25 * domain.height(), 0])
            .build()
        
        let sphere = Sphere3.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = ImplicitSurfaceSet3.builder()
            .withExplicitSurfaces(surfaces: [plane, sphere])
            .build()
        
        XCTAssertFalse(surfaceSet.isBounded())
        
        let cp = surfaceSet.closestPoint(otherPoint: Vector3F(0.5, 0.4, 0.5))
        let answer = Vector3F(0.5, 0.5, 0.5)
        
        XCTAssertEqual(answer.x, cp.x, accuracy: 1e-9)
        XCTAssertEqual(answer.y, cp.y, accuracy: 1e-9)
        XCTAssertEqual(answer.z, cp.z, accuracy: 1e-9)
    }
    
    func testIsValidGeometry() {
        let surfaceSet = ImplicitSurfaceSet3.builder().build()
        
        XCTAssertFalse(surfaceSet.isValidGeometry())
        
        let box = Box3(boundingBox: BoundingBox3F(point1: [0, 0, 0], point2: [1, 2, 3]))
        let surfaceSet2 = ImplicitSurfaceSet3.builder().build()
        surfaceSet2.addExplicitSurface(surface: box)
        
        XCTAssertTrue(surfaceSet2.isValidGeometry())
        
        surfaceSet2.addSurface(surface: surfaceSet)
        
        XCTAssertFalse(surfaceSet2.isValidGeometry())
    }
    
    func testIsInside() {
        let domain = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 1))
        let offset = Vector3F(1, 2, 3)
        
        let plane = Plane3.builder()
            .withNormal(normal: [0, 1, 0])
            .withPoint(point: [0, 0.25 * domain.height(), 0])
            .build()
        
        let sphere = Sphere3.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = ImplicitSurfaceSet3.builder()
            .withExplicitSurfaces(surfaces: [plane, sphere])
            .withTransform(transform: Transform3(translation: offset, orientation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)))
            .build()
        
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector3F(0.5, 0.25, 0.5) + offset))
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector3F(0.5, 1.0, 0.5) + offset))
        XCTAssertFalse(surfaceSet.isInside(otherPoint: Vector3F(0.5, 1.5, 0.5) + offset))
    }
    
    func testUpdateQueryEngine() {
        let sphere = Sphere3.builder()
            .withCenter(center: [-1.0, 1.0, 2.0])
            .withRadius(radius: 0.5)
            .build()
        
        let surfaceSet = ImplicitSurfaceSet3.builder()
            .withExplicitSurfaces(surfaces: [sphere])
            .withTransform(transform: Transform3(translation: [1.0, 2.0, -1.0], orientation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)))
            .build()
        
        let bbox1 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox3F(point1: [-0.5, 2.5, 0.5], point2: [0.5, 3.5, 1.5]).lowerCorner,
                       bbox1.lowerCorner)
        XCTAssertEqual(BoundingBox3F(point1: [-0.5, 2.5, 0.5], point2: [0.5, 3.5, 1.5]).upperCorner,
                       bbox1.upperCorner)
        
        surfaceSet.transform = Transform3(translation: [3.0, -4.0, 7.0], orientation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
        surfaceSet.updateQueryEngine()
        let bbox2 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox3F(point1: [1.5, -3.5, 8.5], point2: [2.5, -2.5, 9.5]).lowerCorner,
                       bbox2.lowerCorner)
        XCTAssertEqual(BoundingBox3F(point1: [1.5, -3.5, 8.5], point2: [2.5, -2.5, 9.5]).upperCorner,
                       bbox2.upperCorner)
        
        sphere.transform = Transform3(translation: [-6.0, 9.0, 2.0], orientation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
        surfaceSet.updateQueryEngine()
        let bbox3 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox3F(point1: [-4.5, 5.5, 10.5], point2: [-3.5, 6.5, 11.5]).lowerCorner,
                       bbox3.lowerCorner)
        XCTAssertEqual(BoundingBox3F(point1: [-4.5, 5.5, 10.5], point2: [-3.5, 6.5, 11.5]).upperCorner,
                       bbox3.upperCorner)
        
        // Plane is unbounded. Total bbox should ignore it.
        let plane = Plane3.builder()
            .withNormal(normal: [1.0, 0.0, 0.0])
            .build()
        surfaceSet.addExplicitSurface(surface: plane)
        surfaceSet.updateQueryEngine()
        let bbox4 = surfaceSet.boundingBox()
        XCTAssertEqual(BoundingBox3F(point1: [-4.5, 5.5, 10.5], point2: [-3.5, 6.5, 11.5]).lowerCorner,
                       bbox4.lowerCorner)
        XCTAssertEqual(BoundingBox3F(point1: [-4.5, 5.5, 10.5], point2: [-3.5, 6.5, 11.5]).upperCorner,
                       bbox4.upperCorner)
    }
}
