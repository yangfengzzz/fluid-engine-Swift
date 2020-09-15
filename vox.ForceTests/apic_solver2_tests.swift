//
//  apic_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class apic_solver2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdateEmpty() throws {
        let solver = ApicSolver2()
        
        var frame = Frame()
        for _ in 0..<2 {
            solver.update(frame: frame)
            frame.advance()
        }
    }
}
