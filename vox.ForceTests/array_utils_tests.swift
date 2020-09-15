//
//  array_utils_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_utils_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testSetRange1() throws {
        var array0 = Array1<Float>(size: 5)
        setRange1(size: 5, value: 3.4, output: &array0)
        for i in 0..<5 {
            XCTAssertEqual(3.4, array0[i])
        }
        
        setRange1(begin: 2, end: 4, value: 4.2, output: &array0)
        for i in 2..<4 {
            XCTAssertEqual(4.2, array0[i])
        }
    }
    
    func testCopyRange1() {
        let array0 = Array1<Float>(lst: [1.0, 2.0, 3.0, 4.0, 5.0])
        var array1 = Array1<Float>(size: 5)
        
        copyRange1(input: array0, begin: 1, end: 3, output: &array1)
        for i in 1..<3 {
            XCTAssertEqual(array0[i], array1[i])
        }
        
        copyRange1(input: array0, size: 5, output: &array1)
        for i in 0..<5 {
            XCTAssertEqual(array0[i], array1[i])
        }
    }
    
    func testCopyRange2() {
        let array0 = Array2<Float>(lst: [[1.0, 2.0],
                                         [3.0, 4.0],
                                         [5.0, 6.0]])
        var array1 = Array2<Float>(width: 2, height: 3)
        
        copyRange2(input: array0, beginX: 0, endX: 1,
                   beginY: 2, endY: 3, output: &array1)
        for j in 2..<3 {
            for i in 0..<1 {
                XCTAssertEqual(array0[i, j], array1[i, j])
            }
        }
        
        copyRange2(input: array0, sizeX: 2, sizeY: 3, output: &array1)
        for j in 0..<3 {
            for i in 0..<2 {
                XCTAssertEqual(array0[i, j], array1[i, j])
            }
        }
    }
    
    func testCopyRange3() {
        let array0 = Array3<Float> (
            lst: [[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]],
                  [[7.0, 8.0], [9.0, 10.0], [11.0, 12.0]]])
        var array1 = Array3<Float>(width: 2, height: 3, depth: 2)
        
        copyRange3(input: array0, beginX: 0, endX: 1,
                   beginY: 2, endY: 3, beginZ: 1, endZ: 2, output: &array1)
        for k in 1..<2 {
            for j in 2..<3 {
                for i in 0..<1 {
                    XCTAssertEqual(array0[i, j, k], array1[i, j, k])
                }
            }
        }
        
        copyRange3(input: array0, sizeX: 2, sizeY: 3, sizeZ: 2, output: &array1)
        for k in 0..<2 {
            for j in 0..<3 {
                for i in 0..<2 {
                    XCTAssertEqual(array0[i, j, k], array1[i, j, k])
                }
            }
        }
    }
    
    func testExtrapolateToRegion2() {
        var data = Array2<Float>(width: 10, height: 12, initVal: 0.0)
        var valid = Array2<CChar>(width: 10, height: 12, initVal: 0)
        
        for j in 3..<10 {
            for i in 2..<6 {
                data[i, j] = Float(i + j * 10)
                valid[i, j] = 1
            }
        }
        
        var output = data.accessor()
        extrapolateToRegion(
            input: data.constAccessor(), valid: valid.constAccessor(),
            numberOfIterations: 6, output: &output)
        
        let dataAnswer = Array2<Float> (
            lst: [[32.0, 32.0, 32.0, 33.0, 34.0, 35.0, 35.0, 35.0, 35.0,  0.0],
                  [32.0, 32.0, 32.0, 33.0, 34.0, 35.0, 35.0, 35.0, 35.0, 35.0],
                  [32.0, 32.0, 32.0, 33.0, 34.0, 35.0, 35.0, 35.0, 35.0, 35.0],
                  [32.0, 32.0, 32.0, 33.0, 34.0, 35.0, 35.0, 35.0, 35.0, 35.0],
                  [42.0, 42.0, 42.0, 43.0, 44.0, 45.0, 45.0, 45.0, 45.0, 45.0],
                  [52.0, 52.0, 52.0, 53.0, 54.0, 55.0, 55.0, 55.0, 55.0, 55.0],
                  [62.0, 62.0, 62.0, 63.0, 64.0, 65.0, 65.0, 65.0, 65.0, 65.0],
                  [72.0, 72.0, 72.0, 73.0, 74.0, 75.0, 75.0, 75.0, 75.0, 75.0],
                  [82.0, 82.0, 82.0, 83.0, 84.0, 85.0, 85.0, 85.0, 85.0, 85.0],
                  [92.0, 92.0, 92.0, 93.0, 94.0, 95.0, 95.0, 95.0, 95.0, 95.0],
                  [92.0, 92.0, 92.0, 93.0, 94.0, 95.0, 95.0, 95.0, 95.0, 95.0],
                  [92.0, 92.0, 92.0, 93.0, 94.0, 95.0, 95.0, 95.0, 95.0, 95.0]
        ])
        
        for j in 0..<12 {
            for i in 0..<10 {
                XCTAssertEqual(dataAnswer[i, j], data[i, j])
            }
        }
    }
    
    func testExtrapolateToRegion3() {
        var data = Array3<Float>(width: 3, height: 4, depth: 5, initVal: 0.0)
        var valid = Array3<CChar>(width: 3, height: 4, depth: 5, initVal: 0)
        
        for k in 1..<4 {
            for j in 2..<3 {
                for i in 1..<2 {
                    data[i, j, k] = 42.0
                    valid[i, j, k] = 1
                }
            }
        }
        
        var output = data.accessor()
        extrapolateToRegion(
            input: data.constAccessor(), valid: valid.constAccessor(),
            numberOfIterations: 5, output: &output)
        
        for k in 0..<5 {
            for j in 0..<4 {
                for i in 0..<3 {
                    XCTAssertEqual(42.0, data[i, j, k])
                }
            }
        }
    }
}
