//
//  pci_sph_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class pci_sph_solver3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdateEmpty() throws {
        // Empty solver test
        let solver = PciSphSolver3()
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 0.01)
        solver.update(frame: frame)
        frame.advance()
        solver.update(frame: frame)
    }
    
    func testParameters() {
        let solver = PciSphSolver3()
        
        solver.setMaxDensityErrorRatio(ratio: 5.0)
        XCTAssertEqual(5.0, solver.maxDensityErrorRatio())
        
        solver.setMaxDensityErrorRatio(ratio: -1.0)
        XCTAssertEqual(0.0, solver.maxDensityErrorRatio())
        
        solver.setMaxNumberOfIterations(n: 10)
        XCTAssertEqual(10, solver.maxNumberOfIterations())
    }
}
