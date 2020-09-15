//
//  implicit_triangle_mesh3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class implicit_triangle_mesh3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSignedDistance() throws {
        let box = Box3.builder()
            .withLowerCorner(pt: [0, 0, 0])
            .withUpperCorner(pt: [1, 1, 1])
            .build()
        let refSurf = SurfaceToImplicit3(surface: box)
        
        let mesh = TriangleMesh3.builder().build()
        mesh.readObj(filename: "cube.obj")
        
        let imesh = ImplicitTriangleMesh3.builder()
            .withTriangleMesh(mesh: mesh)
            .withResolutionX(resolutionX: 20)
            .build()
        
        for i in 0..<getNumberOfSamplePoints3() {
            let sample = getSamplePoints3()[i]
            let refAns = refSurf.signedDistance(otherPoint: sample)
            let actAns = imesh.signedDistance(otherPoint: sample)
            
            XCTAssertEqual(refAns, actAns, accuracy: 1.0 / 20)
        }
    }
}
