//
//  marching_cubes_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class marching_cubes_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConnectivity() throws {
        var triMesh = TriangleMesh3()
        
        var grid = Array3<Float>(width: 2, height: 2, depth: 2)
        grid[0, 0, 0] = -0.5
        grid[0, 0, 1] = -0.5
        grid[0, 1, 0] = 0.5
        grid[0, 1, 1] = 0.5
        grid[1, 0, 0] = -0.5
        grid[1, 0, 1] = -0.5
        grid[1, 1, 0] = 0.5
        grid[1, 1, 1] = 0.5
        
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionNone)
        XCTAssertEqual(24, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionBack)
        XCTAssertEqual(22, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionFront)
        XCTAssertEqual(22, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionLeft)
        XCTAssertEqual(22, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionRight)
        XCTAssertEqual(22, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionDown)
        XCTAssertEqual(24, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionUp)
        XCTAssertEqual(24, triMesh.numberOfPoints())
        
        triMesh.clear()
        marchingCubes(grid: grid.constAccessor(), gridSize: Vector3F(1, 1, 1),
                      origin: Vector3F(), mesh: &triMesh, isoValue: 0,
                      bndClose: kDirectionAll, bndConnectivity: kDirectionAll)
        XCTAssertEqual(8, triMesh.numberOfPoints())
    }
}
