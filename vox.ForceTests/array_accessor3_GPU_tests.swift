//
//  array_accessor3_GPU_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor3_GPU_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParallelForEachIndex() throws {
        var arr1 = Array3<Float>(size: Size3(10, 10, 10))
        arr1.parallelForEachIndex(name: "testParallelForEachIndex3") {
            (_:inout MTLComputeCommandEncoder) in
        }
        
        let acc = arr1.accessor()
        acc.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let ans = i + 10 * (j + 10 * k)
            XCTAssertEqual(ans, Int(acc[i, j, k]))
        }
    }
}
