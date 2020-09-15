//
//  plane3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class plane3_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuilder() {
        let plane = Plane3.builder()
            .withNormal(normal: [1, 0, 0])
            .withPoint(point: [2, 3, 4])
        .build()
        
        XCTAssertEqual(Vector3F(1, 0, 0), plane.normal)
        XCTAssertEqual(Vector3F(2, 3, 4), plane.point)
    }

}
