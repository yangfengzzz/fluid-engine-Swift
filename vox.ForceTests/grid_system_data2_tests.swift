//
//  grid_system_data2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_system_data2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let grids1 = GridSystemData2()
        XCTAssertEqual(0, grids1.resolution().x)
        XCTAssertEqual(0, grids1.resolution().y)
        XCTAssertEqual(1.0, grids1.gridSpacing().x)
        XCTAssertEqual(1.0, grids1.gridSpacing().y)
        XCTAssertEqual(0.0, grids1.origin().x)
        XCTAssertEqual(0.0, grids1.origin().y)
        
        let grids2 = GridSystemData2(
            resolution: [32, 64],
            gridSpacing: [1.0, 2.0],
            origin: [-5.0, 4.5])
        
        XCTAssertEqual(32, grids2.resolution().x)
        XCTAssertEqual(64, grids2.resolution().y)
        XCTAssertEqual(1.0, grids2.gridSpacing().x)
        XCTAssertEqual(2.0, grids2.gridSpacing().y)
        XCTAssertEqual(-5.0, grids2.origin().x)
        XCTAssertEqual(4.5, grids2.origin().y)
        
        let grids3 = GridSystemData2(other: grids2)
        
        XCTAssertEqual(32, grids3.resolution().x)
        XCTAssertEqual(64, grids3.resolution().y)
        XCTAssertEqual(1.0, grids3.gridSpacing().x)
        XCTAssertEqual(2.0, grids3.gridSpacing().y)
        XCTAssertEqual(-5.0, grids3.origin().x)
        XCTAssertEqual(4.5, grids3.origin().y)
        
        XCTAssertTrue(grids2.velocity() !== grids3.velocity())
    }
}
