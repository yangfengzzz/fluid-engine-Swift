//
//  matrix3x3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class matrix3x3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        var mat = Matrix3x3D()
        XCTAssertTrue(mat == Matrix3x3D(m00: 1.0, m01: 0.0, m02: 0.0,
                                        m10: 0.0, m11: 1.0, m12: 0.0,
                                        m20: 0.0, m21: 0.0, m22: 1.0))
        
        let mat2 = Matrix3x3D(scaleValue: 3.1)
        for i in 0..<3 {
            for j in 0..<3 {
                XCTAssertEqual(3.1, mat2[i,j])
            }
        }
        
        let mat3 = Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                              m10: 4.0, m11: 5.0, m12: 6.0,
                              m20: 7.0, m21: 8.0, m22: 9.0)
        var index:Double = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat3[i,j])
            }
        }
        
        let mat4 = Matrix3x3D(lst: [[1.0, 2.0, 3.0],
                                    [4.0, 5.0, 6.0],
                                    [7.0, 8.0, 9.0]])
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat4[i,j])
            }
        }
        
        let mat5 = Matrix3x3D(mat: mat4)
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat5[i,j])
            }
        }
    }
    
    func testSetMethods() {
        var mat = Matrix3x3D()
        
        mat.set(scaleValue: 3.1)
        for i in 0..<3 {
            for j in 0..<3 {
                XCTAssertEqual(3.1, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(m00: 1.0, m01: 2.0, m02: 3.0,
                m10: 4.0, m11: 5.0, m12: 6.0,
                m20: 7.0, m21: 8.0, m22: 9.0)
        var index:Double = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(lst: [[1.0, 2.0, 3.0],
                      [4.0, 5.0, 6.0],
                      [7.0, 8.0, 9.0]])
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(mat: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                m10: 4.0, m11: 5.0, m12: 6.0,
                                m20: 7.0, m21: 8.0, m22: 9.0))
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setDiagonal(s: 3.1)
        for i in 0..<3 {
            for j in 0..<3 {
                if i == j {
                    XCTAssertEqual(3.1, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setOffDiagonal(s: 4.2)
        for i in 0..<3 {
            for j in 0..<3 {
                if i != j {
                    XCTAssertEqual(4.2, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setRow(i: 0, row: Vector3D(1.0, 2.0, 3.0))
        mat.setRow(i: 1, row: Vector3D(4.0, 5.0, 6.0))
        mat.setRow(i: 2, row: Vector3D(7.0, 8.0, 9.0))
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setColumn(i: 0, col: Vector3D(1.0, 4.0, 7.0))
        mat.setColumn(i: 1, col: Vector3D(2.0, 5.0, 8.0))
        mat.setColumn(i: 2, col: Vector3D(3.0, 6.0, 9.0))
        index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
    }
    
    func testBasicGetters() {
        let mat = Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                             m10: 4.0, m11: 5.0, m12: 6.0,
                             m20: 7.0, m21: 8.0, m22: 9.0)
        let mat2 = Matrix3x3D(m00: 1.01, m01: 2.01, m02: 2.99,
                              m10: 4.0, m11: 4.99, m12: 6.001,
                              m20: 7.0003, m21: 8.0, m22: 8.99)
        
        XCTAssertTrue(mat.isSimilar(m: mat2, tol: 0.02))
        XCTAssertFalse(mat.isSimilar(m: mat2, tol: 0.001))
        
        XCTAssertTrue(mat.isSquare())
        
        XCTAssertEqual(3, mat.rows())
        XCTAssertEqual(3, mat.cols())
    }
    
    func testBinaryOperators() {
        let mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        var mat2 = Matrix3x3D()
        var vec = Vector3D()
        
        mat2 = mat.add(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 11.0, m01: -6.0, m02: 9.0,
                          m10: -4.0, m11: 7.0, m12: -2.0,
                          m20: 5.0, m21: 0.0, m22: 3.0)))
        
        mat2 = mat.add(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                     m10: 4.0, m11: 5.0, m12: 6.0,
                                     m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 10.0, m01: -6.0, m02: 10.0,
                          m10: -2.0, m11: 10.0, m12: 2.0,
                          m20: 10.0, m21: 6.0, m22: 10.0)))
        
        mat2 = mat.sub(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 7.0, m01: -10.0, m02: 5.0,
                          m10: -8.0, m11: 3.0, m12: -6.0,
                          m20: 1.0, m21: -4.0, m22: -1.0)))
        
        mat2 = mat.sub(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                     m10: 4.0, m11: 5.0, m12: 6.0,
                                     m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 8.0, m01: -10.0, m02: 4.0,
                          m10: -10.0, m11: 0.0, m12: -10.0,
                          m20: -4.0, m21: -10.0, m22: -8.0)))
        
        mat2 = mat.mul(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 18.0, m01: -16.0, m02: 14.0,
                          m10: -12.0, m11: 10.0, m12: -8.0,
                          m20: 6.0, m21: -4.0, m22: 2.0)))
        
        vec = mat.mul(v: Vector3D(1, 2, 3))
        XCTAssertTrue(vec.isSimilar(other: Vector3D(14.0, -8.0, 2.0)))
        
        mat2 = mat.mul(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                     m10: 4.0, m11: 5.0, m12: 6.0,
                                     m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 26.0, m01: 34.0, m02: 42.0,
                          m10: -14.0, m11: -19.0, m12: -24.0,
                          m20: 2.0, m21: 4.0, m22: 6.0)))
        
        mat2 = mat.div(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 4.5, m01: -4.0, m02: 3.5,
                          m10: -3.0, m11: 2.5, m12: -2.0,
                          m20: 1.5, m21: -1.0, m22: 0.5)))
        
        
        mat2 = mat.radd(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 11.0, m01: -6.0, m02: 9.0,
                          m10: -4.0, m11: 7.0, m12: -2.0,
                          m20: 5.0, m21: 0.0, m22: 3.0)))
        
        mat2 = mat.radd(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                      m10: 4.0, m11: 5.0, m12: 6.0,
                                      m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 10.0, m01: -6.0, m02: 10.0,
                          m10: -2.0, m11: 10.0, m12: 2.0,
                          m20: 10.0, m21: 6.0, m22: 10.0)))
        
        mat2 = mat.rsub(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: -7.0, m01: 10.0, m02: -5.0,
                          m10: 8.0, m11: -3.0, m12: 6.0,
                          m20: -1.0, m21: 4.0, m22: 1.0)))
        
        mat2 = mat.rsub(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                      m10: 4.0, m11: 5.0, m12: 6.0,
                                      m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: -8.0, m01: 10.0, m02: -4.0,
                          m10: 10.0, m11: 0.0, m12: 10.0,
                          m20: 4.0, m21: 10.0, m22: 8.0)))
        
        mat2 = mat.rmul(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 18.0, m01: -16.0, m02: 14.0,
                          m10: -12.0, m11: 10.0, m12: -8.0,
                          m20: 6.0, m21: -4.0, m22: 2.0)))
        
        mat2 = mat.rmul(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                                      m10: 4.0, m11: 5.0, m12: 6.0,
                                      m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 6.0, m01: -4.0, m02: 2.0,
                          m10: 24.0, m11: -19.0, m12: 14.0,
                          m20: 42.0, m21: -34.0, m22: 26.0)))
        
        mat2 = mat.rdiv(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(
                m00: 2.0/9.0, m01: -0.25, m02: 2.0/7.0,
                m10: -1.0/3.0, m11: 0.4, m12: -0.5,
                m20: 2.0/3.0, m21: -1.0, m22: 2.0)))
    }
    
    func testAugmentedOperators() {
        var mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        
        mat.iadd(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 11.0, m01: -6.0, m02: 9.0,
                          m10: -4.0, m11: 7.0, m12: -2.0,
                          m20: 5.0, m21: 0.0, m22: 3.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.iadd(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                               m10: 4.0, m11: 5.0, m12: 6.0,
                               m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 10.0, m01: -6.0, m02: 10.0,
                          m10: -2.0, m11: 10.0, m12: 2.0,
                          m20: 10.0, m21: 6.0, m22: 10.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.isub(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 7.0, m01: -10.0, m02: 5.0,
                          m10: -8.0, m11: 3.0, m12: -6.0,
                          m20: 1.0, m21: -4.0, m22: -1.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.isub(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                               m10: 4.0, m11: 5.0, m12: 6.0,
                               m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 8.0, m01: -10.0, m02: 4.0,
                          m10: -10.0, m11: 0.0, m12: -10.0,
                          m20: -4.0, m21: -10.0, m22: -8.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.imul(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 18.0, m01: -16.0, m02: 14.0,
                          m10: -12.0, m11: 10.0, m12: -8.0,
                          m20: 6.0, m21: -4.0, m22: 2.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.imul(m: Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                               m10: 4.0, m11: 5.0, m12: 6.0,
                               m20: 7.0, m21: 8.0, m22: 9.0))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 26.0, m01: 34.0, m02: 42.0,
                          m10: -14.0, m11: -19.0, m12: -24.0,
                          m20: 2.0, m21: 4.0, m22: 6.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat.idiv(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 4.5, m01: -4.0, m02: 3.5,
                          m10: -3.0, m11: 2.5, m12: -2.0,
                          m20: 1.5, m21: -1.0, m22: 0.5)))
    }
    
    func testModifiers() {
        var mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        
        mat.transpose()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: -6.0, m02: 3.0,
                          m10: -8.0, m11: 5.0, m12: -2.0,
                          m20: 7.0, m21: -4.0, m22: 1.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 2.0)
        mat.invert()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: -2.0/3.0, m01: -2.0/3.0, m02: 1.0,
                          m10: 0.0, m11: 1.0, m12: 2.0,
                          m20: 1.0, m21: 2.0, m22: 1.0)))
    }
    
    func testComplexGetters() {
        var mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        var mat2 = Matrix3x3D()
        
        XCTAssertEqual(5.0, mat.sum())
        XCTAssertEqual(5.0 / 9.0, mat.avg())
        XCTAssertEqual(-8.0, mat.min())
        XCTAssertEqual(9.0, mat.max())
        XCTAssertEqual(1.0, mat.absmin())
        XCTAssertEqual(9.0, mat.absmax())
        XCTAssertEqual(15.0, mat.trace())
        XCTAssertEqual(0.0, mat.determinant())
        
        mat2 = mat.diagonal()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: 0.0, m02: 0.0,
                          m10: 0.0, m11: 5.0, m12: 0.0,
                          m20: 0.0, m21: 0.0, m22: 1.0)))
        
        mat2 = mat.offDiagonal()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 0.0, m01: -8.0, m02: 7.0,
                          m10: -6.0, m11: 0.0, m12: -4.0,
                          m20: 3.0, m21: -2.0, m22: 0.0)))
        
        mat2 = mat.strictLowerTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 0.0, m01: 0.0, m02: 0.0,
                          m10: -6.0, m11: 0.0, m12: 0.0,
                          m20: 3.0, m21: -2.0, m22: 0.0)))
        
        mat2 = mat.strictUpperTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 0.0, m01: -8.0, m02: 7.0,
                          m10: 0.0, m11: 0.0, m12: -4.0,
                          m20: 0.0, m21: 0.0, m22: 0.0)))
        
        mat2 = mat.lowerTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: 0.0, m02: 0.0,
                          m10: -6.0, m11: 5.0, m12: 0.0,
                          m20: 3.0, m21: -2.0, m22: 1.0)))
        
        mat2 = mat.upperTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                          m10: 0.0, m11: 5.0, m12: -4.0,
                          m20: 0.0, m21: 0.0, m22: 1.0)))
        
        mat2 = mat.transposed()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: -6.0, m02: 3.0,
                          m10: -8.0, m11: 5.0, m12: -2.0,
                          m20: 7.0, m21: -4.0, m22: 1.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 2.0)
        mat2 = mat.inverse()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: -2.0/3.0, m01: -2.0/3.0, m02: 1.0,
                          m10: 0.0, m11: 1.0, m12: 2.0,
                          m20: 1.0, m21: 2.0, m22: 1.0)))
    }
    
    func testSetterOperatorOverloadings() {
        var mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        var mat2 = Matrix3x3D()
        
        mat2 = mat
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                          m10: -6.0, m11: 5.0, m12: -4.0,
                          m20: 3.0, m21: -2.0, m22: 1.0)))
        
        mat += 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 11.0, m01: -6.0, m02: 9.0,
                          m10: -4.0, m11: 7.0, m12: -2.0,
                          m20: 5.0, m21: 0.0, m22: 3.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat += Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                          m10: 4.0, m11: 5.0, m12: 6.0,
                          m20: 7.0, m21: 8.0, m22: 9.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 10.0, m01: -6.0, m02: 10.0,
                          m10: -2.0, m11: 10.0, m12: 2.0,
                          m20: 10.0, m21: 6.0, m22: 10.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat -= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 7.0, m01: -10.0, m02: 5.0,
                          m10: -8.0, m11: 3.0, m12: -6.0,
                          m20: 1.0, m21: -4.0, m22: -1.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat -= Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                          m10: 4.0, m11: 5.0, m12: 6.0,
                          m20: 7.0, m21: 8.0, m22: 9.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 8.0, m01: -10.0, m02: 4.0,
                          m10: -10.0, m11: 0.0, m12: -10.0,
                          m20: -4.0, m21: -10.0, m22: -8.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat *= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 18.0, m01: -16.0, m02: 14.0,
                          m10: -12.0, m11: 10.0, m12: -8.0,
                          m20: 6.0, m21: -4.0, m22: 2.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat *= Matrix3x3D(m00: 1.0, m01: 2.0, m02: 3.0,
                          m10: 4.0, m11: 5.0, m12: 6.0,
                          m20: 7.0, m21: 8.0, m22: 9.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 26.0, m01: 34.0, m02: 42.0,
                          m10: -14.0, m11: -19.0, m12: -24.0,
                          m20: 2.0, m21: 4.0, m22: 6.0)))
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        mat /= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 4.5, m01: -4.0, m02: 3.5,
                          m10: -3.0, m11: 2.5, m12: -2.0,
                          m20: 1.5, m21: -1.0, m22: 0.5)))
    }
    
    func testGetterOperatorOverloadings() {
        var mat = Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                             m10: -6.0, m11: 5.0, m12: -4.0,
                             m20: 3.0, m21: -2.0, m22: 1.0)
        
        XCTAssertEqual(9.0, mat[0,0])
        XCTAssertEqual(-8.0, mat[0,1])
        XCTAssertEqual(7.0, mat[0,2])
        XCTAssertEqual(-6.0, mat[1,0])
        XCTAssertEqual(5.0, mat[1,1])
        XCTAssertEqual(-4.0, mat[1,2])
        XCTAssertEqual(3.0, mat[2,0])
        XCTAssertEqual(-2.0, mat[2,1])
        XCTAssertEqual(1.0, mat[2,2])
        
        mat[0,0] = -9.0
        mat[0,1] = 8.0
        mat[0,2] = -7.0
        mat[1,0] = 6.0
        mat[1,1] = -5.0
        mat[1,2] = 4.0
        mat[2,0] = -3.0
        mat[2,1] = 2.0
        mat[2,2] = -1.0
        XCTAssertEqual(-9.0, mat[0,0])
        XCTAssertEqual(8.0, mat[0,1])
        XCTAssertEqual(-7.0, mat[0,2])
        XCTAssertEqual(6.0, mat[1,0])
        XCTAssertEqual(-5.0, mat[1,1])
        XCTAssertEqual(4.0, mat[1,2])
        XCTAssertEqual(-3.0, mat[2,0])
        XCTAssertEqual(2.0, mat[2,1])
        XCTAssertEqual(-1.0, mat[2,2])
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        XCTAssertEqual(9.0, mat[0,0])
        XCTAssertEqual(-8.0, mat[0,1])
        XCTAssertEqual(7.0, mat[0,2])
        XCTAssertEqual(-6.0, mat[1,0])
        XCTAssertEqual(5.0, mat[1,1])
        XCTAssertEqual(-4.0, mat[1,2])
        XCTAssertEqual(3.0, mat[2,0])
        XCTAssertEqual(-2.0, mat[2,1])
        XCTAssertEqual(1.0, mat[2,2])
        
        mat.set(m00: 9.0, m01: -8.0, m02: 7.0,
                m10: -6.0, m11: 5.0, m12: -4.0,
                m20: 3.0, m21: -2.0, m22: 1.0)
        XCTAssertTrue(
            mat == Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                              m10: -6.0, m11: 5.0, m12: -4.0,
                              m20: 3.0, m21: -2.0, m22: 1.0))
        
        mat.set(m00: 9.0, m01: 8.0, m02: 7.0,
                m10: 6.0, m11: 5.0, m12: 4.0,
                m20: 3.0, m21: 2.0, m22: 1.0)
        XCTAssertTrue(
            mat != Matrix3x3D(m00: 9.0, m01: -8.0, m02: 7.0,
                              m10: -6.0, m11: 5.0, m12: -4.0,
                              m20: 3.0, m21: -2.0, m22: 1.0))
    }
    
    func testHelpers() {
        var mat = Matrix3x3D.makeZero()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 0.0, m01: 0.0, m02: 0.0,
                          m10: 0.0, m11: 0.0, m12: 0.0,
                          m20: 0.0, m21: 0.0, m22: 0.0)))
        
        mat = Matrix3x3D.makeIdentity()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 1.0, m01: 0.0, m02: 0.0,
                          m10: 0.0, m11: 1.0, m12: 0.0,
                          m20: 0.0, m21: 0.0, m22: 1.0)))
        
        mat = Matrix3x3D.makeScaleMatrix(sx: 3.0, sy: -4.0, sz: 2.4)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: 3.0, m01: 0.0, m02: 0.0,
                          m10: 0.0, m11: -4.0, m12: 0.0,
                          m20: 0.0, m21: 0.0, m22: 2.4)))
        
        mat = Matrix3x3D.makeScaleMatrix(s: Vector3D(-2.0, 5.0, 3.5))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix3x3D(m00: -2.0, m01: 0.0, m02: 0.0,
                          m10: 0.0, m11: 5.0, m12: 0.0,
                          m20: 0.0, m21: 0.0, m22: 3.5)))
        
        mat = Matrix3x3D.makeRotationMatrix(
            axis: Vector3D(-1.0/3.0, 2.0/3.0, 2.0/3.0), rad: -74.0 / 180.0 * kPiD)
        XCTAssertTrue(mat.isSimilar(m: Matrix3x3D(
            m00: 0.36, m01: 0.48, m02: -0.8,
            m10: -0.8, m11: 0.60, m12: 0.0,
            m20: 0.48, m21: 0.64, m22: 0.6), tol: 0.05))
    }
}
