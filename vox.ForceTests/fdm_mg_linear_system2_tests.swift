//
//  fdm_mg_linear_system2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_mg_linear_system2_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testResizeArrayWithFinest() throws {
        var levels:[Array2<Float>] = []
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: [100, 200],
                                          maxNumberOfLevels: 4, levels: &levels)
        
        XCTAssertEqual(3, levels.count)
        XCTAssertEqual(Size2(100, 200), levels[0].size())
        XCTAssertEqual(Size2(50, 100), levels[1].size())
        XCTAssertEqual(Size2(25, 50), levels[2].size())
        
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: [32, 16],
                                          maxNumberOfLevels: 6, levels: &levels)
        XCTAssertEqual(5, levels.count)
        XCTAssertEqual(Size2(32, 16), levels[0].size())
        XCTAssertEqual(Size2(16, 8), levels[1].size())
        XCTAssertEqual(Size2(8, 4), levels[2].size())
        XCTAssertEqual(Size2(4, 2), levels[3].size())
        XCTAssertEqual(Size2(2, 1), levels[4].size())
        
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: [16, 16],
                                          maxNumberOfLevels: 6, levels: &levels)
        XCTAssertEqual(5, levels.count)
    }
}
