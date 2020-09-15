//
//  particle_system_data3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/25.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class particle_system_data3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let particleSystem = ParticleSystemData3()
        XCTAssertEqual(0, particleSystem.numberOfParticles())
        
        let particleSystem2 = ParticleSystemData3(numberOfParticles: 100)
        XCTAssertEqual(100, particleSystem2.numberOfParticles())
        
        let a0 = particleSystem2.addScalarData(initialVal: 2.0)
        let a1 = particleSystem2.addScalarData(initialVal: 9.0)
        let a2 = particleSystem2.addVectorData(initialVal: [1.0, -3.0, 5.0])
        
        let particleSystem3 = ParticleSystemData3(other: particleSystem2)
        XCTAssertEqual(100, particleSystem3.numberOfParticles())
        let as0:ArrayAccessor1<Float> = particleSystem3.scalarDataAt(idx: a0)
        for i in 0..<100 {
            XCTAssertEqual(2.0, as0[i])
        }
        
        let as1:ArrayAccessor1<Float> = particleSystem3.scalarDataAt(idx: a1)
        for i in 0..<100 {
            XCTAssertEqual(9.0, as1[i])
        }
        
        let as2:ArrayAccessor1<Vector3F> = particleSystem3.vectorDataAt(idx: a2)
        for i in 0..<100 {
            XCTAssertEqual(1.0, as2[i].x)
            XCTAssertEqual(-3.0, as2[i].y)
            XCTAssertEqual(5.0, as2[i].z)
        }
    }
    
    func testResize() {
        let particleSystem = ParticleSystemData3()
        particleSystem.resize(newNumberOfParticles: 12)
        
        XCTAssertEqual(12, particleSystem.numberOfParticles())
    }
    
    func testAddScalarData() {
        let particleSystem = ParticleSystemData3()
        particleSystem.resize(newNumberOfParticles: 12)
        
        let a0 = particleSystem.addScalarData(initialVal: 2.0)
        let a1 = particleSystem.addScalarData(initialVal: 9.0)
        
        XCTAssertEqual(12, particleSystem.numberOfParticles())
        XCTAssertEqual(0, a0)
        XCTAssertEqual(1, a1)
        
        let as0:ArrayAccessor1<Float> = particleSystem.scalarDataAt(idx: a0)
        for i in 0..<12 {
            XCTAssertEqual(2.0, as0[i])
        }
        
        let as1:ArrayAccessor1<Float> = particleSystem.scalarDataAt(idx: a1)
        for i in 0..<12 {
            XCTAssertEqual(9.0, as1[i])
        }
    }
    
    func testAddVectorData() {
        let particleSystem = ParticleSystemData3()
        particleSystem.resize(newNumberOfParticles: 12)
        
        let a0 = particleSystem.addVectorData(initialVal: Vector3F(2.0, 4.0, -1.0))
        let a1 = particleSystem.addVectorData(initialVal: Vector3F(9.0, -2.0, 5.0))
        
        XCTAssertEqual(12, particleSystem.numberOfParticles())
        XCTAssertEqual(3, a0)
        XCTAssertEqual(4, a1)
        
        let as0:ArrayAccessor1<Vector3F> = particleSystem.vectorDataAt(idx: a0)
        for i in 0..<12 {
            XCTAssertEqual(Vector3F(2.0, 4.0, -1.0), as0[i])
        }
        
        let as1:ArrayAccessor1<Vector3F> = particleSystem.vectorDataAt(idx: a1)
        for i in 0..<12 {
            XCTAssertEqual(Vector3F(9.0, -2.0, 5.0), as1[i])
        }
    }
    
    func testAddParticles() {
        let particleSystem = ParticleSystemData3()
        particleSystem.resize(newNumberOfParticles: 12)
        
        particleSystem.addParticles(
            newPositions: Array1<Vector3F>(lst: [Vector3F(1.0, 2.0, 3.0), Vector3F(4.0, 5.0, 6.0)])
                .constAccessor(),
            newVelocities: Array1<Vector3F>(lst: [Vector3F(7.0, 8.0, 9.0), Vector3F(8.0, 7.0, 6.0)])
                .constAccessor(),
            newForces: Array1<Vector3F>(lst: [Vector3F(5.0, 4.0, 3.0), Vector3F(2.0, 1.0, 3.0)])
                .constAccessor())
        
        XCTAssertEqual(14, particleSystem.numberOfParticles())
        let p:ArrayAccessor1<Vector3F> = particleSystem.positions()
        let v:ArrayAccessor1<Vector3F> = particleSystem.velocities()
        let f:ArrayAccessor1<Vector3F> = particleSystem.forces()
        
        XCTAssertEqual(Vector3F(1.0, 2.0, 3.0), p[12])
        XCTAssertEqual(Vector3F(4.0, 5.0, 6.0), p[13])
        XCTAssertEqual(Vector3F(7.0, 8.0, 9.0), v[12])
        XCTAssertEqual(Vector3F(8.0, 7.0, 6.0), v[13])
        XCTAssertEqual(Vector3F(5.0, 4.0, 3.0), f[12])
        XCTAssertEqual(Vector3F(2.0, 1.0, 3.0), f[13])
    }
    
    //    func testAddParticlesException() {
    //        let particleSystem = ParticleSystemData3()
    //        particleSystem.resize(newNumberOfParticles: 12)
    //
    //        do {
    //            particleSystem.addParticles(
    //                newPositions: Array1<Vector3F>(lst: [Vector3F(1.0, 2.0, 3.0), Vector3F(4.0, 5.0, 6.0)])
    //                    .constAccessor(),
    //                newVelocities: Array1<Vector3F>(lst: [Vector3F(7.0, 8.0, 9.0)]).constAccessor(),
    //                newForces: Array1<Vector3F>(lst: [Vector3F(5.0, 4.0, 3.0), Vector3F(2.0, 1.0, 3.0)])
    //                    .constAccessor())
    //
    //            XCTAssertFalse(true, "Invalid argument shoudl throw exception.")
    //        }
    //
    //        XCTAssertEqual(12, particleSystem.numberOfParticles())
    //
    //        do {
    //            particleSystem.addParticles(
    //                newPositions: Array1<Vector3F>(lst: [Vector3F(1.0, 2.0, 3.0), Vector3F(4.0, 5.0, 6.0)])
    //                    .constAccessor(),
    //                newVelocities: Array1<Vector3F>(lst: [Vector3F(7.0, 8.0, 9.0), Vector3F(2.0, 1.0, 3.0)])
    //                    .constAccessor(),
    //                newForces: Array1<Vector3F>(lst: [Vector3F(5.0, 4.0, 3.0)]).constAccessor())
    //
    //            XCTAssertFalse(true, "Invalid argument shoudl throw exception.")
    //        }
    //
    //        XCTAssertEqual(12, particleSystem.numberOfParticles())
    //    }
    
    func testBuildNeighborSearcher() {
        let particleSystem = ParticleSystemData3()
        let positions = ParticleSystemData3.VectorData(lst: [
            [0.1, 0.0, 0.4], [0.6, 0.2, 0.6], [1.0, 0.3, 0.4], [0.9, 0.2, 0.2],
            [0.8, 0.4, 0.9], [0.1, 0.6, 0.2], [0.8, 0.0, 0.5], [0.9, 0.8, 0.2],
            [0.3, 0.5, 0.2], [0.1, 0.6, 0.6], [0.1, 0.2, 0.1], [0.2, 0.0, 0.0],
            [0.2, 0.6, 0.1], [0.1, 0.3, 0.7], [0.9, 0.7, 0.6], [0.4, 0.5, 0.1],
            [0.1, 0.1, 0.6], [0.7, 0.8, 1.0], [0.6, 0.9, 0.4], [0.7, 0.7, 0.0]
        ])
        particleSystem.addParticles(newPositions: positions.constAccessor())
        
        let radius:Float = 0.4
        particleSystem.buildNeighborSearcher(maxSearchRadius: radius)
        
        let neighborSearcher = particleSystem.neighborSearcher()
        let searchOrigin = Vector3F(0.1, 0.2, 0.3)
        var found:[size_t] = []
        neighborSearcher.forEachNearbyPoint(
            origin: searchOrigin, radius: radius,
            callback: {(i:size_t, _:Vector3F) in
                found.append(i)
        })
        
        for ii in 0..<positions.size() {
            if (length(searchOrigin - positions[ii]) <= radius) {
                XCTAssertTrue(found.contains(ii))
            }
        }
    }
    
    func testBuildNeighborLists() {
        let particleSystem = ParticleSystemData3()
        let positions = ParticleSystemData3.VectorData(lst: [
            [0.7, 0.2, 0.2], [0.7, 0.8, 1.0], [0.9, 0.4, 0.0], [0.5, 0.1, 0.6],
            [0.6, 0.3, 0.8], [0.1, 0.6, 0.0], [0.5, 1.0, 0.2], [0.6, 0.7, 0.8],
            [0.2, 0.4, 0.7], [0.8, 0.5, 0.8], [0.0, 0.8, 0.4], [0.3, 0.0, 0.6],
            [0.7, 0.8, 0.3], [0.0, 0.7, 0.1], [0.6, 0.3, 0.8], [0.3, 0.2, 1.0],
            [0.3, 0.5, 0.6], [0.3, 0.9, 0.6], [0.9, 1.0, 1.0], [0.0, 0.1, 0.6]
        ])
        particleSystem.addParticles(newPositions: positions.constAccessor())
        
        let radius:Float = 0.4
        particleSystem.buildNeighborSearcher(maxSearchRadius: radius)
        particleSystem.buildNeighborLists(maxSearchRadius: radius)
        
        let neighborLists = particleSystem.neighborLists()
        XCTAssertEqual(positions.size(), neighborLists.count)
        
        for i in 0..<neighborLists.count {
            let neighbors = neighborLists[i]
            for ii in 0..<positions.size() {
                if (ii != i && length(positions[ii] - positions[i]) <= radius) {
                    XCTAssertTrue(neighbors.contains(ii))
                }
            }
        }
    }
}
