//
//  particle_system_solvers_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class particle_system_solvers_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructor2() throws {
        let solver = ParticleSystemSolver2()
        
        let data = solver.particleSystemData()
        XCTAssertEqual(0, data.numberOfParticles())
        
        let collider = solver.collider()
        XCTAssertTrue(nil == collider)
    }
    
    func testBasicParams2() {
        let solver = ParticleSystemSolver2()
        
        solver.setDragCoefficient(newDragCoefficient: 6.0)
        XCTAssertEqual(6.0, solver.dragCoefficient())
        
        solver.setDragCoefficient(newDragCoefficient: -7.0)
        XCTAssertEqual(0.0, solver.dragCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.5)
        XCTAssertEqual(0.5, solver.restitutionCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 8.0)
        XCTAssertEqual(1.0, solver.restitutionCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: -8.0)
        XCTAssertEqual(0.0, solver.restitutionCoefficient())
        
        solver.setGravity(newGravity: Vector2F(2, -10))
        XCTAssertEqual(Vector2F(2, -10), solver.gravity())
    }
    
    func testUpdate2() {
        let solver = ParticleSystemSolver2()
        solver.setGravity(newGravity: Vector2F(0, -10))
        
        let data = solver.particleSystemData()
        let positions = ParticleSystemData2.VectorData(size: 10)
        data.addParticles(newPositions: positions.constAccessor())
        
        let frame = Frame(newIndex: 0,
                          newTimeIntervalInSeconds: 1.0 / 60.0)
        solver.update(frame: frame)
        
        let position:ConstArrayAccessor1<Vector2F> = data.positions()
        let velocities:ConstArrayAccessor1<Vector2F> = data.velocities()
        for i in 0..<data.numberOfParticles() {
            XCTAssertEqual(0.0, position[i].x)
            XCTAssertNotEqual(0, position[i].y)
            
            XCTAssertEqual(0.0, velocities[i].x)
            XCTAssertNotEqual(0, velocities[i].y)
        }
    }
    
    func testConstructor3() {
        let solver = ParticleSystemSolver3()
        
        let data = solver.particleSystemData()
        XCTAssertEqual(0, data.numberOfParticles())
        
        let collider = solver.collider()
        XCTAssertTrue(nil == collider)
    }
    
    func testBasicParams3() {
        let solver = ParticleSystemSolver3()
        
        solver.setDragCoefficient(newDragCoefficient: 6.0)
        XCTAssertEqual(6.0, solver.dragCoefficient())
        
        solver.setDragCoefficient(newDragCoefficient: -7.0)
        XCTAssertEqual(0.0, solver.dragCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 0.5)
        XCTAssertEqual(0.5, solver.restitutionCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: 8.0)
        XCTAssertEqual(1.0, solver.restitutionCoefficient())
        
        solver.setRestitutionCoefficient(newRestitutionCoefficient: -8.0)
        XCTAssertEqual(0.0, solver.restitutionCoefficient())
        
        solver.setGravity(newGravity: Vector3F(3, -10, 7))
        XCTAssertEqual(Vector3F(3, -10, 7), solver.gravity())
    }
    
    func testUpdate3() {
        let solver = ParticleSystemSolver3()
        solver.setGravity(newGravity: Vector3F(0, -10, 0))
        
        let data = solver.particleSystemData()
        let positions = ParticleSystemData3.VectorData(size: 10)
        data.addParticles(newPositions: positions.constAccessor())
        
        let frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        solver.update(frame: frame)
        
        let position:ConstArrayAccessor1<Vector3F> = data.positions()
        let velocities:ConstArrayAccessor1<Vector3F> = data.velocities()
        for i in 0..<data.numberOfParticles() {
            XCTAssertEqual(0.0, position[i].x)
            XCTAssertNotEqual(0, position[i].y)
            XCTAssertEqual(0.0, position[i].z)
            
            XCTAssertEqual(0.0, velocities[i].x)
            XCTAssertNotEqual(0, velocities[i].y)
            XCTAssertEqual(0.0, velocities[i].z)
        }
    }
}
