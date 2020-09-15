//
//  matrix4x4_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class matrix4x4_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let mat = Matrix4x4D()
        for i in 0..<4 {
            for j in 0..<4 {
                if (i == j) {
                    XCTAssertEqual(1.0, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        let mat2 = Matrix4x4D(scaleValue: 3.1)
        var index:Double = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(3.1, mat2[i,j])
            }
        }
        
        let mat3 = Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                              m10: 5, m11: 6, m12: 7, m13: 8,
                              m20: 9, m21: 10, m22: 11, m23: 12,
                              m30: 13, m31: 14, m32: 15, m33: 16)
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat3[i,j])
            }
        }
        
        let mat4 = Matrix4x4D(
            lst: [[1, 2, 3, 4],
                  [5, 6, 7, 8],
                  [9, 10, 11, 12],
                  [13, 14, 15, 16]])
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat4[i,j])
            }
        }
        
        let mat5 = Matrix4x4D(mat: mat4)
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat5[i,j])
            }
        }
    }
    
    func testSetMethods() {
        var mat = Matrix4x4D()
        
        mat.set(scaleValue: 3.1)
        var index:Double = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(3.1, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(m00: 1, m01: 2, m02: 3, m03: 4,
                m10: 5, m11: 6, m12: 7, m13: 8,
                m20: 9, m21: 10, m22: 11, m23: 12,
                m30: 13, m31: 14, m32: 15, m33: 16)
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(lst: [[1, 2, 3, 4],
                      [5, 6, 7, 8],
                      [9, 10, 11, 12],
                      [13, 14, 15, 16]])
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.set(mat: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                                m10: 5, m11: 6, m12: 7, m13: 8,
                                m20: 9, m21: 10, m22: 11, m23: 12,
                                m30: 13, m31: 14, m32: 15, m33: 16))
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setDiagonal(s: 3.1)
        for i in 0..<4 {
            for j in 0..<4 {
                if i == j {
                    XCTAssertEqual(3.1, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setOffDiagonal(s: 4.2)
        for i in 0..<4 {
            for j in 0..<4 {
                if (i != j) {
                    XCTAssertEqual(4.2, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setRow(i: 0, row: Vector4D(1, 2, 3, 4))
        mat.setRow(i: 1, row: Vector4D(5, 6, 7, 8))
        mat.setRow(i: 2, row: Vector4D(9, 10, 11, 12))
        mat.setRow(i: 3, row: Vector4D(13, 14, 15, 16))
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
        
        mat.set(scaleValue: 0.0)
        mat.setColumn(i: 0, col: Vector4D(1, 5, 9, 13))
        mat.setColumn(i: 1, col: Vector4D(2, 6, 10, 14))
        mat.setColumn(i: 2, col: Vector4D(3, 7, 11, 15))
        mat.setColumn(i: 3, col: Vector4D(4, 8, 12, 16))
        index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                index += 1
                XCTAssertEqual(index, mat[i,j])
            }
        }
    }
    
    func testBasicGetters() {
        let mat = Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                             m10: 5, m11: 6, m12: 7, m13: 8,
                             m20: 9, m21: 10, m22: 11, m23: 12,
                             m30: 13, m31: 14, m32: 15, m33: 16)
        let mat2 = Matrix4x4D(m00: 1.01, m01: 2.01, m02: 2.99, m03: 4.0,
                              m10: 4.99, m11: 6.001, m12: 7.0003, m13: 8.0,
                              m20: 8.99, m21: 10.01, m22: 11, m23: 11.99,
                              m30: 13.01, m31: 14.001, m32: 14.999, m33: 16)
        
        XCTAssertTrue(mat.isSimilar(m: mat2, tol: 0.02))
        XCTAssertFalse(mat.isSimilar(m: mat2, tol: 0.001))
        
        XCTAssertTrue(mat.isSquare())
        
        XCTAssertEqual(4, mat.rows())
        XCTAssertEqual(4, mat.cols())
    }
    
    func testBinaryOperators() {
        let mat = Matrix4x4D(m00: -16, m01: 15, m02: -14, m03: 13,
                             m10: -12, m11: 11, m12: -10, m13: 9,
                             m20: -8, m21: 7, m22: -6, m23: 5,
                             m30: -6, m31: 3, m32: -2, m33: 1)
        var mat2 = Matrix4x4D()
        var vec = Vector4D()
        
        mat2 = mat.add(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-14.0, 17.0, -12.0, 15.0],
                                [-10.0, 13.0, -8.0, 11.0],
                                [-6.0, 9.0, -4.0, 7.0],
                                [-4.0, 5.0, 0.0, 3.0]])))
        
        mat2 = mat.add(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-15.0, 17.0, -11.0, 17.0],
                                [-7.0, 17.0, -3.0, 17.0],
                                [1.0, 17.0, 5.0, 17.0],
                                [7.0, 17.0, 13.0, 17.0]])))
        
        mat2 = mat.sub(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst:  [[-18.0, 13.0, -16.0, 11.0],
                                 [-14.0, 9.0, -12.0, 7.0],
                                 [-10.0, 5.0, -8.0, 3.0],
                                 [-8.0, 1.0, -4.0, -1.0]])))
        
        mat2 = mat.sub(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-17.0, 13.0, -17.0, 9.0],
                                [-17.0, 5.0, -17.0, 1.0],
                                [-17.0, -3.0, -17.0, -7.0],
                                [-19.0, -11.0, -17.0, -15.0]])))
        
        mat2 = mat.mul(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-32.0, 30.0, -28.0, 26.0],
                                [-24.0, 22.0, -20.0, 18.0],
                                [-16.0, 14.0, -12.0, 10.0],
                                [-12.0, 6.0, -4.0, 2.0]])))
        
        vec = mat.mul(v: Vector4D(1, 2, 3, 4))
        XCTAssertTrue(vec.isSimilar(other: Vector4D(24, 16, 8, -2)))
        
        mat2 = mat.mul(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[102, 100, 98, 96],
                                [70, 68, 66, 64],
                                [38, 36, 34, 32],
                                [4, 0, -4, -8]])))
        
        mat2 = mat.div(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-8.0, 15.0/2.0, -7.0, 13.0/2.0],
                                [-6.0, 11.0/2.0, -5.0, 9.0/2.0],
                                [-4.0, 7.0/2.0, -3.0, 5.0/2.0],
                                [-3.0, 3.0/2.0, -1.0, 1.0/2.0]])))
        
        
        mat2 = mat.radd(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-14.0, 17.0, -12.0, 15.0],
                                [-10.0, 13.0, -8.0, 11.0],
                                [-6.0, 9.0, -4.0, 7.0],
                                [-4.0, 5.0, 0.0, 3.0]])))
        
        mat2 = mat.radd(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-15.0, 17.0, -11.0, 17.0],
                                [-7.0, 17.0, -3.0, 17.0],
                                [1.0, 17.0, 5.0, 17.0],
                                [7.0, 17.0, 13.0, 17.0]])))
        
        mat2 = mat.rsub(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[18.0, -13.0, 16.0, -11.0],
                                [14.0, -9.0, 12.0, -7.0],
                                [10.0, -5.0, 8.0, -3.0],
                                [8.0, -1.0, 4.0, 1.0]])))
        
        mat2 = mat.rsub(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[17.0, -13.0, 17.0, -9.0],
                                [17.0, -5.0, 17.0, -1.0],
                                [17.0, 3.0, 17.0, 7.0],
                                [19.0, 11.0, 17.0, 15.0]])))
        
        mat2 = mat.rmul(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-32.0, 30.0, -28.0, 26.0],
                                [-24.0, 22.0, -20.0, 18.0],
                                [-16.0, 14.0, -12.0, 10.0],
                                [-12.0, 6.0, -4.0, 2.0]])))
        
        mat2 = mat.rmul(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-88.0, 70.0, -60.0, 50.0],
                                [-256.0, 214.0, -188.0, 162.0],
                                [-424.0, 358.0, -316.0, 274.0],
                                [-592.0, 502.0, -444.0, 386.0]])))
        
        mat2 = mat.rdiv(s: 2.0)
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-1.0/8.0, 2.0/15.0, -1.0/7.0, 2.0/13.0],
                                [-1.0/6.0, 2.0/11.0, -1.0/5.0, 2.0/9.0],
                                [-1.0/4.0, 2.0/7.0, -1.0/3.0, 2.0/5.0],
                                [-1.0/3.0, 2.0/3.0, -1.0, 2.0]])))
    }
    
    func testAugmentedOperators() {
        var mat = Matrix4x4D(
            m00: -16, m01: 15, m02: -14, m03: 13,
            m10: -12, m11: 11, m12: -10, m13: 9,
            m20: -8, m21: 7, m22: -6, m23: 5,
            m30: -6, m31: 3, m32: -2, m33: 1)
        
        mat.iadd(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-14, 17, -12, 15],
                                [-10, 13, -8, 11],
                                [-6, 9, -4, 7],
                                [-4, 5, 0, 3]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.iadd(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-15, 17, -11, 17],
                                [-7, 17, -3, 17],
                                [1, 17, 5, 17],
                                [7, 17, 13, 17]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.isub(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-18, 13, -16, 11],
                                [-14, 9, -12, 7],
                                [-10, 5, -8, 3],
                                [-8, 1, -4, -1]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.isub(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-17, 13, -17, 9],
                                [-17, 5, -17, 1],
                                [-17, -3, -17, -7],
                                [-19, -11, -17, -15]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.imul(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-32, 30, -28, 26],
                                [-24, 22, -20, 18],
                                [-16, 14, -12, 10],
                                [-12, 6, -4, 2]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.imul(
            m: Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                          m10: 5, m11: 6, m12: 7, m13: 8,
                          m20: 9, m21: 10, m22: 11, m23: 12,
                          m30: 13, m31: 14, m32: 15, m33: 16))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[102, 100, 98, 96],
                                [70, 68, 66, 64],
                                [38, 36, 34, 32],
                                [4, 0, -4, -8]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat.idiv(s: 2.0)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-8.0, 15.0/2.0, -7.0, 13.0/2.0],
                                [-6.0, 11.0/2.0, -5.0, 9.0/2.0],
                                [-4.0, 7.0/2.0, -3.0, 5.0/2.0],
                                [-3.0, 3.0/2.0, -1.0, 1.0/2.0]])))
    }
    
    func testModifiers() {
        var mat = Matrix4x4D(
            m00: -16, m01: 15, m02: -14, m03: 13,
            m10: -12, m11: 11, m12: -10, m13: 9,
            m20: -8, m21: 7, m22: -6, m23: 5,
            m30: -6, m31: 3, m32: -2, m33: 1)
        
        mat.transpose()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-16, -12, -8, -6],
                                [15, 11, 7, 3],
                                [-14, -10, -6, -2],
                                [13, 9, 5, 1]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 6,
                m30: -6, m31: 3, m32: -2, m33: 2)
        mat.invert()
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-1.0/2.0, 1.0/2.0, 1.0/2.0, -1.0/2.0],
                                [-5.0/2.0, 5.0/2.0, 2.0, -1.0],
                                [-5.0/4.0, 1.0/4.0, 5.0/2.0, -1.0/2.0],
                                [1.0, -2.0, 1.0, 0.0]])))
    }
    
    func testComplexGetters() {
        var mat = Matrix4x4D(
            m00: -16, m01: 15, m02: -14, m03: 13,
            m10: -12, m11: 11, m12: -10, m13: 9,
            m20: -8, m21: 7, m22: -6, m23: 5,
            m30: -4, m31: 3, m32: -2, m33: 1)
        var mat2 = Matrix4x4D()
        
        XCTAssertEqual(-8.0, mat.sum())
        XCTAssertEqual(-0.5, mat.avg())
        XCTAssertEqual(-16.0, mat.min())
        XCTAssertEqual(15.0, mat.max())
        XCTAssertEqual(1.0, mat.absmin())
        XCTAssertEqual(-16.0, mat.absmax())
        XCTAssertEqual(-10.0, mat.trace())
        XCTAssertEqual(0.0, mat.determinant())
        
        mat2 = mat.diagonal()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(
                m00: -16, m01: 0, m02: 0, m03: 0,
                m10: 0, m11: 11, m12: 0, m13: 0,
                m20: 0, m21: 0, m22: -6, m23: 0,
                m30: 0, m31: 0, m32: 0, m33: 1)))
        
        mat2 = mat.offDiagonal()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(
                m00: 0, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 0, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: 0, m23: 5,
                m30: -4, m31: 3, m32: -2, m33: 0)))
        
        mat2 = mat.strictLowerTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(m00: 0, m01: 0, m02: 0, m03: 0,
                          m10: -12, m11: 0, m12: 0, m13: 0,
                          m20: -8, m21: 7, m22: 0, m23: 0,
                          m30: -4, m31: 3, m32: -2, m33: 0)))
        
        mat2 = mat.strictUpperTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(m00: 0, m01: 15, m02: -14, m03: 13,
                          m10: 0, m11: 0, m12: -10, m13: 9,
                          m20: 0, m21: 0, m22: 0, m23: 5,
                          m30: 0, m31: 0, m32: 0, m33: 0)))
        
        mat2 = mat.lowerTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(m00: -16, m01: 0, m02: 0, m03: 0,
                          m10: -12, m11: 11, m12: 0, m13: 0,
                          m20: -8, m21: 7, m22: -6, m23: 0,
                          m30: -4, m31: 3, m32: -2, m33: 1)))
        
        mat2 = mat.upperTri()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(m00: -16, m01: 15, m02: -14, m03: 13,
                          m10: 0, m11: 11, m12: -10, m13: 9,
                          m20: 0, m21: 0, m22: -6, m23: 5,
                          m30: 0, m31: 0, m32: 0, m33: 1)))
        
        mat2 = mat.transposed()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-16, -12, -8, -4],
                                [15, 11, 7, 3],
                                [-14, -10, -6, -2],
                                [13, 9, 5, 1]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 6,
                m30: -6, m31: 3, m32: -2, m33: 2)
        mat2 = mat.inverse()
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(lst: [[-1.0/2.0, 1.0/2.0, 1.0/2.0, -1.0/2.0],
                                [-5.0/2.0, 5.0/2.0, 2.0, -1.0],
                                [-5.0/4.0, 1.0/4.0, 5.0/2.0, -1.0/2.0],
                                [1.0, -2.0, 1.0, 0.0]])))
    }
    
    func testSetterOperatorOverloadings() {
        var mat = Matrix4x4D(
            m00: -16, m01: 15, m02: -14, m03: 13,
            m10: -12, m11: 11, m12: -10, m13: 9,
            m20: -8, m21: 7, m22: -6, m23: 5,
            m30: -6, m31: 3, m32: -2, m33: 1)
        var mat2 = Matrix4x4D()
        
        mat2 = mat
        XCTAssertTrue(mat2.isSimilar(
            m: Matrix4x4D(
                m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)))
        
        mat += 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-14, 17, -12, 15],
                                [-10, 13, -8, 11],
                                [-6, 9, -4, 7],
                                [-4, 5, 0, 3]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat +=
            Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                       m10: 5, m11: 6, m12: 7, m13: 8,
                       m20: 9, m21: 10, m22: 11, m23: 12,
                       m30: 13, m31: 14, m32: 15, m33: 16)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-15, 17, -11, 17],
                                [-7, 17, -3, 17],
                                [1, 17, 5, 17],
                                [7, 17, 13, 17]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat -= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst: [[-18, 13, -16, 11],
                                [-14, 9, -12, 7],
                                [-10, 5, -8, 3],
                                [-8, 1, -4, -1]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat -=
            Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                       m10: 5, m11: 6, m12: 7, m13: 8,
                       m20: 9, m21: 10, m22: 11, m23: 12,
                       m30: 13, m31: 14, m32: 15, m33: 16)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst:  [[-17, 13, -17, 9],
                                 [-17, 5, -17, 1],
                                 [-17, -3, -17, -7],
                                 [-19, -11, -17, -15]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat *= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst:  [[-32, 30, -28, 26],
                                 [-24, 22, -20, 18],
                                 [-16, 14, -12, 10],
                                 [-12, 6, -4, 2]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat *=
            Matrix4x4D(m00: 1, m01: 2, m02: 3, m03: 4,
                       m10: 5, m11: 6, m12: 7, m13: 8,
                       m20: 9, m21: 10, m22: 11, m23: 12,
                       m30: 13, m31: 14, m32: 15, m33: 16)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst:  [[102, 100, 98, 96],
                                 [70, 68, 66, 64],
                                 [38, 36, 34, 32],
                                 [4, 0, -4, -8]])))
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -6, m31: 3, m32: -2, m33: 1)
        mat /= 2.0
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(lst:  [[-8.0, 15.0/2.0, -7.0, 13.0/2.0],
                                 [-6.0, 11.0/2.0, -5.0, 9.0/2.0],
                                 [-4.0, 7.0/2.0, -3.0, 5.0/2.0],
                                 [-3.0, 3.0/2.0, -1.0, 1.0/2.0]])))
    }
    
    func testGetterOperatorOverloadings() {
        var mat = Matrix4x4D(
            m00: -16, m01: 15, m02: -14, m03: 13,
            m10: -12, m11: 11, m12: -10, m13: 9,
            m20: -8, m21: 7, m22: -6, m23: 5,
            m30: -4, m31: 3, m32: -2, m33: 1)
        
        var sign:Double = -1.0
        for i in 0..<16 {
            XCTAssertEqual(sign * Double((16 - i)), mat[i/4, i%4])
            sign *= -1.0
            
            mat[i/4, i%4] *= -1.0
        }
        
        sign = 1.0
        for i in 0..<16 {
            XCTAssertEqual(sign * Double((16 - i)), mat[i/4, i%4])
            sign *= -1.0
        }
        
        sign = 1.0
        for i in 0..<4 {
            for j in 0..<4 {
                XCTAssertEqual(sign * Double(16 - (4 * i + j)), mat[i, j])
                sign *= -1.0
            }
        }
        
        mat.set(m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -4, m31: 3, m32: -2, m33: 1)
        XCTAssertTrue(
            mat == Matrix4x4D(
                m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -4, m31: 3, m32: -2, m33: 1))
        
        mat.set(m00: 16, m01: -15, m02: 14, m03: -13,
                m10: 12, m11: -11, m12: 10, m13: -9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -4, m31: 3, m32: -2, m33: 1)
        XCTAssertTrue(
            mat != Matrix4x4D(
                m00: -16, m01: 15, m02: -14, m03: 13,
                m10: -12, m11: 11, m12: -10, m13: 9,
                m20: -8, m21: 7, m22: -6, m23: 5,
                m30: -4, m31: 3, m32: -2, m33: 1))
    }
    
    func testHelpers() {
        var mat = Matrix4x4D.makeZero()
        for i in 0..<16 {
            XCTAssertEqual(0.0, mat[i/4, i%4])
        }
        
        mat = Matrix4x4D.makeIdentity()
        for i in 0..<4 {
            for j in 0..<4 {
                if (i == j) {
                    XCTAssertEqual(1.0, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat = Matrix4x4D.makeScaleMatrix(sx: 3.0, sy: -4.0, sz: 2.4)
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(m00: 3.0, m01: 0.0, m02: 0.0, m03: 0.0,
                          m10: 0.0, m11: -4.0, m12: 0.0, m13: 0.0,
                          m20: 0.0, m21: 0.0, m22: 2.4, m23: 0.0,
                          m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)))
        
        mat = Matrix4x4D.makeScaleMatrix(s: Vector3D(-2.0, 5.0, 3.5))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(m00: -2.0, m01: 0.0, m02: 0.0, m03: 0.0,
                          m10: 0.0, m11: 5.0, m12: 0.0, m13: 0.0,
                          m20: 0.0, m21: 0.0, m22: 3.5, m23: 0.0,
                          m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)))
        
        mat = Matrix4x4D.makeRotationMatrix(
            axis: Vector3D(-1.0/3.0, 2.0/3.0, 2.0/3.0), rad: -74.0 / 180.0 * kPiD)
        XCTAssertTrue(mat.isSimilar(m: Matrix4x4D(
            m00: 0.36, m01: 0.48, m02: -0.8, m03: 0,
            m10: -0.8, m11: 0.60, m12: 0.0, m13: 0,
            m20: 0.48, m21: 0.64, m22: 0.6, m23: 0,
            m30: 0, m31: 0, m32: 0, m33: 1), tol: 0.05))
        
        mat = Matrix4x4D.makeTranslationMatrix(t: Vector3D(-2.0, 5.0, 3.5))
        XCTAssertTrue(mat.isSimilar(
            m: Matrix4x4D(m00: 1.0, m01: 0.0, m02: 0.0, m03: -2.0,
                          m10: 0.0, m11: 1.0, m12: 0.0, m13: 5.0,
                          m20: 0.0, m21: 0.0, m22: 1.0, m23: 3.5,
                          m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)))
    }
    
}
