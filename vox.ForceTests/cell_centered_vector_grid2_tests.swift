//
//  cell_centered_vector_grid2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/5.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class cell_centered_vector_grid2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = CellCenteredVectorGrid2()
        XCTAssertEqual(0, grid1.resolution().x)
        XCTAssertEqual(0, grid1.resolution().y)
        XCTAssertEqual(1.0, grid1.gridSpacing().x)
        XCTAssertEqual(1.0, grid1.gridSpacing().y)
        XCTAssertEqual(0.0, grid1.origin().x)
        XCTAssertEqual(0.0, grid1.origin().y)
        XCTAssertEqual(0, grid1.dataSize().x)
        XCTAssertEqual(0, grid1.dataSize().y)
        XCTAssertEqual(0.5, grid1.dataOrigin().x)
        XCTAssertEqual(0.5, grid1.dataOrigin().y)
        
        // Constructor with params
        let grid2 = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 4,
                                            gridSpacingX: 1.0, gridSpacingY: 2.0,
                                            originX: 3.0, originY: 4.0,
                                            initialValueU: 5.0, initialValueV: 6.0)
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.origin().x)
        XCTAssertEqual(4.0, grid2.origin().y)
        XCTAssertEqual(5, grid2.dataSize().x)
        XCTAssertEqual(4, grid2.dataSize().y)
        XCTAssertEqual(3.5, grid2.dataOrigin().x)
        XCTAssertEqual(5.0, grid2.dataOrigin().y)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2[i, j].x)
            XCTAssertEqual(6.0, grid2[i, j].y)
        }
        
        // Copy constructor
        let grid3 = CellCenteredVectorGrid2(other: grid2)
        XCTAssertEqual(5, grid3.resolution().x)
        XCTAssertEqual(4, grid3.resolution().y)
        XCTAssertEqual(1.0, grid3.gridSpacing().x)
        XCTAssertEqual(2.0, grid3.gridSpacing().y)
        XCTAssertEqual(3.0, grid3.origin().x)
        XCTAssertEqual(4.0, grid3.origin().y)
        XCTAssertEqual(5, grid3.dataSize().x)
        XCTAssertEqual(4, grid3.dataSize().y)
        XCTAssertEqual(3.5, grid3.dataOrigin().x)
        XCTAssertEqual(5.0, grid3.dataOrigin().y)
        grid3.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid3[i, j].x)
            XCTAssertEqual(6.0, grid3[i, j].y)
        }
    }
    
    func testSwap() {
        let grid1 = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 4,
                                            gridSpacingX: 1.0, gridSpacingY: 2.0,
                                            originX: 3.0, originY: 4.0,
                                            initialValueU: 5.0, initialValueV: 6.0)
        let grid2 = CellCenteredVectorGrid2(resolutionX: 3, resolutionY: 8,
                                            gridSpacingX: 2.0, gridSpacingY: 3.0,
                                            originX: 1.0, originY: 5.0,
                                            initialValueU: 4.0, initialValueV: 7.0)
        var father_grid:Grid2 = grid2 as Grid2
        grid1.swap(other: &father_grid)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(3, grid1.dataSize().x)
        XCTAssertEqual(8, grid1.dataSize().y)
        XCTAssertEqual(2.0, grid1.dataOrigin().x)
        XCTAssertEqual(6.5, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j].x)
            XCTAssertEqual(7.0, grid1[i, j].y)
        }
        
        XCTAssertEqual(5, grid2.resolution().x)
        XCTAssertEqual(4, grid2.resolution().y)
        XCTAssertEqual(1.0, grid2.gridSpacing().x)
        XCTAssertEqual(2.0, grid2.gridSpacing().y)
        XCTAssertEqual(3.0, grid2.origin().x)
        XCTAssertEqual(4.0, grid2.origin().y)
        XCTAssertEqual(5, grid2.dataSize().x)
        XCTAssertEqual(4, grid2.dataSize().y)
        XCTAssertEqual(3.5, grid2.dataOrigin().x)
        XCTAssertEqual(5.0, grid2.dataOrigin().y)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(5.0, grid2[i, j].x)
            XCTAssertEqual(6.0, grid2[i, j].y)
        }
    }
    
    func testSet() {
        let grid1 = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 4,
                                            gridSpacingX: 1.0, gridSpacingY: 2.0,
                                            originX: 3.0, originY: 4.0,
                                            initialValueU: 5.0, initialValueV: 6.0)
        let grid2 = CellCenteredVectorGrid2(resolutionX: 3, resolutionY: 8,
                                            gridSpacingX: 2.0, gridSpacingY: 3.0,
                                            originX: 1.0, originY: 5.0,
                                            initialValueU: 4.0, initialValueV: 7.0)
        grid1.set(other: grid2)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(3, grid1.dataSize().x)
        XCTAssertEqual(8, grid1.dataSize().y)
        XCTAssertEqual(2.0, grid1.dataOrigin().x)
        XCTAssertEqual(6.5, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j].x)
            XCTAssertEqual(7.0, grid1[i, j].y)
        }
    }
    
    func testAssignmentOperator() {
        var grid1 = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 4,
                                            gridSpacingX: 1.0, gridSpacingY: 2.0,
                                            originX: 3.0, originY: 4.0,
                                            initialValueU: 5.0, initialValueV: 6.0)
        let grid2 = CellCenteredVectorGrid2(resolutionX: 3, resolutionY: 8,
                                            gridSpacingX: 2.0, gridSpacingY: 3.0,
                                            originX: 1.0, originY: 5.0,
                                            initialValueU: 4.0, initialValueV: 7.0)
        grid1 = grid2
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(3, grid1.dataSize().x)
        XCTAssertEqual(8, grid1.dataSize().y)
        XCTAssertEqual(2.0, grid1.dataOrigin().x)
        XCTAssertEqual(6.5, grid1.dataOrigin().y)
        grid1.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid1[i, j].x)
            XCTAssertEqual(7.0, grid1[i, j].y)
        }
    }
    
    func testBuilder() {
        let grid1 = CellCenteredVectorGrid2.builder().build(
            resolution: Size2(3, 8),
            gridSpacing: Vector2F(2.0, 3.0),
            gridOrigin: Vector2F(1.0, 5.0),
            initialVal: Vector2F(4.0, 7.0))
        
        let grid2 = grid1 as? CellCenteredVectorGrid2
        XCTAssertTrue(grid2 != nil)
        
        XCTAssertEqual(3, grid1.resolution().x)
        XCTAssertEqual(8, grid1.resolution().y)
        XCTAssertEqual(2.0, grid1.gridSpacing().x)
        XCTAssertEqual(3.0, grid1.gridSpacing().y)
        XCTAssertEqual(1.0, grid1.origin().x)
        XCTAssertEqual(5.0, grid1.origin().y)
        XCTAssertEqual(3, grid2!.dataSize().x)
        XCTAssertEqual(8, grid2!.dataSize().y)
        XCTAssertEqual(2.0, grid2!.dataOrigin().x)
        XCTAssertEqual(6.5, grid2!.dataOrigin().y)
        grid2!.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid2![i, j].x)
            XCTAssertEqual(7.0, grid2![i, j].y)
        }
        
        let grid3 = CellCenteredVectorGrid2.builder()
            .withResolution(resolutionX: 3, resolutionY: 8)
            .withGridSpacing(gridSpacingX: 2, gridSpacingY: 3)
            .withOrigin(gridOriginX: 1, gridOriginY: 5)
            .withInitialValue(initialValX: 4, initialValY: 7)
            .build()
        
        XCTAssertEqual(3, grid3.resolution().x)
        XCTAssertEqual(8, grid3.resolution().y)
        XCTAssertEqual(2.0, grid3.gridSpacing().x)
        XCTAssertEqual(3.0, grid3.gridSpacing().y)
        XCTAssertEqual(1.0, grid3.origin().x)
        XCTAssertEqual(5.0, grid3.origin().y)
        XCTAssertEqual(3, grid3.dataSize().x)
        XCTAssertEqual(8, grid3.dataSize().y)
        XCTAssertEqual(2.0, grid3.dataOrigin().x)
        XCTAssertEqual(6.5, grid3.dataOrigin().y)
        grid3.forEachDataPointIndex(){(i:size_t, j:size_t) in
            XCTAssertEqual(4.0, grid3[i, j].x)
            XCTAssertEqual(7.0, grid3[i, j].y)
        }
    }
    
    func testFill() {
        let grid = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 4,
                                           gridSpacingX: 1.0, gridSpacingY: 1.0,
                                           originX: 0.0, originY: 0.0,
                                           initialValueU: 0.0, initialValueV: 0.0)
        grid.fill(value: Vector2F(42.0, 27.0))
        
        for j in 0..<grid.dataSize().y {
            for i in 0..<grid.dataSize().x {
                XCTAssertEqual(42.0, grid[i, j].x)
                XCTAssertEqual(27.0, grid[i, j].y)
            }
        }
        
        let function = {(x:Vector2F)->Vector2F in
            if (x.x < 3.0) {
                return Vector2F(2.0, 3.0)
            } else {
                return Vector2F(5.0, 7.0)
            }
        }
        grid.fill(function: function)
        
        for j in 0..<grid.dataSize().y {
            for i in 0..<grid.dataSize().x {
                if (i < 3) {
                    XCTAssertEqual(2.0, grid[i, j].x)
                    XCTAssertEqual(3.0, grid[i, j].y)
                } else {
                    XCTAssertEqual(5.0, grid[i, j].x)
                    XCTAssertEqual(7.0, grid[i, j].y)
                }
            }
        }
    }
    
    func testDivergenceAtDataPoint() {
        let grid = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 8,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0)
        
        grid.fill(value: Vector2F(1.0, -2.0))
        
        for j in 0..<grid.resolution().y {
            for i in 0..<grid.resolution().x {
                XCTAssertEqual(0.0, grid.divergenceAtDataPoint(i: i, j: j))
            }
        }
        
        grid.fill(){(x:Vector2F)->Vector2F in
            return x
        }
        
        for j in 1..<grid.resolution().y-1 {
            for i in 1..<grid.resolution().x-1 {
                XCTAssertEqual(2.0, grid.divergenceAtDataPoint(i: i, j: j), accuracy:1e-6)
            }
        }
    }
    
    func testCurlAtAtDataPoint() {
        let grid = CellCenteredVectorGrid2(resolutionX: 5, resolutionY: 8,
                                           gridSpacingX: 2.0, gridSpacingY: 3.0)
        
        grid.fill(value: Vector2F(1.0, -2.0))
        
        for j in 0..<grid.resolution().y {
            for i in 0..<grid.resolution().x {
                XCTAssertEqual(0.0, grid.curlAtDataPoint(i: i, j: j))
            }
        }
        
        grid.fill(){(x:Vector2F)->Vector2F in
            return Vector2F(-x.y, x.x)
        }
        
        for j in 1..<grid.resolution().y-1 {
            for i in 1..<grid.resolution().x-1 {
                XCTAssertEqual(2.0, grid.curlAtDataPoint(i: i, j: j), accuracy: 1e-6)
            }
        }
    }
}
