//
//  cg_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class cg_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCGSolve() throws {
        // Solve:
        // | 4 1 | |x|   |1|
        // | 1 3 | |y| = |2|
        
        let matrix = matrix_float2x2(rows: [SIMD2<Float>(4.0, 1.0),
                                            SIMD2<Float>(1.0, 3.0)])
        let rhs = Vector2F(1.0, 2.0)
        
        class BlasType : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector2F
            typealias MatrixType = matrix_float2x2
        }
        
        // Zero iteration should give proper residual from iteration data.
        var x = Vector2F()
        var r = Vector2F()
        var d = Vector2F()
        var q = Vector2F()
        var s = Vector2F()
        var lastNumIter:UInt = 0
        var lastResidualNorm:Float = 0
        
        var nullPrecondition = NullCgPreconditioner<BlasType>()
        pcg(A: matrix, b: rhs, maxNumberOfIterations: 0, tolerance: 0.0,
            M: &nullPrecondition, x: &x, r: &r, d: &d, q: &q, s: &s,
            lastNumberOfIterations: &lastNumIter,
            lastResidualNorm: &lastResidualNorm)
        
        XCTAssertEqual(0.0, x.x)
        XCTAssertEqual(0.0, x.y)
        
        XCTAssertEqual(sqrt(5.0), lastResidualNorm)
        XCTAssertEqual(0, lastNumIter)
        
        x = Vector2F()
        r = Vector2F()
        d = Vector2F()
        q = Vector2F()
        s = Vector2F()
        lastNumIter = 0
        lastResidualNorm = 0
        
        pcg(A: matrix, b: rhs, maxNumberOfIterations: 10, tolerance: 0.0,
            M: &nullPrecondition, x: &x, r: &r, d: &d, q: &q, s: &s,
            lastNumberOfIterations: &lastNumIter,
            lastResidualNorm: &lastResidualNorm)
        
        XCTAssertEqual(1.0 / 11.0, x.x)
        XCTAssertEqual(7.0 / 11.0, x.y)
        
        XCTAssertLessThan(lastResidualNorm, Float.leastNonzeroMagnitude)
        XCTAssertLessThanOrEqual(lastNumIter, 2)
    }
    
    func testPCGSolve() {
        // Solve:
        // | 4 1 | |x|   |1|
        // | 1 3 | |y| = |2|
        
        let matrix = matrix_float2x2(rows: [SIMD2<Float>(4.0, 1.0),
                                            SIMD2<Float>(1.0, 3.0)])
        let rhs = Vector2F(1.0, 2.0)
        
        class BlasFloat : Blas {
            typealias ScalarType = Float
            typealias VectorType = Vector2F
            typealias MatrixType = matrix_float2x2
        }
        
        struct DiagonalPreconditioner : PrecondTypeProtocol{
            typealias BlasType = BlasFloat
            
            var precond = Vector2F()
            
            mutating func build(matrix:matrix_float2x2) {
                precond.x = matrix[0, 0]
                precond.y = matrix[1, 1]
            }
            
            func solve(b:Vector2F, x:inout Vector2F) {
                x = b / precond
            }
        }
        
        var x = Vector2F()
        var r = Vector2F()
        var d = Vector2F()
        var q = Vector2F()
        var s = Vector2F()
        var lastNumIter:UInt = 0
        var lastResidualNorm:Float = 0
        var precond = DiagonalPreconditioner()
        
        precond.build(matrix: matrix)
        
        pcg(A: matrix, b: rhs, maxNumberOfIterations: 10, tolerance: 0.0,
            M: &precond, x: &x, r: &r, d: &d, q: &q, s: &s,
            lastNumberOfIterations: &lastNumIter,
            lastResidualNorm: &lastResidualNorm)
        
        XCTAssertEqual(1.0 / 11.0, x.x, accuracy: 1.0e-6)
        XCTAssertEqual(7.0 / 11.0, x.y)
        
        XCTAssertLessThan(lastResidualNorm, Float.leastNonzeroMagnitude)
        XCTAssertLessThanOrEqual(lastNumIter, 6)
    }
}
