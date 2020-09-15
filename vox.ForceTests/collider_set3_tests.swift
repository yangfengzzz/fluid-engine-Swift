//
//  collider_set3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class collider_set3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testConstructors() throws {
        let box1 = Box3.builder()
            .withLowerCorner(pt: [0, 1, 2])
            .withUpperCorner(pt: [1, 2, 3])
            .build()
        
        let box2 = Box3.builder()
            .withLowerCorner(pt: [3, 4, 5])
            .withUpperCorner(pt: [4, 5, 6])
            .build()
        
        let col1 = RigidBodyCollider3.builder()
            .withSurface(surface: box1)
            .build()
        
        let col2 = RigidBodyCollider3.builder()
            .withSurface(surface: box2)
            .build()
        
        let colSet1 = ColliderSet3()
        XCTAssertEqual(0, colSet1.numberOfColliders())
        
        let colSet3 = ColliderSet3(others: [col1, col2])
        XCTAssertEqual(2, colSet3.numberOfColliders())
        XCTAssertTrue(col1 === colSet3.collider(i: 0))
        XCTAssertTrue(col2 === colSet3.collider(i: 1))
    }
    
    func testBuilder() {
        let box1 = Box3.builder()
            .withLowerCorner(pt: [0, 1, 2])
            .withUpperCorner(pt: [1, 2, 3])
            .build()
        
        let box2 = Box3.builder()
            .withLowerCorner(pt: [3, 4, 5])
            .withUpperCorner(pt: [4, 5, 6])
            .build()
        
        let col1 = RigidBodyCollider3.builder()
            .withSurface(surface: box1)
            .build()
        
        let col2 = RigidBodyCollider3.builder()
            .withSurface(surface: box2)
            .build()
        
        let colSet1 = ColliderSet3.builder().build()
        XCTAssertEqual(0, colSet1.numberOfColliders())
        
        let colSet2 = ColliderSet3.builder()
            .withColliders(others: [col1, col2])
            .build()
        XCTAssertEqual(2, colSet2.numberOfColliders())
        XCTAssertTrue(col1 === colSet2.collider(i: 0))
        XCTAssertTrue(col2 === colSet2.collider(i: 1))
        
        let colSet3 = ColliderSet3.builder().build()
        XCTAssertEqual(0, colSet3.numberOfColliders())
    }
}
