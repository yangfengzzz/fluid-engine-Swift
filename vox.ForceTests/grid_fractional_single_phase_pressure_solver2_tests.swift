//
//  grid_fractional_single_phase_pressure_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_fractional_single_phase_pressure_solver2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolveFreeSurface() throws {
        var vel = FaceCenteredGrid2(resolutionX: 3, resolutionY: 3)
        let fluidSdf = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3)
        
        for j in 0..<3 {
            for i in 0..<4 {
                vel.u(i: i, j: j, val: 0.0)
            }
        }
        
        for j in 0..<4 {
            for i in 0..<3 {
                if (j == 0 || j == 3) {
                    vel.v(i: i, j: j, val: 0.0)
                } else {
                    vel.v(i: i, j: j, val: 1.0)
                }
            }
        }
        
        fluidSdf.fill(){(x:Vector2F)->Float in
            return x.y - 2.0
        }
        
        let solver = GridFractionalSinglePhasePressureSolver2()
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel,
                     boundarySdf: ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                     boundaryVelocity: ConstantVectorField2(value: [0, 0]), fluidSdf: fluidSdf)
        
        for j in 0..<3 {
            for i in 0..<4 {
                XCTAssertEqual(0.0, vel.u(i: i, j: j), accuracy: 1e-6)
            }
        }
        
        for j in 0..<4 {
            for i in 0..<3 {
                XCTAssertEqual(0.0, vel.v(i: i, j: j), accuracy: 1e-6)
            }
        }
        
        let pressure = solver.pressure()
        for i in 0..<3 {
            XCTAssertEqual(1.5, pressure[i, 0], accuracy: 1e-6)
            XCTAssertEqual(0.5, pressure[i, 1], accuracy: 1e-6)
            XCTAssertEqual(0.0, pressure[i, 2], accuracy: 1e-6)
        }
    }
    
    func testSolveFreeSurfaceMg() {
        var vel = FaceCenteredGrid2(resolutionX: 32, resolutionY: 32)
        let fluidSdf = CellCenteredScalarGrid2(resolutionX: 32, resolutionY: 32)
        
        for j in 0..<32 {
            for i in 0..<33 {
                vel.u(i: i, j: j, val: 0.0)
            }
        }
        
        for j in 0..<33 {
            for i in 0..<32 {
                if (j == 0 || j == 32) {
                    vel.v(i: i, j: j, val: 0.0)
                } else {
                    vel.v(i: i, j: j, val: 1.0)
                }
            }
        }
        
        fluidSdf.fill(){(x:Vector2F)->Float in
            return x.y - 16.0
        }
        
        let solver = GridFractionalSinglePhasePressureSolver2()
        solver.setLinearSystemSolver(solver: FdmMgSolver2(maxNumberOfLevels: 5,
                                                          numberOfRestrictionIter: 50,
                                                          numberOfCorrectionIter: 50,
                                                          numberOfCoarsestIter: 50,
                                                          numberOfFinalIter: 50))
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel,
                     boundarySdf: ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                     boundaryVelocity: ConstantVectorField2(value: [0, 0]), fluidSdf: fluidSdf)
        
        for j in 0..<32 {
            for i in 0..<33 {
                XCTAssertEqual(0.0, vel.u(i: i, j: j), accuracy: 0.002)
            }
        }
        
        for j in 0..<16 {
            for i in 0..<32 {
                XCTAssertEqual(0.0, vel.v(i: i, j: j), accuracy: 0.002)
            }
        }
        
        let pressure = solver.pressure()
        for j in 0..<32 {
            for i in 0..<17 {
                if (j < 16) {
                    XCTAssertEqual(15.5 - Float(j), pressure[i, j], accuracy: 0.1)
                } else {
                    XCTAssertEqual(0.0, pressure[i, j], accuracy: 0.1)
                }
            }
        }
    }
}
