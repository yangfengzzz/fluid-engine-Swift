//
//  sphere2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sphere2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let sph1 = Sphere2()
        XCTAssertEqual(0.0, sph1.center.x)
        XCTAssertEqual(0.0, sph1.center.y)
        XCTAssertEqual(1.0, sph1.radius)
        
        let sph2 = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        XCTAssertEqual(3.0, sph2.center.x)
        XCTAssertEqual(-1.0, sph2.center.y)
        XCTAssertEqual(5.0, sph2.radius)
        
        sph2.isNormalFlipped = true
        
        let sph3 = Sphere2(other: sph2)
        XCTAssertEqual(3.0, sph3.center.x)
        XCTAssertEqual(-1.0, sph3.center.y)
        XCTAssertEqual(5.0, sph3.radius)
        XCTAssertTrue(sph3.isNormalFlipped)
    }
    
    func testClosestPoint() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        
        let result1 = sph.closestPoint(otherPoint: [10.0, -1.0])
        XCTAssertEqual(8.0, result1.x, accuracy: 1.0e-6)
        XCTAssertEqual(-1.0, result1.y)
        
        let result2 = sph.closestPoint(otherPoint: [3.0, -10.0])
        XCTAssertEqual(3.0, result2.x)
        XCTAssertEqual(-6.0, result2.y, accuracy: 1.0e-6)
        
        let result3 = sph.closestPoint(otherPoint: [3.0, 3.0])
        XCTAssertEqual(3.0, result3.x)
        XCTAssertEqual(4.0, result3.y, accuracy: 1.0e-6)
    }
    
    func testClosestDistance() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        
        let result1 = sph.closestDistance(otherPoint: [10.0, -1.0])
        XCTAssertEqual(2.0, result1)
        
        let result2 = sph.closestDistance(otherPoint: [3.0, -10.0])
        XCTAssertEqual(4.0, result2)
        
        let result3 = sph.closestDistance(otherPoint: [3.0, 3.0])
        XCTAssertEqual(1.0, result3)
    }
    
    func testIntersects() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 = sph.intersects(ray: Ray2F(newOrigin: [10.0, -1.0],
                                                newDirection: [-1.0, 0.0]))
        XCTAssertTrue(result1)
        
        let result2 = sph.intersects(ray: Ray2F(newOrigin: [3.0, -10.0],
                                                newDirection: [0.0, -1.0]))
        XCTAssertFalse(result2)
        
        let result3 = sph.intersects(ray: Ray2F(newOrigin: [3.0, 3.0],
                                                newDirection: [1.0, 0.0]))
        XCTAssertTrue(result3)
    }
    
    func testClosestIntersection() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 = sph.closestIntersection(ray: Ray2F(newOrigin: [10.0, -1.0],
                                                         newDirection: [-1.0, 0.0]))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(2.0, result1.distance, accuracy: 1.0e-6)
        XCTAssertEqual(8.0, result1.point.x)
        XCTAssertEqual(-1.0, result1.point.y)
        
        let result2 = sph.closestIntersection(ray: Ray2F(newOrigin: [3.0, -10.0],
                                                         newDirection: [0.0, -1.0]))
        XCTAssertFalse(result2.isIntersecting)
        
        let result3 = sph.closestIntersection(ray: Ray2F(newOrigin: [3.0, 3.0],
                                                         newDirection: [0.0, 1.0]))
        XCTAssertTrue(result3.isIntersecting)
        XCTAssertEqual(1.0, result3.distance, accuracy: 1.0e-6)
        XCTAssertEqual(3.0, result3.point.x)
        XCTAssertEqual(4.0, result3.point.y)
    }
    
    func testBoundingBox() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        let bbox = sph.boundingBox()
        
        XCTAssertEqual(-2.0, bbox.lowerCorner.x)
        XCTAssertEqual(-6.0, bbox.lowerCorner.y)
        XCTAssertEqual(8.0, bbox.upperCorner.x)
        XCTAssertEqual(4.0, bbox.upperCorner.y)
    }
    
    func testClosestNormal() {
        let sph = Sphere2(center: [3.0, -1.0], radiustransform: 5.0)
        sph.isNormalFlipped = true
        
        let result1 = sph.closestNormal(otherPoint: [10.0, -1.0])
        XCTAssertEqual(-1.0, result1.x, accuracy: 1.0e-6)
        XCTAssertEqual(0.0, result1.y)
        
        let result2 = sph.closestNormal(otherPoint: [3.0, -10.0])
        XCTAssertEqual(0.0, result2.x)
        XCTAssertEqual(1.0, result2.y, accuracy: 1.0e-6)
        
        let result3 = sph.closestNormal(otherPoint: [3.0, 3.0])
        XCTAssertEqual(0.0, result3.x)
        XCTAssertEqual(-1.0, result3.y, accuracy: 1.0e-6)
    }
    
    func testBuilder() {
        let sph = Sphere2.builder()
            .withCenter(center: [3.0, -1.0])
                .withRadius(radius: 5.0).build()
        XCTAssertEqual(3.0, sph.center.x)
        XCTAssertEqual(-1.0, sph.center.y)
        XCTAssertEqual(5.0, sph.radius)
    }
}
