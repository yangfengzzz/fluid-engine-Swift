//
//  sph_system_data2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sph_system_data2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParameters() throws {
        let data = SphSystemData2()
        
        data.setTargetDensity(targetDensity: 123.0)
        data.setTargetSpacing(spacing: 0.549)
        data.setRelativeKernelRadius(relativeRadius: 2.5)
        
        XCTAssertEqual(123.0, data.targetDensity())
        XCTAssertEqual(0.549, data.targetSpacing())
        XCTAssertEqual(0.549, data.radius())
        XCTAssertEqual(2.5, data.relativeKernelRadius())
        XCTAssertEqual(2.5 * 0.549, data.kernelRadius())
        
        data.setKernelRadius(kernelRadius: 1.9)
        XCTAssertEqual(1.9, data.kernelRadius())
        XCTAssertEqual(1.9 / 2.5, data.targetSpacing())
        
        data.setRadius(newRadius: 0.413)
        XCTAssertEqual(0.413, data.targetSpacing())
        XCTAssertEqual(0.413, data.radius())
        XCTAssertEqual(2.5, data.relativeKernelRadius())
        XCTAssertEqual(2.5 * 0.413, data.kernelRadius())
        
        data.setMass(newMass: 2.0 * data.mass())
        XCTAssertEqual(246.0, data.targetDensity())
    }
    
    func testParticles() {
        let data = SphSystemData2()
        
        data.setTargetSpacing(spacing: 1.0)
        data.setRelativeKernelRadius(relativeRadius: 1.0)
        
        data.addParticle(newPosition: Vector2F(0, 0))
        data.addParticle(newPosition: Vector2F(1, 0))
        
        data.buildNeighborSearcher()
        data.updateDensities()
        
        // See if we get symmetric density profile
        let den:ConstArrayAccessor1<Float> = data.densities()
        XCTAssertLessThan(0.0, den[0])
        XCTAssertEqual(den[0], den[1])
        
        let values = Array1<Float>(lst: [1.0, 1.0])
        let midVal = data.interpolate(origin: Vector2F(0.5, 0),
                                      values: values.constAccessor())
        XCTAssertLessThan(0.0, midVal)
        XCTAssertGreaterThan(1.0, midVal)
    }
}
