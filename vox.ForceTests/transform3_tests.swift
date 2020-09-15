//
//  transform3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class transform3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let t1 = Transform3()
        
        XCTAssertEqual(Vector3F(), t1.translation)
        XCTAssertEqual(0.0, t1.orientation.angle)
        
        let t2 = Transform3(translation: [2.0, -5.0, 1.0],
                            orientation: simd_quatf(angle: kQuarterPiF, axis: [0.0, 1.0, 0.0]))
        
        XCTAssertEqual(Vector3F(2.0, -5.0, 1.0), t2.translation)
        XCTAssertEqual(Vector3F(0.0, 1.0, 0.0), t2.orientation.axis)
        XCTAssertEqual(kQuarterPiF, t2.orientation.angle, accuracy:1e-6)
    }
    
    func testTransform() {
        let t = Transform3(translation: [2.0, -5.0, 1.0],
                           orientation: simd_quatf(angle: kHalfPiF, axis: [0.0, 1.0, 0.0]))
        
        let r1 = t.toWorld(pointInLocal: [4.0, 1.0, -3.0])
        XCTAssertEqual(-1.0, r1.x, accuracy:1e-6)
        XCTAssertEqual(-4.0, r1.y, accuracy:1e-6)
        XCTAssertEqual(-3.0, r1.z, accuracy:1e-6)
        
        let r2 = t.toLocal(pointInWorld: r1)
        XCTAssertEqual(4.0, r2.x, accuracy:1e-6)
        XCTAssertEqual(1.0, r2.y, accuracy:1e-9)
        XCTAssertEqual(-3.0, r2.z, accuracy:1e-6)
        
        let r3 = t.toWorldDirection(dirInLocal: [4.0, 1.0, -3.0])
        XCTAssertEqual(-3.0, r3.x, accuracy:1e-6)
        XCTAssertEqual(1.0, r3.y, accuracy:1e-9)
        XCTAssertEqual(-4.0, r3.z, accuracy:1e-9)
        
        let r4 = t.toLocalDirection(dirInWorld: r3)
        XCTAssertEqual(4.0, r4.x, accuracy:1e-6)
        XCTAssertEqual(1.0, r4.y, accuracy:1e-9)
        XCTAssertEqual(-3.0, r4.z, accuracy:1e-6)
        
        let bbox = BoundingBox3F(point1: [-2, -1, -3], point2: [2, 1, 3])
        let r5 = t.toWorld(bboxInLocal: bbox)
        XCTAssertEqual(length(BoundingBox3F(point1: [-1, -6, -1],
                                            point2: [5, -4, 3]).lowerCorner - r5.lowerCorner),
                       0, accuracy:1e-9)
        
        let r6 = t.toLocal(bboxInWorld: r5)
        XCTAssertEqual(length(bbox.lowerCorner - r6.lowerCorner),
                       0, accuracy:1e-6)
    }
}
