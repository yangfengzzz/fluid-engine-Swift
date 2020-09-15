//
//  plane2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class plane2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBuilder() {
        let plane = Plane2.builder()
            .withNormal(normal: [1, 0])
            .withPoint(point: [2, 3])
            .build()
        
        XCTAssertEqual(Vector2F(1, 0), plane.normal)
        XCTAssertEqual(Vector2F(2, 3), plane.point)
    }
    
}
