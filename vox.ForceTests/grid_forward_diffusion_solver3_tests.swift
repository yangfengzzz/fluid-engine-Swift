//
//  grid_forward_diffusion_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_forward_diffusion_solver3_tests: XCTestCase {
    
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
        
        let diffusionSolver = GridForwardEulerDiffusionSolver3()
        diffusionSolver.solve(source: src, diffusionCoefficient: 1.0 / 12.0,
                              timeIntervalInSeconds: 1.0, dest: &dst)
        
        XCTAssertEqual(1.0/12.0, dst[1, 1, 0])
        XCTAssertEqual(1.0/12.0, dst[0, 1, 1])
        XCTAssertEqual(1.0/12.0, dst[1, 0, 1])
        XCTAssertEqual(1.0/12.0, dst[2, 1, 1])
        XCTAssertEqual(1.0/12.0, dst[1, 2, 1])
        XCTAssertEqual(1.0/12.0, dst[1, 1, 2])
        XCTAssertEqual(1.0/2.0,  dst[1, 1, 1])
    }
}
