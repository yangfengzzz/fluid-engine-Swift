//
//  array1_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array1_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        var arr = Array1<Float>()
        XCTAssertEqual(arr.size(), 0)
        
        arr = Array1<Float>(size: 9, initVal: 1.5)
        XCTAssertEqual(arr.size(), 9)
        for i in 0..<9 {
            XCTAssertEqual(arr[i], 1.5)
        }
        
        arr = Array1<Float>(lst: [1.0, 2.0, 3.0, 4.0])
        XCTAssertEqual(arr.size(), 4)
        for i in 0..<4 {
            XCTAssertEqual(arr[i], Float(i) + 1.0)
        }
        
        let arr1 = Array1<Float>(other: arr)
        XCTAssertEqual(arr1.size(), 4)
        for i in 0..<4 {
            XCTAssertEqual(arr1[i], Float(i) + 1.0)
        }
    }
    
    func testSetMethods() {
        var arr1 = Array1<Float>(size: 12, initVal: -1.0)
        arr1.set(value: 3.5)
        for a in arr1 {
            XCTAssertEqual(3.5, a)
        }
        
        var arr2 = Array1<Float>()
        arr1.set(other: arr2)
        XCTAssertEqual(arr1.size(), arr2.size())
        for i in 0..<arr2.size() {
            XCTAssertEqual(arr1[i], arr2[i])
        }
        
        arr2 = Array1<Float>(lst: [2.0, 5.0, 9.0, -1.0])
        XCTAssertEqual(4, arr2.size())
        XCTAssertEqual(2.0, arr2[0])
        XCTAssertEqual(5.0, arr2[1])
        XCTAssertEqual(9.0, arr2[2])
        XCTAssertEqual(-1.0, arr2[3])
    }
    
    func testClear() {
        var arr1 = Array1<Float>(lst: [2.0, 5.0, 9.0, -1.0])
        arr1.clear()
        XCTAssertEqual(0, arr1.size())
    }
    
    func testResizeMethod() {
        var arr = Array1<Float>()
        arr.resize(size: 9)
        XCTAssertEqual(9, arr.size())
        for i in 0..<9 {
            XCTAssertEqual(0.0, arr[i])
        }
        
        arr.resize(size: 12, initVal: 4.0)
        XCTAssertEqual(12, arr.size())
        for i in 0..<8 {
            if (i < 9) {
                XCTAssertEqual(0.0, arr[i])
            } else {
                XCTAssertEqual(4.0, arr[i])
            }
        }
    }
    
    func testIterators() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        
        var i:size_t = 0
        for elem in arr1 {
            XCTAssertEqual(arr1[i], elem)
            i += 1
        }
        
        i = 0
        for elem in arr1 {
            XCTAssertEqual(arr1[i], elem)
            i += 1
        }
    }
    
    func testForEach() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        var i:size_t = 0
        arr1.forEach {(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        var cnt:size_t = 0
        arr1.forEachIndex{(i:size_t) in
            XCTAssertEqual(cnt, i)
            cnt += 1
        }
    }
    
    func testParallelForEach() {
        var arr1 = Array1<Float>(size: 200)
        arr1.forEachIndex(){(i:size_t) in
            arr1[i] = Float(200 - i)
        }
        
        arr1.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        arr1.forEachIndex(){(i:size_t) in
            let ans:Float = 2.0 * Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
    
    func testParallelForEachIndex() {
        var arr1 = Array1<Float>(size: 200)
        arr1.forEachIndex(){(i:size_t) in
            arr1[i] = Float(200 - i)
        }
        
        arr1.parallelForEachIndex(){(i:size_t) in
            let ans:Float = Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
}
