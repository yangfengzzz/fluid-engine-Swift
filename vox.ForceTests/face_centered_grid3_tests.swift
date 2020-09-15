//
//  face_centered_grid3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class face_centered_grid3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = FaceCenteredGrid3()
        XCTAssertEqual(0, grid1.resolution().x)
        XCTAssertEqual(0, grid1.resolution().y)
        XCTAssertEqual(0, grid1.resolution().z)
        XCTAssertEqual(1.0, grid1.gridSpacing().x)
        XCTAssertEqual(1.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(0.0, grid1.origin().x)
        XCTAssertEqual(0.0, grid1.origin().y)
        XCTAssertEqual(0.0, grid1.origin().z)
        XCTAssertEqual(0, grid1.uSize().x)
        XCTAssertEqual(0, grid1.uSize().y)
        XCTAssertEqual(0, grid1.uSize().z)
        XCTAssertEqual(0, grid1.vSize().x)
        XCTAssertEqual(0, grid1.vSize().y)
        XCTAssertEqual(0, grid1.vSize().z)
        XCTAssertEqual(0, grid1.wSize().x)
        XCTAssertEqual(0, grid1.wSize().y)
        XCTAssertEqual(0, grid1.wSize().z)
        XCTAssertEqual(0.0, grid1.uOrigin().x)
        XCTAssertEqual(0.5, grid1.uOrigin().y)
        XCTAssertEqual(0.5, grid1.uOrigin().z)
        XCTAssertEqual(0.5, grid1.vOrigin().x)
        XCTAssertEqual(0.0, grid1.vOrigin().y)
        XCTAssertEqual(0.5, grid1.vOrigin().z)
        XCTAssertEqual(0.5, grid1.wOrigin().x)
        XCTAssertEqual(0.5, grid1.wOrigin().y)
        XCTAssertEqual(0.0, grid1.wOrigin().z)
        
        // Constructor with params
        let grid2 = FaceCenteredGrid3(
            resolutionX: 5, resolutionY: 4, resolutionZ: 3,
            gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
            originX: 4.0, originY: 5.0, originZ: 6.0,
            initialValueU: 7.0, initialValueV: 8.0, initialValueW: 9.0)
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(3, grid2.resolution().z)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.gridSpacing().z)
        XCTAssertEqual(4.0, grid2.origin().x)
        XCTAssertEqual(5.0, grid2.origin().y)
        XCTAssertEqual(6.0, grid2.origin().z)
        XCTAssertEqual(6, grid2.uSize().x)
        XCTAssertEqual(4, grid2.uSize().y)
        XCTAssertEqual(3, grid2.uSize().z)
        XCTAssertEqual(5, grid2.vSize().x)
        XCTAssertEqual(5, grid2.vSize().y)
        XCTAssertEqual(3, grid2.vSize().z)
        XCTAssertEqual(5, grid2.wSize().x)
        XCTAssertEqual(4, grid2.wSize().y)
        XCTAssertEqual(4, grid2.wSize().z)
        XCTAssertEqual(4.0, grid2.uOrigin().x)
        XCTAssertEqual(6.0, grid2.uOrigin().y)
        XCTAssertEqual(7.5, grid2.uOrigin().z)
        XCTAssertEqual(4.5, grid2.vOrigin().x)
        XCTAssertEqual(5.0, grid2.vOrigin().y)
        XCTAssertEqual(7.5, grid2.vOrigin().z)
        XCTAssertEqual(4.5, grid2.wOrigin().x)
        XCTAssertEqual(6.0, grid2.wOrigin().y)
        XCTAssertEqual(6.0, grid2.wOrigin().z)
        grid2.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid2.u(i: i, j: j, k: k))
        }
        grid2.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid2.v(i: i, j: j, k: k))
        }
        grid2.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(9.0, grid2.w(i: i, j: j, k: k))
        }
        
        // Copy constructor
        let grid3 = FaceCenteredGrid3(other: grid2)
        XCTAssertEqual(5, grid3.resolution().x)
        XCTAssertEqual(4, grid3.resolution().y)
        XCTAssertEqual(3, grid3.resolution().z)
        XCTAssertEqual(1.0, grid3.gridSpacing().x)
        XCTAssertEqual(2.0, grid3.gridSpacing().y)
        XCTAssertEqual(3.0, grid3.gridSpacing().z)
        XCTAssertEqual(4.0, grid3.origin().x)
        XCTAssertEqual(5.0, grid3.origin().y)
        XCTAssertEqual(6.0, grid3.origin().z)
        XCTAssertEqual(6, grid3.uSize().x)
        XCTAssertEqual(4, grid3.uSize().y)
        XCTAssertEqual(3, grid3.uSize().z)
        XCTAssertEqual(5, grid3.vSize().x)
        XCTAssertEqual(5, grid3.vSize().y)
        XCTAssertEqual(3, grid3.vSize().z)
        XCTAssertEqual(5, grid3.wSize().x)
        XCTAssertEqual(4, grid3.wSize().y)
        XCTAssertEqual(4, grid3.wSize().z)
        XCTAssertEqual(4.0, grid3.uOrigin().x)
        XCTAssertEqual(6.0, grid3.uOrigin().y)
        XCTAssertEqual(7.5, grid3.uOrigin().z)
        XCTAssertEqual(4.5, grid3.vOrigin().x)
        XCTAssertEqual(5.0, grid3.vOrigin().y)
        XCTAssertEqual(7.5, grid3.vOrigin().z)
        XCTAssertEqual(4.5, grid3.wOrigin().x)
        XCTAssertEqual(6.0, grid3.wOrigin().y)
        XCTAssertEqual(6.0, grid3.wOrigin().z)
        grid3.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid3.u(i: i, j: j, k: k))
        }
        grid3.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid3.v(i: i, j: j, k: k))
        }
        grid3.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(9.0, grid3.w(i: i, j: j, k: k))
        }
    }
    
    func testFill() {
        let grid = FaceCenteredGrid3(
            resolutionX: 5, resolutionY: 4, resolutionZ: 6,
            gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
            originX: 0.0, originY: 0.0, originZ: 0.0,
            initialValueU: 0.0, initialValueV: 0.0, initialValueW: 0.0)
        grid.fill(value: Vector3F(42.0, 27.0, 31.0))
        
        for k in 0..<grid.uSize().z {
            for j in 0..<grid.uSize().y {
                for i in 0..<grid.uSize().x {
                    XCTAssertEqual(42.0, grid.u(i: i, j: j, k: k))
                }
            }
        }
        
        for k in 0..<grid.vSize().z {
            for j in 0..<grid.vSize().y {
                for i in 0..<grid.vSize().x {
                    XCTAssertEqual(27.0, grid.v(i: i, j: j, k: k))
                }
            }
        }
        
        for k in 0..<grid.wSize().z {
            for j in 0..<grid.wSize().y {
                for i in 0..<grid.wSize().x {
                    XCTAssertEqual(31.0, grid.w(i: i, j: j, k: k))
                }
            }
        }
        
        let function = {(x:Vector3F)->Vector3F in
            return x
        }
        grid.fill(function: function)
        
        for k in 0..<grid.uSize().z {
            for j in 0..<grid.uSize().y {
                for i in 0..<grid.uSize().x {
                    XCTAssertEqual(Float(i), grid.u(i: i, j: j, k: k))
                }
            }
        }
        
        for k in 0..<grid.vSize().z {
            for j in 0..<grid.vSize().y {
                for i in 0..<grid.vSize().x {
                    XCTAssertEqual(Float(j), grid.v(i: i, j: j, k: k))
                }
            }
        }
        
        for k in 0..<grid.wSize().z {
            for j in 0..<grid.wSize().y {
                for i in 0..<grid.wSize().x {
                    XCTAssertEqual(Float(k), grid.w(i: i, j: j, k: k))
                }
            }
        }
    }
    
    func testDivergenceAtCellCenter() {
        let grid = FaceCenteredGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6)
        
        grid.fill(value: Vector3F(1.0, -2.0, 3.0))
        
        for k in 0..<grid.resolution().z {
            for j in 0..<grid.resolution().y {
                for i in 0..<grid.resolution().x {
                    XCTAssertEqual(0.0, grid.divergenceAtCellCenter(i: i, j: j, k: k))
                }
            }
        }
        
        grid.fill(){(x:Vector3F)->Vector3F in
            return x
        }
        
        for k in 0..<grid.resolution().z {
            for j in 0..<grid.resolution().y {
                for i in 0..<grid.resolution().x {
                    XCTAssertEqual(3.0, grid.divergenceAtCellCenter(i: i, j: j, k: k))
                }
            }
        }
    }
    
    func testCurlAtCellCenter() {
        let grid = FaceCenteredGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.5)
        
        grid.fill(value: Vector3F(1.0, -2.0, 3.0))
        
        for k in 0..<grid.resolution().z {
            for j in 0..<grid.resolution().y {
                for i in 0..<grid.resolution().x {
                    let curl = grid.curlAtCellCenter(i: i, j: j, k: k)
                    XCTAssertEqual(0.0, curl.x)
                    XCTAssertEqual(0.0, curl.y)
                    XCTAssertEqual(0.0, curl.z)
                }
            }
        }
        
        grid.fill(){(x:Vector3F)->Vector3F in
            return Vector3F(x.y, x.z, x.x)
        }
        
        for k in 1..<grid.resolution().z-1 {
            for j in 1..<grid.resolution().y-1 {
                for i in 1..<grid.resolution().x-1 {
                    let curl = grid.curlAtCellCenter(i: i, j: j, k: k)
                    XCTAssertEqual(-1.0, curl.x)
                    XCTAssertEqual(-1.0, curl.y)
                    XCTAssertEqual(-1.0, curl.z)
                }
            }
        }
    }
    
    func testValueAtCellCenter() {
        let grid = FaceCenteredGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.5)
        grid.fill(){(x:Vector3F)->Vector3F in
            return Vector3F(3.0 * x.y + 1.0, 5.0 * x.z + 7.0, -1.0 * x.x - 9.0)
        }
        
        let pos = grid.cellCenterPosition()
        grid.forEachCellIndex(){(i:size_t, j:size_t, k:size_t) in
            let val = grid.valueAtCellCenter(i: i, j: j, k: k)
            let x = pos(i, j, k)
            let expected = Vector3F(3.0 * x.y + 1.0, 5.0 * x.z + 7.0, -1.0 * x.x - 9.0)
            XCTAssertEqual(expected.x, val.x, accuracy: 1e-6)
            XCTAssertEqual(expected.y, val.y, accuracy: 1e-6)
            XCTAssertEqual(expected.z, val.z, accuracy: 1e-6)
        }
    }
    
    func testSample() {
        let grid = FaceCenteredGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.5)
        grid.fill(){(x:Vector3F)->Vector3F in
            return Vector3F(3.0 * x.y + 1.0, 5.0 * x.z + 7.0, -1.0 * x.x - 9.0)
        }
        
        let pos = grid.cellCenterPosition()
        grid.forEachCellIndex(){(i:size_t, j:size_t, k:size_t) in
            let x = pos(i, j, k)
            let val = grid.sample(x: x)
            let expected = Vector3F(3.0 * x.y + 1.0, 5.0 * x.z + 7.0, -1.0 * x.x - 9.0)
            XCTAssertEqual(expected.x, val.x, accuracy: 1e-6)
            XCTAssertEqual(expected.y, val.y, accuracy: 1e-6)
            XCTAssertEqual(expected.z, val.z, accuracy: 1e-6)
        }
    }
    
    func testBuilder() {
        let builder = FaceCenteredGrid3.builder()
        
        let grid = builder.build(
            resolution: Size3(5, 2, 7),
            gridSpacing: Vector3F(2.0, 4.0, 1.5),
            gridOrigin: Vector3F(-1.0, 2.0, 7.0),
            initialVal: Vector3F(3.0, 5.0, -2.0))
        XCTAssertEqual(Size3(5, 2, 7), grid.resolution())
        XCTAssertEqual(Vector3F(2.0, 4.0, 1.5), grid.gridSpacing())
        XCTAssertEqual(Vector3F(-1.0, 2.0, 7.0), grid.origin())
        
        let faceCenteredGrid = grid as? FaceCenteredGrid3
        faceCenteredGrid!.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(3.0, faceCenteredGrid!.u(i: i, j: j, k: k))
        }
        faceCenteredGrid!.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(5.0, faceCenteredGrid!.v(i: i, j: j, k: k))
        }
        faceCenteredGrid!.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(-2.0, faceCenteredGrid!.w(i: i, j: j, k: k))
        }
        
        let grid2 = FaceCenteredGrid3.builder()
            .withResolution(resolutionX: 5, resolutionY: 2, resolutionZ: 7)
            .withGridSpacing(gridSpacingX: 2.0, gridSpacingY: 4.0, gridSpacingZ: 1.5)
            .withOrigin(gridOriginX: -1.0, gridOriginY: 2.0, gridOriginZ: 7.0)
            .withInitialValue(initialValX: 3.0, initialValY: 5.0, initialValZ: -2.0)
            .build()
        XCTAssertEqual(Size3(5, 2, 7), grid2.resolution())
        XCTAssertEqual(Vector3F(2.0, 4.0, 1.5), grid2.gridSpacing())
        XCTAssertEqual(Vector3F(-1.0, 2.0, 7.0), grid2.origin())
        
        grid2.forEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(3.0, grid2.u(i: i, j: j, k: k))
        }
        grid2.forEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(5.0, grid2.v(i: i, j: j, k: k))
        }
        grid2.forEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(-2.0, grid2.w(i: i, j: j, k: k))
        }
    }
}
