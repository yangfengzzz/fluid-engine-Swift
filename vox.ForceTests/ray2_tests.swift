//
//  ray2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class ray2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let ray = Ray2D()
        XCTAssertEqual(Vector2D(), ray.origin)
        XCTAssertEqual(Vector2D(1, 0), ray.direction)
        
        let ray2 = Ray2D(newOrigin: [1, 2], newDirection: [3, 4])
        XCTAssertEqual(Vector2D(1, 2), ray2.origin)
        XCTAssertEqual(normalize(Vector2D(3, 4)), ray2.direction)
        
        let ray3 = Ray2D(other: ray2)
        XCTAssertEqual(Vector2D(1, 2), ray3.origin)
        XCTAssertEqual(normalize(Vector2D(3, 4)), ray3.direction)
    }
    
    func testPointAt() {
        let ray = Ray2D()
        XCTAssertEqual(Vector2D(4.5, 0.0), ray.pointAt(t: 4.5))
    }
    
}
