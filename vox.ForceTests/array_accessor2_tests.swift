//
//  array_accessor2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let arr = Array2<Double>(lst:
            [[1, 2, 3, 4, 5],
             [6, 7, 8, 9, 10],
             [11, 12, 13, 14, 15],
             [16, 17, 18, 19, 20],
        ])
        let acc = arr.accessor()
        
        XCTAssertEqual(5, acc.size().x)
        XCTAssertEqual(4, acc.size().y)
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size().x * arr.size().y),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array2<Float> (
            lst: [[1.0,  2.0,  3.0,  4.0],
                  [5.0,  6.0,  7.0,  8.0],
                  [9.0, 10.0, 11.0, 12.0]])
        let acc = arr1.accessor()
        
        var cnt:Float = 1.0
        for elem in acc {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
        
        cnt = 1.0
        for elem in acc {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
    }
    
    func testForEach() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        let acc1 = arr1.accessor()
        
        var i:size_t = 0
        acc1.forEach{(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        let acc1 = arr1.accessor()
        
        acc1.forEachIndex{(i:size_t, j:size_t) in
            let idx = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
    
    func testParallelForEach() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        var acc = arr1.accessor()
        
        acc.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        acc.forEachIndex(){(i:size_t, j:size_t) in
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
        let acc = arr1.accessor()
        
        acc.parallelForEachIndex(){(i:size_t, j:size_t) in
            let idx:size_t = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
}

class array_const_accessor2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let arr = Array2<Double>(lst:
            [[1, 2, 3, 4, 5],
             [6, 7, 8, 9, 10],
             [11, 12, 13, 14, 15],
             [16, 17, 18, 19, 20],
        ])
        let acc = arr.constAccessor()
        
        XCTAssertEqual(5, acc.size().x)
        XCTAssertEqual(4, acc.size().y)
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size().x * arr.size().y),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array2<Float> (
            lst: [[1.0,  2.0,  3.0,  4.0],
                  [5.0,  6.0,  7.0,  8.0],
                  [9.0, 10.0, 11.0, 12.0]])
        let acc = arr1.constAccessor()
        
        var cnt:Float = 1.0
        for elem in acc {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
        
        cnt = 1.0
        for elem in acc {
            XCTAssertEqual(cnt, elem)
            cnt += 1.0
        }
    }
    
    func testForEach() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        let acc = arr1.constAccessor()
        
        var i:size_t = 0
        acc.forEach{(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        let acc = arr1.constAccessor()
        
        acc.forEachIndex{(i:size_t, j:size_t) in
            let idx = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
    
    func testParallelForEachIndex() {
        let arr1 = Array2<Float>(lst : [
            [1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [9.0, 10.0, 11.0, 12.0] ])
        let acc = arr1.constAccessor()
        
        acc.parallelForEachIndex(){(i:size_t, j:size_t) in
            let idx:size_t = i + (4 * j) + 1
            XCTAssertEqual(Float(idx), arr1[i, j])
        }
    }
}
