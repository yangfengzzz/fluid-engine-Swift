//
//  point_particle_emitter2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point_particle_emitter2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let emitter = PointParticleEmitter2 (
            origin: [1.0, 2.0],
            direction: normalize(Vector2F(0.5, 1.0)),
            speed: 3.0,
            spreadAngleInDegrees: 15.0,
            maxNumOfNewParticlesPerSec: 4,
            maxNumOfParticles: 18)
        
        XCTAssertEqual(4, emitter.maxNumberOfNewParticlesPerSecond())
        XCTAssertEqual(18, emitter.maxNumberOfParticles())
    }
    
    func testEmit() {
        let dir = normalize(Vector2F(0.5, 1.0))
        
        let emitter = PointParticleEmitter2 (
            origin: [1.0, 2.0],
            direction: dir,
            speed: 3.0,
            spreadAngleInDegrees: 15.0,
            maxNumOfNewParticlesPerSec: 4,
            maxNumOfParticles: 18)
        
        let particles = ParticleSystemData2()
        emitter.setTarget(particles: particles)
        
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0)
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertEqual(4, particles.numberOfParticles())
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertEqual(8, particles.numberOfParticles())
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertEqual(12, particles.numberOfParticles())
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertEqual(16, particles.numberOfParticles())
        
        frame.advance()
        emitter.update(currentTimeInSeconds: frame.timeInSeconds(),
                       timeIntervalInSeconds: frame.timeIntervalInSeconds)
        XCTAssertEqual(18, particles.numberOfParticles())
        
        let pos:ArrayAccessor1<Vector2F> = particles.positions()
        let vel:ArrayAccessor1<Vector2F> = particles.velocities()
        
        for i in 0..<particles.numberOfParticles() {
            XCTAssertEqual(1.0, pos[i].x)
            XCTAssertEqual(2.0, pos[i].y)
            
            XCTAssertLessThan(
                cos(Math.degreesToRadians(angleInDegrees: 15.0)),
                dot(normalize(vel[i]), dir))
            XCTAssertEqual(3.0, length(vel[i]), accuracy: 1.0e-6)
        }
    }
    
    func testBuilder() {
        let emitter = PointParticleEmitter2.builder()
            .withOrigin(origin: [1.0, 2.0])
            .withDirection(direction: normalize(Vector2F(0.5, 1.0)))
            .withSpeed(speed: 3.0)
            .withSpreadAngleInDegrees(spreadAngleInDegrees: 15.0)
            .withMaxNumberOfNewParticlesPerSecond(maxNumOfNewParticlesPerSec: 4)
            .withMaxNumberOfParticles(maxNumberOfParticles: 18)
            .build()
        
        XCTAssertEqual(4, emitter.maxNumberOfNewParticlesPerSecond())
        XCTAssertEqual(18, emitter.maxNumberOfParticles())
    }
}
