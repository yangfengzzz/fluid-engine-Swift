//
//  array3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        var arr = Array3<Float>()
        XCTAssertEqual(0, arr.width())
        XCTAssertEqual(0, arr.height())
        XCTAssertEqual(0, arr.depth())
        
        arr = Array3<Float>(size: Size3(3, 7, 4))
        XCTAssertEqual(3, arr.width())
        XCTAssertEqual(7, arr.height())
        XCTAssertEqual(4, arr.depth())
        for i in 0..<84 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr = Array3<Float>(size: Size3(1, 9, 5), initVal: 1.5)
        XCTAssertEqual(1, arr.width())
        XCTAssertEqual(9, arr.height())
        XCTAssertEqual(5, arr.depth())
        for i in 0..<45 {
            XCTAssertEqual(1.5, arr[i])
        }
        
        arr = Array3<Float>(width: 5, height: 2, depth: 8)
        XCTAssertEqual(5, arr.width())
        XCTAssertEqual(2, arr.height())
        XCTAssertEqual(8, arr.depth())
        for i in 0..<80 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr = Array3<Float>(width: 3, height: 4, depth: 2, initVal: 7.0)
        XCTAssertEqual(3, arr.width())
        XCTAssertEqual(4, arr.height())
        XCTAssertEqual(2, arr.depth())
        for i in 0..<24 {
            XCTAssertEqual(7.0, arr[i])
        }
        
        arr = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        XCTAssertEqual(4, arr.width())
        XCTAssertEqual(3, arr.height())
        XCTAssertEqual(2, arr.depth())
        for i in 0..<24 {
            XCTAssertEqual(Float(i) + 1.0, arr[i])
        }
        
        arr = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        let arr2 = Array3<Float>(other: arr)
        
        XCTAssertEqual(4, arr2.width())
        XCTAssertEqual(3, arr2.height())
        XCTAssertEqual(2, arr2.depth())
        for i in 0..<24 {
            XCTAssertEqual(Float(i) + 1.0, arr2[i])
        }
    }
    
    func testClear() {
        var arr = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        arr.clear()
        XCTAssertEqual(0, arr.width())
        XCTAssertEqual(0, arr.height())
        XCTAssertEqual(0, arr.depth())
    }
    
    func testResizeMethod() {
        var arr = Array3<Float>()
        arr.resize(size: Size3(2, 9, 5))
        XCTAssertEqual(2, arr.width())
        XCTAssertEqual(9, arr.height())
        XCTAssertEqual(5, arr.depth())
        for i in 0..<90 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr.resize(size: Size3(8, 13, 7), initVal: 4.0)
        XCTAssertEqual(8, arr.width())
        XCTAssertEqual(13, arr.height())
        XCTAssertEqual(7, arr.depth())
        for k in 0..<7 {
            for j in 0..<13 {
                for i in 0..<8 {
                    if (i < 2 && j < 9 && k < 5) {
                        XCTAssertEqual(0.0, arr[i, j, k])
                    } else {
                        XCTAssertEqual(4.0, arr[i, j, k])
                    }
                }
            }
        }
        
        arr = Array3<Float>()
        arr.resize(width: 7, height: 6, depth: 3)
        XCTAssertEqual(7, arr.width())
        XCTAssertEqual(6, arr.height())
        XCTAssertEqual(3, arr.depth())
        for i in 0..<126 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr.resize(width: 1, height: 9, depth: 4, initVal: 3.0)
        XCTAssertEqual(1, arr.width())
        XCTAssertEqual(9, arr.height())
        XCTAssertEqual(4, arr.depth())
        for k in 0..<4 {
            for j in 0..<9 {
                for i in 0..<1 {
                    if (j < 6 && k < 3) {
                        XCTAssertEqual(0.0, arr[i, j, k])
                    } else {
                        XCTAssertEqual(3.0, arr[i, j, k])
                    }
                }
            }
        }
    }
    
    func testIterators() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
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
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        var i:size_t = 0
        arr1.forEach{(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        arr1.forEachIndex{(i:size_t, j:size_t, k:size_t) in
            let idx = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
        }
    }
    
    func testParallelForEach() {
        var arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        arr1.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        arr1.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let idx:size_t = i + (4 * (j + 3 * k)) + 1
            let ans:Float = 2.0 * Float(idx)
            XCTAssertEqual(ans, arr1[i, j, k])
        }
    }
    
    func testParallelForEachIndex() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        
        arr1.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let idx:size_t = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
        }
    }
}
