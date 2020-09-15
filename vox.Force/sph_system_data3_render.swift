//
//  sph_system_data3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit


class SphSystemData3Renderable: Renderable {
    let sphSystem = SphSystemData3()
    let grid = CellCenteredScalarGrid2(resolutionX: 512, resolutionY: 512,
                                       gridSpacingX: 1.0 / 512, gridSpacingY: 1.0 / 512)
    let gridX = CellCenteredScalarGrid2(resolutionX: 64, resolutionY: 64,
                                        gridSpacingX: 1.0 / 64, gridSpacingY: 1.0 / 64)
    let gridY = CellCenteredScalarGrid2(resolutionX: 64, resolutionY: 64,
                                        gridSpacingX: 1.0 / 64, gridSpacingY: 1.0 / 64)
    
    func Interpolate() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(point1: Vector3F(0, 0, 0),
                                 point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox, spacing: spacing, points: &points)
        
        sphSystem.addParticles(newPositions: points.constAccessor())
        sphSystem.setTargetSpacing(spacing: spacing)
        sphSystem.buildNeighborSearcher()
        sphSystem.buildNeighborLists()
        sphSystem.updateDensities()
        
        let data = Array1<Float>(size: points.size(), initVal: 1.0)
        
        let gridPos = grid.dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: grid.dataSize().x,
                    beginIndexY: 0, endIndexY: grid.dataSize().y){(i:size_t, j:size_t) in
                        let xy = gridPos(i, j)
                        let p = Vector3F(xy.x, xy.y, 0.5)
                        grid[i, j] = sphSystem.interpolate(origin: p, values: data.constAccessor())
        }
    }
    
    func Gradient() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(point1: Vector3F(0, 0, 0),
                                 point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox, spacing: spacing, points: &points)
        
        sphSystem.addParticles(newPositions: points.constAccessor())
        sphSystem.setTargetSpacing(spacing: spacing)
        sphSystem.buildNeighborSearcher()
        sphSystem.buildNeighborLists()
        sphSystem.updateDensities()
        
        var data = Array1<Float>(size: points.size())
        var gradX = Array1<Float>(size: points.size())
        var gradY = Array1<Float>(size: points.size())
        
        for i in 0..<data.size() {
            data[i] = Float.random(in: 0.0...1.0)
        }
        
        for i in 0..<data.size() {
            let g = sphSystem.gradientAt(i: i, values: data.constAccessor())
            gradX[i] = g.x
            gradY[i] = g.y
        }
        
        let gridPos = grid.dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: grid.dataSize().x,
                    beginIndexY: 0, endIndexY: grid.dataSize().y){(i:size_t, j:size_t) in
                        let xy = gridPos(i, j)
                        let p = Vector3F(xy.x, xy.y, 0.5)
                        gridX[i, j] = sphSystem.interpolate(origin: p, values: data.constAccessor())
        }
        
        parallelFor(beginIndexX: 0, endIndexX: grid.dataSize().x,
                    beginIndexY: 0, endIndexY: grid.dataSize().y){(i:size_t, j:size_t) in
                        let xy = gridPos(i, j)
                        let p = Vector3F(xy.x, xy.y, 0.5)
                        gridX[i, j] = sphSystem.interpolate(origin: p, values: gradX.constAccessor())
                        gridY[i, j] = sphSystem.interpolate(origin: p, values: gradY.constAccessor())
        }
    }
    
    func Laplacian() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(point1: Vector3F(0, 0, 0),
                                 point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox, spacing: spacing, points: &points)
        
        sphSystem.addParticles(newPositions: points.constAccessor())
        sphSystem.setTargetSpacing(spacing: spacing)
        sphSystem.buildNeighborSearcher()
        sphSystem.buildNeighborLists()
        sphSystem.updateDensities()
        
        var data = Array1<Float>(size: points.size())
        var laplacian = Array1<Float>(size: points.size())
        
        for i in 0..<data.size() {
            data[i] = Float.random(in: 0.0...1.0)
        }
        
        for i in 0..<data.size() {
            laplacian[i] = sphSystem.laplacianAt(i: i, values: data.constAccessor())
        }
        
        let gridPos = grid.dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: grid.dataSize().x,
                    beginIndexY: 0, endIndexY: grid.dataSize().y){(i:size_t, j:size_t) in
                        let xy = gridPos(i, j)
                        let p = Vector3F(xy.x, xy.y, 0.5)
                        grid[i, j] = sphSystem.interpolate(origin: p, values: data.constAccessor())
        }
        
        parallelFor(beginIndexX: 0, endIndexX: grid.dataSize().x,
                    beginIndexY: 0, endIndexY: grid.dataSize().y){(i:size_t, j:size_t) in
                        let xy = gridPos(i, j)
                        let p = Vector3F(xy.x, xy.y, 0.5)
                        grid[i, j] = sphSystem.interpolate(origin: p, values: laplacian.constAccessor())
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
