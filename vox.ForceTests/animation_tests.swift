//
//  animation_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class animation_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let frame = Frame()
        XCTAssertEqual(0, frame.index)
        XCTAssertEqual(1.0 / 60.0, frame.timeIntervalInSeconds)
    }
    
    func testTimeInSeconds() {
        var frame = Frame()
        
        frame.index = 180
        
        XCTAssertEqual(3.0, frame.timeInSeconds())
    }
    
    func testAdvance() {
        var frame = Frame()
        
        frame.index = 45
        
        for _ in 0..<9 {
            frame.advance()
        }
        
        XCTAssertEqual(54, frame.index)
        
        frame.advance(delta: 23)
        
        XCTAssertEqual(77, frame.index)
        
        frame.advance()
        XCTAssertEqual(78, frame.index)
        
        XCTAssertEqual(78, frame.index)
        frame.advance()
        
        XCTAssertEqual(79, frame.index)
    }
}
