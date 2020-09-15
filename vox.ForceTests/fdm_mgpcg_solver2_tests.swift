//
//  fdm_mgpcg_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_mgpcg_solver2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSolve() throws {
        let levels:size_t = 6
        var system = FdmMgLinearSystem2()
        system.resizeWithCoarsest(coarsestResolution: [4, 4], numberOfLevels: levels)
        
        // Simple Poisson eq.
        for l in 0..<system.numberOfLevels() {
            let invdx:Float = pow(Float(0.5), Float(l))
            var A = system.A[l]
            var b = system.b[l]
            
            system.x[l].set(value: 0)
            
            A.forEachIndex(){(i:size_t, j:size_t) in
                if (i > 0) {
                    A[i, j].center += invdx * invdx
                }
                if (i < A.width() - 1) {
                    A[i, j].center += invdx * invdx
                    A[i, j].right -= invdx * invdx
                }
                
                if (j > 0) {
                    A[i, j].center += invdx * invdx
                } else {
                    b[i, j] += invdx
                }
                
                if (j < A.height() - 1) {
                    A[i, j].center += invdx * invdx
                    A[i, j].up -= invdx * invdx
                } else {
                    b[i, j] -= invdx
                }
            }
        }
        
        let solver = FdmMgpcgSolver2(numberOfCgIter: 200,
                                     maxNumberOfLevels: levels,
                                     numberOfRestrictionIter: 5,
                                     numberOfCorrectionIter: 5,
                                     numberOfCoarsestIter: 10,
                                     numberOfFinalIter: 10,
                                     maxTolerance: 1e-4)
        XCTAssertTrue(solver.solve(system: &system))
    }
}
