//
//  quaternion_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class quaternion_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func tesConstructors() {
        var q = QuaternionD()
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(0.0, q.x)
        XCTAssertEqual(0.0, q.y)
        XCTAssertEqual(0.0, q.z)
        
        q = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        q = QuaternionD(other: QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4))
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        q = QuaternionD(lst: [ 1, 2, 3, 4 ])
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        // set with axis & angle
        let originalAxis = Vector3D(1, 3, 2).normalized()
        let originalAngle:Double = 0.4
        q = QuaternionD(axis: originalAxis, angle: originalAngle)
        var axis = q.axis()
        var angle = q.angle()
        XCTAssertEqual(originalAxis.x, axis.x)
        XCTAssertEqual(originalAxis.y, axis.y)
        XCTAssertEqual(originalAxis.z, axis.z)
        XCTAssertEqual(originalAngle, angle)
        
        // set with from & to vectors (90 degrees)
        let from = Vector3D(1, 0, 0)
        let to = Vector3D(0, 0, 1)
        q = QuaternionD(from: from, to: to)
        axis = q.axis()
        angle = q.angle()
        XCTAssertEqual(0.0, axis.x)
        XCTAssertEqual(-1.0, axis.y)
        XCTAssertEqual(0.0, axis.z)
        XCTAssertEqual(Double.pi/2.0, angle)
        
        let rotationBasis0 = Vector3D(1, 0, 0)
        let rotationBasis1 = Vector3D(0, 0, 1)
        let rotationBasis2 = Vector3D(0, -1, 0)
        q = QuaternionD(axis0: rotationBasis0, axis1: rotationBasis1, axis2: rotationBasis2)
        XCTAssertEqual(sqrt(2.0) / 2.0, q.w)
        XCTAssertEqual(sqrt(2.0) / 2.0, q.x)
        XCTAssertEqual(0.0, q.y)
        XCTAssertEqual(0.0, q.z)
    }
    
    func testBasicSetters() {
        var q = QuaternionD()
        q.set(other: QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4))
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        q.set(newW: 1, newX: 2, newY: 3, newZ: 4)
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        q.set(lst: [ 1, 2, 3, 4 ])
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(2.0, q.x)
        XCTAssertEqual(3.0, q.y)
        XCTAssertEqual(4.0, q.z)
        
        // set with axis & angle
        let originalAxis = Vector3D(1, 3, 2).normalized()
        let originalAngle:Double = 0.4
        q.set(axis: originalAxis, angle: originalAngle)
        var axis = q.axis()
        var angle = q.angle()
        XCTAssertEqual(originalAxis.x, axis.x)
        XCTAssertEqual(originalAxis.y, axis.y, accuracy:1.0e-15)
        XCTAssertEqual(originalAxis.z, axis.z)
        XCTAssertEqual(originalAngle, angle)
        
        // set with from & to vectors (90 degrees)
        let from = Vector3D(1, 0, 0)
        let to = Vector3D(0, 0, 1)
        q.set(from: from, to: to)
        axis = q.axis()
        angle = q.angle()
        XCTAssertEqual(0.0, axis.x)
        XCTAssertEqual(-1.0, axis.y)
        XCTAssertEqual(0.0, axis.z)
        XCTAssertEqual(Double.pi/2.0, angle, accuracy:1.0e-15)
        
        let rotationBasis0 = Vector3D(1, 0, 0)
        let rotationBasis1 = Vector3D(0, 0, 1)
        let rotationBasis2 = Vector3D(0, -1, 0)
        q.set(rotationBasis0: rotationBasis0,
              rotationBasis1: rotationBasis1,
              rotationBasis2: rotationBasis2)
        XCTAssertEqual(sqrt(2.0) / 2.0, q.w)
        XCTAssertEqual(sqrt(2.0) / 2.0, q.x, accuracy:1.0e-15)
        XCTAssertEqual(0.0, q.y)
        XCTAssertEqual(0.0, q.z)
    }
    
    func testNormalized() {
        let q = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        let qn = q.normalized()
        
        let denom:Double = sqrt(30.0)
        XCTAssertEqual(1.0 / denom, qn.w)
        XCTAssertEqual(2.0 / denom, qn.x)
        XCTAssertEqual(3.0 / denom, qn.y)
        XCTAssertEqual(4.0 / denom, qn.z)
    }
    
    func testBinaryOperators() {
        var q1 = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        var q2 = QuaternionD(newW: 1, newX: -2, newY: -3, newZ: -4)
        
        var q3 = q1.mul(other: q2)
        
        XCTAssertEqual(30.0, q3.w)
        XCTAssertEqual(0.0, q3.x)
        XCTAssertEqual(0.0, q3.y)
        XCTAssertEqual(0.0, q3.z)
        
        q1.normalize()
        let v = Vector3D(7, 8, 9)
        let ans1 = q1.mul(v: v)
        
        let m = q1.matrix3()
        let ans2 = m.mul(v: v)
        
        XCTAssertEqual(ans2.x, ans1.x)
        XCTAssertEqual(ans2.y, ans1.y)
        XCTAssertEqual(ans2.z, ans1.z)
        
        q1.set(newW: 1, newX: 2, newY: 3, newZ: 4)
        q2.set(newW: 5, newX: 6, newY: 7, newZ: 8)
        XCTAssertEqual(70.0, q1.dot(other: q2))
        
        q3 = q1.mul(other: q2)
        XCTAssertEqual(q3, q2.rmul(other: q1))
        q1.imul(other: q2)
        XCTAssertEqual(q3, q1)
    }
    
    func testModifiers() {
        var q = QuaternionD(newW: 4, newX: 3, newY: 2, newZ: 1)
        q.setIdentity()
        
        XCTAssertEqual(1.0, q.w)
        XCTAssertEqual(0.0, q.x)
        XCTAssertEqual(0.0, q.y)
        XCTAssertEqual(0.0, q.z)
        
        q.set(newW: 4, newX: 3, newY: 2, newZ: 1)
        q.normalize()
        
        let denom = sqrt(30.0)
        XCTAssertEqual(4.0 / denom, q.w)
        XCTAssertEqual(3.0 / denom, q.x)
        XCTAssertEqual(2.0 / denom, q.y)
        XCTAssertEqual(1.0 / denom, q.z)
        
        var axis = Vector3D()
        var angle:Double = 0
        q.getAxisAngle(axis: &axis, angle: &angle)
        q.rotate(angleInRadians: 1.0)
        var newAngle:Double = 0
        q.getAxisAngle(axis: &axis, angle: &newAngle)
        
        XCTAssertEqual(angle + 1.0, newAngle)
    }
    
    func testComplexGetters() {
        var q = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        
        let q2 = q.inverse()
        XCTAssertEqual(1.0/30.0, q2.w)
        XCTAssertEqual(-1.0/15.0, q2.x)
        XCTAssertEqual(-1.0/10.0, q2.y)
        XCTAssertEqual(-2.0/15.0, q2.z)
        
        q.set(newW: 1, newX: 0, newY: 5, newZ: 2)
        q.normalize()
        let mat3 = q.matrix3()
        let solution3:[Double] = [
            -14.0 / 15.0, -2.0 / 15.0, 1.0 / 3.0,
            2.0 / 15.0, 11.0 / 15.0, 2.0 / 3.0,
            -1.0 / 3.0, 2.0 / 3.0, -2.0 / 3.0]
        
        for i in 0..<9 {
            XCTAssertEqual(solution3[i], mat3[i/3, i%3], accuracy:1.0e-15)
        }
        
        let mat4 = q.matrix4()
        let solution4:[Double] = [
            -14.0 / 15.0, -2.0 / 15.0, 1.0 / 3.0, 0.0,
            2.0 / 15.0, 11.0 / 15.0, 2.0 / 3.0, 0.0,
            -1.0 / 3.0, 2.0 / 3.0, -2.0 / 3.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        var axis =  Vector3D()
        var angle:Double = 0
        q.getAxisAngle(axis: &axis, angle: &angle)
        
        XCTAssertEqual(0.0, axis.x)
        XCTAssertEqual(5.0 / sqrt(29.0), axis.y)
        XCTAssertEqual(2.0 / sqrt(29.0), axis.z)
        XCTAssertEqual(axis, q.axis())
        XCTAssertEqual(angle, q.angle())
        XCTAssertEqual(2.0 * acos(1.0 / sqrt(30.0)), angle)
        
        for i in 0..<16 {
            XCTAssertEqual(solution4[i], mat4[i/4, i%4], accuracy:1.0e-15)
        }
        
        q.set(newW: 1, newX: 2, newY: 3, newZ: 4)
        XCTAssertEqual(sqrt(30.0), q.l2Norm())
    }

    func testSetterOperators() {
        var q = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        var q2 = QuaternionD(newW: 5, newX: 6, newY: 7, newZ: 8)
        
        q2 = q
        XCTAssertEqual(1.0, q2.w)
        XCTAssertEqual(2.0, q2.x)
        XCTAssertEqual(3.0, q2.y)
        XCTAssertEqual(4.0, q2.z)
        
        q2.set(newW: 5, newX: 6, newY: 7, newZ: 8)
        q *= q2
        XCTAssertEqual(-60.0, q.w)
        XCTAssertEqual(12.0, q.x)
        XCTAssertEqual(30.0, q.y)
        XCTAssertEqual(24.0, q.z)
    }
    
    func tesetGetterOperators() {
        var q = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        XCTAssertEqual(1.0, q[0])
        XCTAssertEqual(2.0, q[1])
        XCTAssertEqual(3.0, q[2])
        XCTAssertEqual(4.0, q[3])
        
        let q2 = QuaternionD(newW: 1, newX: 2, newY: 3, newZ: 4)
        XCTAssertTrue(q == q2)
        
        q[0] = 5.0
        q[1] = 6.0
        q[2] = 7.0
        q[3] = 8.0
        XCTAssertEqual(5.0, q[0])
        XCTAssertEqual(6.0, q[1])
        XCTAssertEqual(7.0, q[2])
        XCTAssertEqual(8.0, q[3])
        XCTAssertTrue(q != q2)
    }
}
