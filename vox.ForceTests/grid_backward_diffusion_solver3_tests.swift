//
//  grid_backward_diffusion_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_backward_diffusion_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolve() throws {
        let src = CellCenteredScalarGrid3(resolutionX: 3, resolutionY: 3, resolutionZ: 3,
                                          gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
                                          originX: 0.0, originY: 0.0, originZ: 0.0)
        var dst: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 3, resolutionY: 3, resolutionZ: 3,
                                                       gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
                                                       originX: 0.0, originY: 0.0, originZ: 0.0)
        
        src[1, 1, 1] = 1.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver3()
        diffusionSolver.solve(source: src, diffusionCoefficient: 1.0 / 12.0,
                              timeIntervalInSeconds: 1.0, dest: &dst)
        
        let solution = Array3<Float>(lst: [
            [
                [0.001058, 0.005291, 0.001058],
                [0.005291, 0.041270, 0.005291],
                [0.001058, 0.005291, 0.001058]
            ],
            [
                [0.005291, 0.041270, 0.005291],
                [0.041270, 0.680423, 0.041270],
                [0.005291, 0.041270, 0.005291]
            ],
            [
                [0.001058, 0.005291, 0.001058],
                [0.005291, 0.041270, 0.005291],
                [0.001058, 0.005291, 0.001058]
            ]
        ])
        
        dst.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(solution[i, j, k], dst[i, j, k], accuracy: 1e-6)
        }
    }
}
