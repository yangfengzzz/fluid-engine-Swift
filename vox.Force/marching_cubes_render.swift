//
//  marching_cubes_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class MarchingCubesRenderable: Renderable {
    var triMesh = TriangleMesh3()
    
    func SingleCube() {
        var grid = Array3<Float>(width: 2, height: 2, depth: 2)
        grid[0, 0, 0] = -0.5
        grid[0, 0, 1] = -0.5
        grid[0, 1, 0] =  0.5
        grid[0, 1, 1] =  0.5
        grid[1, 0, 0] = -0.5
        grid[1, 0, 1] = -0.5
        grid[1, 1, 0] =  0.5
        grid[1, 1, 1] =  0.5
        
        marchingCubes(
            grid: grid.constAccessor(),
            gridSize: Vector3F(1, 1, 1),
            origin: Vector3F(),
            mesh: &triMesh,
            isoValue: 0,
            bndClose: kDirectionAll,
            bndConnectivity: kDirectionAll)
    }
    
    func FourCubes() {
        let grid = VertexCenteredScalarGrid3(resolutionX: 2, resolutionY: 1, resolutionZ: 2)
        grid.fill(){(x:Vector3F)->Float in
            return x.y - 0.5
        }
        
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func Sphere1() {
        let grid = VertexCenteredScalarGrid3(resolutionX: 16, resolutionY: 16, resolutionZ: 16)
        grid.fill(){(x:Vector3F)->Float in
            return length(x - [8.0, 8.0, 8.0]) - 3.0
        }
        
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func Sphere2() {
        let grid = VertexCenteredScalarGrid3(resolutionX: 16, resolutionY: 16, resolutionZ: 16)
        grid.fill(){(x:Vector3F)->Float in
            return length(x - [0.0, 4.0, 3.0]) - 6.0
        }
                
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh,
            isoValue: 0,
            bndClose: kDirectionAll)
    }
    
    func Sphere3() {
        let grid = VertexCenteredScalarGrid3(resolutionX: 16, resolutionY: 16, resolutionZ: 16)
        grid.fill(){(x:Vector3F)->Float in
            return length(x - [11.0, 14.0, 12.0]) - 6.0
        }
                
        marchingCubes(
            grid: grid.constDataAccessor(),
            gridSize: grid.gridSpacing(),
            origin: grid.origin(),
            mesh: &triMesh,
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
