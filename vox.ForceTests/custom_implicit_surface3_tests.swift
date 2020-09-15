//
//  custom_implicit_surface3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class custom_implicit_surface3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testSignedDistance() throws {
        let cis = CustomImplicitSurface3(function: {(pt:Vector3F)->Float in
            return length(pt - Vector3F(0.5, 0.5, 0.5)) - 0.25
        }, domain: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]), resolution: 1e-3)
        
        XCTAssertEqual(0.25, cis.signedDistance(otherPoint: [1, 0.5, 0.5]))
        XCTAssertEqual(-0.25, cis.signedDistance(otherPoint: [0.5, 0.5, 0.5]))
        XCTAssertEqual(0.0, cis.signedDistance(otherPoint: [0.5, 0.75, 0.5]))
    }
    
    func testCloseestPoint() {
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.45, 0.55])
            .withRadius(radius: 0.3)
            .build()
        let refSurf = SurfaceToImplicit3(surface: sphere)
        
        let cis1 = CustomImplicitSurface3(function: {(pt:Vector3F)->Float in
            return refSurf.signedDistance(otherPoint: pt)
        }, domain: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]), resolution: 1e-3)
        
        for i in 0..<getNumberOfSamplePoints3() {
            let sample = getSamplePoints3()[i]
            if (length(sample - sphere.center) > 0.01) {
                let refAns = refSurf.closestPoint(otherPoint: sample)
                let actAns = cis1.closestPoint(otherPoint: sample)
                
                XCTAssertEqual(refAns.x, actAns.x, accuracy: 1e-3)
                XCTAssertEqual(refAns.y, actAns.y, accuracy: 1e-3)
                XCTAssertEqual(refAns.z, actAns.z, accuracy: 1e-3)
            }
        }
    }
    
    func testCloseestNormal() {
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.45, 0.55])
            .withRadius(radius: 0.3)
            .build()
        let refSurf = SurfaceToImplicit3(surface: sphere)
        
        let cis1 = CustomImplicitSurface3(function: {(pt:Vector3F)->Float in
            return refSurf.signedDistance(otherPoint: pt)
        }, domain: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]), resolution: 1e-3)
        
        for i in 0..<getNumberOfSamplePoints3() {
            let sample = getSamplePoints3()[i]
            let refAns = refSurf.closestNormal(otherPoint: sample)
            let actAns = cis1.closestNormal(otherPoint: sample)
            
            XCTAssertEqual(refAns.x, actAns.x, accuracy: 1e-3)
            XCTAssertEqual(refAns.y, actAns.y, accuracy: 1e-3)
            XCTAssertEqual(refAns.z, actAns.z, accuracy: 1e-3)
        }
    }
    
    func testIntersects() {
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.45, 0.55])
            .withRadius(radius: 0.3)
            .build()
        let refSurf = SurfaceToImplicit3(surface: sphere)
        
        let cis1 = CustomImplicitSurface3(function: {(pt:Vector3F)->Float in
            return refSurf.signedDistance(otherPoint: pt)
        }, domain: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]), resolution: 1e-3)
        
        for i in 0..<getNumberOfSamplePoints3() {
            let x = getSamplePoints3()[i]
            let d = getSampleDirs3()[i]
            let refAns = refSurf.intersects(ray: Ray3F(newOrigin: x, newDirection: d))
            let actAns = cis1.intersects(ray: Ray3F(newOrigin: x, newDirection: d))
            XCTAssertEqual(refAns, actAns)
        }
    }
    
    func testClosestIntersection() {
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.45, 0.55])
            .withRadius(radius: 0.3)
            .build()
        let refSurf = SurfaceToImplicit3(surface: sphere)
        
        let cis1 = CustomImplicitSurface3(function: {(pt:Vector3F)->Float in
            return refSurf.signedDistance(otherPoint: pt)
        }, domain: BoundingBox3F(point1: [0, 0, 0], point2: [1, 1, 1]),
           resolution: 1e-3, rayMarchingResolution: 1e-3)
        
        for i in 0..<getNumberOfSamplePoints3() {
            let x = getSamplePoints3()[i]
            let d = getSampleDirs3()[i]
            let refAns = refSurf.closestIntersection(ray: Ray3F(newOrigin: x, newDirection: d))
            let actAns = cis1.closestIntersection(ray: Ray3F(newOrigin: x, newDirection: d))
            XCTAssertEqual(refAns.isIntersecting, actAns.isIntersecting)
            XCTAssertEqual(refAns.distance, actAns.distance, accuracy: 1e-5)
            
            XCTAssertEqual(refAns.point.x, actAns.point.x, accuracy: 1e-5)
            XCTAssertEqual(refAns.point.y, actAns.point.y, accuracy: 1e-5)
            XCTAssertEqual(refAns.point.z, actAns.point.z, accuracy: 1e-5)
            XCTAssertEqual(refAns.normal.x, actAns.normal.x, accuracy: 1e-3)
            XCTAssertEqual(refAns.normal.y, actAns.normal.y, accuracy: 1e-3)
            XCTAssertEqual(refAns.normal.z, actAns.normal.z, accuracy: 1e-3)
        }
    }
}
