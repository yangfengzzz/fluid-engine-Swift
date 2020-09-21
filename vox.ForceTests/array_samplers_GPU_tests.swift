//
//  array_samplers_GPU_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_samplers_GPU_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNearestArraySampler1() throws {
        var grid = Array1<Float>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        let output = Array1<Float>(lst: [ 10.0, 20.0, 30.0, 40.0 ])
        
        grid.parallelForEachIndex(name: "testNearestArraySampler1") {
            (encoder: inout MTLComputeCommandEncoder, _:inout Int) in
            encoder.setBuffer(output._data, offset: 0, index: 1)
        }
        
        XCTAssertLessThan(abs(output[0] - 1.0), 1e-9)
        XCTAssertLessThan(abs(output[1] - 3.0), 1e-9)
        XCTAssertLessThan(abs(output[2] - 4.0), 1e-9)
    }
}
