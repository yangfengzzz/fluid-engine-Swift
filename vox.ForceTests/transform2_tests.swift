//
//  transform2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class transform2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let t1 = Transform2()
        
        XCTAssertEqual(Vector2F(), t1.translation)
        XCTAssertEqual(0.0, t1.orientation)
        
        let t2 = Transform2(translation: [2.0, -5.0], orientation: kQuarterPiF)
        
        XCTAssertEqual(Vector2F(2.0, -5.0), t2.translation)
        XCTAssertEqual(kQuarterPiF, t2.orientation)
    }
    
    func testTransform() {
        let t = Transform2(translation: [2.0, -5.0], orientation: kHalfPiF)
        
        let r1 = t.toWorld(pointInLocal: [4.0, 1.0])
        XCTAssertEqual(1.0, r1.x, accuracy:1.0e-6)
        XCTAssertEqual(-1.0, r1.y)
        
        let r2 = t.toLocal(pointInWorld: r1)
        XCTAssertEqual(4.0, r2.x)
        XCTAssertEqual(1.0, r2.y, accuracy: 1.0e-6)
        
        let r3 = t.toWorldDirection(dirInLocal: [4.0, 1.0])
        XCTAssertEqual(-1.0, r3.x, accuracy:1.0e-6)
        XCTAssertEqual(4.0, r3.y)
        
        let r4 = t.toLocalDirection(dirInWorld: r3)
        XCTAssertEqual(4.0, r4.x)
        XCTAssertEqual(1.0, r4.y, accuracy: 1.0e-6)
        
        let bbox = BoundingBox2F(point1: [-2, -1], point2: [2, 1])
        let r5 = t.toWorld(bboxInLocal: bbox)
        XCTAssertEqual(length(BoundingBox2F(point1: [1, -7],
                                            point2: [3, -3]).lowerCorner - r5.lowerCorner),
                       0, accuracy:1.0e-6)
        XCTAssertEqual(length(BoundingBox2F(point1: [1, -7],
                                            point2: [3, -3]).upperCorner - r5.upperCorner),
                       0, accuracy:1.0e-15)
        
        let r6 = t.toLocal(bboxInWorld: r5)
        XCTAssertEqual(length(bbox.lowerCorner - r6.lowerCorner),
                       0, accuracy:1.0e-6)
        XCTAssertEqual(length(bbox.upperCorner - r6.upperCorner),
                       0, accuracy:1.0e-6)
    }
}
