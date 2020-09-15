//
//  fdm_iccg_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_iccg_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolveLowRes() throws {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system, size: [3, 3, 3])
        
        let solver = FdmIccgSolver3(maxNumberOfIterations: 10, tolerance: 1e-4)
        _ = solver.solve(system: &system)
        
        XCTAssertGreaterThan(solver.tolerance(), solver.lastResidual())
    }
    
    func testSolve() {
        var system = FdmLinearSystem3()
        FdmLinearSystemSolverTestHelper3.buildTestLinearSystem(system: &system,
                                                               size: [32, 32, 32])
        
        let solver = FdmIccgSolver3(maxNumberOfIterations: 200, tolerance: 1e-3)
        XCTAssertTrue(solver.solve(system: &system))
    }
}
