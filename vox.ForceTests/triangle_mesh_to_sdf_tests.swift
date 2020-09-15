//
//  triangle_mesh_to_sdf_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class triangle_mesh_to_sdf_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTriangleMeshToSdf() throws {
        let mesh = TriangleMesh3()
        
        // Build a cube
        mesh.addPoint(pt: [0.0, 0.0, 0.0])
        mesh.addPoint(pt: [0.0, 0.0, 1.0])
        mesh.addPoint(pt: [0.0, 1.0, 0.0])
        mesh.addPoint(pt: [0.0, 1.0, 1.0])
        mesh.addPoint(pt: [1.0, 0.0, 0.0])
        mesh.addPoint(pt: [1.0, 0.0, 1.0])
        mesh.addPoint(pt: [1.0, 1.0, 0.0])
        mesh.addPoint(pt: [1.0, 1.0, 1.0])
        
        mesh.addPointTriangle(newPointIndices: [0, 1, 3])
        mesh.addPointTriangle(newPointIndices: [0, 3, 2])
        mesh.addPointTriangle(newPointIndices: [4, 6, 7])
        mesh.addPointTriangle(newPointIndices: [4, 7, 5])
        mesh.addPointTriangle(newPointIndices: [0, 4, 5])
        mesh.addPointTriangle(newPointIndices: [0, 5, 1])
        mesh.addPointTriangle(newPointIndices: [2, 3, 7])
        mesh.addPointTriangle(newPointIndices: [2, 7, 6])
        mesh.addPointTriangle(newPointIndices: [0, 2, 6])
        mesh.addPointTriangle(newPointIndices: [0, 6, 4])
        mesh.addPointTriangle(newPointIndices: [1, 5, 7])
        mesh.addPointTriangle(newPointIndices: [1, 7, 3])
        
        var grid:ScalarGrid3 =
            CellCenteredScalarGrid3 (resolutionX: 3, resolutionY: 3, resolutionZ: 3,
                                     gridSpacingX: 1.0, gridSpacingY: 1.0, gridSpacingZ: 1.0,
                                     originX: -1.0, originY: -1.0, originZ: -1.0)
        
        triangleMeshToSdf(mesh: mesh, sdf: &grid, exactBand: 10)
        
        let box = Box3(lowerCorner: Vector3F(), upperCorner: Vector3F(1.0, 1.0, 1.0))
        
        let gridPos = grid.dataPosition()
        grid.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            let pos = gridPos(i, j, k)
            var ans = box.closestDistance(otherPoint: pos)
            ans *= box.bound.contains(point: pos) ? -1.0 : 1.0
            XCTAssertEqual(ans, grid[i, j, k])
        }
    }
}
