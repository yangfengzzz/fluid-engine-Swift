//
//  array_samplers_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class array_samplers_tests: XCTestCase {
    
    override func setUpWithError() throws {
        _ = Renderer()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testNearestArraySampler1() throws {
        var grid = Array1<Double>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        var gridSpacing:Double = 1.0, gridOrigin:Double = 0.0
        var sampler = NearestArraySampler1<Double, Double>(
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var s0:Double = sampler[pt: 0.45]
        XCTAssertLessThan(fabs(s0 - 1.0), 1e-9)
        
        var s1:Double = sampler[pt: 1.57]
        XCTAssertLessThan(fabs(s1 - 3.0), 1e-9)
        
        let s2:Double = sampler[pt: 3.51]
        XCTAssertLessThan(fabs(s2 - 4.0), 1e-9)
        
        grid = Array1<Double>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        gridSpacing = 0.5
        gridOrigin = -1.0
        sampler = NearestArraySampler1<Double, Double>(
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        s0 = sampler[pt: 0.45]
        XCTAssertLessThan(fabs(s0 - 4.0), 1e-9)
        
        s1 = sampler[pt: -0.05]
        XCTAssertLessThan(fabs(s1 - 3.0), 1e-9)
    }
    
    func testLinearArraySampler1() {
        var grid = Array1<Double>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        var gridSpacing:Double = 1.0, gridOrigin:Double = 0.0
        var sampler = LinearArraySampler1<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var s0:Double = sampler[pt: 0.5]
        XCTAssertLessThan(fabs(s0 - 1.5), 1e-9)
        
        var s1:Double = sampler[pt: 1.8]
        XCTAssertLessThan(fabs(s1 - 2.8), 1e-9)
        
        let s2:Double = sampler[pt: 3.5]
        XCTAssertEqual(4.0, s2, accuracy: 1e-9)
        
        grid = Array1<Double>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        gridSpacing = 0.5
        gridOrigin = -1.0
        sampler = LinearArraySampler1<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        s0 = sampler[pt: 0.2]
        XCTAssertLessThan(fabs(s0 - 3.4), 1e-9)
        
        s1 = sampler[pt: -0.7]
        XCTAssertLessThan(fabs(s1 - 1.6), 1e-9)
    }
    
    func testCubicArraySampler1() {
        let grid = Array1<Double>(lst: [ 1.0, 2.0, 3.0, 4.0 ])
        let gridSpacing:Double = 1.0, gridOrigin:Double = 0.0
        let sampler = CubicArraySampler1<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let s0:Double = sampler[pt: 1.25]
        XCTAssertLessThan(2.0, s0)
        XCTAssertGreaterThan(3.0, s0)
    }
    
    func testNearestArraySampler2() {
        var grid = Array2<Double> (
            lst: [[ 1.0, 2.0, 3.0, 4.0 ],
                  [ 2.0, 3.0, 4.0, 5.0 ],
                  [ 3.0, 4.0, 5.0, 6.0 ],
                  [ 4.0, 5.0, 6.0, 7.0 ],
                  [ 5.0, 6.0, 7.0, 8.0 ]])
        var gridSpacing = Vector2D(1.0, 1.0), gridOrigin = Vector2D()
        var sampler = NearestArraySampler2<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var s0:Double = sampler[pt: Vector2D(0.45, 0.45)]
        XCTAssertLessThan(fabs(s0 - 1.0), 1e-9)
        
        var s1:Double = sampler[pt: Vector2D(1.57, 4.01)]
        XCTAssertLessThan(fabs(s1 - 7.0), 1e-9)
        
        let s2:Double = sampler[pt: Vector2D(3.50, 1.21)]
        XCTAssertLessThan(fabs(s2 - 5.0), 1e-9)
        
        grid = Array2<Double> (
            lst: [[ 1.0, 2.0, 3.0, 4.0 ],
                  [ 2.0, 3.0, 4.0, 5.0 ],
                  [ 3.0, 4.0, 5.0, 6.0 ],
                  [ 4.0, 5.0, 6.0, 7.0 ],
                  [ 5.0, 6.0, 7.0, 8.0 ]])
        gridSpacing = Vector2D(0.5, 0.25)
        gridOrigin = Vector2D(-1.0, -0.5)
        sampler = NearestArraySampler2<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        s0 = sampler[pt: Vector2D(0.45, 0.4)]
        XCTAssertLessThan(fabs(s0 - 8.0), 1e-9)
        
        s1 = sampler[pt: Vector2D(-0.05, 0.37)]
        XCTAssertLessThan(fabs(s1 - 6.0), 1e-9)
    }
    
    func testLinearArraySampler2() {
        var grid = Array2<Double> (
            lst: [[ 1.0, 2.0, 3.0, 4.0 ],
                  [ 2.0, 3.0, 4.0, 5.0 ],
                  [ 3.0, 4.0, 5.0, 6.0 ],
                  [ 4.0, 5.0, 6.0, 7.0 ],
                  [ 5.0, 6.0, 7.0, 8.0 ]])
        var gridSpacing = Vector2D(1.0, 1.0), gridOrigin = Vector2D()
        var sampler = LinearArraySampler2<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        var s0:Double = sampler[pt: Vector2D(0.5, 0.5)]
        XCTAssertLessThan(fabs(s0 - 2.0), 1e-9)
        
        var s1:Double = sampler[pt: Vector2D(1.5, 4.0)]
        XCTAssertLessThan(fabs(s1 - 6.5), 1e-9)
        
        grid = Array2<Double> (
            lst: [[ 1.0, 2.0, 3.0, 4.0 ],
                  [ 2.0, 3.0, 4.0, 5.0 ],
                  [ 3.0, 4.0, 5.0, 6.0 ],
                  [ 4.0, 5.0, 6.0, 7.0 ],
                  [ 5.0, 6.0, 7.0, 8.0 ]])
        gridSpacing = Vector2D(0.5, 0.25)
        gridOrigin = Vector2D(-1.0, -0.5)
        sampler = LinearArraySampler2<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        s0 = sampler[pt: Vector2D(0.5, 0.5)]
        XCTAssertLessThan(fabs(s0 - 8.0), 1e-9)
        
        s1 = sampler[pt: Vector2D(-0.5, 0.375)]
        XCTAssertLessThan(fabs(s1 - 5.5), 1e-9)
    }
    
    func testCubicArraySampler2() {
        let grid = Array2<Double> (
            lst: [[ 1.0, 2.0, 3.0, 4.0 ],
                  [ 2.0, 3.0, 4.0, 5.0 ],
                  [ 3.0, 4.0, 5.0, 6.0 ],
                  [ 4.0, 5.0, 6.0, 7.0 ],
                  [ 5.0, 6.0, 7.0, 8.0 ]])
        let gridSpacing = Vector2D(1.0, 1.0), gridOrigin = Vector2D()
        let sampler = CubicArraySampler2<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let s0 = sampler[pt: Vector2D(1.5, 2.8)]
        XCTAssertLessThan(4.0, s0)
        XCTAssertGreaterThan(6.0, s0)
    }
    
    func testCubicArraySampler3() {
        var grid = Array3<Double>(width: 4, height: 4, depth: 4)
        for k in 0..<4 {
            for j in 0..<4 {
                for i in 0..<4 {
                    grid[i, j, k] = Double(i + j + k)
                }
            }
        }
        
        let gridSpacing = Vector3D(1.0, 1.0, 1.0), gridOrigin = Vector3D()
        let sampler = CubicArraySampler3<Double, Double> (
            accessor: grid.constAccessor(),
            gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let s0:Double = sampler[pt: Vector3D(1.5, 1.8, 1.2)]
        XCTAssertLessThan(3.0, s0)
        XCTAssertGreaterThan(6.0, s0)
    }
}
