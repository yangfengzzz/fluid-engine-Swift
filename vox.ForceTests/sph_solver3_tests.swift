//
//  sph_solver3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sph_solver3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUpdateEmpty() throws {
        // Empty solver test
        let solver = SphSolver3()
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 0.01)
        solver.update(frame: frame)
        frame.advance()
        solver.update(frame: frame)
    }
    
    func testParameters() {
        let solver = SphSolver3()
        
        solver.setEosExponent(newEosExponent: 5.0)
        XCTAssertEqual(5.0, solver.eosExponent())
        
        solver.setEosExponent(newEosExponent: -1.0)
        XCTAssertEqual(1.0, solver.eosExponent())
        
        solver.setNegativePressureScale(newNegativePressureScale: 0.3)
        XCTAssertEqual(0.3, solver.negativePressureScale())
        
        solver.setNegativePressureScale(newNegativePressureScale: -1.0)
        XCTAssertEqual(0.0, solver.negativePressureScale())
        
        solver.setNegativePressureScale(newNegativePressureScale: 3.0)
        XCTAssertEqual(1.0, solver.negativePressureScale())
        
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.3)
        XCTAssertEqual(0.3, solver.viscosityCoefficient())
        
        solver.setViscosityCoefficient(newViscosityCoefficient: -1.0)
        XCTAssertEqual(0.0, solver.viscosityCoefficient())
        
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 0.3)
        XCTAssertEqual(0.3, solver.pseudoViscosityCoefficient())
        
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: -1.0)
        XCTAssertEqual(0.0, solver.pseudoViscosityCoefficient())
        
        solver.setSpeedOfSound(newSpeedOfSound: 0.3)
        XCTAssertEqual(0.3, solver.speedOfSound())
        
        solver.setSpeedOfSound(newSpeedOfSound: -1.0)
        XCTAssertGreaterThan(solver.speedOfSound(), 0.0)
        
        solver.setTimeStepLimitScale(newScale: 0.3)
        XCTAssertEqual(0.3, solver.timeStepLimitScale())
        
        solver.setTimeStepLimitScale(newScale: -1.0)
        XCTAssertEqual(0.0, solver.timeStepLimitScale())
    }
}
