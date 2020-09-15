//
//  physics_animation_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class CustomPhysicsAnimation: PhysicsAnimation {
    override func onAdvanceTimeStep(timeIntervalInSeconds:Double) {}
}

class physics_animation_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let pa = CustomPhysicsAnimation()
        XCTAssertEqual(-1, pa.currentFrame().index)
    }
    
    func testProperties() {
        let pa = CustomPhysicsAnimation()
        
        pa.setIsUsingFixedSubTimeSteps(isUsing: true)
        XCTAssertTrue(pa.isUsingFixedSubTimeSteps())
        pa.setIsUsingFixedSubTimeSteps(isUsing: false)
        XCTAssertFalse(pa.isUsingFixedSubTimeSteps())
        
        pa.setNumberOfFixedSubTimeSteps(numberOfSteps: 42)
        XCTAssertEqual(42, pa.numberOfFixedSubTimeSteps())
        
        pa.setCurrentFrame(frame: Frame(newIndex: 8, newTimeIntervalInSeconds: 0.01))
        XCTAssertEqual(8, pa.currentFrame().index)
        XCTAssertEqual(0.01, pa.currentFrame().timeIntervalInSeconds)
    }
    
    func testUpdates() {
        let pa = CustomPhysicsAnimation()
        
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 0.1)
        for _ in 0...15 {
            pa.update(frame: frame)
            frame.advance()
        }
        
        XCTAssertEqual(1.5, pa.currentTimeInSeconds(), accuracy: 1.0e-15)
        
        let pa2 = CustomPhysicsAnimation()
        
        for _ in 0...15 {
            pa2.advanceSingleFrame()
        }
        
        XCTAssertEqual(pa2.currentFrame().timeIntervalInSeconds * 15.0,
                       pa2.currentTimeInSeconds())
    }
}
