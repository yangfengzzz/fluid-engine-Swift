//
//  point_simple_list_searcher3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_simple_list_searcher3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testForEachNearbyPoint() throws {
        let points = Array1<Vector3F>(lst: [
            Vector3F(0, 1, 3),
            Vector3F(2, 5, 4),
            Vector3F(-1, 3, 0)
        ])
        
        let searcher = PointSimpleListSearcher3()
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
    
    func testCopyConstructor() {
        let points = Array1<Vector3F>(lst: [
            Vector3F(0, 1, 3),
            Vector3F(2, 5, 4),
            Vector3F(-1, 3, 0)
        ])
        
        let searcher = PointSimpleListSearcher3()
        searcher.build(points: points.constAccessor())
        
        let searcher2 = PointSimpleListSearcher3(other: searcher)
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
