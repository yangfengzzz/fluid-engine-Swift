//
//  fdm_gauss_seidel_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_gauss_seidel_solver3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSolveLowRes() throws {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system, size: [3, 3, 3])
        
        let solver = FdmGaussSeidelSolver3(maxNumberOfIterations: 100,
                                           residualCheckInterval: 10, tolerance: 1e-6)
        _ = solver.solve(system: &system)
        
        XCTAssertGreaterThan(solver.tolerance(), solver.lastResidual())
    }
    
    func testSolve() {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system,
                                                               size: [32, 32, 32])
        
        var buffer = FdmVector3(other: system.x)
        FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
        let norm0 = FdmBlas3.l2Norm(v: buffer)
        
        let solver = FdmGaussSeidelSolver3(maxNumberOfIterations: 100,
                                           residualCheckInterval: 10, tolerance: 1e-9)
        _ = solver.solve(system: &system)
        
        FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
        let norm1 = FdmBlas3.l2Norm(v: buffer)
        
        XCTAssertLessThan(norm1, norm0)
    }
    
    func testRelax() {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system,
                                                               size: [32, 32, 32])
        
        var buffer = FdmVector3(other: system.x)
        FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
        var norm0 = FdmBlas3.l2Norm(v: buffer)
        
        for _ in 0..<200 {
            FdmGaussSeidelSolver3.relax(A: system.A, b: system.b, sorFactor: 1.0, x: &system.x)
            
            FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
            let norm = FdmBlas3.l2Norm(v: buffer)
            XCTAssertLessThan(norm, norm0)
            
            norm0 = norm
        }
    }
    
    func testRelaxRedBlack() {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system,
                                                               size: [32, 32, 32])
        
        var buffer = FdmVector3(other: system.x)
        FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
        var norm0 = FdmBlas3.l2Norm(v: buffer)
        
        for i in 0..<200 {
            FdmGaussSeidelSolver3.relaxRedBlack(A: system.A, b: system.b, sorFactor: 1.0,
                                                x: &system.x)
            
            FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &buffer)
            let norm = FdmBlas3.l2Norm(v: buffer)
            if (i > 0) {
                XCTAssertLessThan(norm, norm0)
            }
            
            norm0 = norm
        }
    }
}
