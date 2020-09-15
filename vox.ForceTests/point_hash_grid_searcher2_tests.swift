//
//  point_hash_grid_searcher2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_hash_grid_searcher2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testForEachNearbyPoint() throws {
        let points = Array1<Vector2F>(lst: [
            Vector2F(1, 3),
            Vector2F(2, 5),
            Vector2F(-1, 3)
        ])
        
        let searcher = PointHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                              gridSpacing: 2.0 * sqrt(10))
        searcher.build(points: points.constAccessor())
        
        searcher.forEachNearbyPoint(
            origin: Vector2F(0, 0),
            radius: sqrt(10.0),callback: {(i:size_t, pt:Vector2F) in
                XCTAssertTrue(i == 0 || i == 2)
                
                if (i == 0) {
                    XCTAssertEqual(points[0], pt)
                } else if (i == 2) {
                    XCTAssertEqual(points[2], pt)
                }
        })
    }
    
    func testForEachNearbyPointEmpty() {
        let points = Array1<Vector2F>()
        
        let searcher = PointHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                              gridSpacing: 2.0 * sqrt(10))
        searcher.build(points: points.constAccessor())
        
        searcher.forEachNearbyPoint(
            origin: Vector2F(0, 0),
            radius: sqrt(10.0),callback: {(_:size_t, _:Vector2F) in
        })
    }
    
    func testBuild() {
        var points = Array1<Vector2F>()
        let pointsGenerator = TrianglePointGenerator()
        let bbox = BoundingBox2F(
            point1: Vector2F(0, 0),
            point2: Vector2F(1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox, spacing: spacing, points: &points)
        
        let pointSearcher = PointHashGridSearcher2(resolutionX: 4, resolutionY: 4, gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        var grid = Array2<size_t>(width: 4, height: 4)
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point2I(i, j))
                let value = pointSearcher.buckets()[key].count
                grid[i, j] = value
            }
        }
        
        let parallelSearcher = PointParallelHashGridSearcher2(resolutionX: 4, resolutionY: 4, gridSpacing: 0.18)
        parallelSearcher.build(points: points.constAccessor())
        
        for j in 0..<grid.size().y {
            for i in 0..<grid.size().x {
                let key = parallelSearcher.getHashKeyFromBucketIndex(bucketIndex: Point2I(i, j))
                let start = parallelSearcher.startIndexTable()[key]
                let end = parallelSearcher.endIndexTable()[key]
                let value = end - start
                XCTAssertEqual(grid[i, j], value)
            }
        }
    }
}
