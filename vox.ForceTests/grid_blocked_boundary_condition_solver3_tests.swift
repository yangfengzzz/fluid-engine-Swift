//
//  grid_blocked_boundary_condition_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_blocked_boundary_condition_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClosedDomain() throws {
        let bndSolver = GridBlockedBoundaryConditionSolver3()
        let gridSize = Size3(10, 10, 10)
        let gridSpacing = Vector3F(1.0, 1.0, 1.0)
        let gridOrigin = Vector3F(-5.0, -5.0, -5.0)
        
        bndSolver.updateCollider(newCollider: nil, gridSize: gridSize,
                                 gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var velocity = FaceCenteredGrid3(resolution: gridSize,
                                         gridSpacing: gridSpacing, origin: gridOrigin)
        velocity.fill(value: Vector3F(1.0, 1.0, 1.0))
        
        bndSolver.constrainVelocity(velocity: &velocity)
        
        velocity.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            if (i == 0 || i == gridSize.x) {
                XCTAssertEqual(0.0, velocity.u(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.u(i: i, j: j, k: k))
            }
        }
        
        velocity.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            if (j == 0 || j == gridSize.y) {
                XCTAssertEqual(0.0, velocity.v(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.v(i: i, j: j, k: k))
            }
        }
        
        velocity.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            if (k == 0 || k == gridSize.z) {
                XCTAssertEqual(0.0, velocity.w(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.w(i: i, j: j, k: k))
            }
        }
    }
    
    func testOpenDomain() {
        let bndSolver = GridBlockedBoundaryConditionSolver3()
        let gridSize = Size3(10, 10, 10)
        let gridSpacing = Vector3F(1.0, 1.0, 1.0)
        let gridOrigin = Vector3F(-5.0, -5.0, -5.0)
        
        // Partially open domain
        bndSolver.setClosedDomainBoundaryFlag(
            flag: kDirectionLeft | kDirectionUp | kDirectionFront)
        bndSolver.updateCollider(newCollider: nil, gridSize: gridSize,
                                 gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var velocity = FaceCenteredGrid3(resolution: gridSize,
                                         gridSpacing: gridSpacing, origin: gridOrigin)
        velocity.fill(value: Vector3F(1.0, 1.0, 1.0))
        
        bndSolver.constrainVelocity(velocity: &velocity)
        
        velocity.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            if (i == 0) {
                XCTAssertEqual(0.0, velocity.u(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.u(i: i, j: j, k: k))
            }
        }
        
        velocity.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            if (j == gridSize.y) {
                XCTAssertEqual(0.0, velocity.v(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.v(i: i, j: j, k: k))
            }
        }
        
        velocity.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            if (k == gridSize.z) {
                XCTAssertEqual(0.0, velocity.w(i: i, j: j, k: k))
            } else {
                XCTAssertEqual(1.0, velocity.w(i: i, j: j, k: k))
            }
        }
    }
}
