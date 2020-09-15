//
//  samplers_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class samplers_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUniformSampleCone() throws {
        for _ in 0..<100 {
            let u1 = Float.random(in: 0...1)
            let u2 = Float.random(in: 0...1)
            
            let pt = uniformSampleCone(u1: u1, u2: u2,
                                       axis: Vector3F(1, 0, 0),
                                       angle: 0.5)
            
            let dots = dot(pt, Vector3F(1, 0, 0))
            XCTAssertLessThan(cos(0.5), dots)
            
            let d = length(pt)
            XCTAssertEqual(1.0, d, accuracy: 1.0e-6)
        }
    }
    
    func testUniformSampleHemisphere() {
        for _ in 0..<100 {
            let u1 = Float.random(in: 0...1)
            let u2 = Float.random(in: 0...1)
            
            let pt = uniformSampleHemisphere(u1: u1, u2: u2,
                                             normal: Vector3F(1, 0, 0))
            
            let dots = dot(pt, Vector3F(1, 0, 0))
            XCTAssertLessThan(cos(kHalfPiF), dots)
            
            let d = length(pt)
            XCTAssertEqual(1.0, d, accuracy: 1.0e-6)
        }
    }
    
    func testUniformSampleSphere() {
        for _ in 0..<100 {
            let u1 = Float.random(in: 0...1)
            let u2 = Float.random(in: 0...1)
            
            let pt = uniformSampleSphere(u1: u1, u2: u2)
            
            let d = length(pt)
            XCTAssertEqual(1.0, d, accuracy: 1.0e-6)
        }
    }
    
    func testUniformSampleDisk() {
        for _ in 0..<100 {
            let u1 = Float.random(in: 0...1)
            let u2 = Float.random(in: 0...1)
            
            let pt = uniformSampleDisk(u1: u1, u2: u2)
            
            let d = length(pt)
            XCTAssertGreaterThan(1.0, d)
        }
    }
}
