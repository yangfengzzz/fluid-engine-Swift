//
//  fdm_jacobi_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_jacobi_solver2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolve() throws {
        var system = FdmLinearSystem2()
        FdmLinearSystemSolverTestHelper2.buildTestLinearSystem(system: &system, size: [3, 3])
        
        let solver = FdmJacobiSolver2(maxNumberOfIterations: 100,
                                      residualCheckInterval: 10, tolerance: 1e-9)
        _ = solver.solve(system: &system)
        
        XCTAssertGreaterThan(solver.tolerance(), solver.lastResidual())
    }
}
