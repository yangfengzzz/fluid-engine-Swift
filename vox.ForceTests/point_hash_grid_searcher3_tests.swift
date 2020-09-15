//
//  point_hash_grid_searcher3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_hash_grid_searcher3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testForEachNearbyPoint() throws {
        let points = Array1<Vector3F>(lst: [
            Vector3F(0, 1, 3),
            Vector3F(2, 5, 4),
            Vector3F(-1, 3, 0)
        ])
        
        let searcher = PointHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                              gridSpacing: 2.0 * sqrt(10))
        searcher.build(points: points.constAccessor())
        
        var cnt:Int = 0
        searcher.forEachNearbyPoint(
            origin: Vector3F(0, 0, 0),
            radius: sqrt(10.0), callback: {(i:size_t, pt:Vector3F) in
                XCTAssertTrue(i == 0 || i == 2)
                
                if (i == 0) {
                    XCTAssertEqual(points[0], pt)
                } else if (i == 2) {
                    XCTAssertEqual(points[2], pt)
                }
                
                cnt += 1
        })
        XCTAssertEqual(2, cnt)
    }
    
    func testForEachNearbyPointEmpty() {
        let points = Array1<Vector3F>()
        
        let searcher = PointHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                              gridSpacing: 2.0 * sqrt(10))
        searcher.build(points: points.constAccessor())
        
        searcher.forEachNearbyPoint(
            origin: Vector3F(0, 0, 0),
            radius: sqrt(10.0), callback: {(_:size_t, _:Vector3F) in
        })
    }
    
    func testBuild() {
        var points = Array1<Vector3F>()
        let pointsGenerator = BccLatticePointGenerator()
        let bbox = BoundingBox3F(
            point1: Vector3F(0, 0, 0),
            point2: Vector3F(1, 1, 1))
        let spacing:Float = 0.1
        
        pointsGenerator.generate(boundingBox: bbox, spacing: spacing, points: &points)
        
        let pointSearcher = PointHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                                   gridSpacing: 0.18)
        pointSearcher.build(points: points.constAccessor())
        
        var grid = Array3<size_t>(width: 4, height: 4, depth: 4)
        
        grid.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let key = pointSearcher.getHashKeyFromBucketIndex(bucketIndex: Point3I(i, j, k))
            let value = pointSearcher.buckets()[key].count
            grid[i, j, k] = value
        }
        
        let parallelSearcher = PointParallelHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                                              gridSpacing: 0.18)
        parallelSearcher.build(points: points.constAccessor())
        
        grid.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            let key = parallelSearcher.getHashKeyFromBucketIndex(bucketIndex: Point3I(i, j, k))
            let start = parallelSearcher.startIndexTable()[key]
            let end = parallelSearcher.endIndexTable()[key]
            let value = end - start
            XCTAssertEqual(grid[i, j, k], value)
        }
    }
    
    func testCopyConstructor() {
        let points = Array1<Vector3F>(lst: [
            Vector3F(0, 1, 3),
            Vector3F(2, 5, 4),
            Vector3F(-1, 3, 0)
        ])
        
        let searcher = PointHashGridSearcher3(resolutionX: 4, resolutionY: 4, resolutionZ: 4,
                                              gridSpacing: 2.0 * sqrt(10))
        searcher.build(points: points.constAccessor())
        
        let searcher2 = PointHashGridSearcher3(other: searcher)
        var cnt:Int = 0
        searcher2.forEachNearbyPoint(
            origin: Vector3F(0, 0, 0),
            radius: sqrt(10.0), callback: {(i:size_t, pt:Vector3F) in
                XCTAssertTrue(i == 0 || i == 2)
                
                if (i == 0) {
                    XCTAssertEqual(points[0], pt)
                } else if (i == 2) {
                    XCTAssertEqual(points[2], pt)
                }
                
                cnt += 1
        })
        XCTAssertEqual(2, cnt)
    }
}
