//
//  vector3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vector3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let vec = Vector3F()
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(0.0, vec.y)
        XCTAssertEqual(0.0, vec.z)
        
        let vec2 = Vector3F(5.0, 3.0, 8.0)
        XCTAssertEqual(5.0, vec2.x)
        XCTAssertEqual(3.0, vec2.y)
        XCTAssertEqual(8.0, vec2.z)
        
        let vec3 = Vector2F(4.0, 7.0)
        let vec4 = Vector3F(vec3, 9.0)
        XCTAssertEqual(4.0, vec4.x)
        XCTAssertEqual(7.0, vec4.y)
        XCTAssertEqual(9.0, vec4.z)
        
        let vec5 = Vector3F(7.0, 6.0, 1.0)
        XCTAssertEqual(7.0, vec5.x)
        XCTAssertEqual(6.0, vec5.y)
        XCTAssertEqual(1.0, vec5.z)
        
        let vec6 = Vector3F(vec5)
        XCTAssertEqual(7.0, vec6.x)
        XCTAssertEqual(6.0, vec6.y)
        XCTAssertEqual(1.0, vec6.z)
    }
    
    func testSetMethods() {
        var vec = Vector3F()
        vec.replace(with: Vector3F(4.0, 2.0, 8.0), where: [true, true, true])
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(2.0, vec.y)
        XCTAssertEqual(8.0, vec.z)
        
        vec.replace(with: Vector3F(Vector2F(1.0, 3.0), 10.0), where: [true, true, true])
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(10.0, vec.z)
        
        let lst:[Float] = [0.0, 5.0, 6.0]
        vec.replace(with: Vector3F(lst), where: [true, true, true])
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(5.0, vec.y)
        XCTAssertEqual(6.0, vec.z)
        
        vec.replace(with: Vector3F(9.0, 8.0, 2.0), where: [true, true, true])
        XCTAssertEqual(9.0, vec.x)
        XCTAssertEqual(8.0, vec.y)
        XCTAssertEqual(2.0, vec.z)
    }
    
    func testBasicSetterMethods() {
        var vec = Vector3F(3.0, 9.0, 4.0)
        vec = Vector3F.zero
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(0.0, vec.y)
        XCTAssertEqual(0.0, vec.z)
        
        vec.replace(with: Vector3F(4.0, 2.0, 8.0), where: [true, true, true])
        vec.normalized()
        let len = vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
        XCTAssertTrue(fabsf(len - 1.0) < 1e-6)
    }
    
    func testBinaryOperatorMethods() {
        var vec = Vector3F(3.0, 9.0, 4.0)
        vec = vec + 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(13.0, vec.y)
        XCTAssertEqual(8.0, vec.z)
        
        vec = vec + Vector3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(14.0, vec.y)
        XCTAssertEqual(13.0, vec.z)
        
        vec = vec - 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
        
        vec = vec - Vector3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec = vec * 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(-14.0, vec.z)
        
        vec = vec * Vector3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec = vec / 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        XCTAssertEqual(-1.75, vec.z)
        
        vec = vec / Vector3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        let d = dot(vec, Vector3F(4.0, 2.0, 1.0))
        XCTAssertEqual(3.0, d)
        
        let c = cross(vec, Vector3F(5.0, -7.0, 2.0))
        XCTAssertEqual(-43.0, c.x)
        XCTAssertEqual(-37.0, c.y)
        XCTAssertEqual(-22.0, c.z)
    }
    
    func testBinaryInverseOperatorMethods() {
        var vec = Vector3F(5.0, 14.0, 13.0)
        vec = 8.0 - vec
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-6.0, vec.y)
        XCTAssertEqual(-5.0, vec.z)
        
        vec = Vector3F(-5.0, 3.0, -1.0) - vec
        XCTAssertEqual(-8.0, vec.x)
        XCTAssertEqual(9.0, vec.y)
        XCTAssertEqual(4.0, vec.z)
        
        vec = Vector3F(-12.0, -9.0, 8.0)
        vec = 36.0 / vec
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(-4.0, vec.y)
        XCTAssertEqual(4.5, vec.z)
        
        vec = Vector3F(3.0, -16.0, 18.0) / vec
        XCTAssertEqual(-1.0, vec.x)
        XCTAssertEqual(4.0, vec.y)
        XCTAssertEqual(4.0, vec.z)
        
        let c = cross(Vector3F(5.0, -7.0, 3.0), vec)
        XCTAssertEqual(-40.0, c.x)
        XCTAssertEqual(-23.0, c.y)
        XCTAssertEqual(13.0, c.z)
    }
    
    func testAugmentedOperatorMethods() {
        var vec = Vector3F(3.0, 9.0, 4.0)
        vec += 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(13.0, vec.y)
        XCTAssertEqual(8.0, vec.z)
        
        vec += Vector3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(14.0, vec.y)
        XCTAssertEqual(13.0, vec.z)
        
        vec -= 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
        
        vec -= Vector3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec *= 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(-14.0, vec.z)
        
        vec *= Vector3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec /= 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        XCTAssertEqual(-1.75, vec.z)
        
        vec /= Vector3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
    }
    
    func testAtMethods() {
        var vec = Vector3F(8.0, 9.0, 1.0)
        XCTAssertEqual(8.0, vec[0])
        XCTAssertEqual(9.0, vec[1])
        XCTAssertEqual(1.0, vec[2])
        
        vec[0] = 7.0
        vec[1] = 6.0
        vec[2] = 5.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
    }
    
    func testBasicGetterMethods() {
        let vec = Vector3F(3.0, 7.0, -1.0)
        var vec2 = Vector3F(-3.0, -7.0, 1.0)
        
        XCTAssertEqual(9.0, vec.sum())
        XCTAssertEqual(3.0, vec.avg)
        XCTAssertEqual(-1.0, vec.min())
        XCTAssertEqual(7.0, vec.max())
        XCTAssertEqual(1.0, vec2.absmin)
        XCTAssertEqual(-7.0, vec2.absmax)
        XCTAssertEqual(1, vec.dominantAxis)
        XCTAssertEqual(2, vec.subminantAxis)
        
        let eps:Float = 1.0e-6
        vec2 = normalize(vec)
        XCTAssertTrue(vec2.x * vec2.x + vec2.y * vec2.y + vec2.z * vec2.z - 1.0 < eps)
        
        vec2 *= 2.0
        XCTAssertTrue(length(vec2) - 2.0 < eps)
        XCTAssertTrue(length_squared(vec2) - 4.0 < eps)
    }
    
    func testBracketOperators() {
        var vec = Vector3F(8.0, 9.0, 1.0)
        XCTAssertEqual(8.0, vec[0])
        XCTAssertEqual(9.0, vec[1])
        XCTAssertEqual(1.0, vec[2])
        
        vec[0] = 7.0
        vec[1] = 6.0
        vec[2] = 5.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
    }
    
    func testAssignmentOperators() {
        let vec = Vector3F(5.0, 1.0, 0.0)
        var vec2 = Vector3F(3.0, 3.0, 3.0)
        vec2 = vec
        XCTAssertEqual(5.0, vec2.x)
        XCTAssertEqual(1.0, vec2.y)
        XCTAssertEqual(0.0, vec2.z)
    }
    
    func testAugmentedOperators() {
        var vec = Vector3F(3.0, 9.0, -2.0)
        vec += 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(13.0, vec.y)
        XCTAssertEqual(2.0, vec.z)
        
        vec += Vector3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(14.0, vec.y)
        XCTAssertEqual(7.0, vec.z)
        
        vec -= 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(-1.0, vec.z)
        
        vec -= Vector3F(-5.0, 3.0, -6.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
        
        vec *= 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(10.0, vec.z)
        
        vec *= Vector3F(3.0, -2.0, 0.4)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        XCTAssertEqual(4.0, vec.z)
        
        vec /= 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        XCTAssertEqual(1.0, vec.z)
        
        vec /= Vector3F(3.0, -1.0, 2.0)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(0.5, vec.z)
    }
    
    func testEqualOperatators() {
        var vec = Vector3F()
        let vec2 = Vector3F(3.0, 7.0, 4.0)
        let vec3 = Vector3F(3.0, 5.0, 4.0)
        let vec4 = Vector3F(5.0, 1.0, 2.0)
        vec = vec2
        XCTAssertTrue(vec == vec2)
        XCTAssertFalse(vec == vec3)
        XCTAssertFalse(vec != vec2)
        XCTAssertTrue(vec != vec3)
        XCTAssertTrue(vec != vec4)
    }
    
    func testMinMaxFunctions() {
        let vec = Vector3F(5.0, 1.0, 0.0)
        let vec2 = Vector3F(3.0, 3.0, 3.0)
        let minVector = min(vec, vec2)
        let maxVector = max(vec, vec2)
        XCTAssertTrue(minVector == Vector3F(3.0, 1.0, 0.0))
        XCTAssertTrue(maxVector == Vector3F(5.0, 3.0, 3.0))
    }
    
    func testClampFunction() {
        let vec = Vector3F(2.0, 4.0, 1.0)
        let low = Vector3F(3.0, -1.0, 0.0)
        let high = Vector3F(5.0, 2.0, 3.0)
        let clampedVec = vec.clamped(lowerBound: low, upperBound: high)
        XCTAssertTrue(clampedVec == Vector3F(3.0, 2.0, 1.0))
    }
    
    func testCeilFloorFunctions() {
        let vec =  Vector3F(2.2, 4.7, -0.2)
        let ceilVec = ceil(vec)
        XCTAssertTrue(ceilVec == Vector3F(3.0, 5.0, 0.0))
        
        let floorVec = floor(vec)
        XCTAssertTrue(floorVec == Vector3F(2.0, 4.0, -1.0))
    }
    
    func testBinaryOperators() {
        var vec = Vector3F(3.0, 9.0, 4.0)
        vec = vec + 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(13.0, vec.y)
        XCTAssertEqual(8.0, vec.z)
        
        vec = vec + Vector3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(14.0, vec.y)
        XCTAssertEqual(13.0, vec.z)
        
        vec = vec - 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(5.0, vec.z)
        
        vec = vec - Vector3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec = vec * 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        XCTAssertEqual(-14.0, vec.z)
        
        vec = vec * Vector3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        vec = vec / 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        XCTAssertEqual(-1.75, vec.z)
        
        vec = vec / Vector3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        XCTAssertEqual(-7.0, vec.z)
        
        let v = normalize(Vector3D(2.0, 1.0, 3.0))
        let normal = normalize(Vector3D(1.0, 1.0, 1.0))
        
        let reflected = v.reflected(with: normal)
        let reflectedAnswer = normalize(Vector3D(-2.0, -3.0, -1.0))
        XCTAssertEqual(length(reflected - reflectedAnswer), 0.0, accuracy:1e-9)
        
        let projected = v.projected(with: normal)
        XCTAssertEqual(dot(projected, normal), 0.0, accuracy:1e-9)
        
        let tangential = normal.tangential
        XCTAssertEqual(dot(tangential[0], normal), 0.0, accuracy:1e-9)
        XCTAssertEqual(dot(tangential[1], normal), 0.0, accuracy:1e-9)
    }
}
