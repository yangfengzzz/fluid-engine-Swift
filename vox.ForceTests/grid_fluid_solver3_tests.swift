//
//  grid_fluid_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_fluid_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructor() throws {
        let solver = GridFluidSolver3()
        
        // Check if the sub-step solvers are present
        XCTAssertTrue(solver.advectionSolver() != nil)
        XCTAssertTrue(solver.diffusionSolver() != nil)
        XCTAssertTrue(solver.pressureSolver() != nil)
        
        // Check default parameters
        XCTAssertGreaterThanOrEqual(solver.viscosityCoefficient(), 0.0)
        XCTAssertGreaterThan(solver.maxCfl(), 0.0)
        XCTAssertEqual(kDirectionAll, solver.closedDomainBoundaryFlag())
        
        // Check grid system data
        XCTAssertEqual(1, solver.gridSystemData().resolution().x)
        XCTAssertEqual(1, solver.gridSystemData().resolution().y)
        XCTAssertEqual(1, solver.gridSystemData().resolution().z)
        XCTAssertTrue(solver.gridSystemData().velocity() === solver.velocity())
        
        // Collider should be null
        XCTAssertTrue(solver.collider() == nil)
    }
    
    func testResizeGridSystemData() {
        let solver = GridFluidSolver3()
        
        solver.resizeGrid(
            newSize: Size3(1, 2, 3),
            newGridSpacing: Vector3F(4.0, 5.0, 6.0),
            newGridOrigin: Vector3F(7.0, 8.0, 9.0))
        
        XCTAssertEqual(1, solver.resolution().x)
        XCTAssertEqual(2, solver.resolution().y)
        XCTAssertEqual(3, solver.resolution().z)
        XCTAssertEqual(4.0, solver.gridSpacing().x)
        XCTAssertEqual(5.0, solver.gridSpacing().y)
        XCTAssertEqual(6.0, solver.gridSpacing().z)
        XCTAssertEqual(7.0, solver.gridOrigin().x)
        XCTAssertEqual(8.0, solver.gridOrigin().y)
        XCTAssertEqual(9.0, solver.gridOrigin().z)
    }
    
    func testMinimumResolution() {
        let solver = GridFluidSolver3()
        
        solver.resizeGrid(newSize: Size3(1, 1, 1),
                          newGridSpacing: Vector3F(1.0, 1.0, 1.0),
                          newGridOrigin: Vector3F())
        solver.velocity().fill(value: Vector3F())
        
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        frame.timeIntervalInSeconds = 0.01
        solver.update(frame: frame)
    }
    
    func testGravityOnly() {
        let solver = GridFluidSolver3()
        solver.setGravity(newGravity: Vector3F(0, -10, 0.0))
        solver.setAdvectionSolver(newSolver: nil)
        solver.setDiffusionSolver(newSolver: nil)
        solver.setPressureSolver(newSolver: nil)
        
        solver.resizeGrid(
            newSize: Size3(3, 3, 3),
            newGridSpacing: Vector3F(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0),
            newGridOrigin: Vector3F())
        solver.velocity().fill(value: Vector3F())
        
        let frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 0.01)
        solver.update(frame: frame)
        
        solver.velocity().forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(0.0, solver.velocity().u(i: i, j: j, k: k), accuracy: 1e-8)
        }
        
        solver.velocity().forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            if (j == 0 || j == 3) {
                XCTAssertEqual(0.0, solver.velocity().v(i: i, j: j, k: k), accuracy: 1e-8)
            } else {
                XCTAssertEqual(-0.1, solver.velocity().v(i: i, j: j, k: k), accuracy: 1e-8)
            }
        }
        
        solver.velocity().forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(0.0, solver.velocity().w(i: i, j: j, k: k), accuracy: 1e-8)
        }
    }
}
