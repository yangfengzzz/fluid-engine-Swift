//
//  point_simple_list_searcher2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_simple_list_searcher2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testForEachNearbyPoint() throws {
        let points = Array1<Vector2F>(lst: [
            Vector2F(1, 3),
            Vector2F(2, 5),
            Vector2F(-1, 3)
        ])
        
        let searcher = PointSimpleListSearcher2()
        searcher.build(points: points.constAccessor())
        
        searcher.forEachNearbyPoint(
            origin: Vector2F(0, 0),
            radius: sqrt(10.0), callback: {(i:size_t, pt:Vector2F) in
                XCTAssertTrue(i == 0 || i == 2)
                
                if (i == 0) {
                    XCTAssertEqual(points[0], pt)
                } else if (i == 2) {
                    XCTAssertEqual(points[2], pt)
                }
        })
    }
}
