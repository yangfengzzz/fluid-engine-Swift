//
//  matrix2x2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class matrix2x2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let mat = matrix_double2x2()
        XCTAssertTrue(mat == matrix_double2x2(rows: [SIMD2<Double>(1.0, 0.0),
                                                     SIMD2<Double>(0.0, 1.0)]))
        
        let mat2 = matrix_double2x2(3.1)
        for i in 0..<2 {
            for j in 0..<2{
                XCTAssertEqual(3.1, mat2[i,j])
            }
        }
        
        let mat3 = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                           SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat3[0,0])
        XCTAssertEqual(2.0, mat3[0,1])
        XCTAssertEqual(3.0, mat3[1,0])
        XCTAssertEqual(4.0, mat3[1,1])
        
        let mat4 = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                           SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat4[0,0])
        XCTAssertEqual(2.0, mat4[0,1])
        XCTAssertEqual(3.0, mat4[1,0])
        XCTAssertEqual(4.0, mat4[1,1])
        
        let mat5 = mat4
        XCTAssertEqual(1.0, mat5[0,0])
        XCTAssertEqual(2.0, mat5[0,1])
        XCTAssertEqual(3.0, mat5[1,0])
        XCTAssertEqual(4.0, mat5[1,1])
    }
    
    func testSetMethods() {
        var mat = matrix_double2x2()
        
        mat = matrix_double2x2(3.1)
        for i in 0..<2 {
            for j in 0..<2{
                XCTAssertEqual(3.1, mat[i,j])
            }
        }
        
        mat = matrix_double2x2(0.0)
        mat = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                      SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat[0,0])
        XCTAssertEqual(2.0, mat[0,1])
        XCTAssertEqual(3.0, mat[1,0])
        XCTAssertEqual(4.0, mat[1,1])
        
        mat = matrix_double2x2(0.0)
        mat = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                      SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat[0,0])
        XCTAssertEqual(2.0, mat[0,1])
        XCTAssertEqual(3.0, mat[1,0])
        XCTAssertEqual(4.0, mat[1,1])
        
        mat = matrix_double2x2(0.0)
        mat = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                      SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat[0,0])
        XCTAssertEqual(2.0, mat[0,1])
        XCTAssertEqual(3.0, mat[1,0])
        XCTAssertEqual(4.0, mat[1,1])
        
        mat = matrix_double2x2(0.0)
        mat.columns.0[0] = 3.1
        mat.columns.1[1] = 3.1
        for i in 0..<2 {
            for j in 0..<2{
                if (i == j) {
                    XCTAssertEqual(3.1, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat = matrix_double2x2(0.0)
        mat.columns.0[1] = 4.2
        mat.columns.1[0] = 4.2
        for i in 0..<2 {
            for j in 0..<2{
                if (i != j) {
                    XCTAssertEqual(4.2, mat[i, j])
                } else {
                    XCTAssertEqual(0.0, mat[i, j])
                }
            }
        }
        
        mat = matrix_double2x2(0.0)
        mat = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                      SIMD2<Double>(3.0, 4.0)])
        XCTAssertEqual(1.0, mat[0,0])
        XCTAssertEqual(2.0, mat[0,1])
        XCTAssertEqual(3.0, mat[1,0])
        XCTAssertEqual(4.0, mat[1,1])
        
        mat = matrix_double2x2(0.0)
        mat = matrix_double2x2(Vector2D(1.0, 3.0),
                               Vector2D(2.0, 4.0))
        XCTAssertEqual(1.0, mat[0,0])
        XCTAssertEqual(2.0, mat[0,1])
        XCTAssertEqual(3.0, mat[1,0])
        XCTAssertEqual(4.0, mat[1,1])
    }
    
    func testBasicGetters() {
        let mat = matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                          SIMD2<Double>(3.0, 4.0)])
        let mat2 = matrix_double2x2(rows: [SIMD2<Double>(1.01, 2.01),
                                           SIMD2<Double>(2.99, 4.0)])
        
        XCTAssertTrue(simd_almost_equal_elements(mat, mat2, 0.02))
        XCTAssertFalse(simd_almost_equal_elements(mat, mat2, 0.001))
        XCTAssertTrue(mat.isSquare)
        XCTAssertEqual(2, mat.rows)
        XCTAssertEqual(2, mat.cols)
    }
    
    func testBinaryOperators() {
        let mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                          SIMD2<Double>(-2.0, 1.0)])
        var mat2 = matrix_double2x2()
        var vec = Vector2D()
        
        mat2 = simd_add(mat, matrix_double2x2(2.0))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-2.0, 5.0),
                                                                               SIMD2<Double>(0.0, 3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_add(mat, matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                     SIMD2<Double>(3.0, 4.0)]))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-3.0, 5.0),
                                                                               SIMD2<Double>(1.0, 5.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_sub(mat, matrix_double2x2(2.0))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-6.0, 1.0),
                                                                               SIMD2<Double>(-4.0, -1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_sub(mat, matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                     SIMD2<Double>(3.0, 4.0)]))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-5.0, 1.0),
                                                                               SIMD2<Double>(-5.0, -3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(mat, matrix_double2x2(2.0))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-8.0, 6.0),
                                                                               SIMD2<Double>(-4.0, 2.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        vec =  simd_mul(Vector2D(1, 2), mat)
        XCTAssertTrue(vec.isSimilar(other: Vector2D(2.0, 0.0)))
        
        mat2 = simd_mul(mat, matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                     SIMD2<Double>(3.0, 4.0)]))
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(5.0, 4.0),
                                                                               SIMD2<Double>(1.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(mat, matrix_double2x2(2.0).inverse)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-2.0, 1.5),
                                                                               SIMD2<Double>(-1.0, 0.5)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_add(matrix_double2x2(2.0), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-2.0, 5.0),
                                                                               SIMD2<Double>(0.0, 3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                SIMD2<Double>(3.0, 4.0)]), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-3.0, 5.0),
                                                                               SIMD2<Double>(1.0, 5.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_sub(matrix_double2x2(2.0), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(6.0, -1.0),
                                                                               SIMD2<Double>(4.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_sub(matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                SIMD2<Double>(3.0, 4.0)]), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(5.0, -1.0),
                                                                               SIMD2<Double>(5.0, 3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(matrix_double2x2(2.0), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-8.0, 6.0),
                                                                               SIMD2<Double>(-4.0, 2.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                                SIMD2<Double>(3.0, 4.0)]), mat)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-8.0, 5.0),
                                                                               SIMD2<Double>(-20.0, 13.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = simd_mul(mat, matrix_double2x2(2.0).inverse)
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-0.5, 2.0/3.0),
                                                                               SIMD2<Double>(-1.0, 2.0)]),
                                                 Double.leastNonzeroMagnitude))
    }
    
    func testModifiers() {
        var mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                          SIMD2<Double>(-2.0, 1.0)])
        
        mat = mat.transpose
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-4, -4),
                                                                              SIMD2<Double>(3.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat = mat.inverse
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(0.5, -1.5),
                                                                              SIMD2<Double>(1.0, -2.0)]),
                                                 Double.leastNonzeroMagnitude))
    }
    
    func testComplexGetters() {
        let mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                          SIMD2<Double>(-2.0, 1.0)])
        var mat2 = matrix_double2x2()
        
        XCTAssertEqual(-2.0, mat.sum)
        XCTAssertEqual(-0.5, mat.avg)
        XCTAssertEqual(-4.0, mat.min)
        XCTAssertEqual(3.0, mat.max)
        XCTAssertEqual(1.0, mat.absmin)
        XCTAssertEqual(-4.0, mat.absmax)
        XCTAssertEqual(-3.0, mat.trace)
        XCTAssertEqual(2.0, mat.determinant)
        
        mat2 = mat.diagonal
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-4.0, 0.0),
                                                                               SIMD2<Double>(0.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.offDiagonal
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(0.0, 3.0),
                                                                               SIMD2<Double>(-2.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        
        mat2 = mat.strictLowerTri
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(0.0, 0.0),
                                                                               SIMD2<Double>(-2.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.strictUpperTri
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(0.0, 3.0),
                                                                               SIMD2<Double>(0.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.lowerTri
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-4.0, 0.0),
                                                                               SIMD2<Double>(-2.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.upperTri
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                                                               SIMD2<Double>(0.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.transpose
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(-4.0, -2.0),
                                                                               SIMD2<Double>(3.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat2 = mat.inverse
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(0.5, -1.5),
                                                                               SIMD2<Double>(1.0, -2.0)]),
                                                 Double.leastNonzeroMagnitude))
    }
    
    func testSetterOperatorOverloadings() {
        var mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                          SIMD2<Double>(-2.0, 1.0)])
        
        let mat2 = -mat
        XCTAssertTrue(simd_almost_equal_elements(mat2, matrix_double2x2(rows: [SIMD2<Double>(4.0, -3.0),
                                                                               SIMD2<Double>(2.0, -1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat += matrix_double2x2(2.0)
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-2, 5.0),
                                                                              SIMD2<Double>(0.0, 3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat += matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                       SIMD2<Double>(3.0, 4.0)])
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-3.0, 5.0),
                                                                              SIMD2<Double>(1.0, 5.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat -= matrix_double2x2(2.0)
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-6.0, 1.0),
                                                                              SIMD2<Double>(-4.0, -1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat -= matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                       SIMD2<Double>(3.0, 4.0)])
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-5.0, 1.0),
                                                                              SIMD2<Double>(-5.0, -3.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat *= 2.0
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-8.0, 6.0),
                                                                              SIMD2<Double>(-4.0, 2.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat *= matrix_double2x2(rows: [SIMD2<Double>(1.0, 2.0),
                                       SIMD2<Double>(3.0, 4.0)])
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(5.0, 4.0),
                                                                              SIMD2<Double>(1.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        mat *= matrix_double2x2(2.0).inverse
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-2.0, 1.5),
                                                                              SIMD2<Double>(-1.0, 0.5)]),
                                                 Double.leastNonzeroMagnitude))
    }
    
    func testGetterOperatorOverloadings() {
        var mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                          SIMD2<Double>(-2.0, 1.0)])
        
        XCTAssertEqual(-4.0, mat[0,0])
        XCTAssertEqual(3.0, mat[0,1])
        XCTAssertEqual(-2.0, mat[1,0])
        XCTAssertEqual(1.0, mat[1,1])
        
        mat[0,0] = 4.0
        mat[0,1] = -3.0
        mat[1,0] = 2.0
        mat[1,1] = -1.0
        XCTAssertEqual(4.0, mat[0,0])
        XCTAssertEqual(-3.0, mat[0,1])
        XCTAssertEqual(2.0, mat[1,0])
        XCTAssertEqual(-1.0, mat[1,1])
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        XCTAssertEqual(-4.0, mat[0, 0])
        XCTAssertEqual(3.0, mat[0, 1])
        XCTAssertEqual(-2.0, mat[1, 0])
        XCTAssertEqual(1.0, mat[1, 1])
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                                                              SIMD2<Double>(-2.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                      SIMD2<Double>(-2.0, 1.0)])
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-4.0, 3.0),
                                                                              SIMD2<Double>(-2.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
    }
    
    func testHelpers() {
        var mat = matrix_double2x2()
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(0.0, 0.0),
                                                                              SIMD2<Double>(0.0, 0.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(1)
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(1.0, 0.0),
                                                                              SIMD2<Double>(0.0, 1.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(diagonal: SIMD2<Double>(3.0, -4.0))
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(3.0, 0.0),
                                                                              SIMD2<Double>(0.0, -4.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2(diagonal: SIMD2<Double>(-2.0, 5.0))
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(-2.0, 0.0),
                                                                              SIMD2<Double>(0.0, 5.0)]),
                                                 Double.leastNonzeroMagnitude))
        
        mat = matrix_double2x2.makeRotationMatrix(rad: kPiD / 3.0)
        XCTAssertTrue(simd_almost_equal_elements(mat, matrix_double2x2(rows: [SIMD2<Double>(0.5, -sqrt(3.0) / 2.0),
                                                                              SIMD2<Double>(sqrt(3.0) / 2.0, 0.5)]),
                                                 1.0e-15))
    }
}
