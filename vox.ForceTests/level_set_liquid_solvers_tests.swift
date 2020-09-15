//
//  level_set_liquid_solvers_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class level_set_liquid_solvers_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testComputeVolume2() throws {
        let solver = LevelSetLiquidSolver2()
        solver.setIsGlobalCompensationEnabled(isEnabled: true)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size2(32, 64),
                    gridSpacing: Vector2F(dx, dx),
                    origin: Vector2F())
        
        // Source setting
        let radius:Float = 0.15
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Sphere2(center: domain.midPoint(),
                                                       radiustransform: radius))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector2F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
        
        // Measure the volume
        let volume = solver.computeVolume()
        let ans = Math.square(of: radius) * kPiF
        
        XCTAssertEqual(ans, volume, accuracy: 0.001)
    }
    
    func testComputeVolume3() {
        let solver = LevelSetLiquidSolver3()
        solver.setIsGlobalCompensationEnabled(isEnabled: true)
        
        let data = solver.gridSystemData()
        let dx:Float = 1.0 / 32.0
        data.resize(resolution: Size3(32, 64, 32),
                    gridSpacing: Vector3F(dx, dx, dx),
                    origin: Vector3F())
        
        // Source setting
        let radius:Float = 0.15
        let domain = data.boundingBox()
        let surfaceSet = ImplicitSurfaceSet3()
        surfaceSet.addExplicitSurface(surface: Sphere3(center: domain.midPoint(),
                                                       radiustransform: radius))
        
        let sdf = solver.signedDistanceField()
        sdf.fill(){(x:Vector3F)->Float in
            return surfaceSet.signedDistance(otherPoint: x)
        }
        
        // Measure the volume
        let volume = solver.computeVolume()
        let ans = 4.0 / 3.0 * Math.cubic(of: radius) * kPiF
        
        XCTAssertEqual(ans, volume, accuracy: 0.001)
    }
}
