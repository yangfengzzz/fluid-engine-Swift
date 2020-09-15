//
//  rigid_body_collider2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class rigid_body_collider2_tests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testResolveCollision() throws {
        // 1. No penetration
        var collider = RigidBodyCollider2 (
            surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0)))
        
        var newPosition = Vector2F(1, 0.1)
        var newVelocity = Vector2F(1, 0)
        var radius:Float = 0.05
        var restitutionCoefficient:Float = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
        
        
        // 2. Penetration within radius
        collider = RigidBodyCollider2 (
            surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0)))
        
        newPosition = Vector2F(1, 0.1)
        newVelocity = Vector2F(1, 0)
        radius = 0.2
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.2, newPosition.y)
        
        
        // 3. Sitting
        collider = RigidBodyCollider2 (
            surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0)))
        
        newPosition = Vector2F(1, 0.1)
        newVelocity = Vector2F(1, 0)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
        
        
        // 4. Bounce-back
        collider = RigidBodyCollider2(
            surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0)))
        
        newPosition = Vector2F(1, -1)
        newVelocity = Vector2F(1, -1)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(restitutionCoefficient, newVelocity.y)
        
        
        // 4. Friction
        collider = RigidBodyCollider2(
            surface: Plane2(normal: Vector2F(0, 1), point: Vector2F(0, 0)))
        
        newPosition = Vector2F(1, -1)
        newVelocity = Vector2F(1, -1)
        radius = 0.1
        restitutionCoefficient = 0.5
        
        collider.setFrictionCoefficient(newFrictionCoeffient: 0.1)
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertGreaterThan(1.0, newVelocity.x)
        XCTAssertEqual(restitutionCoefficient, newVelocity.y)
    }
    
    func testVelocityAt() {
        let collider = RigidBodyCollider2(surface: Plane2(normal: Vector2F(0, 1),
                                                          point: Vector2F(0, 0)))
        
        var surface = collider.surface()
        surface.transform.setTranslation(translation: [-1, -2])
        surface.transform.setOrientation(orientation: 0.1)
        collider.linearVelocity = [1, 3]
        collider.angularVelocity = 4.0
        
        let result = collider.velocityAt(point: [5, 7])
        XCTAssertEqual(-35.0, result.x)
        XCTAssertEqual(27.0, result.y)
    }
    
    func testEmpty() {
        let collider = RigidBodyCollider2(surface: ImplicitSurfaceSet2.builder().build())
        
        var newPosition = Vector2F(1, 0.1)
        var newVelocity = Vector2F(1, 0)
        let radius:Float = 0.05
        let restitutionCoefficient:Float = 0.5
        
        collider.resolveCollision(radius: radius, restitutionCoefficient: restitutionCoefficient,
                                  position: &newPosition, velocity: &newVelocity)
        
        XCTAssertEqual(1.0, newPosition.x)
        XCTAssertEqual(0.1, newPosition.y)
        XCTAssertEqual(1.0, newVelocity.x)
        XCTAssertEqual(0.0, newVelocity.y)
    }
}
