//
//  face_centered_grid2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class face_centered_grid2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = FaceCenteredGrid2()
        XCTAssertEqual(0, grid1.resolution().x)
        XCTAssertEqual(0, grid1.resolution().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().x)
        XCTAssertEqual(1.0, grid1.gridSpacing().y)
        XCTAssertEqual(0.0, grid1.origin().x)
        XCTAssertEqual(0.0, grid1.origin().y)
        XCTAssertEqual(0, grid1.uSize().x)
        XCTAssertEqual(0, grid1.uSize().y)
        XCTAssertEqual(0, grid1.vSize().x)
        XCTAssertEqual(0, grid1.vSize().y)
        XCTAssertEqual(0.0, grid1.uOrigin().x)
        XCTAssertEqual(0.5, grid1.uOrigin().y)
        XCTAssertEqual(0.5, grid1.vOrigin().x)
        XCTAssertEqual(0.0, grid1.vOrigin().y)
        
        // Constructor with params
        let grid2 = FaceCenteredGrid2(resolutionX: 5, resolutionY: 4,
                                      gridSpacingX: 1.0, gridSpacingY: 2.0,
                                      originX: 3.0, originY: 4.0,
                                      initialValueU: 5.0, initialValueV: 6.0)
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.origin().x)
        XCTAssertEqual(4.0, grid2.origin().y)
        XCTAssertEqual(6, grid2.uSize().x)
        XCTAssertEqual(4, grid2.uSize().y)
        XCTAssertEqual(5, grid2.vSize().x)
        XCTAssertEqual(5, grid2.vSize().y)
        XCTAssertEqual(3.0, grid2.uOrigin().x)
        XCTAssertEqual(5.0, grid2.uOrigin().y)
        XCTAssertEqual(3.5, grid2.vOrigin().x)
        XCTAssertEqual(4.0, grid2.vOrigin().y)
        grid2.forEachUIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2.u(i: i, j: j))
        }
        grid2.forEachVIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(6.0, grid2.v(i: i, j: j))
        }
        
        // Copy constructor
        let grid3 = FaceCenteredGrid2(other: grid2)
        XCTAssertEqual(5, grid3.resolution().x)
        XCTAssertEqual(4, grid3.resolution().y)
        XCTAssertEqual(1.0, grid3.gridSpacing().x)
        XCTAssertEqual(2.0, grid3.gridSpacing().y)
        XCTAssertEqual(3.0, grid3.origin().x)
        XCTAssertEqual(4.0, grid3.origin().y)
        XCTAssertEqual(6, grid3.uSize().x)
        XCTAssertEqual(4, grid3.uSize().y)
        XCTAssertEqual(5, grid3.vSize().x)
        XCTAssertEqual(5, grid3.vSize().y)
        XCTAssertEqual(3.0, grid3.uOrigin().x)
        XCTAssertEqual(5.0, grid3.uOrigin().y)
        XCTAssertEqual(3.5, grid3.vOrigin().x)
        XCTAssertEqual(4.0, grid3.vOrigin().y)
        grid3.forEachUIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid3.u(i: i, j: j))
        }
        grid3.forEachVIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(6.0, grid3.v(i: i, j: j))
        }
    }
    
    func testFill() {
        let grid = FaceCenteredGrid2(resolutionX: 5, resolutionY: 4,
                                     gridSpacingX: 1.0, gridSpacingY: 1.0,
                                     originX: 0.0, originY: 0.0,
                                     initialValueU: 0.0, initialValueV: 0.0)
        grid.fill(value: Vector2F(42.0, 27.0))
        
        for j in 0..<grid.uSize().y {
            for i in 0..<grid.uSize().x {
                XCTAssertEqual(42.0, grid.u(i: i, j: j))
            }
        }
        
        for j in 0..<grid.vSize().y {
            for i in 0..<grid.vSize().x {
                XCTAssertEqual(27.0, grid.v(i: i, j: j))
            }
        }
        
        let function = {(x:Vector2F)->Vector2F in
            return x
        }
        grid.fill(function: function)
        
        for j in 0..<grid.uSize().y {
            for i in 0..<grid.uSize().x {
                XCTAssertEqual(Float(i), grid.u(i: i, j: j))
            }
        }
        
        for j in 0..<grid.vSize().y {
            for i in 0..<grid.vSize().x {
                XCTAssertEqual(Float(j), grid.v(i: i, j: j))
            }
        }
    }
    
    func testDivergenceAtCellCenter() {
        let grid = FaceCenteredGrid2(resolutionX: 5, resolutionY: 8,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0)
        
        grid.fill(value: Vector2F(1.0, -2.0))
        
        for j in 0..<grid.resolution().y {
            for i in 0..<grid.resolution().x {
                XCTAssertEqual(0.0, grid.divergenceAtCellCenter(i: i, j: j))
            }
        }
        
        grid.fill(){(x:Vector2F)->Vector2F in
            return x
        }
        
        for j in 0..<grid.resolution().y {
            for i in 0..<grid.resolution().x {
                XCTAssertEqual(2.0, grid.divergenceAtCellCenter(i: i, j: j), accuracy: 1e-6)
            }
        }
    }
    
    func testCurlAtCellCenter() {
        let grid = FaceCenteredGrid2(resolutionX: 5, resolutionY: 8,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0)
        
        grid.fill(value: Vector2F(1.0, -2.0))
        
        for j in 0..<grid.resolution().y {
            for i in 0..<grid.resolution().x {
                XCTAssertEqual(0.0, grid.curlAtCellCenter(i: i, j: j))
            }
        }
        
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(-x.y, x.x)
        }
        
        for j in 1..<grid.resolution().y-1 {
            for i in 1..<grid.resolution().x-1 {
                XCTAssertEqual(2.0, grid.curlAtCellCenter(i: i, j: j), accuracy: 1e-6)
            }
        }
    }
    
    func testValueAtCellCenter() {
        let grid = FaceCenteredGrid2(resolutionX: 5, resolutionY: 8,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0)
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(3.0 * x.y + 1.0, 5.0 * x.x + 7.0)
        }
        
        let pos = grid.cellCenterPosition()
        grid.forEachCellIndex(){(i:size_t, j:size_t) in
            let val = grid.valueAtCellCenter(i: i, j: j)
            let x = pos(i, j)
            let expected = Vector2F(3.0 * x.y + 1.0, 5.0 * x.x + 7.0)
            XCTAssertEqual(expected.x, val.x, accuracy: 1e-6)
            XCTAssertEqual(expected.y, val.y, accuracy: 1e-6)
        }
    }
    
    func testSample() {
        let grid = FaceCenteredGrid2(resolutionX: 5, resolutionY: 8,
                                     gridSpacingX: 2.0, gridSpacingY: 3.0)
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(3.0 * x.y + 1.0, 5.0 * x.x + 7.0)
        }
        
        let pos = grid.cellCenterPosition()
        grid.forEachCellIndex(){(i:size_t, j:size_t) in
            let x = pos(i, j)
            let val = grid.sample(x: x)
            let expected = Vector2F(3.0 * x.y + 1.0, 5.0 * x.x + 7.0)
            XCTAssertEqual(expected.x, val.x, accuracy: 1e-6)
            XCTAssertEqual(expected.y, val.y, accuracy: 1e-6)
        }
    }
    
    func testBuilder() {
        let builder = FaceCenteredGrid2.builder()
        
        let grid = builder.build(
            resolution: Size2(5, 2),
            gridSpacing: Vector2F(2.0, 4.0),
            gridOrigin: Vector2F(-1.0, 2.0),
            initialVal: Vector2F(3.0, 5.0))
        XCTAssertEqual(Size2(5, 2), grid.resolution())
        XCTAssertEqual(Vector2F(2.0, 4.0), grid.gridSpacing())
        XCTAssertEqual(Vector2F(-1.0, 2.0), grid.origin())
        
        let faceCenteredGrid
            = grid as? FaceCenteredGrid2
        XCTAssertTrue(faceCenteredGrid != nil)
        
        faceCenteredGrid!.forEachUIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(3.0, faceCenteredGrid!.u(i: i, j: j))
        }
        faceCenteredGrid!.forEachVIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, faceCenteredGrid!.v(i: i, j: j))
        }
        
        let grid2 = FaceCenteredGrid2.builder()
            .withResolution(resolutionX: 5, resolutionY: 2)
            .withGridSpacing(gridSpacingX: 2, gridSpacingY: 4)
            .withOrigin(gridOriginX: -1, gridOriginY: 2)
            .withInitialValue(initialValX: 3, initialValY: 5)
            .build()
        
        XCTAssertEqual(Size2(5, 2), grid2.resolution())
        XCTAssertEqual(Vector2F(2.0, 4.0), grid2.gridSpacing())
        XCTAssertEqual(Vector2F(-1.0, 2.0), grid2.origin())
        
        grid2.forEachUIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(3.0, grid2.u(i: i, j: j))
        }
        grid2.forEachVIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2.v(i: i, j: j))
        }
    }
}
