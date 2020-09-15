//
//  vertex_centered_scalar_grid2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vertex_centered_scalar_grid2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = VertexCenteredScalarGrid2()
        XCTAssertEqual(0, grid1.resolution().x)
        XCTAssertEqual(0, grid1.resolution().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().x)
        XCTAssertEqual(1.0, grid1.gridSpacing().y)
        XCTAssertEqual(0.0, grid1.origin().x)
        XCTAssertEqual(0.0, grid1.origin().y)
        XCTAssertEqual(0, grid1.dataSize().x)
        XCTAssertEqual(0, grid1.dataSize().y)
        XCTAssertEqual(0.0, grid1.dataOrigin().x)
        XCTAssertEqual(0.0, grid1.dataOrigin().y)
        
        // Constructor with params
        let grid2 = VertexCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0,
                                              originX: 3.0, originY: 4.0, initialValue: 5.0)
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.origin().x)
        XCTAssertEqual(4.0, grid2.origin().y)
        XCTAssertEqual(6, grid2.dataSize().x)
        XCTAssertEqual(5, grid2.dataSize().y)
        XCTAssertEqual(3.0, grid2.dataOrigin().x)
        XCTAssertEqual(4.0, grid2.dataOrigin().y)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2[i, j])
        }
        
        // Copy constructor
        let grid3 = VertexCenteredScalarGrid2(other: grid2)
        XCTAssertEqual(5, grid3.resolution().x)
        XCTAssertEqual(4, grid3.resolution().y)
        XCTAssertEqual(1.0, grid3.gridSpacing().x)
        XCTAssertEqual(2.0, grid3.gridSpacing().y)
        XCTAssertEqual(3.0, grid3.origin().x)
        XCTAssertEqual(4.0, grid3.origin().y)
        XCTAssertEqual(6, grid3.dataSize().x)
        XCTAssertEqual(5, grid3.dataSize().y)
        XCTAssertEqual(3.0, grid3.dataOrigin().x)
        XCTAssertEqual(4.0, grid3.dataOrigin().y)
        grid3.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid3[i, j])
        }
    }
    
    func testSwap() {
        let grid1 = VertexCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0,
                                              originX: 3.0, originY: 4.0,
                                              initialValue: 5.0)
        let grid2 = VertexCenteredScalarGrid2(resolutionX: 3, resolutionY: 8,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0,
                                              originX: 1.0, originY: 5.0,
                                              initialValue: 4.0)
        var father_grid:Grid2 = grid2 as Grid2
        grid1.swap(other: &father_grid)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(1.0, grid1.dataOrigin().x)
        XCTAssertEqual(5.0, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j])
        }
        
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.origin().x)
        XCTAssertEqual(4.0, grid2.origin().y)
        XCTAssertEqual(6, grid2.dataSize().x)
        XCTAssertEqual(5, grid2.dataSize().y)
        XCTAssertEqual(3.0, grid2.dataOrigin().x)
        XCTAssertEqual(4.0, grid2.dataOrigin().y)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2[i, j])
        }
    }
    
    func testSet() {
        let grid1 = VertexCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0,
                                              originX: 3.0, originY: 4.0, initialValue: 5.0)
        let grid2 = VertexCenteredScalarGrid2(resolutionX: 3, resolutionY: 8,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0,
                                              originX: 1.0, originY: 5.0, initialValue: 4.0)
        grid1.set(other: grid2)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(1.0, grid1.dataOrigin().x)
        XCTAssertEqual(5.0, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j])
        }
    }
    
    func testAssignmentOperator() {
        var grid1 = VertexCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0,
                                              originX: 3.0, originY: 4.0, initialValue: 5.0)
        let grid2 = VertexCenteredScalarGrid2(resolutionX: 3, resolutionY: 8,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0,
                                              originX: 1.0, originY: 5.0, initialValue: 4.0)
        grid1 = grid2
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(1.0, grid1.dataOrigin().x)
        XCTAssertEqual(5.0, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j])
        }
    }
    
    func testBuilder() {
        var grid1 = VertexCenteredScalarGrid2.builder().build(
            resolution: Size2(3, 8),
            gridSpacing: Vector2F(2.0, 3.0),
            gridOrigin: Vector2F(1.0, 5.0), initialVal: 4.0)
        
        let grid2 = grid1 as? VertexCenteredScalarGrid2
        XCTAssertTrue(grid2 != nil)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(1.0, grid1.dataOrigin().x)
        XCTAssertEqual(5.0, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j])
        }
        
        grid1 = VertexCenteredScalarGrid2.builder()
            .withResolution(resolutionX: 3, resolutionY: 8)
            .withGridSpacing(gridSpacingX: 2, gridSpacingY: 3)
            .withOrigin(gridOriginX: 1, gridOriginY: 5)
            .withInitialValue(initialVal: 4)
            .build()
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(1.0, grid1.dataOrigin().x)
        XCTAssertEqual(5.0, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j])
        }
    }
    
    func testFill() {
        let grid = VertexCenteredScalarGrid2(resolutionX: 5, resolutionY: 4,
                                             gridSpacingX: 1.0, gridSpacingY: 1.0,
                                             originX: 0.0, originY: 0.0, initialValue: 0.0)
        grid.fill(value: 42.0)
        
        for j in 0..<grid.dataSize().y {
            for i in 0..<grid.dataSize().x {
                XCTAssertEqual(42.0, grid[i, j])
            }
        }
        
        let function = {(x:Vector2F)->Float in
            if (x.x < 3.0) {
                return 2.0
            } else {
                return 5.0
            }
        }
        grid.fill(function: function)
        
        for j in 0..<4 {
            for i in 0..<5 {
                if (i < 3) {
                    XCTAssertEqual(2.0, grid[i, j])
                } else {
                    XCTAssertEqual(5.0, grid[i, j])
                }
            }
        }
    }
}
