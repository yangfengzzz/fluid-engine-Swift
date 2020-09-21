//
//  sph_solver2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sph_solver2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUpdateEmpty() throws {
        // Empty solver test
        let solver = SphSolver2()
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 0.01)
        solver.update(frame: frame)
        frame.advance()
        solver.update(frame: frame)
    }
    
    func testParameters() {
        let solver = SphSolver2()
        
        solver.setEosExponent(newEosExponent: 5.0)
        XCTAssertEqual(5.0, solver.eosExponent())
        
        solver.setEosExponent(newEosExponent: -1.0)
        XCTAssertEqual(1.0, solver.eosExponent())
        
        solver.setNegativePressureScale(newNegativePressureScale: 0.3)
        XCTAssertEqual(0.3, solver.negativePressureScale())
        
        solver.setNegativePressureScale(newNegativePressureScale: -1.0)
        XCTAssertEqual(0.0, solver.negativePressureScale())
        
        solver.setNegativePressureScale(newNegativePressureScale: 3.0)
        XCTAssertEqual(1.0, solver.negativePressureScale())
        
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.3)
        XCTAssertEqual(0.3, solver.viscosityCoefficient())
        
        solver.setViscosityCoefficient(newViscosityCoefficient: -1.0)
        XCTAssertEqual(0.0, solver.viscosityCoefficient())
        
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 0.3)
        XCTAssertEqual(0.3, solver.pseudoViscosityCoefficient())
        
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: -1.0)
        XCTAssertEqual(0.0, solver.pseudoViscosityCoefficient())
        
        solver.setSpeedOfSound(newSpeedOfSound: 0.3)
        XCTAssertEqual(0.3, solver.speedOfSound())
        
        solver.setSpeedOfSound(newSpeedOfSound: -1.0)
        XCTAssertGreaterThan(solver.speedOfSound(), 0.0)
        
        solver.setTimeStepLimitScale(newScale: 0.3)
        XCTAssertEqual(0.3, solver.timeStepLimitScale())
        
        solver.setTimeStepLimitScale(newScale: -1.0)
        XCTAssertEqual(0.0, solver.timeStepLimitScale())
    }
    
    func testNeighborListsBuffer() {
        //SteadyState
        let solver = SphSolver2()
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.1)
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 10.0)
        
        let particles = solver.sphSystemData()
        let targetSpacing = particles.targetSpacing()
        
        var initialBound = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 0.5))
        initialBound.expand(delta: -targetSpacing)
        
        let emitter = VolumeParticleEmitter2(implicitSurface: SurfaceToImplicit2(surface: Sphere2(center: Vector2F(),
                                                                                                  radiustransform: 10.0)),
                                             maxRegion: initialBound,
                                             spacing: particles.targetSpacing(),
                                             initialVel: Vector2F())
        emitter.setJitter(newJitter: 0.0)
        solver.setEmitter(newEmitter: emitter)
        
        let box = Box2(lowerCorner: Vector2F(), upperCorner: Vector2F(1, 1))
        box.isNormalFlipped = true
        let collider = RigidBodyCollider2(surface: box)
        
        solver.setCollider(newCollider: collider)
        
        //Update
        var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
        frame.advance()
        solver.update(frame: frame)
        
        //Output
        let result = Array1<Int32>(size: solver.sphSystemData()._neighborLists_index.size())
        solver.sphSystemData().buildNeighborListsBuffer()
        parallelFor(beginIndex: 0, endIndex: solver.sphSystemData()._neighborLists_index.size(),
                    name: "testNeighborListsBuffer") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = result.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = particles.loadNeighborLists(encoder: &encoder, index_begin: index)
        }
        
        let neighborLists = solver.sphSystemData()._neighborLists_index
        for i in 0..<result.size() {
            XCTAssertEqual(result[i], neighborLists[i])
        }
    }
}
