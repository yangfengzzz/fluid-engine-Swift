//
//  volume_particle_emitter3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class volume_particle_emitter3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let sphere = SurfaceToImplicit3(surface: Sphere3(center: Vector3F(1.0, 2.0, 4.0),
                                                         radiustransform: 3.0))
        
        let region = BoundingBox3F(point1: [0.0, 0.0, 0.0], point2: [3.0, 3.0, 3.0])
        
        let emitter = VolumeParticleEmitter3 (
            implicitSurface: sphere,
            maxRegion: region,
            spacing: 0.1,
            initialVel: [-1.0, 0.5, 2.5],
            linearVel: [0.0, 0.0, 0.0],
            angularVel: [0.0, 0.0, 0.0],
            maxNumberOfParticles: 30,
            jitter: 0.01,
            isOneShot: false,
            allowOverlapping: true)
        
        XCTAssertEqual(region.lowerCorner, emitter.maxRegion().lowerCorner)
        XCTAssertEqual(region.upperCorner, emitter.maxRegion().upperCorner)
        XCTAssertEqual(0.01, emitter.jitter())
        XCTAssertFalse(emitter.isOneShot())
        XCTAssertTrue(emitter.allowOverlapping())
        XCTAssertEqual(30, emitter.maxNumberOfParticles())
        XCTAssertEqual(0.1, emitter.spacing())
        XCTAssertEqual(-1.0, emitter.initialVelocity().x)
        XCTAssertEqual(0.5, emitter.initialVelocity().y)
        XCTAssertEqual(2.5, emitter.initialVelocity().z)
        XCTAssertEqual(Vector3F(), emitter.linearVelocity())
        XCTAssertEqual(Vector3F(), emitter.angularVelocity())
        XCTAssertTrue(emitter.isEnabled())
    }
    
    func testEmit() {
        let sphere = SurfaceToImplicit3(surface: Sphere3(center: Vector3F(1.0, 2.0, 4.0),
                                                         radiustransform: 3.0))
        
        let box = BoundingBox3F(point1: [0.0, 0.0, 0.0], point2: [3.0, 3.0, 3.0])
        
        let emitter = VolumeParticleEmitter3(
            implicitSurface: sphere,
            maxRegion: box,
            spacing: 0.5,
            initialVel: [-1.0, 0.5, 2.5],
            linearVel: [3.0, 4.0, 5.0],
            angularVel: [0.0, 0.0, 5.0],
            maxNumberOfParticles: 30,
            jitter: 0.0,
            isOneShot: false,
            allowOverlapping: false)
        
        let particles = ParticleSystemData3()
        emitter.setTarget(particles: particles)
        
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0)
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        
        var pos:ArrayAccessor1<Vector3F> = particles.positions()
        let vel:ArrayAccessor1<Vector3F> = particles.velocities()
        
        XCTAssertEqual(30, particles.numberOfParticles())
        for i in 0..<particles.numberOfParticles() {
            XCTAssertGreaterThan(3.0, length(pos[i] - Vector3F(1.0, 2.0, 4.0)))
            XCTAssertTrue(box.contains(point: pos[i]))
            
            let r = pos[i]
            let w = 5.0 * Vector3F(-r.y, r.x, 0.0)
            XCTAssertEqual(length(Vector3F(2.0, 4.5, 7.5) + w - vel[i]), 0, accuracy: 1e-9)
        }
        
        emitter.setIsEnabled(enabled: false)
        frame.advance()
        emitter.setMaxNumberOfParticles(newMaxNumberOfParticles: 80)
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        
        XCTAssertEqual(30, particles.numberOfParticles())
        emitter.setIsEnabled(enabled: true)
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        
        XCTAssertEqual(79, particles.numberOfParticles())
        
        pos = particles.positions()
        for i in 0..<particles.numberOfParticles() {
            pos[i] += Vector3F(2.0, 1.5, 5.0)
        }
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertLessThan(79, particles.numberOfParticles())
    }
    
    func testBuilder() {
        let sphere = Sphere3(center: Vector3F(1.0, 2.0, 4.0), radiustransform: 3.0)
        
        let emitter = VolumeParticleEmitter3.builder()
            .withSurface(surface: sphere)
            .withMaxRegion(bounds: BoundingBox3F(point1: [0.0, 0.0, 0.0],
                                                 point2: [3.0, 3.0, 3.0]))
            .withSpacing(spacing: 0.1)
            .withInitialVelocity(initialVel: [-1.0, 0.5, 2.5])
            .withLinearVelocity(linearVel: [3.0, 4.0, 5.0])
            .withAngularVelocity(angularVel: [0.0, 1.0, 2.0])
            .withMaxNumberOfParticles(maxNumberOfParticles: 30)
            .withJitter(jitter: 0.01)
            .withIsOneShot(isOneShot: false)
            .withAllowOverlapping(allowOverlapping: true)
            .build()
        
        XCTAssertEqual(0.01, emitter.jitter())
        XCTAssertFalse(emitter.isOneShot())
        XCTAssertTrue(emitter.allowOverlapping())
        XCTAssertEqual(30, emitter.maxNumberOfParticles())
        XCTAssertEqual(0.1, emitter.spacing())
        XCTAssertEqual(-1.0, emitter.initialVelocity().x)
        XCTAssertEqual(0.5, emitter.initialVelocity().y)
        XCTAssertEqual(2.5, emitter.initialVelocity().z)
        XCTAssertEqual(Vector3F(3.0, 4.0, 5.0), emitter.linearVelocity())
        XCTAssertEqual(Vector3F(0.0, 1.0, 2.0), emitter.angularVelocity())
    }
}
