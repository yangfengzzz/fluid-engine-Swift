//
//  triangle3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/16.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class triangle3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let tri1 = Triangle3()
        for j in 0..<3 {
            XCTAssertEqual(0.0, tri1.points.0[j])
            XCTAssertEqual(0.0, tri1.normals.0[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(0.0, tri1.points.1[j])
            XCTAssertEqual(0.0, tri1.normals.1[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(0.0, tri1.points.2[j])
            XCTAssertEqual(0.0, tri1.normals.2[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(0.0, tri1.uvs.0[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(0.0, tri1.uvs.1[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(0.0, tri1.uvs.2[j])
        }
        
        let points =
            (Vector3F(1, 2, 3), Vector3F(4, 5, 6), Vector3F(7, 8, 9))
        let normals =
            (Vector3F(1, 0, 0), Vector3F(0, 1, 0), Vector3F(0, 0, 1))
        let uvs =
            (Vector2F(1, 0), Vector2F(0, 1), Vector2F(0.5, 0.5))
        
        let tri2 = Triangle3(points: points, normals: normals, uvs: uvs)

        for j in 0..<3 {
            XCTAssertEqual(points.0[j], tri2.points.0[j])
            XCTAssertEqual(normals.0[j], tri2.normals.0[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.1[j], tri2.points.1[j])
            XCTAssertEqual(normals.1[j], tri2.normals.1[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.2[j], tri2.points.2[j])
            XCTAssertEqual(normals.2[j], tri2.normals.2[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.0[j], tri2.uvs.0[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.1[j], tri2.uvs.1[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.2[j], tri2.uvs.2[j])
        }
        
        let tri3 =  Triangle3(other: tri2)

        for j in 0..<3 {
            XCTAssertEqual(points.0[j], tri3.points.0[j])
            XCTAssertEqual(normals.0[j], tri3.normals.0[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.1[j], tri3.points.1[j])
            XCTAssertEqual(normals.1[j], tri3.normals.1[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.2[j], tri3.points.2[j])
            XCTAssertEqual(normals.2[j], tri3.normals.2[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.0[j], tri3.uvs.0[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.1[j], tri3.uvs.1[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.2[j], tri3.uvs.2[j])
        }
    }
    
    func testBasicGetters() {
        let tri = Triangle3()
        tri.points = (Vector3F(0, 0, -1), Vector3F(1, 0, -1), Vector3F(0, 1, -1))
        
        XCTAssertEqual(0.5, tri.area())
        
        var b0 = Float(0)
        var b1 = Float(0)
        var b2 = Float(0)
        tri.getBarycentricCoords(pt: Vector3F(0.5, 0.5, -1),
                                                          b0: &b0, b1: &b1, b2: &b2)
        XCTAssertEqual(0.0, b0)
        XCTAssertEqual(0.5, b1)
        XCTAssertEqual(0.5, b2)
        
        let n = tri.faceNormal()
        XCTAssertEqual(Vector3F(0, 0, 0.99999994), n)
    }
    
    func testSurfaceGetters() {
        let tri = Triangle3()
        tri.points = (Vector3F(0, 0, -1), Vector3F(1, 0, -1), Vector3F(0, 1, -1))
        tri.normals = (Vector3F(1, 0, 0), Vector3F(0, 1, 0), Vector3F(0, 0, 1))
        let cp1 = tri.closestPoint(otherPoint: [0.4, 0.4, 3.0])
        XCTAssertEqual(Vector3F(0.4, 0.4, -1), cp1)
        
        let cp2 = tri.closestPoint(otherPoint: [-3.0, -3.0, 0.0])
        XCTAssertEqual(Vector3F(0, 0, -1), cp2)
        
        let cn1 = tri.closestNormal(otherPoint: [0.4, 0.4, 3.0])
        XCTAssertEqual(length(normalize(Vector3F(1, 2, 2)) - cn1), 0, accuracy:1.0e-6)
        
        let cn2 = tri.closestNormal(otherPoint: [-3.0, -3.0, 0.0])
        XCTAssertEqual(Vector3F(1, 0, 0), cn2)
        
        let ints1 = tri.intersects(ray: Ray3F(newOrigin: [0.4, 0.4, -5.0], newDirection: [0, 0, 1]))
        XCTAssertTrue(ints1)
        
        let ints2 = tri.intersects(ray: Ray3F(newOrigin: [-1, 2, 3], newDirection: [0, 0, -1]))
        XCTAssertFalse(ints2)
        
        let ints3 = tri.intersects(ray: Ray3F(newOrigin: [1, 1, 0], newDirection: [0, 0, -1]))
        XCTAssertFalse(ints3)
        
        let cints1 = tri.closestIntersection(ray: Ray3F(newOrigin: [0.4, 0.4, -5.0], newDirection: [0, 0, 1]))
        XCTAssertTrue(cints1.isIntersecting)
        XCTAssertEqual(Vector3F(0.4, 0.4, -1.0000002), cints1.point)
        XCTAssertEqual(4.0, cints1.distance)
        XCTAssertEqual(length(normalize(Vector3F(1, 2, 2)) - cints1.normal), 0, accuracy:1.0e-6)
    }
    
    func testBuilder() {
        let points =
            (Vector3F(1, 2, 3), Vector3F(4, 5, 6), Vector3F(7, 8, 9))
        let normals =
            (Vector3F(1, 0, 0), Vector3F(0, 1, 0), Vector3F(0, 0, 1))
        let uvs =
            (Vector2F(1, 0), Vector2F(0, 1), Vector2F(0.5, 0.5))
        
        let tri = Triangle3.builder()
            .withPoints(points: points)
            .withNormals(normals: normals)
            .withUvs(uvs: uvs)
            .build()
        
        for j in 0..<3 {
            XCTAssertEqual(points.0[j], tri.points.0[j])
            XCTAssertEqual(normals.0[j], tri.normals.0[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.1[j], tri.points.1[j])
            XCTAssertEqual(normals.1[j], tri.normals.1[j])
        }
        for j in 0..<3 {
            XCTAssertEqual(points.2[j], tri.points.2[j])
            XCTAssertEqual(normals.2[j], tri.normals.2[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.0[j], tri.uvs.0[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.1[j], tri.uvs.1[j])
        }
        for j in 0..<2 {
            XCTAssertEqual(uvs.2[j], tri.uvs.2[j])
        }
    }
}
