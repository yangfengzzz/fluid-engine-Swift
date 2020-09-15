//
//  grid_blocked_boundary_condition_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_blocked_boundary_condition_solver2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClosedDomain() throws {
        let bndSolver = GridBlockedBoundaryConditionSolver2()
        let gridSize = Size2(10, 10)
        let gridSpacing = Vector2F(1.0, 1.0)
        let gridOrigin = Vector2F(-5.0, -5.0)
        
        bndSolver.updateCollider(newCollider: nil, gridSize: gridSize,
                                 gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var velocity = FaceCenteredGrid2(resolution: gridSize,
                                         gridSpacing: gridSpacing,
                                         origin: gridOrigin)
        velocity.fill(value: Vector2F(1.0, 1.0))
        
        bndSolver.constrainVelocity(velocity: &velocity)
        
        velocity.forEachUIndex(){(i:size_t, j:size_t) in
            if (i == 0 || i == gridSize.x) {
                XCTAssertEqual(0.0, velocity.u(i: i, j: j))
            } else {
                XCTAssertEqual(1.0, velocity.u(i: i, j: j))
            }
        }
        
        velocity.forEachVIndex(){(i:size_t, j:size_t) in
            if (j == 0 || j == gridSize.y) {
                XCTAssertEqual(0.0, velocity.v(i: i, j: j))
            } else {
                XCTAssertEqual(1.0, velocity.v(i: i, j: j))
            }
        }
    }
    
    func testOpenDomain() {
        let bndSolver = GridBlockedBoundaryConditionSolver2()
        let gridSize = Size2(10, 10)
        let gridSpacing = Vector2F(1.0, 1.0)
        let gridOrigin = Vector2F(-5.0, -5.0)
        
        // Partially open domain
        bndSolver.setClosedDomainBoundaryFlag(flag: kDirectionLeft | kDirectionUp)
        bndSolver.updateCollider(newCollider: nil, gridSize: gridSize,
                                 gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var velocity = FaceCenteredGrid2(resolution: gridSize,
                                         gridSpacing: gridSpacing, origin: gridOrigin)
        velocity.fill(value: Vector2F(1.0, 1.0))
        
        bndSolver.constrainVelocity(velocity: &velocity)
        
        velocity.forEachUIndex(){(i:size_t, j:size_t) in
            if (i == 0) {
                XCTAssertEqual(0.0, velocity.u(i: i, j: j))
            } else {
                XCTAssertEqual(1.0, velocity.u(i: i, j: j))
            }
        }
        
        velocity.forEachVIndex(){(i:size_t, j:size_t) in
            if (j == gridSize.y) {
                XCTAssertEqual(0.0, velocity.v(i: i, j: j))
            } else {
                XCTAssertEqual(1.0, velocity.v(i: i, j: j))
            }
        }
    }
}
