//
//  grid_single_phase_pressure_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_single_phase_pressure_solver2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSolveSinglePhase() throws {
        var vel = FaceCenteredGrid2(resolutionX: 3, resolutionY: 3)
        
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
        
        let solver = GridSinglePhasePressureSolver2()
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel,
                     boundarySdf: ConstantScalarField2(value: Float.greatestFiniteMagnitude),
                     boundaryVelocity: ConstantVectorField2(value: [0, 0]),
                     fluidSdf: ConstantScalarField2(value: -Float.greatestFiniteMagnitude))
        
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
        for j in 0..<2 {
            for i in 0..<3 {
                XCTAssertEqual(pressure[i, j + 1] - pressure[i, j], -1.0, accuracy: 1e-6)
            }
        }
    }
    
    func testSolveSinglePhaseWithBoundary() {
        var vel = FaceCenteredGrid2(resolutionX: 3, resolutionY: 3)
        let boundarySdf = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3)
        
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
        
        // Wall on the right-most column
        boundarySdf.fill(){(x:Vector2F)->Float in
            return -x.x + 2.0
        }
        
        let solver = GridSinglePhasePressureSolver2()
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel, boundarySdf: boundarySdf)
        
        for j in 0..<3 {
            for i in 0..<4 {
                XCTAssertEqual(0.0, vel.u(i: i, j: j), accuracy: 1e-6)
            }
        }
        
        for j in 0..<4 {
            for i in 0..<3 {
                if (i == 2 && (j == 1 || j == 2)) {
                    XCTAssertEqual(1.0, vel.v(i: i, j: j), accuracy: 1e-6)
                } else {
                    XCTAssertEqual(0.0, vel.v(i: i, j: j), accuracy: 1e-6)
                }
            }
        }
        
        let pressure = solver.pressure()
        for j in 0..<2 {
            for i in 0..<2 {
                XCTAssertEqual(pressure[i, j + 1] - pressure[i, j], -1.0, accuracy: 1e-6)
            }
        }
    }
    
    func testSolveFreeSurface() {
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
        
        let solver = GridSinglePhasePressureSolver2()
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
        for j in 0..<3 {
            for i in 0..<3 {
                let p = Float(2 - j)
                XCTAssertEqual(p, pressure[i, j], accuracy: 1e-6)
            }
        }
    }
    
    func testSolveFreeSurfaceWithBoundary() {
        var vel = FaceCenteredGrid2(resolutionX: 3, resolutionY: 3)
        let fluidSdf = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3)
        let boundarySdf = CellCenteredScalarGrid2(resolutionX: 3, resolutionY: 3)
        
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
        
        // Wall on the right-most column
        boundarySdf.fill(){(x:Vector2F)->Float in
            return -x.x + 2.0
        }
        fluidSdf.fill(){(x:Vector2F)->Float in
            return x.y - 2.0
        }
        
        let solver = GridSinglePhasePressureSolver2()
        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel,
                     boundarySdf: boundarySdf, boundaryVelocity: ConstantVectorField2(value: [0, 0]),
                     fluidSdf: fluidSdf)
        
        for j in 0..<3 {
            for i in 0..<4 {
                XCTAssertEqual(0.0, vel.u(i: i, j: j), accuracy: 1e-6)
            }
        }
        
        for j in 0..<4 {
            for i in 0..<3 {
                if (i == 2 && (j == 1 || j == 2)) {
                    XCTAssertEqual(1.0, vel.v(i: i, j: j), accuracy: 1e-6)
                } else {
                    XCTAssertEqual(0.0, vel.v(i: i, j: j), accuracy: 1e-6)
                }
            }
        }
        
        let pressure = solver.pressure()
        for j in 0..<3 {
            for i in 0..<2 {
                let p = Float(2 - j)
                XCTAssertEqual(p, pressure[i, j], accuracy: 1e-6)
            }
        }
    }
    
//    func testSolveSinglePhaseWithMg() {
//        let n:size_t = 64
//        var vel = FaceCenteredGrid2(resolutionX: n, resolutionY: n)
//
//        for j in 0..<n {
//            for i in 0..<n+1 {
//                vel.u(i: i, j: j, val: 0.0)
//            }
//        }
//
//        for j in 0..<n+1 {
//            for i in 0..<n {
//                if (j == 0 || j == n) {
//                    vel.v(i: i, j: j, val: 0.0)
//                } else {
//                    vel.v(i: i, j: j, val: 1.0)
//                }
//            }
//        }
//
//        let solver = GridSinglePhasePressureSolver2()
//        solver.setLinearSystemSolver(solver: FdmMgSolver2(maxNumberOfLevels: 5,
//                                                          numberOfRestrictionIter: 10,
//                                                          numberOfCorrectionIter: 10,
//                                                          numberOfCoarsestIter: 40,
//                                                          numberOfFinalIter: 10))
//
//        solver.solve(input: vel, timeIntervalInSeconds: 1.0, output: &vel)
//
//        for j in 0..<n {
//            for i in 0..<n+1 {
//                XCTAssertEqual(0.0, vel.u(i: i, j: j), accuracy: 0.01)
//            }
//        }
//
//        for j in 0..<n+1 {
//            for i in 0..<n {
//                XCTAssertEqual(0.0, vel.v(i: i, j: j), accuracy: 0.05)
//            }
//        }
//    }
}
