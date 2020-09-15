//
//  triangle_mesh3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class triangle_mesh3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let mesh1 = TriangleMesh3()
        XCTAssertEqual(0, mesh1.numberOfPoints())
        XCTAssertEqual(0, mesh1.numberOfNormals())
        XCTAssertEqual(0, mesh1.numberOfUvs())
        XCTAssertEqual(0, mesh1.numberOfTriangles())
    }
    
    func testReadObj() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        XCTAssertEqual(96, mesh.numberOfPoints())//unlike tinyobj
        XCTAssertEqual(96, mesh.numberOfNormals())
        XCTAssertEqual(108, mesh.numberOfTriangles())
    }
    
    func testClosestPoint() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        let bruteForceSearch = {(pt:Vector3F)->Vector3F in
            var minDist2 = Float.greatestFiniteMagnitude
            var result = Vector3F()
            for i in 0..<mesh.numberOfTriangles() {
                let tri = mesh.triangle(i: i)
                let localResult = tri.closestPoint(otherPoint: pt)
                let localDist2 = length_squared(pt - localResult)
                if (localDist2 < minDist2) {
                    minDist2 = localDist2
                    result = localResult
                }
            }
            return result
        }
        
        let numSamples = getNumberOfSamplePoints3()
        for i in 0..<numSamples {
            let actual = mesh.closestPoint(otherPoint: getSamplePoints3()[i])
            let expected = bruteForceSearch(getSamplePoints3()[i])
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testClosestNormal() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kSphereTriMesh5x5.obj")
        
        let bruteForceSearch = {(pt:Vector3F)->Vector3F in
            var minDist2 = Float.greatestFiniteMagnitude
            var result = Vector3F()
            for i in 0..<mesh.numberOfTriangles() {
                let tri = mesh.triangle(i: i)
                let localResult = tri.closestNormal(otherPoint: pt)
                let closestPt = tri.closestPoint(otherPoint: pt)
                let localDist2 = length_squared(pt - closestPt)
                if (localDist2 < minDist2) {
                    minDist2 = localDist2
                    result = localResult
                }
            }
            return result
        }
        
        let numSamples = getNumberOfSamplePoints3()
        for i in 0..<numSamples {
            let actual = mesh.closestNormal(otherPoint: getSamplePoints3()[i])
            let expected = bruteForceSearch(getSamplePoints3()[i])
            XCTAssertEqual(length(expected - actual), 0, accuracy: 1e-6)
        }
    }
    
    func testClosestDistance() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        let bruteForceSearch = {(pt:Vector3F)->Float in
            var minDist = Float.greatestFiniteMagnitude
            for i in 0..<mesh.numberOfTriangles() {
                let tri = mesh.triangle(i: i)
                let localResult = tri.closestDistance(otherPoint: pt)
                if (localResult < minDist) {
                    minDist = localResult
                }
            }
            return minDist
        }
        
        let numSamples = getNumberOfSamplePoints3()
        for i in 0..<numSamples {
            let actual = mesh.closestDistance(otherPoint: getSamplePoints3()[i])
            let expected = bruteForceSearch(getSamplePoints3()[i])
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testIntersects() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        let numSamples = getNumberOfSamplePoints3()
        
        let bruteForceTest = {(ray:Ray3F)->Bool in
            for i in 0..<mesh.numberOfTriangles() {
                let tri = mesh.triangle(i: i)
                if (tri.intersects(ray: ray)) {
                    return true
                }
            }
            return false
        }
        
        for i in 0..<numSamples {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i], newDirection: getSampleDirs3()[i])
            let actual = mesh.intersects(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testClosestIntersection() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        let numSamples = getNumberOfSamplePoints3()
        
        let bruteForceTest = {(ray:Ray3F)->SurfaceRayIntersection3 in
            var result = SurfaceRayIntersection3()
            for i in 0..<mesh.numberOfTriangles() {
                let tri = mesh.triangle(i: i)
                let localResult = tri.closestIntersection(ray: ray)
                if (localResult.distance < result.distance) {
                    result = localResult
                }
            }
            return result
        }
        
        for i in 0..<numSamples {
            let ray = Ray3F(newOrigin: getSamplePoints3()[i], newDirection: getSampleDirs3()[i])
            let actual = mesh.closestIntersection(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected.distance, actual.distance, accuracy: 1.0e-6)
            XCTAssertEqual(length(expected.point - actual.point), 0, accuracy: 1.0e-6)
            XCTAssertEqual(expected.normal, actual.normal)
            XCTAssertEqual(expected.isIntersecting, actual.isIntersecting)
        }
    }
    
    func testIsInside() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        let numSamples = getNumberOfSamplePoints3()
        
        for i in 0..<numSamples {
            let p = getSamplePoints3()[i]
            let actual = mesh.isInside(otherPoint: p)
            let expected = mesh.boundingBox().contains(point: p)
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testBoundingBox() {
        let mesh = TriangleMesh3()
        mesh.readObj(filename: "kCubeTriMesh3x3x3As.obj")
        
        XCTAssertEqual(BoundingBox3F(point1: [-0.5, -0.5, -0.5], point2: [0.5, 0.5, 0.5]).lowerCorner,
                       mesh.boundingBox().lowerCorner)
        XCTAssertEqual(BoundingBox3F(point1: [-0.5, -0.5, -0.5], point2: [0.5, 0.5, 0.5]).upperCorner,
                       mesh.boundingBox().upperCorner)
    }
    
    func testBuilder() {
        let points = TriangleMesh3.PointArray([
            Vector3F(1, 2, 3),
            Vector3F(4, 5, 6),
            Vector3F(7, 8, 9),
            Vector3F(10, 11, 12)
        ])
        
        let normals = TriangleMesh3.NormalArray([
            Vector3F(10, 11, 12),
            Vector3F(7, 8, 9),
            Vector3F(4, 5, 6),
            Vector3F(1, 2, 3)
        ])
        
        let uvs = TriangleMesh3.UvArray([
            Vector2F(13, 14),
            Vector2F(15, 16)
        ])
        
        let pointIndices = TriangleMesh3.IndexArray([
            Point3UI(0, 1, 2),
            Point3UI(0, 1, 3)
        ])
        
        let normalIndices = TriangleMesh3.IndexArray([
            Point3UI(1, 2, 3),
            Point3UI(2, 1, 0)
        ])
        
        let uvIndices = TriangleMesh3.IndexArray([
            Point3UI(1, 0, 2),
            Point3UI(3, 1, 0)
        ])
        
        let mesh = TriangleMesh3.builder()
            .withPoints(points: points)
            .withNormals(normals: normals)
            .withUvs(uvs: uvs)
            .withPointIndices(pointIndices: pointIndices)
            .withNormalIndices(normalIndices: normalIndices)
            .withUvIndices(uvIndices: uvIndices)
            .build()
        
        XCTAssertEqual(4, mesh.numberOfPoints())
        XCTAssertEqual(4, mesh.numberOfNormals())
        XCTAssertEqual(2, mesh.numberOfUvs())
        XCTAssertEqual(2, mesh.numberOfTriangles())
        
        for i in 0..<mesh.numberOfPoints() {
            XCTAssertEqual(points[i], mesh.point(i: i))
        }
        
        for i in 0..<mesh.numberOfNormals() {
            XCTAssertEqual(normals[i], mesh.normal(i: i))
        }
        
        for i in 0..<mesh.numberOfUvs() {
            XCTAssertEqual(uvs[i], mesh.uv(i: i))
        }
        
        for i in 0..<mesh.numberOfTriangles() {
            XCTAssertEqual(pointIndices[i], mesh.pointIndex(i: i))
            XCTAssertEqual(normalIndices[i], mesh.normalIndex(i: i))
            XCTAssertEqual(uvIndices[i], mesh.uvIndex(i: i))
        }
    }
}
