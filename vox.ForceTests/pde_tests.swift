//
//  pde_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class pde_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUpwind1() throws {
        let values:[Float] = [0.0, 1.0, -1.0]
        let result = upwind1(D0: values, dx: 0.5)
        
        XCTAssertEqual(2.0, result.0)
        XCTAssertEqual(-4.0, result.1)
        
        let d0 = upwind1(D0: values, dx: 2.0, isDirectionPositive: true)
        let d1 = upwind1(D0: values, dx: 2.0, isDirectionPositive: false)
        
        XCTAssertEqual(0.5, d0)
        XCTAssertEqual(-1.0, d1)
    }
    
    func testCd2() {
        let values:[Float] = [0.0, 1.0, -1.0]
        let result = cd2(D0: values, dx: 0.5)
        
        XCTAssertEqual(-1.0, result)
    }
    
    func testEno3() {
        let values0:[Float] = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        let result0 = eno3(D0: values0, dx: 0.5)
        
        // Sanity check for linear case
        XCTAssertEqual(2.0, result0.0)
        XCTAssertEqual(2.0, result0.1)
        
        let d0 = eno3(D0: values0, dx: 2.0, isDirectionPositive: true)
        let d1 = eno3(D0: values0, dx: 2.0, isDirectionPositive: false)
        
        XCTAssertEqual(0.5, d0)
        XCTAssertEqual(0.5, d1)
        
        // Unit-step function
        let values1:[Float] = [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
        let result1 = eno3(D0: values1, dx: 0.5)
        
        // Check monotonicity
        XCTAssertLessThan(0.0, result1.0)
        XCTAssertEqual(0.0, result1.1)
    }
    
    func testWeno5() {
        let values0:[Float] = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        let result0 = weno5(v: values0, h: 0.5)
        
        // Sanity check for linear case
        XCTAssertEqual(2.0, result0.0)
        XCTAssertEqual(2.0, result0.1)
        
        let d0 = weno5(v: values0, h: 2.0, is_velocity_positive: true)
        let d1 = weno5(v: values0, h: 2.0, is_velocity_positive: false)
        
        XCTAssertEqual(0.5, d0)
        XCTAssertEqual(0.5, d1)
        
        // Unit-step function
        let values1:[Float] = [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
        let result1 = weno5(v: values1, h: 0.5)
        
        // Check monotonicity
        XCTAssertLessThan(0.0, result1.0)
        XCTAssertLessThan(abs(result1.1), 1e-10)
    }
}
