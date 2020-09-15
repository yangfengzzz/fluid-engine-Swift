//
//  array2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        var arr = Array2<Float>()
        XCTAssertEqual(0, arr.width())
        XCTAssertEqual(0, arr.height())
        
        arr = Array2<Float>(size: Size2(3, 7))
        XCTAssertEqual(3, arr.width())
        XCTAssertEqual(7, arr.height())
        for i in 0..<21 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr = Array2<Float>(size: Size2(1, 9), initVal: 1.5)
        XCTAssertEqual(1, arr.width())
        XCTAssertEqual(9, arr.height())
        for i in 0..<9 {
            XCTAssertEqual(1.5, arr[i])
        }
        
        arr = Array2<Float>(width: 5, height: 2)
        XCTAssertEqual(5, arr.width())
        XCTAssertEqual(2, arr.height())
        for i in 0..<10 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr = Array2<Float>(width: 3, height: 4, initVal: 7.0)
        XCTAssertEqual(3, arr.width())
        XCTAssertEqual(4, arr.height())
        for i in 0..<12 {
            XCTAssertEqual(7.0, arr[i])
        }
        
        arr = Array2<Float>(lst:
            [[1.0,  2.0,  3.0,  4.0],
             [5.0,  6.0,  7.0,  8.0],
             [9.0, 10.0, 11.0, 12.0]])
        XCTAssertEqual(4, arr.width())
        XCTAssertEqual(3, arr.height())
        for i in 0..<12 {
            XCTAssertEqual(Float(i) + 1.0, arr[i])
        }
        
        arr = Array2<Float>(
            lst: [[1.0,  2.0,  3.0,  4.0],
                  [5.0,  6.0,  7.0,  8.0],
                  [9.0, 10.0, 11.0, 12.0]])
        let arr2 = Array2<Float>(other: arr)
        XCTAssertEqual(4, arr2.width())
        XCTAssertEqual(3, arr2.height())
        for i in 0..<12 {
            XCTAssertEqual(Float(i) + 1.0, arr2[i])
        }
    }
    
    func testClear() {
        var arr = Array2<Float>(
            lst: [[1.0,  2.0,  3.0,  4.0],
                  [5.0,  6.0,  7.0,  8.0],
                  [9.0, 10.0, 11.0, 12.0]])
        
        arr.clear()
        XCTAssertEqual(0, arr.width())
        XCTAssertEqual(0, arr.height())
    }
    
    func testResizeMethod() {
        var arr = Array2<Float>()
        arr.resize(size: Size2(2, 9))
        XCTAssertEqual(2, arr.width())
        XCTAssertEqual(9, arr.height())
        for i in 0..<18 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr.resize(size: Size2(8, 13), initVal: 4.0)
        XCTAssertEqual(8, arr.width())
        XCTAssertEqual(13, arr.height())
        for i in 0..<8 {
            for j in 0..<13 {
                if (i < 2 && j < 9) {
                    print("\(i), \(j)")
                    XCTAssertEqual(0.0, arr[i, j])
                } else {
                    XCTAssertEqual(4.0, arr[i, j])
                }
            }
        }
        
        arr = Array2<Float>()
        arr.resize(width: 7, height: 6)
        XCTAssertEqual(7, arr.width())
        XCTAssertEqual(6, arr.height())
        for i in 0..<42 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr.resize(width: 1, height: 9, initVal: 3.0)
        XCTAssertEqual(1, arr.width())
        XCTAssertEqual(9, arr.height())
        for i in 0..<1 {
            for j in 0..<9 {
                if (j < 6) {
                    XCTAssertEqual(0.0, arr[i, j])
                } else {
                    XCTAssertEqual(3.0, arr[i, j])
                }
            }
        }
    }
    
    func testAtMethod() {
        let values:[Float] = [ 0.0, 1.0, 2.0,
                               3.0, 4.0, 5.0,
                               6.0, 7.0, 8.0,
                               9.0, 10.0, 11.0 ]
        var arr = Array2<Float>(width: 4, height: 3)
        for i in 0..<12 {
            arr[i] = values[i]
        }
        
        // Test row-major
        XCTAssertEqual(0.0,  arr[0, 0])
        XCTAssertEqual(1.0,  arr[1, 0])
        XCTAssertEqual(2.0,  arr[2, 0])
        XCTAssertEqual(3.0,  arr[3, 0])
        XCTAssertEqual(4.0,  arr[0, 1])
        XCTAssertEqual(5.0,  arr[1, 1])
        XCTAssertEqual(6.0,  arr[2, 1])
        XCTAssertEqual(7.0,  arr[3, 1])
        XCTAssertEqual(8.0,  arr[0, 2])
        XCTAssertEqual(9.0,  arr[1, 2])
        XCTAssertEqual(10.0, arr[2, 2])
        XCTAssertEqual(11.0, arr[3, 2])
    }
    
    func testIterators() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0],
            [4.0, 5.0, 6.0],
            [7.0, 8.0, 9.0],
            [10.0, 11.0, 12.0] ])
        
        var cnt:Float = 1.0
        for elem in arr1 {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
        
        cnt = 1.0
        for elem in arr1 {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
    }
    
    func testForEach() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        
        var i:size_t = 0
        arr1.forEach{(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        
        arr1.forEachIndex{(i:size_t, j:size_t) in
            let idx = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
    
    func testParallelForEach() {
        var arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        
        arr1.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        arr1.forEachIndex(){(i:size_t, j:size_t) in
            let idx:size_t = i + (4 * j) + 1
            let ans:Float = 2.0 * Float(idx)
            XCTAssertEqual(ans, arr1[i, j])
        }
    }
    
    func testParallelForEachIndex() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        
        arr1.parallelForEachIndex(){(i:size_t, j:size_t) in
            let idx:size_t = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
}
