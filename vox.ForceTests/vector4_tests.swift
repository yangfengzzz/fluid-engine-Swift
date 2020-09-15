//
//  vector4_tests.swift
//  vox.0orceTests
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vector4_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicGetterMethods() throws {
        let vec = Vector4F(3.0, 7.0, -1.0, 11.0)
        var vec2 = Vector4F(-3.0, -7.0, 1.0, 4.0)
        let vec3 = Vector4F(3.0, 1.0, -5.0, 4.0)
        let vec4 = Vector4F(-3.0, 2.0, 1.0, -4.0)
        
        XCTAssertEqual(20.0, vec.sum())
        XCTAssertEqual(5.0, vec.avg)
        XCTAssertEqual(-1.0, vec.min())
        XCTAssertEqual(11.0, vec.max())
        XCTAssertEqual(1.0, vec2.absmin)
        XCTAssertEqual(-7.0, vec2.absmax)
        XCTAssertEqual(2, vec3.dominantAxis)
        XCTAssertEqual(2, vec4.subminantAxis)
        
        let eps:Float = 1.0e-6
        vec2 = normalize(vec)
        XCTAssertTrue(vec2.x * vec2.x + vec2.y * vec2.y + vec2.z * vec2.z + vec2.w * vec2.w - 1.0 < eps)
        
        vec2 *= 2.0
        XCTAssertTrue(length(vec2) - 2.0 < eps)
        XCTAssertTrue(length_squared(vec2) - 4.0 < eps)
    }

}
