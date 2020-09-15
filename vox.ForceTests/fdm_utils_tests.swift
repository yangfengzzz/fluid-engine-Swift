//
//  fdm_utils_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class fdm_utils_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testScalarToGradient2() throws {
        let grid = CellCenteredScalarGrid2(resolutionX: 10, resolutionY: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0,
                                           originX: -1.0, originY: 4.0)
        grid.fill(){(x:Vector2F)->Float in
            return -5.0 * x.x + 4.0 * x.y
        }
        
        let grad = gradient2(data: grid.constDataAccessor(),
                             gridSpacing: grid.gridSpacing(), i: 5, j: 3)
        XCTAssertEqual(-5.0, grad.x)
        XCTAssertEqual(4.0, grad.y)
    }
    
    func testVectorToGradient2() {
        let grid = CellCenteredVectorGrid2(resolutionX: 10, resolutionY: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0,
                                           originX: -1.0, originY: 4.0)
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(-5.0 * x.x + 4.0 * x.y, 2.0 * x.x - 7.0 * x.y)
        }
        
        let grad = gradient2(data: grid.constDataAccessor(),
                             gridSpacing: grid.gridSpacing(), i: 5, j: 3)
        XCTAssertEqual(-5.0, grad[0].x)
        XCTAssertEqual(4.0, grad[0].y)
        XCTAssertEqual(2.0, grad[1].x)
        XCTAssertEqual(-7.0, grad[1].y)
    }
    
    func testScalarToGradient3() {
        let grid = CellCenteredScalarGrid3(resolutionX: 10, resolutionY: 10, resolutionZ: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 0.5,
                                           originX: -1.0, originY: 4.0, originZ: 2.0)
        grid.fill(){(x:Vector3F)->Float in
            return -5.0 * x.x + 4.0 * x.y + 2.0 * x.z
        }
        
        let grad = gradient3(data: grid.constDataAccessor(),
                             gridSpacing: grid.gridSpacing(), i: 5, j: 3, k: 4)
        XCTAssertEqual(-5.0, grad.x)
        XCTAssertEqual(4.0, grad.y)
        XCTAssertEqual(2.0, grad.z)
    }
    
    func testVectorToGradient3() {
        let grid = CellCenteredVectorGrid3(resolutionX: 10, resolutionY: 10, resolutionZ: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 0.5,
                                           originX: -1.0, originY: 4.0, originZ: 2.0)
        grid.fill(){(x:Vector3F)->Vector3F in
            return Vector3F(
                -5.0 * x.x + 4.0 * x.y + 2.0 * x.z,
                2.0 * x.x - 7.0 * x.y,
                x.y + 3.0 * x.z)
        }
        
        let grad = gradient3(data: grid.constDataAccessor(),
                             gridSpacing: grid.gridSpacing(), i: 5, j: 3, k: 4)
        XCTAssertEqual(-5.0, grad[0].x)
        XCTAssertEqual(4.0, grad[0].y)
        XCTAssertEqual(2.0, grad[0].z)
        XCTAssertEqual(2.0, grad[1].x)
        XCTAssertEqual(-7.0, grad[1].y)
        XCTAssertEqual(0.0, grad[1].z)
        XCTAssertEqual(0.0, grad[2].x)
        XCTAssertEqual(1.0, grad[2].y)
        XCTAssertEqual(3.0, grad[2].z)
    }
    
    func testScalarToLaplacian2() {
        let grid = CellCenteredScalarGrid2(resolutionX: 10, resolutionY: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0,
                                           originX: -1.0, originY: 4.0)
        grid.fill(){(x:Vector2F)->Float in
            return -5.0 * x.x * x.x + 4.0 * x.y * x.y
        }
        
        let lapl = laplacian2(data: grid.constDataAccessor(),
                              gridSpacing: grid.gridSpacing(), i: 5, j: 3)
        XCTAssertEqual(-2.0, lapl)
    }
    
    func testVectorToLaplacian2() {
        let grid = CellCenteredVectorGrid2(resolutionX: 10, resolutionY: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0,
                                           originX: -1.0, originY: 4.0)
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(
                -5.0 * x.x * x.x + 4.0 * x.y * x.y,
                2.0 * x.x * x.x - 7.0 * x.y * x.y)
        }
        
        let lapl = laplacian2(data: grid.constDataAccessor(),
                              gridSpacing: grid.gridSpacing(), i: 5, j: 3)
        XCTAssertEqual(-2.0, lapl.x)
        XCTAssertEqual(-10.0, lapl.y)
    }
    
    func testScalarToLaplacian3() {
        let grid = CellCenteredScalarGrid3(resolutionX: 10, resolutionY: 10, resolutionZ: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 0.5,
                                           originX: -1.0, originY: 4.0, originZ: 2.0)
        grid.fill(){(x:Vector3F)->Float in
            return -5.0 * x.x * x.x + 4.0 * x.y * x.y - 3.0 * x.z * x.z
        }
        
        let lapl = laplacian3(data: grid.constDataAccessor(),
                              gridSpacing: grid.gridSpacing(), i: 5, j: 3, k: 4)
        XCTAssertEqual(-8.0, lapl)
    }
    
    func testVectorToLaplacian3() {
        let grid = CellCenteredVectorGrid3(resolutionX: 10, resolutionY: 10, resolutionZ: 10,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 0.5,
                                           originX: -1.0, originY: 4.0, originZ: 2.0)
        grid.fill(){(x:Vector3F)->Vector3F in
            return Vector3F(
                -5.0 * x.x * x.x + 4.0 * x.y * x.y + 2.0 * x.z * x.z,
                2.0 * x.x * x.x - 7.0 * x.y * x.y,
                x.y * x.y + 3.0 * x.z * x.z)
        }
        
        let lapl = laplacian3(data: grid.constDataAccessor(),
                              gridSpacing: grid.gridSpacing(), i: 5, j: 3, k: 4)
        XCTAssertEqual(2.0, lapl.x)
        XCTAssertEqual(-10.0, lapl.y)
        XCTAssertEqual(8.0, lapl.z)
    }
}
