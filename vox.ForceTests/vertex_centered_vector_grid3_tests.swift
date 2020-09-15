//
//  vertex_centered_vector_grid3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class vertex_centered_vector_grid3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        // Default constructors
        let grid1 = VertexCenteredVectorGrid3()
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
        let grid2 = VertexCenteredVectorGrid3(
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
        XCTAssertEqual(6, grid2.dataSize().x)
        XCTAssertEqual(5, grid2.dataSize().y)
        XCTAssertEqual(4, grid2.dataSize().z)
        XCTAssertEqual(4.0, grid2.dataOrigin().x)
        XCTAssertEqual(5.0, grid2.dataOrigin().y)
        XCTAssertEqual(6.0, grid2.dataOrigin().z)
        grid2.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(7.0, grid2[i, j, k].x)
            XCTAssertEqual(8.0, grid2[i, j, k].y)
            XCTAssertEqual(9.0, grid2[i, j, k].z)
        }
        
        // Copy constructor
        let grid3 = VertexCenteredVectorGrid3(other: grid2)
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
            XCTAssertEqual(7.0, grid3[i, j, k].x)
            XCTAssertEqual(8.0, grid3[i, j, k].y)
            XCTAssertEqual(9.0, grid3[i, j, k].z)
        }
    }
    
    func testSwap() {
        let grid1 = VertexCenteredVectorGrid3(
            resolutionX: 5, resolutionY: 4, resolutionZ: 3,
            gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
            originX: 4.0, originY: 5.0, originZ: 6.0,
            initialValueU: 7.0, initialValueV: 8.0, initialValueW: 9.0)
        let grid2 = VertexCenteredVectorGrid3(
            resolutionX: 3, resolutionY: 8, resolutionZ: 5,
            gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
            originX: 5.0, originY: 4.0, originZ: 7.0,
            initialValueU: 8.0, initialValueV: 1.0, initialValueW: 3.0)
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
            XCTAssertEqual(8.0, grid1[i, j, k].x)
            XCTAssertEqual(1.0, grid1[i, j, k].y)
            XCTAssertEqual(3.0, grid1[i, j, k].z)
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
            XCTAssertEqual(7.0, grid2[i, j, k].x)
            XCTAssertEqual(8.0, grid2[i, j, k].y)
            XCTAssertEqual(9.0, grid2[i, j, k].z)
        }
    }
    
    func testSet() {
        let grid1 = VertexCenteredVectorGrid3 (
            resolutionX: 5, resolutionY: 4, resolutionZ: 3,
            gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
            originX: 4.0, originY: 5.0, originZ: 6.0,
            initialValueU: 7.0, initialValueV: 8.0, initialValueW: 9.0)
        let grid2 = VertexCenteredVectorGrid3 (
            resolutionX: 3, resolutionY: 8, resolutionZ: 5,
            gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
            originX: 5.0, originY: 4.0, originZ: 7.0,
            initialValueU: 8.0, initialValueV: 1.0, initialValueW: 3.0)
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
            XCTAssertEqual(8.0, grid1[i, j, k].x)
            XCTAssertEqual(1.0, grid1[i, j, k].y)
            XCTAssertEqual(3.0, grid1[i, j, k].z)
        }
    }
    
    func testAssignmentOperator() {
        var grid1 = VertexCenteredVectorGrid3(
            resolutionX: 5, resolutionY: 4, resolutionZ: 3,
            gridSpacingX: 1.0, gridSpacingY: 2.0, gridSpacingZ: 3.0,
            originX: 4.0, originY: 5.0, originZ: 6.0,
            initialValueU: 7.0, initialValueV: 8.0, initialValueW: 9.0)
        let grid2 = VertexCenteredVectorGrid3(
            resolutionX: 3, resolutionY: 8, resolutionZ: 5,
            gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0,
            originX: 5.0, originY: 4.0, originZ: 7.0,
            initialValueU: 8.0, initialValueV: 1.0, initialValueW: 3.0)
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
            XCTAssertEqual(8.0, grid1[i, j, k].x)
            XCTAssertEqual(1.0, grid1[i, j, k].y)
            XCTAssertEqual(3.0, grid1[i, j, k].z)
        }
    }
    
    func testBuilder() {
        let grid1 = VertexCenteredVectorGrid3.builder().build(
            resolution: Size3(3, 8, 5),
            gridSpacing: Vector3F(2.0, 3.0, 1.0),
            gridOrigin: Vector3F(5.0, 4.0, 7.0),
            initialVal: Vector3F(8.0, 1.0, 3.0))
        
        let grid2 = grid1 as? VertexCenteredVectorGrid3
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
        XCTAssertEqual(4, grid2!.dataSize().x)
        XCTAssertEqual(9, grid2!.dataSize().y)
        XCTAssertEqual(6, grid2!.dataSize().z)
        XCTAssertEqual(5.0, grid2!.dataOrigin().x)
        XCTAssertEqual(4.0, grid2!.dataOrigin().y)
        XCTAssertEqual(7.0, grid2!.dataOrigin().z)
        grid2!.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid2![i, j, k].x)
            XCTAssertEqual(1.0, grid2![i, j, k].y)
            XCTAssertEqual(3.0, grid2![i, j, k].z)
        }
        
        let grid3 = VertexCenteredVectorGrid3.builder()
            .withResolution(resolutionX: 3, resolutionY: 8, resolutionZ: 5)
            .withGridSpacing(gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.0)
            .withOrigin(gridOriginX: 5, gridOriginY: 4, gridOriginZ: 7)
            .withInitialValue(initialValX: 8, initialValY: 1, initialValZ: 3)
            .build()
        
        XCTAssertEqual(3, grid3.resolution().x)
        XCTAssertEqual(8, grid3.resolution().y)
        XCTAssertEqual(5, grid3.resolution().z)
        XCTAssertEqual(2.0, grid3.gridSpacing().x)
        XCTAssertEqual(3.0, grid3.gridSpacing().y)
        XCTAssertEqual(1.0, grid3.gridSpacing().z)
        XCTAssertEqual(5.0, grid3.origin().x)
        XCTAssertEqual(4.0, grid3.origin().y)
        XCTAssertEqual(7.0, grid3.origin().z)
        XCTAssertEqual(4, grid3.dataSize().x)
        XCTAssertEqual(9, grid3.dataSize().y)
        XCTAssertEqual(6, grid3.dataSize().z)
        XCTAssertEqual(5.0, grid3.dataOrigin().x)
        XCTAssertEqual(4.0, grid3.dataOrigin().y)
        XCTAssertEqual(7.0, grid3.dataOrigin().z)
        grid3.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            XCTAssertEqual(8.0, grid3[i, j, k].x)
            XCTAssertEqual(1.0, grid3[i, j, k].y)
            XCTAssertEqual(3.0, grid3[i, j, k].z)
        }
    }
    
    func testFill() {
        let grid = VertexCenteredVectorGrid3(
            resolutionX: 5, resolutionY: 4, resolutionZ: 6,
            gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
            originX: 0.0, originY: 0.0, originZ: 0.0,
            initialValueU: 0.0, initialValueV: 0.0, initialValueW: 0.0)
        grid.fill(value: Vector3F(42.0, 27.0, 31.0))
        
        for k in 0..<grid.dataSize().z {
            for j in 0..<grid.dataSize().y {
                for i in 0..<grid.dataSize().x {
                    XCTAssertEqual(42.0, grid[i, j, k].x)
                    XCTAssertEqual(27.0, grid[i, j, k].y)
                    XCTAssertEqual(31.0, grid[i, j, k].z)
                }
            }
        }
        
        let function = {(x:Vector3F)->Vector3F in
            if (x.x < 3.0) {
                return Vector3F(2.0, 3.0, 1.0)
            } else {
                return Vector3F(5.0, 7.0, 9.0)
            }
        }
        grid.fill(function: function)
        
        for k in 0..<grid.dataSize().z {
            for j in 0..<grid.dataSize().y {
                for i in 0..<grid.dataSize().x {
                    if (i < 3) {
                        XCTAssertEqual(2.0, grid[i, j, k].x)
                        XCTAssertEqual(3.0, grid[i, j, k].y)
                        XCTAssertEqual(1.0, grid[i, j, k].z)
                    } else {
                        XCTAssertEqual(5.0, grid[i, j, k].x)
                        XCTAssertEqual(7.0, grid[i, j, k].y)
                        XCTAssertEqual(9.0, grid[i, j, k].z)
                    }
                }
            }
        }
    }
    
    func testDivergenceAtDataPoint() {
        let grid = VertexCenteredVectorGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6)
        
        grid.fill(value: Vector3F(1.0, -2.0, 3.0))
        
        for k in 0..<grid.resolution().z {
            for j in 0..<grid.resolution().y {
                for i in 0..<grid.resolution().x {
                    XCTAssertEqual(0.0, grid.divergenceAtDataPoint(i: i, j: j, k: k))
                }
            }
        }
        
        grid.fill(){(x:Vector3F)->Vector3F in
            return x
        }
        
        for k in 1..<grid.resolution().z-1 {
            for j in 1..<grid.resolution().y-1 {
                for i in 1..<grid.resolution().x-1 {
                    XCTAssertEqual(3.0, grid.divergenceAtDataPoint(i: i, j: j, k: k))
                }
            }
        }
    }
    
    func testCurlAtDataPoint() {
        let grid = VertexCenteredVectorGrid3(resolutionX: 5, resolutionY: 8, resolutionZ: 6,
                                             gridSpacingX: 2.0, gridSpacingY: 3.0, gridSpacingZ: 1.5)
        
        grid.fill(value: Vector3F(1.0, -2.0, 3.0))
        
        for k in 0..<grid.resolution().z {
            for j in 0..<grid.resolution().y {
                for i in 0..<grid.resolution().x {
                    let curl = grid.curlAtDataPoint(i: i, j: j, k: k)
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
                    let curl = grid.curlAtDataPoint(i: i, j: j, k: k)
                    XCTAssertEqual(-1.0, curl.x)
                    XCTAssertEqual(-1.0, curl.y)
                    XCTAssertEqual(-1.0, curl.z)
                }
            }
        }
    }
}
