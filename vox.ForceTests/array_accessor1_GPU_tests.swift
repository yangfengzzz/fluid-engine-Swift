//
//  array_accessor1_GPU_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor1_GPU_tests: XCTestCase {

    override func setUpWithError() throws {
        _ = Renderer()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParallelForEachIndex() throws {
        var arr1 = Array1<Float>(size: 200)
        arr1.parallelForEachIndex(name: "testParallelForEachIndex") {
            (_:inout MTLComputeCommandEncoder, _:inout Int) in
        }
        
        let acc = arr1.accessor()
        acc.forEachIndex(){(i:size_t) in
            let ans:Float = Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
}
