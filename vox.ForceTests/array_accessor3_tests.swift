//
//  array_accessor3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let arr = Array3<Double>(lst:
            [[[1, 2, 3, 4, 5],
              [6, 7, 8, 9, 10],
              [11, 12, 13, 14, 15],
              [16, 17, 18, 19, 20]],
             [[21, 22, 23, 24, 25],
              [26, 26, 28, 29, 30],
              [31, 32, 33, 34, 35],
              [36, 37, 38, 39, 40]],
             [[41, 42, 43, 44, 45],
              [46, 47, 48, 49, 50],
              [51, 52, 53, 54, 55],
              [56, 57, 58, 59, 60]]
        ])
        let acc = arr.accessor()
        
        XCTAssertEqual(5, acc.size().x)
        XCTAssertEqual(4, acc.size().y)
        XCTAssertEqual(3, acc.size().z)
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size().x * arr.size().y * arr.size().z),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
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
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        let acc = arr1.accessor()
        
        var i:size_t = 0
        acc.forEach{(val:Float) in
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
        let acc = arr1.accessor()
        
        acc.forEachIndex{(i:size_t, j:size_t, k:size_t) in
            let idx = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
        }
    }
    
    func testParallelForEach() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        var acc = arr1.accessor()
        
        acc.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        acc.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
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
        let acc = arr1.accessor()
        
        acc.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let idx:size_t = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
        }
    }
}

class array_const_accessor3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let arr = Array3<Double>(lst:
            [[[1, 2, 3, 4, 5],
              [6, 7, 8, 9, 10],
              [11, 12, 13, 14, 15],
              [16, 17, 18, 19, 20]],
             [[21, 22, 23, 24, 25],
              [26, 26, 28, 29, 30],
              [31, 32, 33, 34, 35],
              [36, 37, 38, 39, 40]],
             [[41, 42, 43, 44, 45],
              [46, 47, 48, 49, 50],
              [51, 52, 53, 54, 55],
              [56, 57, 58, 59, 60]]
        ])
        let acc = arr.constAccessor()
        
        XCTAssertEqual(5, acc.size().x)
        XCTAssertEqual(4, acc.size().y)
        XCTAssertEqual(3, acc.size().z)
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size().x * arr.size().y * arr.size().z),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
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
        let arr1 = Array3<Float>(
            lst: [[[ 1.0,  2.0,  3.0,  4.0],
                   [ 5.0,  6.0,  7.0,  8.0],
                   [ 9.0, 10.0, 11.0, 12.0]],
                  [[13.0, 14.0, 15.0, 16.0],
                   [17.0, 18.0, 19.0, 20.0],
                   [21.0, 22.0, 23.0, 24.0]]])
        let acc = arr1.constAccessor()
        
        var i:size_t = 0
        acc.forEach{(val:Float) in
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
        let acc = arr1.constAccessor()
        
        acc.forEachIndex{(i:size_t, j:size_t, k:size_t) in
            let idx = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
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
        let acc = arr1.constAccessor()
        
        acc.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let idx:size_t = i + (4 * (j + 3 * k)) + 1
            XCTAssertEqual(Float(idx), arr1[i, j, k])
        }
    }
}
