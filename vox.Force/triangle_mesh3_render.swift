//
//  triangle_mesh3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class TriangleMesh3Renderable: Renderable {
    let triMesh = TriangleMesh3()
    
    func PointsOnlyGeometries() {
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
    }
    
    func PointsAndNormalGeometries() {
        triMesh.addPoint(pt: [0, 0, 0])
        triMesh.addPoint(pt: [0, 0, 1])
        triMesh.addPoint(pt: [0, 1, 0])
        triMesh.addPoint(pt: [0, 1, 1])
        triMesh.addPoint(pt: [1, 0, 0])
        triMesh.addPoint(pt: [1, 0, 1])
        triMesh.addPoint(pt: [1, 1, 0])
        triMesh.addPoint(pt: [1, 1, 1])
        
        triMesh.addNormal(n: [-1, 0, 0])
        triMesh.addNormal(n: [1, 0, 0])
        triMesh.addNormal(n: [0, -1, 0])
        triMesh.addNormal(n: [0, 1, 0])
        triMesh.addNormal(n: [0, 0, -1])
        triMesh.addNormal(n: [0, 0, 1])
        
        // -x
        triMesh.addPointNormalTriangle(newPointIndices: [0, 1, 3], newNormalIndices: [0, 0, 0])
        triMesh.addPointNormalTriangle(newPointIndices: [0, 3, 2], newNormalIndices: [0, 0, 0])
        
        // +x
        triMesh.addPointNormalTriangle(newPointIndices: [4, 6, 7], newNormalIndices: [1, 1, 1])
        triMesh.addPointNormalTriangle(newPointIndices: [4, 7, 5], newNormalIndices: [1, 1, 1])
        
        // -y
        triMesh.addPointNormalTriangle(newPointIndices: [0, 4, 5], newNormalIndices: [2, 2, 2])
        triMesh.addPointNormalTriangle(newPointIndices: [0, 5, 1], newNormalIndices: [2, 2, 2])
        
        // +y
        triMesh.addPointNormalTriangle(newPointIndices: [2, 3, 7], newNormalIndices: [3, 3, 3])
        triMesh.addPointNormalTriangle(newPointIndices: [2, 7, 6], newNormalIndices: [3, 3, 3])
        
        // -z
        triMesh.addPointNormalTriangle(newPointIndices: [0, 2, 6], newNormalIndices: [4, 4, 4])
        triMesh.addPointNormalTriangle(newPointIndices: [0, 6, 4], newNormalIndices: [4, 4, 4])
        
        // +z
        triMesh.addPointNormalTriangle(newPointIndices: [1, 5, 7], newNormalIndices: [5, 5, 5])
        triMesh.addPointNormalTriangle(newPointIndices: [1, 7, 3], newNormalIndices: [5, 5, 5])
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
