//
//  cylinder3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/24.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class cylinder3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let cyl1 = Cylinder3()
        XCTAssertFalse(cyl1.isNormalFlipped)
        XCTAssertEqual(0.0, cyl1.center.x)
        XCTAssertEqual(0.0, cyl1.center.y)
        XCTAssertEqual(0.0, cyl1.center.z)
        XCTAssertEqual(1.0, cyl1.radius)
        XCTAssertEqual(1.0, cyl1.height)
        XCTAssertEqual(-1.0, cyl1.boundingBox().lowerCorner.x)
        XCTAssertEqual(-0.5, cyl1.boundingBox().lowerCorner.y)
        XCTAssertEqual(-1.0, cyl1.boundingBox().lowerCorner.z)
        XCTAssertEqual(1.0, cyl1.boundingBox().upperCorner.x)
        XCTAssertEqual(0.5, cyl1.boundingBox().upperCorner.y)
        XCTAssertEqual(1.0, cyl1.boundingBox().upperCorner.z)
        
        let cyl2 = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 5.0)
        XCTAssertFalse(cyl2.isNormalFlipped)
        XCTAssertEqual(1.0, cyl2.center.x)
        XCTAssertEqual(2.0, cyl2.center.y)
        XCTAssertEqual(3.0, cyl2.center.z)
        XCTAssertEqual(4.0, cyl2.radius)
        XCTAssertEqual(5.0, cyl2.height)
        XCTAssertEqual(-3.0, cyl2.boundingBox().lowerCorner.x)
        XCTAssertEqual(-0.5, cyl2.boundingBox().lowerCorner.y)
        XCTAssertEqual(-1.0, cyl2.boundingBox().lowerCorner.z)
        XCTAssertEqual(5.0, cyl2.boundingBox().upperCorner.x)
        XCTAssertEqual(4.5, cyl2.boundingBox().upperCorner.y)
        XCTAssertEqual(7.0, cyl2.boundingBox().upperCorner.z)
        
        cyl2.isNormalFlipped = true
        let cyl3 = Cylinder3(other: cyl2)
        XCTAssertTrue(cyl3.isNormalFlipped)
        XCTAssertEqual(1.0, cyl3.center.x)
        XCTAssertEqual(2.0, cyl3.center.y)
        XCTAssertEqual(3.0, cyl3.center.z)
        XCTAssertEqual(4.0, cyl3.radius)
        XCTAssertEqual(5.0, cyl3.height)
        XCTAssertEqual(-3.0, cyl3.boundingBox().lowerCorner.x)
        XCTAssertEqual(-0.5, cyl3.boundingBox().lowerCorner.y)
        XCTAssertEqual(-1.0, cyl3.boundingBox().lowerCorner.z)
        XCTAssertEqual(5.0, cyl3.boundingBox().upperCorner.x)
        XCTAssertEqual(4.5, cyl3.boundingBox().upperCorner.y)
        XCTAssertEqual(7.0, cyl3.boundingBox().upperCorner.z)
    }
    
    func testClosestPoint() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        
        let result1 = cyl.closestPoint(otherPoint: [7, 2, 3])
        XCTAssertEqual(5.0, result1.x)
        XCTAssertEqual(2.0, result1.y)
        XCTAssertEqual(3.0, result1.z)
        
        let result2 = cyl.closestPoint(otherPoint: [1, 6, 2])
        XCTAssertEqual(1.0, result2.x, accuracy: 1.0e-6)
        XCTAssertEqual(5.0, result2.y)
        XCTAssertEqual(2.0, result2.z)
        
        let result3 = cyl.closestPoint(otherPoint: [6, -5, 3])
        XCTAssertEqual(5.0, result3.x)
        XCTAssertEqual(-1.0, result3.y)
        XCTAssertEqual(3.0, result3.z)
    }
    
    func testClosestDistance() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        
        let result1 = cyl.closestDistance(otherPoint: [7, 2, 3])
        XCTAssertEqual(length(Vector3F(5, 2, 3) - Vector3F(7, 2, 3)), result1)
        
        let result2 = cyl.closestDistance(otherPoint: [1, 6, 2])
        XCTAssertEqual(length(Vector3F(1, 5, 2) - Vector3F(1, 6, 2)), result2)
        
        let result3 = cyl.closestDistance(otherPoint: [6, -5, 3])
        XCTAssertEqual(length(Vector3F(5, -1, 3) - Vector3F(6, -5, 3)), result3)
    }
    
    func testIntersects() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        
        // 1. Trivial case
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [7, 2, 3], newDirection: [-1, 0, 0])))
        
        // 2. Within the infinite cylinder, above the cylinder, hitting the upper cap
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [1, 6, 2], newDirection: [0, -1, 0])))
        
        // 2-1. Within the infinite cylinder, below the cylinder, hitting the lower cap
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [1, -2, 2], newDirection: [0, 1, 0])))
        
        // 2-2. Within the infinite cylinder, above the cylinder, missing the cylinder
        XCTAssertFalse(cyl.intersects(ray: Ray3F(newOrigin: [1, 6, 2], newDirection: [1, 0, 0])))
        
        // 2-3. Within the infinite cylinder, below the cylinder, missing the cylinder
        XCTAssertFalse(cyl.intersects(ray: Ray3F(newOrigin: [1, -2, 2], newDirection: [1, 0, 0])))
        
        // 3. Within the cylinder, hitting the upper cap
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [0, 1, 0])))
        
        // 3-1. Within the cylinder, hitting the lower cap
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [0, -1, 0])))
        
        // 4. Within the cylinder, hitting the infinite cylinder
        XCTAssertTrue(cyl.intersects(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [1, 0, 0])))
        
        // 5. Outside the infinite cylinder, hitting the infinite cylinder, but missing the cylinder (passing above)
        XCTAssertFalse(cyl.intersects(ray: Ray3F(newOrigin: [7, 12, 3], newDirection: [-1, 0, 0])))
        
        // 6. Outside the infinite cylinder, hitting the infinite cylinder, but missing the cylinder (passing below)
        XCTAssertFalse(cyl.intersects(ray: Ray3F(newOrigin: [7, -10, 3], newDirection: [-1, 0, 0])))
        
        // 7. Missing the infinite cylinder
        XCTAssertFalse(cyl.intersects(ray: Ray3F(newOrigin: [6, -5, 3], newDirection: [0, 0, 1])))
    }
    
    func testclosestIntersection() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        
        // 1. Trivial case
        let result1 = cyl.closestIntersection(ray: Ray3F(newOrigin: [7, 2, 3], newDirection: [-1, 0, 0]))
        XCTAssertTrue(result1.isIntersecting)
        XCTAssertEqual(2.0, result1.distance)
        
        // 2. Within the infinite cylinder, above the cylinder, hitting the upper cap
        let result2 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, 6, 2], newDirection: [0, -1, 0]))
        XCTAssertTrue(result2.isIntersecting)
        XCTAssertEqual(1.0, result2.distance, accuracy: 1.0e-6)
        
        // 2-1. Within the infinite cylinder, below the cylinder, hitting the lower cap
        let result2_1 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, -2, 2], newDirection: [0, 1, 0]))
        XCTAssertTrue(result2_1.isIntersecting)
        XCTAssertEqual(1.0, result2_1.distance, accuracy: 1.0e-6)
        
        // 2-2. Within the infinite cylinder, above the cylinder, missing the cylinder
        let result2_2 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, 6, 2], newDirection: [1, 0, 0]))
        XCTAssertFalse(result2_2.isIntersecting)
        
        // 2-3. Within the infinite cylinder, below the cylinder, missing the cylinder
        let result2_3 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, -2, 2], newDirection: [1, 0, 0]))
        XCTAssertFalse(result2_3.isIntersecting)
        
        // 3. Within the cylinder, hitting the upper cap
        let result3 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [0, 1, 0]))
        XCTAssertTrue(result3.isIntersecting)
        XCTAssertEqual(3.0, result3.distance, accuracy: 1.0e-6)
        
        // 3-1. Within the cylinder, hitting the lower cap
        let result3_1 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [0, -1, 0]))
        XCTAssertTrue(result3_1.isIntersecting)
        XCTAssertEqual(3.0, result3_1.distance, accuracy: 1.0e-6)
        
        // 4. Within the cylinder, hitting the infinite cylinder
        let result4 = cyl.closestIntersection(ray: Ray3F(newOrigin: [1, 2, 3], newDirection: [1, 0, 0]))
        XCTAssertTrue(result4.isIntersecting)
        XCTAssertEqual(4.0, result4.distance, accuracy: 1.0e-6)
        
        // 5. Outside the infinite cylinder, hitting the infinite cylinder, but missing the cylinder (passing above)
        let result5 = cyl.closestIntersection(ray: Ray3F(newOrigin: [7, 12, 3], newDirection: [-1, 0, 0]))
        XCTAssertFalse(result5.isIntersecting)
        
        // 6. Outside the infinite cylinder, hitting the infinite cylinder, but missing the cylinder (passing below)
        let result6 = cyl.closestIntersection(ray: Ray3F(newOrigin: [7, -10, 3], newDirection: [-1, 0, 0]))
        XCTAssertFalse(result6.isIntersecting)
        
        // 7. Missing the infinite cylinder
        let result4_ = cyl.closestIntersection(ray: Ray3F(newOrigin: [6, -5, 3], newDirection: [0, 0, 1]))
        XCTAssertFalse(result4_.isIntersecting)
    }
    
    func testBoundingBox() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        let bbox  = cyl.boundingBox()
        XCTAssertEqual(-3.0, bbox.lowerCorner.x)
        XCTAssertEqual(-1.0, bbox.lowerCorner.y)
        XCTAssertEqual(-1.0, bbox.lowerCorner.z)
        XCTAssertEqual(5.0, bbox.upperCorner.x)
        XCTAssertEqual(5.0, bbox.upperCorner.y)
        XCTAssertEqual(7.0, bbox.upperCorner.z)
    }
    
    func testClosestNormal() {
        let cyl = Cylinder3(center: Vector3F(1, 2, 3), radius: 4.0, height: 6.0)
        cyl.isNormalFlipped = true
        
        let result1 = cyl.closestNormal(otherPoint: [7, 2, 3])
        XCTAssertEqual(-1.0, result1.x, accuracy: 1.0e-6)
        XCTAssertEqual(0.0, result1.y)
        XCTAssertEqual(0.0, result1.z)
        
        let result2 = cyl.closestNormal(otherPoint: [1, 6, 2])
        XCTAssertEqual(0.0, result2.x)
        XCTAssertEqual(-1.0, result2.y)
        XCTAssertEqual(0.0, result2.z)
        
        let result3 = cyl.closestNormal(otherPoint: [6, -1.5, 3])
        XCTAssertEqual(-1.0, result3.x)
        XCTAssertEqual(0.0, result3.y)
        XCTAssertEqual(0.0, result3.z)
        
        let result4 = cyl.closestNormal(otherPoint: [3, 0, 3])
        XCTAssertEqual(0.0, result4.x)
        XCTAssertEqual(1.0, result4.y)
        XCTAssertEqual(0.0, result4.z)
    }
    
    func testBuilder() {
        let cyl2 = Cylinder3.builder()
            .withCenter(center: [1, 2, 3])
            .withRadius(radius: 4.0)
            .withHeight(height: 5.0)
            .build()
        
        XCTAssertFalse(cyl2.isNormalFlipped)
        XCTAssertEqual(1.0, cyl2.center.x)
        XCTAssertEqual(2.0, cyl2.center.y)
        XCTAssertEqual(3.0, cyl2.center.z)
        XCTAssertEqual(4.0, cyl2.radius)
        XCTAssertEqual(5.0, cyl2.height)
        XCTAssertEqual(-3.0, cyl2.boundingBox().lowerCorner.x)
        XCTAssertEqual(-0.5, cyl2.boundingBox().lowerCorner.y)
        XCTAssertEqual(-1.0, cyl2.boundingBox().lowerCorner.z)
        XCTAssertEqual(5.0, cyl2.boundingBox().upperCorner.x)
        XCTAssertEqual(4.5, cyl2.boundingBox().upperCorner.y)
        XCTAssertEqual(7.0, cyl2.boundingBox().upperCorner.z)
    }
}
