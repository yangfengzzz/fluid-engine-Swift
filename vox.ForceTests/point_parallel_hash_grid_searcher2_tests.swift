//
//  point_parallel_hash_grid_searcher2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_parallel_hash_grid_searcher2_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testForEachNearbyPoint() throws {
        let points = Array1<Vector2F>(lst: [
            Vector2F(1, 3),
            Vector2F(2, 5),
            Vector2F(-1, 3)
        ])
        
        let searcher = PointParallelHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                                      gridSpacing: sqrt(10))
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
        
        let searcher = PointParallelHashGridSearcher2(resolutionX: 4, resolutionY: 4,
                                                      gridSpacing: sqrt(10))
        searcher.build(points: points.constAccessor())
        
        searcher.forEachNearbyPoint(
            origin: Vector2F(0, 0),
            radius: sqrt(10.0), callback: {(_:size_t, _:Vector2F) in
        })
    }
}
