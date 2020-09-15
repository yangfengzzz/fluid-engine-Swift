//
//  flip_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class flip_solver3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdateEmpty() throws {
        let solver = FlipSolver3()
        
        var frame = Frame()
        for _ in 0..<2 {
            solver.update(frame: frame)
            frame.advance()
        }
    }
    
    func testPicBlendingFactor() {
        let solver = FlipSolver3()
        
        solver.setPicBlendingFactor(factor: 0.3)
        XCTAssertEqual(0.3, solver.picBlendingFactor())
        
        solver.setPicBlendingFactor(factor: 2.4)
        XCTAssertEqual(1.0, solver.picBlendingFactor())
        
        solver.setPicBlendingFactor(factor: -0.9)
        XCTAssertEqual(0.0, solver.picBlendingFactor())
    }
}
