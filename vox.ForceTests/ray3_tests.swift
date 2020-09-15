//
//  ray3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class ray3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let ray = Ray3D()
        XCTAssertEqual(Vector3D(), ray.origin)
        XCTAssertEqual(Vector3D(1, 0, 0), ray.direction)
        
        let ray2 = Ray3D(newOrigin: [1, 2, 3], newDirection: [4, 5, 6])
        XCTAssertEqual(Vector3D(1, 2, 3), ray2.origin)
        XCTAssertEqual(normalize(Vector3D(4, 5, 6)), ray2.direction)
        
        let ray3 = Ray3D(other: ray2)
        XCTAssertEqual(Vector3D(1, 2, 3), ray3.origin)
        XCTAssertEqual(normalize(Vector3D(4, 5, 6)), ray3.direction)
    }
    
    func testPointAt() {
        let ray = Ray3D()
        XCTAssertEqual(Vector3D(4.5, 0.0, 0.0), ray.pointAt(t: 4.5))
    }
    
}
