//
//  grid_backward_diffusion_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_backward_diffusion_solver2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolve() throws {
        let src = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3,
                                          gridSpacingX: 1.0, gridSpacingY: 1.0,
                                          originX: 0.0, originY: 0.0)
        var dst: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3,
                                                       gridSpacingX: 1.0, gridSpacingY: 1.0,
                                                       originX: 0.0, originY: 0.0)
        
        src[1, 1] = 1.0
        
        let diffusionSolver = GridBackwardEulerDiffusionSolver2()
        diffusionSolver.solve(source: src, diffusionCoefficient: 1.0 / 8.0,
                              timeIntervalInSeconds: 1.0, dest: &dst)
        
        let solution = Array2<Float>(lst: [
            [0.012987, 0.064935, 0.012987],
            [0.064935, 0.688312, 0.064935],
            [0.012987, 0.064935, 0.012987]
        ])
        
        dst.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(solution[i, j], dst[i, j], accuracy: 1e-6)
        }
    }
}
