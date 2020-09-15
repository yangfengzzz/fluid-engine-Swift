//
//  sphere3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sphere3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let sph1 = Sphere3()
        XCTAssertEqual(0.0, sph1.center.x)
        XCTAssertEqual(0.0, sph1.center.y)
        XCTAssertEqual(0.0, sph1.center.z)
        XCTAssertEqual(1.0, sph1.radius)
        
        let sph2 = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        XCTAssertEqual(3.0, sph2.center.x)
        XCTAssertEqual(-1.0, sph2.center.y)
        XCTAssertEqual(2.0, sph2.center.z)
        XCTAssertEqual(5.0, sph2.radius)
        
        sph2.isNormalFlipped = true
        
        let sph3 = Sphere3(other: sph2)
        XCTAssertEqual(3.0, sph3.center.x)
        XCTAssertEqual(-1.0, sph3.center.y)
        XCTAssertEqual(2.0, sph3.center.z)
        XCTAssertEqual(5.0, sph3.radius)
        XCTAssertTrue(sph3.isNormalFlipped)
    }
    
    func testClosestPoint() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        
        let result1 = sph.closestPoint(otherPoint: [10.0, -1.0, 2.0])
        XCTAssertEqual(8.0, result1.x, accuracy: 1.0e-6)
        XCTAssertEqual(-1.0, result1.y)
        XCTAssertEqual(2.0, result1.z)
        
        let result2 = sph.closestPoint(otherPoint: [3.0, -10.0, 2.0])
        XCTAssertEqual(3.0, result2.x)
        XCTAssertEqual(-6.0, result2.y, accuracy: 1.0e-6)
        XCTAssertEqual(2.0, result2.z)
        
        let result3 = sph.closestPoint(otherPoint: [3.0, 3.0, 2.0])
        XCTAssertEqual(3.0, result3.x)
        XCTAssertEqual(4.0, result3.y, accuracy: 1.0e-6)
        XCTAssertEqual(2.0, result3.z)
    }
    
    func testClosestDistance() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        
        let result1 = sph.closestDistance(otherPoint: [10.0, -1.0, 2.0])
        XCTAssertEqual(2.0, result1)
        
        let result2 = sph.closestDistance(otherPoint: [3.0, -10.0, 2.0])
        XCTAssertEqual(4.0, result2)
        
        let result3 = sph.closestDistance(otherPoint: [3.0, 3.0, 2.0])
        XCTAssertEqual(1.0, result3)
    }
    
    func testIntersects() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 = sph.intersects(ray: Ray3F(newOrigin: [10.0, -1.0, 2.0],
                                                newDirection: [-1.0, 0.0, 0.0]))
        XCTAssertTrue(result1)
        
        let result2 = sph.intersects(ray: Ray3F(newOrigin: [3.0, -10.0, 2.0],
                                                newDirection: [0.0, -1.0, 0.0]))
        XCTAssertFalse(result2)
        
        let result3 = sph.intersects(ray: Ray3F(newOrigin: [3.0, 3.0, 2.0],
                                                newDirection: [1.0, 0.0, 0.0]))
        XCTAssertTrue(result3)
    }
    
    func testClosestIntersection() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 =
            sph.closestIntersection(ray: Ray3F(newOrigin: [10.0, -1.0, 2.0],
                                               newDirection: [-1.0, 0.0, 0.0]))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(2.0, result1.distance, accuracy: 1.0e-6)
        XCTAssertEqual(8.0, result1.point.x)
        XCTAssertEqual(-1.0, result1.point.y)
        XCTAssertEqual(2.0, result1.point.z)
        XCTAssertEqual(-1.0, result1.normal.x)
        XCTAssertEqual(0.0, result1.normal.y)
        XCTAssertEqual(0.0, result1.normal.z)
        
        let result2 =
            sph.closestIntersection(ray: Ray3F(newOrigin: [3.0, -10.0, 2.0],
                                               newDirection: [0.0, -1.0, 0.0]))
        XCTAssertFalse(result2.isIntersecting)
        
        let result3 =
            sph.closestIntersection(ray: Ray3F(newOrigin: [3.0, 3.0, 2.0],
                                               newDirection: [0.0, 1.0, 0.0]))
        XCTAssertTrue(result3.isIntersecting)
        XCTAssertEqual(1.0, result3.distance, accuracy: 1.0e-6)
        XCTAssertEqual(3.0, result3.point.x)
        XCTAssertEqual(4.0, result3.point.y)
        XCTAssertEqual(2.0, result3.point.z)
        XCTAssertEqual(0.0, result3.normal.x)
        XCTAssertEqual(-1.0, result3.normal.y)
        XCTAssertEqual(0.0, result3.normal.z)
    }
    
    func testBoundingBox() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        let bbox = sph.boundingBox()
        
        XCTAssertEqual(-2.0, bbox.lowerCorner.x)
        XCTAssertEqual(-6.0, bbox.lowerCorner.y)
        XCTAssertEqual(-3.0, bbox.lowerCorner.z)
        XCTAssertEqual(8.0, bbox.upperCorner.x)
        XCTAssertEqual(4.0, bbox.upperCorner.y)
        XCTAssertEqual(7.0, bbox.upperCorner.z)
    }
    
    func testClosestNormal() {
        let sph = Sphere3(center: [3.0, -1.0, 2.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 = sph.closestNormal(otherPoint: [10.0, -1.0, 2.0])
        XCTAssertEqual(-1.0, result1.x, accuracy: 1.0e-6)
        XCTAssertEqual(0.0, result1.y)
        XCTAssertEqual(0.0, result1.z)
        
        let result2 = sph.closestNormal(otherPoint: [3.0, -10.0, 2.0])
        XCTAssertEqual(0.0, result2.x)
        XCTAssertEqual(1.0, result2.y, accuracy: 1.0e-6)
        XCTAssertEqual(0.0, result2.z)
        
        let result3 = sph.closestNormal(otherPoint: [3.0, 3.0, 2.0])
        XCTAssertEqual(0.0, result3.x)
        XCTAssertEqual(-1.0, result3.y, accuracy: 1.0e-6)
        XCTAssertEqual(0.0, result3.z)
    }
    
    func testBuilder() {
        let sph = Sphere3.builder()
            .withCenter(center: [3.0, -1.0, 2.0])
            .withRadius(radius: 5.0)
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        XCTAssertEqual(3.0, sph.center.x)
        XCTAssertEqual(-1.0, sph.center.y)
        XCTAssertEqual(2.0, sph.center.z)
        XCTAssertEqual(5.0, sph.radius)
        XCTAssertTrue(sph.isNormalFlipped)
    }
}
