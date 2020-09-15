//
//  vertex_centered_scalar_grid3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vertex_centered_scalar_grid3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = VertexCenteredScalarGrid3()
        XCTAssertEqual(0, grid1.resolution().x)
        XCTAssertEqual(0, grid1.resolution().y)
        XCTAssertEqual(0, grid1.resolution().z)
        XCTAssertEqual(1.0, grid1.gridSpacing().x)
        XCTAssertEqual(1.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(0.0, grid1.origin().x)
        XCTAssertEqual(0.0, grid1.origin().y)
        XCTAssertEqual(0.0, grid1.origin().z)
        XCTAssertEqual(0, grid1.dataSize().x)
        XCTAssertEqual(0, grid1.dataSize().y)
        XCTAssertEqual(0, grid1.dataSize().z)
        XCTAssertEqual(0.0, grid1.dataOrigin().x)
        XCTAssertEqual(0.0, grid1.dataOrigin().y)
        XCTAssertEqual(0.0, grid1.dataOrigin().z)
        
        // Constructor with params
        let grid2 = VertexCenteredScalarGrid3(resolutionX: 5, resolutionY: 4, resolutionZ: 3,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
                                              originX: 4.0, originY: 5.0, originZ: 6.0, initialValue: 7.0)
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(3, grid2.resolution().z)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.gridSpacing().z)
        XCTAssertEqual(4.0, grid2.origin().x)
        XCTAssertEqual(5.0, grid2.origin().y)
        XCTAssertEqual(6.0, grid2.origin().z)
        XCTAssertEqual(6, grid2.dataSize().x)
        XCTAssertEqual(5, grid2.dataSize().y)
        XCTAssertEqual(4, grid2.dataSize().z)
        XCTAssertEqual(4.0, grid2.dataOrigin().x)
        XCTAssertEqual(5.0, grid2.dataOrigin().y)
        XCTAssertEqual(6.0, grid2.dataOrigin().z)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid2[i, j, k])
        }
        
        // Copy constructor
        let grid3 = VertexCenteredScalarGrid3(other: grid2)
        XCTAssertEqual(5, grid3.resolution().x)
        XCTAssertEqual(4, grid3.resolution().y)
        XCTAssertEqual(3, grid3.resolution().z)
        XCTAssertEqual(1.0, grid3.gridSpacing().x)
        XCTAssertEqual(2.0, grid3.gridSpacing().y)
        XCTAssertEqual(3.0, grid3.gridSpacing().z)
        XCTAssertEqual(4.0, grid3.origin().x)
        XCTAssertEqual(5.0, grid3.origin().y)
        XCTAssertEqual(6.0, grid3.origin().z)
        XCTAssertEqual(6, grid3.dataSize().x)
        XCTAssertEqual(5, grid3.dataSize().y)
        XCTAssertEqual(4, grid3.dataSize().z)
        XCTAssertEqual(4.0, grid3.dataOrigin().x)
        XCTAssertEqual(5.0, grid3.dataOrigin().y)
        XCTAssertEqual(6.0, grid3.dataOrigin().z)
        grid3.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid3[i, j, k])
        }
    }
    
    func testSwap() {
        let grid1 = VertexCenteredScalarGrid3(resolutionX: 5, resolutionY: 4, resolutionZ: 3,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
                                              originX: 4.0, originY: 5.0, originZ: 6.0, initialValue: 7.0)
        let grid2 = VertexCenteredScalarGrid3(resolutionX: 3, resolutionY: 8, resolutionZ: 5,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
                                              originX: 5.0, originY: 4.0, originZ: 7.0, initialValue: 8.0)
        var father_grid:Grid3 = grid2 as Grid3
        grid1.swap(other: &father_grid)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(5, grid1.resolution().z)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(5.0, grid1.origin().x)
        XCTAssertEqual(4.0, grid1.origin().y)
        XCTAssertEqual(7.0, grid1.origin().z)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(6, grid1.dataSize().z)
        XCTAssertEqual(5.0, grid1.dataOrigin().x)
        XCTAssertEqual(4.0, grid1.dataOrigin().y)
        XCTAssertEqual(7.0, grid1.dataOrigin().z)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid1[i, j, k])
        }
        
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(3, grid2.resolution().z)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.gridSpacing().z)
        XCTAssertEqual(4.0, grid2.origin().x)
        XCTAssertEqual(5.0, grid2.origin().y)
        XCTAssertEqual(6.0, grid2.origin().z)
        XCTAssertEqual(6, grid2.dataSize().x)
        XCTAssertEqual(5, grid2.dataSize().y)
        XCTAssertEqual(4, grid2.dataSize().z)
        XCTAssertEqual(4.0, grid2.dataOrigin().x)
        XCTAssertEqual(5.0, grid2.dataOrigin().y)
        XCTAssertEqual(6.0, grid2.dataOrigin().z)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid2[i, j, k])
        }
    }
    
    func testSet() {
        let grid1 = VertexCenteredScalarGrid3(resolutionX: 5, resolutionY: 4, resolutionZ: 3,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
                                              originX: 4.0, originY: 5.0, originZ: 6.0, initialValue: 7.0)
        let grid2 = VertexCenteredScalarGrid3(resolutionX: 3, resolutionY: 8, resolutionZ: 5,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
                                              originX: 5.0, originY: 4.0, originZ: 7.0, initialValue: 8.0)
        grid1.set(other: grid2)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(5, grid1.resolution().z)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(5.0, grid1.origin().x)
        XCTAssertEqual(4.0, grid1.origin().y)
        XCTAssertEqual(7.0, grid1.origin().z)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(6, grid1.dataSize().z)
        XCTAssertEqual(5.0, grid1.dataOrigin().x)
        XCTAssertEqual(4.0, grid1.dataOrigin().y)
        XCTAssertEqual(7.0, grid1.dataOrigin().z)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid1[i, j, k])
        }
    }
    
    func testAssignmentOperator() {
        var grid1 = VertexCenteredScalarGrid3(resolutionX: 5, resolutionY: 4, resolutionZ: 3,
                                              gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
                                              originX: 4.0, originY: 5.0, originZ: 6.0, initialValue: 7.0)
        let grid2 = VertexCenteredScalarGrid3(resolutionX: 3, resolutionY: 8, resolutionZ: 5,
                                              gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
                                              originX: 5.0, originY: 4.0, originZ: 7.0, initialValue: 8.0)
        grid1 = grid2
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(5, grid1.resolution().z)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(5.0, grid1.origin().x)
        XCTAssertEqual(4.0, grid1.origin().y)
        XCTAssertEqual(7.0, grid1.origin().z)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(6, grid1.dataSize().z)
        XCTAssertEqual(5.0, grid1.dataOrigin().x)
        XCTAssertEqual(4.0, grid1.dataOrigin().y)
        XCTAssertEqual(7.0, grid1.dataOrigin().z)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid1[i, j, k])
        }
    }
    
    func testBuilder() {
        var grid1 = VertexCenteredScalarGrid3.builder().build(
            resolution: Size3(3, 8, 5),
            gridSpacing: Vector3F(2.0, 3.0, 1.0),
            gridOrigin: Vector3F(5.0, 4.0, 7.0),
            initialVal: 8.0)
        
        let grid2
            = grid1 as? VertexCenteredScalarGrid3
        XCTAssertTrue(grid2 != nil)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(5, grid1.resolution().z)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(5.0, grid1.origin().x)
        XCTAssertEqual(4.0, grid1.origin().y)
        XCTAssertEqual(7.0, grid1.origin().z)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(6, grid1.dataSize().z)
        XCTAssertEqual(5.0, grid1.dataOrigin().x)
        XCTAssertEqual(4.0, grid1.dataOrigin().y)
        XCTAssertEqual(7.0, grid1.dataOrigin().z)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid1[i, j, k])
        }
        
        grid1 = VertexCenteredScalarGrid3.builder()
            .withResolution(resolutionX: 3, resolutionY: 8, resolutionZ: 5)
            .withGridSpacing(gridSpacingX: 2, gridSpacingY: 3, gridSpacingZ: 1)
            .withOrigin(gridOriginX: 5, gridOriginY: 4, gridOriginZ: 7)
            .withInitialValue(initialVal: 8.0)
            .build()
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(5, grid1.resolution().z)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().z)
        XCTAssertEqual(5.0, grid1.origin().x)
        XCTAssertEqual(4.0, grid1.origin().y)
        XCTAssertEqual(7.0, grid1.origin().z)
        XCTAssertEqual(4, grid1.dataSize().x)
        XCTAssertEqual(9, grid1.dataSize().y)
        XCTAssertEqual(6, grid1.dataSize().z)
        XCTAssertEqual(5.0, grid1.dataOrigin().x)
        XCTAssertEqual(4.0, grid1.dataOrigin().y)
        XCTAssertEqual(7.0, grid1.dataOrigin().z)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid1[i, j, k])
        }
    }
    
    func testFill() {
        let grid = VertexCenteredScalarGrid3(resolutionX: 5, resolutionY: 4, resolutionZ: 6,
                                             gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
                                             originX: 0.0, originY: 0.0, originZ: 0.0, initialValue: 0.0)
        grid.fill(value: 42.0)
        
        for k in 0..<grid.dataSize().z {
            for j in 0..<grid.dataSize().y {
                for i in 0..<grid.dataSize().x {
                    XCTAssertEqual(42.0, grid[i, j, k])
                }
            }
        }
        
        let function = {(x:Vector3F)->Float in
            if (x.x < 3.0) {
                return 2.0
            } else {
                return 5.0
            }
        }
        
        grid.fill(function: function)
        
        for k in 0..<grid.dataSize().z {
            for j in 0..<grid.dataSize().y {
                for i in 0..<grid.dataSize().x {
                    if (i < 3) {
                        XCTAssertEqual(2.0, grid[i, j, k])
                    } else {
                        XCTAssertEqual(5.0, grid[i, j, k])
                    }
                }
            }
        }
    }
}
