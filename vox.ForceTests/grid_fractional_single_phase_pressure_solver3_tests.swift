//
//  grid_fractional_single_phase_pressure_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_fractional_single_phase_pressure_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolveFreeSurface() throws {
        var vel = FaceCenteredGrid3(resolutionX: 3, resolutionY: 3, resolutionZ: 3)
        let fluidSdf = CellCenteredScalarGrid3(resolutionX: 3, resolutionY: 3, resolutionZ: 3)
        
        vel.fill(value: Vector3F())
        
        for k in 0..<3 {
            for j in 0..<4 {
                for i in 0..<3 {
                    if (j == 0 || j == 3) {
                        vel.v(i: i, j: j, k: k, val: 0.0)
                    } else {
                        vel.v(i: i, j: j, k: k, val: 1.0)
                    }
                }
            }
        }
        
        fluidSdf.fill(){(x:Vector3F)->Float in
            return x.y - 2.0
        }
        
        let solver = GridFractionalSinglePhasePressureSolver3()
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel,
                     boundarySdf: ConstantScalarField3(value: Float.greatestFiniteMagnitude),
                     boundaryVelocity: ConstantVectorField3(value: [0, 0, 0]), fluidSdf: fluidSdf)
        
        for k in 0..<3 {
            for j in 0..<3 {
                for i in 0..<4 {
                    XCTAssertEqual(0.0, vel.u(i: i, j: j, k: k), accuracy: 1e-6)
                }
            }
        }
        
        for k in 0..<3 {
            for j in 0..<4 {
                for i in 0..<3 {
                    XCTAssertEqual(0.0, vel.v(i: i, j: j, k: k), accuracy: 1e-6)
                }
            }
        }
        
        for k in 0..<4 {
            for j in 0..<3 {
                for i in 0..<3 {
                    XCTAssertEqual(0.0, vel.w(i: i, j: j, k: k), accuracy: 1e-6)
                }
            }
        }
        
        let pressure = solver.pressure()
        for k in 0..<3 {
            for j in 0..<2 {
                for i in 0..<3 {
                    let p = 1.5 - Float(j)
                    XCTAssertEqual(p, pressure[i, j, k], accuracy: 1e-6)
                }
            }
        }
    }
}
