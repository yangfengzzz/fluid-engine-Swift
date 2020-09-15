//
//  array_accessor2_GPU_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor2_GPU_tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParallelForEachIndex() throws {
        var arr1 = Array2<Float>(size: Size2(10, 10))
        arr1.parallelForEachIndex(name: "testParallelForEachIndex2") {
            (_:inout MTLComputeCommandEncoder) in
        }

        let acc = arr1.accessor()
        acc.forEachIndex(){(i:size_t, j:size_t) in
            let ans = i + 10 * j
            XCTAssertEqual(ans, Int(arr1[i, j]))
        }
    }
    
    func testGridLoader() {
        let grid1 = CellCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                            gridSpacingX: 1.0, gridSpacingY: 2.0,
                                            originX: 3.0, originY: 4.0, initialValue: 5.0)
        var array1 = Array2<Float>(size: Size2(5, 4))
        array1.parallelForEachIndex(name: "testGridLoader") { (encoder:inout MTLComputeCommandEncoder) in
            _ = grid1.loadGPUBuffer(encoder: &encoder, index_begin: 1)
        }
        
        for i in 0..<5 {
            for j in 0..<4 {
                XCTAssertEqual(grid1.dataAccessor().at(i: i, j: j)!, array1[i, j])
            }
        }
    }
}
