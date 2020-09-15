//
//  triangle_mesh_to_sdf_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class TriangleMeshToSdfRenderable: Renderable {
    var triMesh2 = TriangleMesh3()
    
    func Cube() {
        let triMesh = TriangleMesh3()
        
        triMesh.addPoint(pt: [0, 0, 0])
        triMesh.addPoint(pt: [0, 0, 1])
        triMesh.addPoint(pt: [0, 1, 0])
        triMesh.addPoint(pt: [0, 1, 1])
        triMesh.addPoint(pt: [1, 0, 0])
        triMesh.addPoint(pt: [1, 0, 1])
        triMesh.addPoint(pt: [1, 1, 0])
        triMesh.addPoint(pt: [1, 1, 1])
        
        // -x
        triMesh.addPointTriangle(newPointIndices: [0, 1, 3])
        triMesh.addPointTriangle(newPointIndices: [0, 3, 2])
        
        // +x
        triMesh.addPointTriangle(newPointIndices: [4, 6, 7])
        triMesh.addPointTriangle(newPointIndices: [4, 7, 5])
        
        // -y
        triMesh.addPointTriangle(newPointIndices: [0, 4, 5])
        triMesh.addPointTriangle(newPointIndices: [0, 5, 1])
        
        // +y
        triMesh.addPointTriangle(newPointIndices: [2, 3, 7])
        triMesh.addPointTriangle(newPointIndices: [2, 7, 6])
        
        // -z
        triMesh.addPointTriangle(newPointIndices: [0, 2, 6])
        triMesh.addPointTriangle(newPointIndices: [0, 6, 4])
        
        // +z
        triMesh.addPointTriangle(newPointIndices: [1, 5, 7])
        triMesh.addPointTriangle(newPointIndices: [1, 7, 3])
        
        var grid: ScalarGrid3 = VertexCenteredScalarGrid3(resolutionX: 64, resolutionY: 64, resolutionZ: 64,
                                                          gridSpacingX: 3.0/64, gridSpacingY: 3.0/64, gridSpacingZ: 3.0/64,
                                                          originX: -1.0, originY: -1.0, originZ: -1.0)
        
        triangleMeshToSdf(mesh: triMesh, sdf: &grid)
        
        var temp = Array2<Float>(width: 64, height: 64)
        for j in 0..<64 {
            for i in 0..<64 {
                temp[i, j] = grid[i, j, 32]
            }
        }
        
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh2,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func Bunny() {
        let triMesh = TriangleMesh3()
        triMesh.readObj(filename: "bunny.obj")
        
        var box = triMesh.boundingBox()
        let scale = Vector3F(box.width(), box.height(), box.depth())
        box.lowerCorner -= 0.2 * scale
        box.upperCorner += 0.2 * scale
        
        var grid: ScalarGrid3 = VertexCenteredScalarGrid3(
            resolutionX: 100, resolutionY: 100, resolutionZ: 100,
            gridSpacingX: box.width() / 100, gridSpacingY: box.height() / 100, gridSpacingZ: box.depth() / 100,
            originX: box.lowerCorner.x, originY: box.lowerCorner.y, originZ: box.lowerCorner.z)
        
        triangleMeshToSdf(mesh: triMesh, sdf: &grid)
        
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh2,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func Dragon() {
        let triMesh = TriangleMesh3()
        triMesh.readObj(filename: "dragon.obj")
        
        var box = triMesh.boundingBox()
        let scale = Vector3F(box.width(), box.height(), box.depth())
        box.lowerCorner -= 0.2 * scale
        box.upperCorner += 0.2 * scale
        
        var grid: ScalarGrid3 = VertexCenteredScalarGrid3(
            resolutionX: 100, resolutionY: 100, resolutionZ: 100,
            gridSpacingX: box.width() / 100, gridSpacingY: box.height() / 100, gridSpacingZ: box.depth() / 100,
            originX: box.lowerCorner.x, originY: box.lowerCorner.y, originZ: box.lowerCorner.z)
        
        triangleMeshToSdf(mesh: triMesh, sdf: &grid)
        
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh2,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
