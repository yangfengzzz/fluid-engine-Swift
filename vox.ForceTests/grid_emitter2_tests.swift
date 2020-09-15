//
//  grid_emitter2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class grid_emitter2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testVelocity() throws {
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 0.75])
            .withRadius(radius: 0.15)
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: sphere)
            .build()
        
        let grid = CellCenteredVectorGrid2.builder()
            .withResolution(resolution: [16, 16])
            .withGridSpacing(gridSpacing: [Float(1.0)/16.0, Float(1.0)/16.0])
            .withOrigin(gridOrigin: [0, 0])
            .build()
        
        let mapper = {(sdf:Float, pt:Vector2F, oldVal:Vector2F)->Vector2F in
            if (sdf < 0.0) {
                return Vector2F(pt.y, -pt.x)
            } else {
                return Vector2F(oldVal)
            }
        }
        
        emitter.addTarget(vectorGridTarget: grid, customMapper: mapper)
        
        emitter.update(currentTimeInSeconds: 0.0, timeIntervalInSeconds: 0.01)
        
        let pos = grid.dataPosition()
        grid.forEachDataPointIndex(){(i:size_t, j:size_t) in
            let gx = pos(i, j)
            let sdf = emitter.sourceRegion().signedDistance(otherPoint: gx)
            if (isInsideSdf(phi: sdf)) {
                let answer = Vector2F(gx.y, -gx.x)
                let acttual = grid[i, j]
                
                XCTAssertEqual(answer.x, acttual.x, accuracy: 1e-6)
                XCTAssertEqual(answer.y, acttual.y, accuracy: 1e-6)
            }
        }
    }
    
    func testSignedDistance() {
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 0.75])
            .withRadius(radius: 0.15)
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: sphere)
            .build()
        
        let grid = CellCenteredScalarGrid2.builder()
            .withResolution(resolution: [16, 16])
            .withGridSpacing(gridSpacing: [Float(1.0)/16.0, Float(1.0)/16.0])
            .withOrigin(gridOrigin: [0, 0])
            .withInitialValue(initialVal: Float.greatestFiniteMagnitude)
            .build()
        
        emitter.addSignedDistanceTarget(scalarGridTarget: grid)
        
        emitter.update(currentTimeInSeconds: 0.0, timeIntervalInSeconds: 0.01)
        
        let pos = grid.dataPosition()
        grid.forEachDataPointIndex(){(i:size_t, j:size_t) in
            let gx = pos(i, j)
            let answer = length(sphere.center - gx) - 0.15
            let acttual = grid[i, j]
            
            XCTAssertEqual(answer, acttual, accuracy: 1e-6)
        }
    }
    
    func testStepFunction() {
        let sphere = Sphere2.builder()
            .withCenter(center: [0.5, 0.75])
            .withRadius(radius: 0.15)
            .build()
        
        let emitter = VolumeGridEmitter2.builder()
            .withSourceRegion(sourceRegion: sphere)
            .build()
        
        let grid = CellCenteredScalarGrid2.builder()
            .withResolution(resolution: [16, 16])
            .withGridSpacing(gridSpacing: [Float(1.0)/16.0, Float(1.0)/16.0])
            .withOrigin(gridOrigin: [0, 0])
            .build()
        
        emitter.addStepFunctionTarget(scalarGridTarget: grid, minValue: 3.0, maxValue: 7.0)
        
        emitter.update(currentTimeInSeconds: 0.0, timeIntervalInSeconds: 0.01)
        
        let pos = grid.dataPosition()
        grid.forEachDataPointIndex(){(i:size_t, j:size_t) in
            let gx = pos(i, j)
            var answer = length(sphere.center - gx) - 0.15
            answer = 4.0 * (1.0 - smearedHeavisideSdf(phi: answer * 16.0)) + 3.0
            let acttual = grid[i, j]
            
            XCTAssertEqual(answer, acttual, accuracy: 1e-5)
        }
    }
}
