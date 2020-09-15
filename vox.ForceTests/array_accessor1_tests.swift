//
//  array_accessor1_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_accessor1_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testConstructors() throws {
        var data:[Double] = []
        for i in 0..<5 {
            data.append(Double(i))
        }
        
        let arr = Array1<Double>(lst: data)
        let acc = arr.accessor()
        
        XCTAssertEqual(5, acc.size())
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size()),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array1<Float>(lst: [6.0, 4.0, 1.0, -5.0])
        let acc = arr1.accessor()
        
        var i:size_t = 0
        for elem in acc {
            XCTAssertEqual(acc[i], elem)
            i += 1
        }
        
        i = 0
        for elem in acc {
            XCTAssertEqual(acc[i], elem)
            i += 1
        }
    }
    
    func testForEach() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        let acc = arr1.accessor()
        var i:size_t = 0
        acc.forEach {(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        let acc = arr1.accessor()
        var cnt:size_t = 0
        acc.forEachIndex{(i:size_t) in
            XCTAssertEqual(cnt, i)
            cnt += 1
        }
    }
    
    func testParallelForEach() {
        var arr1 = Array1<Float>(size: 200)
        var acc = arr1.accessor()
        
        acc.forEachIndex(){(i:size_t) in
            arr1[i] = Float(200 - i)
        }
        
        acc.parallelForEach(){(val: inout Float) in
            val *= 2.0
        }
        
        acc.forEachIndex(){(i:size_t) in
            let ans:Float = 2.0 * Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
    
    func testParallelForEachIndex() {
        var arr1 = Array1<Float>(size: 200)
        let acc = arr1.accessor()
        
        acc.forEachIndex(){(i:size_t) in
            arr1[i] = Float(200 - i)
        }
        
        acc.parallelForEachIndex(){(i:size_t) in
            let ans:Float = Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
}

class array_const_accessor1_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testConstructors() throws {
        var data:[Double] = []
        for i in 0..<5 {
            data.append(Double(i))
        }
        
        let arr = Array1<Double>(lst: data)
        let acc = arr.constAccessor()
        
        XCTAssertEqual(5, acc.size())
        XCTAssertEqual(arr.data()?.contents()
            .bindMemory(to: Double.self, capacity: arr.size()),
                       acc.data())
    }
    
    func testIterators() {
        let arr1 = Array1<Float>(lst: [6.0, 4.0, 1.0, -5.0])
        let acc = arr1.constAccessor()
        
        var i:size_t = 0
        for elem in acc {
            XCTAssertEqual(acc[i], elem)
            i += 1
        }
        
        i = 0
        for elem in acc {
            XCTAssertEqual(acc[i], elem)
            i += 1
        }
    }
    
    func testForEach() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        let acc = arr1.constAccessor()
        var i:size_t = 0
        acc.forEach {(val:Float) in
            XCTAssertEqual(arr1[i], val)
            i += 1
        }
    }
    
    func testForEachIndex() {
        let arr1 = Array1<Float>(lst : [6.0,  4.0,  1.0,  -5.0])
        let acc = arr1.constAccessor()
        var cnt:size_t = 0
        acc.forEachIndex{(i:size_t) in
            XCTAssertEqual(cnt, i)
            cnt += 1
        }
    }
    
    func testParallelForEachIndex() {
        var arr1 = Array1<Float>(size: 200)
        let acc = arr1.constAccessor()
        
        acc.forEachIndex(){(i:size_t) in
            arr1[i] = Float(200 - i)
        }
        
        acc.parallelForEachIndex(){(i:size_t) in
            let ans:Float = Float(200 - i)
            XCTAssertEqual(ans, arr1[i])
        }
    }
}
