//
//  surface_set2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class surface_set2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() {
        let sset1 = SurfaceSet2()
        XCTAssertEqual(0, sset1.numberOfSurfaces())
        
        let sph1 = Sphere2.builder()
            .withRadius(radius: 1.0)
            .withCenter(center: [0, 0])
            .build()
        let sph2 = Sphere2.builder()
            .withRadius(radius: 0.5)
            .withCenter(center: [0, 3])
            .build()
        let sph3 = Sphere2.builder()
            .withRadius(radius: 0.25)
            .withCenter(center: [-2, 0])
            .build()
        let sset2 = SurfaceSet2(other: [sph1, sph2, sph3],
                                transform: Transform2(),
                                isNormalFlipped: false)
        XCTAssertEqual(3, sset2.numberOfSurfaces())
        XCTAssertEqual(sph1.radius,
                       (sset2.surfaceAt(i: 0) as! Sphere2).radius)
        XCTAssertEqual(sph2.radius,
                       (sset2.surfaceAt(i: 1) as! Sphere2).radius)
        XCTAssertEqual(sph3.radius,
                       (sset2.surfaceAt(i: 2) as! Sphere2).radius)
        XCTAssertEqual(Vector2F(), sset2.transform.translation)
        XCTAssertEqual(0.0, sset2.transform.orientation)
        
        let sset3 = SurfaceSet2(other: [sph1, sph2, sph3],
                                transform: Transform2(translation: Vector2F(1, 2), orientation: 0.5),
                                isNormalFlipped: false)
        XCTAssertEqual(Vector2F(1, 2), sset3.transform.translation)
        XCTAssertEqual(0.5, sset3.transform.orientation)
        
        let sset4 = SurfaceSet2(other: sset3)
        XCTAssertEqual(3, sset4.numberOfSurfaces())
        XCTAssertEqual(sph1.radius,
                       (sset4.surfaceAt(i: 0) as! Sphere2).radius)
        XCTAssertEqual(sph2.radius,
                       (sset4.surfaceAt(i: 1) as! Sphere2).radius)
        XCTAssertEqual(sph3.radius,
                       (sset4.surfaceAt(i: 2) as! Sphere2).radius)
        XCTAssertEqual(Vector2F(1, 2), sset4.transform.translation)
        XCTAssertEqual(0.5, sset4.transform.orientation)
    }
    
    func testAddSurface() {
        let sset1 = SurfaceSet2()
        XCTAssertEqual(0, sset1.numberOfSurfaces())
        
        let sph1 = Sphere2.builder()
            .withRadius(radius: 1.0)
            .withCenter(center: [0, 0])
            .build()
        let sph2 = Sphere2.builder()
            .withRadius(radius: 0.5)
            .withCenter(center: [0, 3])
            .build()
        let sph3 = Sphere2.builder()
            .withRadius(radius: 0.25)
            .withCenter(center: [-2, 0]).build()
        
        sset1.addSurface(surface: sph1)
        sset1.addSurface(surface: sph2)
        sset1.addSurface(surface: sph3)
        
        XCTAssertEqual(3, sset1.numberOfSurfaces())
        XCTAssertEqual(sph1.radius,
                       (sset1.surfaceAt(i: 0) as! Sphere2).radius)
        XCTAssertEqual(sph2.radius,
                       (sset1.surfaceAt(i: 1) as! Sphere2).radius)
        XCTAssertEqual(sph3.radius,
                       (sset1.surfaceAt(i: 2) as! Sphere2).radius)
        XCTAssertEqual(Vector2F(), sset1.transform.translation)
        XCTAssertEqual(0.0, sset1.transform.orientation)
    }
    
    func testClosestPoint() {
        let sset1 = SurfaceSet2()
        
        // Test empty set
        let emptyPoint = sset1.closestPoint(otherPoint: [1.0, 2.0])
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.x)
        XCTAssertEqual(Float.greatestFiniteMagnitude, emptyPoint.y)
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
        }
        
        let bruteForceSearch = {(pt:Vector2F)->Vector2F in
            var minDist2 = Float.greatestFiniteMagnitude
            var result = Vector2F()
            for i in 0..<numSamples/2 {
                let localResult = sset1.surfaceAt(i: i).closestPoint(otherPoint: pt)
                let localDist2 = length_squared(pt - localResult)
                if (localDist2 < minDist2) {
                    minDist2 = localDist2
                    result = localResult
                }
            }
            return result
        }
        
        // Use second half of the samples as the query points
        for i in numSamples/2..<numSamples {
            let actual = sset1.closestPoint(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
        }
        for i in numSamples/2..<numSamples {
            let actual = sset2.closestPoint(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testClosestNormal() {
        let sset1 = SurfaceSet2()
        
        // Test empty set
        _ = sset1.closestNormal(otherPoint: [1.0, 2.0])
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
        }
        
        let bruteForceSearch = {(pt:Vector2F)->Vector2F in
            var minDist2 = Float.greatestFiniteMagnitude
            var result = Vector2F()
            for i in 0..<numSamples/2 {
                let localResult = sset1.surfaceAt(i: i).closestNormal(otherPoint: pt)
                let closestPt = sset1.surfaceAt(i: i).closestPoint(otherPoint: pt)
                let localDist2 = length_squared(pt - closestPt)
                if (localDist2 < minDist2) {
                    minDist2 = localDist2
                    result = localResult
                }
            }
            return result
        }
        
        // Use second half of the samples as the query points
        for i in numSamples/2..<numSamples {
            let actual = sset1.closestNormal(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
        }
        for i in numSamples/2..<numSamples {
            let actual = sset2.closestNormal(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testClosestDistance() {
        let sset1 = SurfaceSet2()
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
        }
        
        let bruteForceSearch = {(pt:Vector2F)->Float in
            var minDist = Float.greatestFiniteMagnitude
            for i in 0..<numSamples/2 {
                let localDist = sset1.surfaceAt(i: i).closestDistance(otherPoint: pt)
                if (localDist < minDist) {
                    minDist = localDist
                }
            }
            return minDist
        }
        
        // Use second half of the samples as the query points
        for i in numSamples/2..<numSamples {
            let actual = sset1.closestDistance(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
        }
        for i in numSamples/2..<numSamples {
            let actual = sset2.closestDistance(otherPoint: getSamplePoints2()[i])
            let expected = bruteForceSearch(getSamplePoints2()[i])
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testIntersects() {
        let sset1 = SurfaceSet2()
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
        }
        
        let bruteForceTest = {(ray:Ray2F)->Bool in
            for i in 0..<numSamples/2 {
                if (sset1.surfaceAt(i: i).intersects(ray: ray)) {
                    return true
                }
            }
            return false
        }
        
        // Use second half of the samples as the query points
        for i in numSamples/2..<numSamples {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i],
                            newDirection: getSampleDirs2()[i])
            let actual = sset1.intersects(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected, actual)
        }
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
        }
        for i in numSamples/2..<numSamples{
            let ray = Ray2F(newOrigin: getSamplePoints2()[i],
                            newDirection: getSampleDirs2()[i])
            let actual = sset2.intersects(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected, actual)
        }
    }
    
    func testClosestIntersection() {
        let sset1 = SurfaceSet2()
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
        }
        
        let bruteForceTest = {(ray:Ray2F)->SurfaceRayIntersection2 in
            var result = SurfaceRayIntersection2()
            for i in 0..<numSamples/2 {
                let localResult = sset1.surfaceAt(i: i).closestIntersection(ray: ray)
                if (localResult.distance < result.distance) {
                    result = localResult
                }
            }
            return result
        }
        
        //TODO: Still have problem which should be exact same
        // Use second half of the samples as the query points
        for i in numSamples/2..<numSamples {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i],
                            newDirection: getSampleDirs2()[i])
            let actual = sset1.closestIntersection(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected.distance, actual.distance, accuracy: 1.0e-4)
            XCTAssertEqual(length(expected.point - actual.point), 0, accuracy: 1.0e-4)
            XCTAssertEqual(length(expected.normal - actual.normal), 0, accuracy: 1.0e-2)
            XCTAssertEqual(expected.isIntersecting, actual.isIntersecting)
        }
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
        }
        for i in numSamples/2..<numSamples {
            let ray = Ray2F(newOrigin: getSamplePoints2()[i],
                            newDirection: getSampleDirs2()[i])
            let actual = sset2.closestIntersection(ray: ray)
            let expected = bruteForceTest(ray)
            XCTAssertEqual(expected.distance, actual.distance, accuracy: 1.0e-4)
            XCTAssertEqual(length(expected.point - actual.point), 0, accuracy: 1.0e-4)
            XCTAssertEqual(length(expected.normal - actual.normal), 0, accuracy: 1.0e-2)
            XCTAssertEqual(expected.isIntersecting, actual.isIntersecting)
        }
    }
    
    func testBoundingBox() {
        let sset1 = SurfaceSet2()
        
        let numSamples = getNumberOfSamplePoints2()
        
        // Use first half of the samples as the centers of the spheres
        var answer = BoundingBox2F()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: getSamplePoints2()[i])
                .build()
            sset1.addSurface(surface: sph)
            
            answer.merge(other: sph.boundingBox())
        }
        
        XCTAssertEqual(length(answer.lowerCorner - sset1.boundingBox().lowerCorner),
                       0.0, accuracy:1.0e-6)
        XCTAssertEqual(length(answer.upperCorner - sset1.boundingBox().upperCorner),
                       0.0, accuracy:1.0e-9)
        
        // Now with translation instead of center
        let sset2 = SurfaceSet2()
        var debug = BoundingBox2F()
        for i in 0..<numSamples/2 {
            let sph = Sphere2.builder()
                .withRadius(radius: 0.01)
                .withCenter(center: [0, 0])
                .withTranslation(translation: getSamplePoints2()[i])
                .build()
            sset2.addSurface(surface: sph)
            
            debug.merge(other: sph.boundingBox())
        }
        
        XCTAssertEqual(length(answer.lowerCorner - debug.lowerCorner),
                       0, accuracy:1.0e-9)
        XCTAssertEqual(length(answer.upperCorner - debug.upperCorner),
                       0, accuracy:1.0e-9)
        XCTAssertEqual(length(answer.lowerCorner - sset2.boundingBox().lowerCorner),
                       0, accuracy:1.0e-6)
        XCTAssertEqual(length(answer.upperCorner - sset2.boundingBox().upperCorner),
                       0, accuracy:1.0e-9)
    }
    
    func testMixedBoundTypes() {
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0.0, 0.25 * domain.height()])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = SurfaceSet2.builder()
            .withSurfaces(others: [plane, sphere])
            .build()
        
        XCTAssertFalse(surfaceSet.isBounded())
        
        let cp = surfaceSet.closestPoint(otherPoint: Vector2F(0.5, 0.4))
        let answer = Vector2F(0.5, 0.5)
        
        XCTAssertEqual(length(answer - cp), 0, accuracy:1.0e-9)
    }
    
    func testIsValidGeometry() {
        let surfaceSet = SurfaceSet2.builder().build()
        
        XCTAssertFalse(surfaceSet.isValidGeometry())
        
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0, 0.25 * domain.height()])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet2 = SurfaceSet2.builder()
            .withSurfaces(others: [plane, sphere])
            .build()
        
        XCTAssertTrue(surfaceSet2.isValidGeometry())
        
        surfaceSet2.addSurface(surface: surfaceSet)
        
        XCTAssertFalse(surfaceSet2.isValidGeometry())
    }
    
    func testIsInside() {
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        let offset = Vector2F(1, 2)
        
        let plane = Plane2.builder()
            .withNormal(normal: [0, 1])
            .withPoint(point: [0, 0.25 * domain.height()])
            .build()
        
        let sphere = Sphere2.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let surfaceSet = SurfaceSet2.builder()
            .withSurfaces(others: [plane, sphere])
            .withTransform(transform: Transform2(translation: offset, orientation: 0.0))
            .build()
        
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector2F(0.5, 0.25) + offset))
        XCTAssertTrue(surfaceSet.isInside(otherPoint: Vector2F(0.5, 1.0) + offset))
        XCTAssertFalse(surfaceSet.isInside(otherPoint: Vector2F(0.5, 1.5) + offset))
    }
    
    func testUpdateQueryEngine() {
        let sphere = Sphere2.builder()
            .withCenter(center: [-1.0, 1.0])
            .withRadius(radius: 0.5)
            .build()
        
        let surfaceSet = SurfaceSet2.builder()
            .withSurfaces(others: [sphere])
            .withTransform(transform: Transform2(translation: [1.0, 2.0], orientation: 0.0))
            .build()
        
        let bbox1 = surfaceSet.boundingBox()
        XCTAssertEqual(length(BoundingBox2F(point1: [-0.5, 2.5],
                                            point2: [0.5, 3.5]).lowerCorner - bbox1.lowerCorner), 0)
        XCTAssertEqual(length(BoundingBox2F(point1: [-0.5, 2.5],
                                            point2: [0.5, 3.5]).upperCorner - bbox1.upperCorner), 0)
        
        surfaceSet.transform = Transform2(translation: [3.0, -4.0], orientation: 0.0)
        surfaceSet.updateQueryEngine()
        let bbox2 = surfaceSet.boundingBox()
        XCTAssertEqual(length(BoundingBox2F(point1: [1.5, -3.5],
                                            point2: [2.5, -2.5]).lowerCorner - bbox2.lowerCorner), 0)
        XCTAssertEqual(length(BoundingBox2F(point1: [1.5, -3.5],
                                            point2: [2.5, -2.5]).upperCorner - bbox2.upperCorner), 0)
        
        sphere.transform = Transform2(translation: [-6.0, 9.0], orientation: 0.0)
        surfaceSet.updateQueryEngine()
        let bbox3 = surfaceSet.boundingBox()
        XCTAssertEqual(length(BoundingBox2F(point1: [-4.5, 5.5],
                                            point2: [-3.5, 6.5]).lowerCorner - bbox3.lowerCorner), 0)
        XCTAssertEqual(length(BoundingBox2F(point1: [-4.5, 5.5],
                                            point2: [-3.5, 6.5]).upperCorner - bbox3.upperCorner), 0)
        
        // Plane is unbounded. Total bbox should ignore it.
        let plane = Plane2.builder()
            .withNormal(normal: [1.0, 0.0])
            .build()
        surfaceSet.addSurface(surface: plane)
        surfaceSet.updateQueryEngine()
        let bbox4 = surfaceSet.boundingBox()
        XCTAssertEqual(length(BoundingBox2F(point1: [-4.5, 5.5],
                                            point2: [-3.5, 6.5]).lowerCorner - bbox4.lowerCorner), 0)
        XCTAssertEqual(length(BoundingBox2F(point1: [-4.5, 5.5],
                                            point2: [-3.5, 6.5]).upperCorner - bbox4.upperCorner), 0)
    }
}
