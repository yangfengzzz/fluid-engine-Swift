//
//  blas_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class blas_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSet() throws {
        var vec = Vector3F()
        
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        Blas3.set(s: 3.14, result: &vec)
        
        XCTAssertEqual(3.14, vec.x)
        XCTAssertEqual(3.14, vec.y)
        XCTAssertEqual(3.14, vec.z)
        
        let vec2 = Vector3F(5.1, 3.7, 8.2)
        Blas3.set(v: vec2, result: &vec)
        
        XCTAssertEqual(5.1, vec.x)
        XCTAssertEqual(3.7, vec.y)
        XCTAssertEqual(8.2, vec.z)
        
        var mat = matrix_float3x3()
        
        Blas3.set(s: 0.414, result: &mat)
        
        for i in 0..<3 {
            for j in 0..<3 {
                let elem = mat[i, j]
                XCTAssertEqual(0.414, elem)
            }
        }
        
        let mat2 = matrix_float3x3(rows: [SIMD3<Float>(1, 2, 3),
                                          SIMD3<Float>(4, 5, 6),
                                          SIMD3<Float>(7, 8, 9)])
        Blas3.set(m: mat2, result: &mat)
        var index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                //must care about col first
                XCTAssertEqual(Float(index + 1), mat[j, i])
                index += 1
            }
        }
    }
    
    func testDot() {
        let vec = Vector3F(1.0, 2.0, 3.0)
        let vec2 = Vector3F(4.0, 5.0, 6.0)
        
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        let result = Blas3.dot(a: vec, b: vec2)
        XCTAssertEqual(32.0, result)
    }
    
    func testAxpy() {
        var result = Vector3F()
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        Blas3.axpy(
            a: 2.5, x: Vector3F(1, 2, 3), y: Vector3F(4, 5, 6), result: &result)
        
        XCTAssertEqual(6.5, result.x)
        XCTAssertEqual(10.0, result.y)
        XCTAssertEqual(13.5, result.z)
    }
    
    func testMvm() {
        let mat = matrix_float3x3(rows: [SIMD3<Float>(1, 2, 3),
                                         SIMD3<Float>(4, 5, 6),
                                         SIMD3<Float>(7, 8, 9)])
        
        var result = Vector3F()
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        Blas3.mvm(
            m: mat, v: Vector3F(1, 2, 3), result: &result)
        
        XCTAssertEqual(14.0, result.x)
        XCTAssertEqual(32.0, result.y)
        XCTAssertEqual(50.0, result.z)
    }
    
    func testResidual() {
        let mat = matrix_float3x3(rows: [SIMD3<Float>(1, 2, 3),
                                         SIMD3<Float>(4, 5, 6),
                                         SIMD3<Float>(7, 8, 9)])
        
        var result = Vector3F()
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        Blas3.residual(
            a: mat, x: Vector3F(1, 2, 3), b: Vector3F(4, 5, 6), result: &result)
        
        XCTAssertEqual(-10.0, result.x)
        XCTAssertEqual(-27.0, result.y)
        XCTAssertEqual(-44.0, result.z)
    }
    
    func testL2Norm() {
        let vec = Vector3F(-1.0, 2.0, -3.0)
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        let result = Blas3.l2Norm(v: vec)
        XCTAssertEqual(sqrt(14.0), result)
    }
    
    func testLInfNorm() {
        let vec = Vector3F(-1.0, 2.0, -3.0)
        class Blas3 : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector3F
            typealias MatrixType = matrix_float3x3
        }
        let result = Blas3.lInfNorm(v: vec)
        XCTAssertEqual(3.0, result)
    }
}
