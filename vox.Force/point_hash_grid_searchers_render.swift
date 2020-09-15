//
//  point_hash_grid_searchers_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class PointHashGridSearcher2Renderable: Renderable {
    var grid = Array2<Float>(width: 4, height: 4, initVal: 0.0)
    
    func Build() {
        var points = Array1<Vector2F>()
        let pointsGenerator = TrianglePointGenerator()
        let bbox = BoundingBox2F(
            point1: Vector2F(0, 0),
            point2: Vector2F(1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox,
                                 spacing: spacing, points: &points)
        
        let pointSearcher = PointHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                                   gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point2I(i, j))
                let value = pointSearcher.buckets()[key].count
                grid[i, j] += Float(value)
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class PointHashGridSearcher3Renderable: Renderable {
    var grid = Array2<Float>(width: 4, height: 4, initVal: 0.0)
    
    func Build() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(
            point1: Vector3F(0, 0, 0),
            point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox,
                                 spacing: spacing, points: &points)
        
        let pointSearcher = PointHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                                   gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point3I(i, j, 0))
                let value = pointSearcher.buckets()[key].count
                grid[i, j] += Float(value)
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class PointParallelHashGridSearcher2Renderable: Renderable {
    var grid = Array2<Float>(width: 4, height: 4, initVal: 0.0)
    
    func Build() {
        var points = Array1<Vector2F>()
        let pointsGenerator = TrianglePointGenerator()
        let bbox = BoundingBox2F(
            point1: Vector2F(0, 0),
            point2: Vector2F(1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox,
                                 spacing: spacing, points: &points)
        
        let pointSearcher = PointParallelHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                                           gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point2I(i, j))
                let start = pointSearcher.startIndexTable()[key]
                let end = pointSearcher.endIndexTable()[key]
                let value = end - start
                grid[i, j] += Float(value)
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class PointParallelHashGridSearcher3Renderable: Renderable {
    var grid = Array2<Float>(width: 4, height: 4, initVal: 0.0)
    
    func Build() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(
            point1: Vector3F(0, 0, 0),
            point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox,
                                 spacing: spacing, points: &points)
        
        let pointSearcher = PointParallelHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                                           gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point3I(i, j, 0))
                let start = pointSearcher.startIndexTable()[key]
                let end = pointSearcher.endIndexTable()[key]
                let value = end - start
                grid[i, j] += Float(value)
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
