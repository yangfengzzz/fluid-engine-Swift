//
//  vector2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vector2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructors() throws {
        let vec = Vector2F()
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(0.0, vec.y)
        
        let vec2 = Vector2F(5.0, 3.0)
        XCTAssertEqual(5.0, vec2.x)
        XCTAssertEqual(3.0, vec2.y)
        
        let vec5 = Vector2F(7.0, 6.0)
        XCTAssertEqual(7.0, vec5.x)
        XCTAssertEqual(6.0, vec5.y)
        
        let vec6 = Vector2F(vec5)
        XCTAssertEqual(7.0, vec6.x)
        XCTAssertEqual(6.0, vec6.y)
    }
    
    func testSetMethods() {
        var vec = Vector2F()
        vec.replace(with: Vector2F(4.0, 2.0), where: [true, true])
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(2.0, vec.y)
        
        let lst:[Float] = [0.0, 5.0]
        vec.replace(with: Vector2F(lst), where: [true, true])
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(5.0, vec.y)
        
        vec.replace(with: Vector2F(9.0, 8.0), where: [true, true])
        XCTAssertEqual(9.0, vec.x)
        XCTAssertEqual(8.0, vec.y)
    }
    
    func testBasicSetterMethods() {
        var vec = Vector2F(3.0, 9.0)
        vec = Vector2F.zero
        XCTAssertEqual(0.0, vec.x)
        XCTAssertEqual(0.0, vec.y)
        
        vec.replace(with: Vector2F(4.0, 2.0), where: [true, true])
        vec.normalized()
        let len = vec.x * vec.x + vec.y * vec.y
        XCTAssertEqual(len, 1.0, accuracy: 1.0e-6)
    }
    
    func testBinaryOperatorMethods() {
        var vec = Vector2F(3.0, 9.0)
        vec = vec + 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(13.0, vec.y)
        
        vec = vec + Vector2F(-2.0, 1.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(14.0, vec.y)
        
        vec = vec - 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec = vec - Vector2F(-5.0, 3.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        vec = vec * 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec = vec * Vector2F(3.0, -2.0)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        
        vec = vec / 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        
        vec = vec / Vector2F(3.0, -1.0)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        let d = dot(vec, Vector2F(4.0, 2.0))
        XCTAssertEqual(d, 10.0)
        
        let c = cross(vec, Vector2F(5.0, -7.0))
        XCTAssertEqual(c.z, -22.0)
    }
    
    func testBinaryInverseOperatorMethods() {
        var vec = Vector2F(3.0, 9.0)
        vec = 8.0 - vec
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(-1.0, vec.y)
        
        vec = Vector2F(-5.0, 3.0) - vec
        XCTAssertEqual(-10.0, vec.x)
        XCTAssertEqual(4.0, vec.y)
        
        vec = Vector2F(-4.0, -3.0)
        vec = 12.0 / vec
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(vec.y, -4.0)
        
        vec = Vector2F(3.0, -16.0) / vec
        XCTAssertEqual(-1.0, vec.x)
        XCTAssertEqual(4.0, vec.y)
        
        let c = cross(Vector2F(5.0, -7.0), vec)
        XCTAssertEqual(c.z, 13.0)
    }
    
    func testAugmentedOperatorMethods() {
        var vec = Vector2F(3.0, 9.0)
        vec += 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(vec.y, 13.0)
        
        vec += Vector2F(-2.0, 1.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(vec.y, 14.0)
        
        vec -= 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec -= Vector2F(-5.0, 3.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        vec *= 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec *= Vector2F(3.0, -2.0)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        
        vec /= 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        
        vec /= Vector2F(3.0, -1.0)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
    }

    func testAtMethod() {
        var vec = Vector2F(8.0, 9.0)
        XCTAssertEqual(vec[0], 8.0)
        XCTAssertEqual(vec[1], 9.0)
        
        vec[0] = 7.0
        vec[1] = 6.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
    }
    
    func testBasicGetterMethods() {
        let vec = Vector2F(3.0, 7.0)
        var vec2 = Vector2F(-3.0, -7.0)
        
        XCTAssertEqual(vec.sum(), 10.0)
        XCTAssertEqual(vec.avg, 5.0)
        XCTAssertEqual(vec.min(), 3.0)
        XCTAssertEqual(vec.max(), 7.0)
        XCTAssertEqual(vec2.absmin, -3.0)
        XCTAssertEqual(vec2.absmax, -7.0)
        XCTAssertEqual(vec.dominantAxis, 1)
        XCTAssertEqual(vec.subminantAxis, 0)
        
        let eps:Float = 1.0e-6
        vec2 = normalize(vec)
        XCTAssertEqual(vec2.x * vec2.x + vec2.y * vec2.y, 1.0, accuracy:eps)
        
        vec2 *= 2.0
        XCTAssertEqual(length(vec2), 2.0, accuracy:eps)
        XCTAssertEqual(length_squared(vec2), 4.0, accuracy:eps)
    }
    
    func testBracketOperator() {
        var vec = Vector2F(8.0, 9.0)
        XCTAssertEqual(vec[0], 8.0)
        XCTAssertEqual(vec[1], 9.0)
        
        vec[0] = 7.0
        vec[1] = 6.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
    }
    
    func testAssignmentOperator() {
        let vec =  Vector2F(5.0, 1.0)
        var vec2 = Vector2F(3.0, 3.0)
        vec2 = vec
        XCTAssertEqual(5.0, vec2.x)
        XCTAssertEqual(vec2.y, 1.0)
    }
    
    func testAugmentedOperators() {
        var vec = Vector2F(3.0, 9.0)
        vec += 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(vec.y, 13.0)
        
        vec += Vector2F(-2.0, 1.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(vec.y, 14.0)
        
        vec -= 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec -= Vector2F(-5.0, 3.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        vec *= 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec *= Vector2F(3.0, -2.0)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        
        vec /= 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        
        vec /= Vector2F(3.0, -1.0)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
    }
    
    func testEqualOperator() {
        var vec = Vector2F()
        let vec2 = Vector2F(3.0, 7.0)
        let vec3 = Vector2F(3.0, 5.0)
        let vec4 = Vector2F(5.0, 1.0)
        vec = vec2
        XCTAssertTrue(vec == vec2)
        XCTAssertFalse(vec == vec3)
        XCTAssertFalse(vec != vec2)
        XCTAssertTrue(vec != vec3)
        XCTAssertTrue(vec != vec4)
    }
    
    func testMinMaxFunction() {
        let vec =  Vector2F(5.0, 1.0)
        let vec2 = Vector2F(3.0, 3.0)
        let minVector = min(vec, vec2)
        let maxVector = max(vec, vec2)
        XCTAssertEqual(Vector2F(3.0, 1.0), minVector)
        XCTAssertEqual(Vector2F(5.0, 3.0), maxVector)
    }
    
    func testClampFunction() {
        let vec = Vector2F(2.0, 4.0)
        let low = Vector2F(3.0, -1.0)
        let high = Vector2F(5.0, 2.0)
        let clampedVec = vec.clamped(lowerBound: low, upperBound: high)
        XCTAssertEqual(Vector2F(3.0, 2.0), clampedVec)
    }
    
    func testCeilFloorFunction() {
        let vec = Vector2F(2.2, 4.7)
        let ceilVec = vec.rounded(.up)
        XCTAssertEqual(Vector2F(3.0, 5.0), ceilVec)
        
        let floorVec = vec.rounded(.down)
        XCTAssertEqual(Vector2F(2.0, 4.0), floorVec)
    }
    
    func testBinaryOperators() {
        var vec = Vector2F(3.0, 9.0)
        vec = vec + 4.0
        XCTAssertEqual(7.0, vec.x)
        XCTAssertEqual(vec.y, 13.0)
        
        vec = vec + Vector2F(-2.0, 1.0)
        XCTAssertEqual(5.0, vec.x)
        XCTAssertEqual(vec.y, 14.0)
        
        vec = vec - 8.0
        XCTAssertEqual(-3.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec = vec - Vector2F(-5.0, 3.0)
        XCTAssertEqual(2.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        vec = vec * 2.0
        XCTAssertEqual(4.0, vec.x)
        XCTAssertEqual(6.0, vec.y)
        
        vec = vec * Vector2F(3.0, -2.0)
        XCTAssertEqual(12.0, vec.x)
        XCTAssertEqual(-12.0, vec.y)
        
        vec = vec / 4.0
        XCTAssertEqual(3.0, vec.x)
        XCTAssertEqual(-3.0, vec.y)
        
        vec = vec / Vector2F(3.0, -1.0)
        XCTAssertEqual(1.0, vec.x)
        XCTAssertEqual(3.0, vec.y)
        
        let v = normalize(Vector2D(2.0, 1.0))
        let normal = normalize(Vector2D(1.0, 1.0))
        
        let reflected = v.reflected(with:normal)
        let reflectedAnswer = normalize(Vector2D(-1.0, -2.0))
        XCTAssertEqual(length(reflected - reflectedAnswer), 0.0, accuracy:1e-9)
        
        let projected = v.projected(with:normal)
        XCTAssertEqual(dot(projected, normal), 0.0, accuracy:1e-9)
        
        let tangential = normal.tangential
        XCTAssertEqual(dot(tangential, normal), 0.0, accuracy:1e-9)
    }
}
