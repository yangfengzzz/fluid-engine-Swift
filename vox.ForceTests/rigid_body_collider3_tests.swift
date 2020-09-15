//
//  rigid_body_collider3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class rigid_body_collider3_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testResolveCollision() throws {
        // 1. No penetration
        
        var collider = RigidBodyCollider3 (
            surface: Plane3(normal: Vector3F(0, 1, 0), point: Vector3F(0, 0, 0)))
        
        var newPosition = Vector3F(1, 0.1, 0)
        var newVelocity = Vector3F(1, 0, 0)
        var radius:Float = 0.05
        var restitutionCoefficient:Float = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
        XCTAssertEqual(0.0, newVelocity.z)
        
        
        // 2. Penetration within radius
        collider = RigidBodyCollider3(
            surface: Plane3(normal: Vector3F(0, 1, 0), point: Vector3F(0, 0, 0)))
        
        newPosition = Vector3F(1, 0.1, 0)
        newVelocity = Vector3F(1, 0, 0)
        radius = 0.2
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.2, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        
        
        // 3. Sitting
        collider = RigidBodyCollider3(surface: Plane3(normal: Vector3F(0, 1, 0),
                                                      point: Vector3F(0, 0, 0)))
        
        newPosition = Vector3F(1, 0.1, 0)
        newVelocity = Vector3F(1, 0, 0)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
        XCTAssertEqual(0.0, newVelocity.z)
        
        
        // 4. Bounce-back
        collider = RigidBodyCollider3(surface: Plane3(normal: Vector3F(0, 1, 0),
                                                      point: Vector3F(0, 0, 0)))
        
        newPosition = Vector3F(1, -1, 0)
        newVelocity = Vector3F(1, -1, 0)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(restitutionCoefficient, newVelocity.y)
        XCTAssertEqual(0.0, newVelocity.z)
        
        
        // 4. Friction
        collider = RigidBodyCollider3(surface: Plane3(normal: Vector3F(0, 1, 0),
                                                      point: Vector3F(0, 0, 0)))
        
        newPosition = Vector3F(1, -1, 0)
        newVelocity = Vector3F(1, -1, 0)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.setFrictionCoefficient(newFrictionCoeffient: 0.1)
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        XCTAssertGreaterThan(1.0, newVelocity.x)
        XCTAssertEqual(restitutionCoefficient, newVelocity.y)
        XCTAssertEqual(0.0, newVelocity.z)
    }
    
    func testVelocityAt() {
        let collider = RigidBodyCollider3(surface: Plane3(normal: Vector3F(0, 1, 0),
                                                          point: Vector3F(0, 0, 0)))
        
        collider.linearVelocity = [1, 3, -2]
        collider.angularVelocity = [0, 0, 4]
        var surface = collider.surface()
        surface.transform.setTranslation(translation: [-1, -2, 2])
        surface.transform.setOrientation(orientation: simd_quatf(ix: 1, iy: 0, iz: 0, r: 0.1))
        
        let result = collider.velocityAt(point: [5, 7, 8])
        XCTAssertEqual(-35.0, result.x)
        XCTAssertEqual(27.0, result.y)
        XCTAssertEqual(-2.0, result.z)
    }
    
    func testEmpty() {
        let collider = RigidBodyCollider3(surface: ImplicitSurfaceSet3.builder().build())
        
        var newPosition = Vector3F(1, 0.1, 0)
        var newVelocity = Vector3F(1, 0, 0)
        let radius:Float = 0.05
        let restitutionCoefficient:Float = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(0.0, newPosition.z)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
        XCTAssertEqual(0.0, newVelocity.z)
    }
}
