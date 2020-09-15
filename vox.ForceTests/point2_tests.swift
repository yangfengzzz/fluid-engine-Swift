//
//  point2_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let pt:Point2F = Point2F()
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(0.0, pt.y)
        
        let pt2:Point2F = Point2F(5.0, 3.0)
        XCTAssertEqual(5.0, pt2.x)
        XCTAssertEqual(3.0, pt2.y)
        
        let pt5:Point2F = Point2F([Float(7.0), Float(6.0)])
        XCTAssertEqual(7.0, pt5.x)
        XCTAssertEqual(6.0, pt5.y)
        
        let pt6:Point2F = Point2F(pt5)
        XCTAssertEqual(7.0, pt6.x)
        XCTAssertEqual(6.0, pt6.y)
    }
    
    func testReplaceMethods() throws {
        var pt:Point2F = Point2F()
        pt.replace(with: Point2F(4.0, 2.0), where: [true, true])
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(2.0, pt.y)
        
        let lst:[Float] = [0.0, 5.0]
        pt.replace(with: Point2F(lst), where: [true, true])
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(5.0, pt.y)
        
        pt.replace(with: Point2F(9.0, 8.0), where: [true, true])
        XCTAssertEqual(9.0, pt.x)
        XCTAssertEqual(8.0, pt.y)
    }
    
    func testBasicSetterMethods() {
        var pt:Point2F = Point2F(3.0, 9.0)
        pt = Point2F.zero
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(0.0, pt.y)
    }
    
    func testBinaryOperatorMethods() {
        var pt:Point2F = Point2F(3.0, 9.0)
        pt = pt + 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(13.0, pt.y)
        
        pt = pt + Point2F(-2.0, 1.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(14.0, pt.y)
        
        pt = pt - 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt = pt - Point2F(-5.0, 3.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        
        pt = pt * 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt = pt * Point2F(3.0, -2.0)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        
        pt = pt / 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        
        pt = pt / Point2F(3.0, -1.0)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
    }
    
    func testBinaryInverseOperatorMethods(){
        var pt:Point2F = Point2F(3.0, 9.0)
        pt = 8.0 - pt
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(-1.0, pt.y)
        
        pt = Point2F(-5.0, 3.0) - pt
        XCTAssertEqual(-10.0, pt.x)
        XCTAssertEqual(4.0, pt.y)
        
        pt = Point2F(-4.0, -3.0)
        pt = 12.0 / pt
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(pt.y, -4.0)
        
        pt = Point2F(3.0, -16.0) / pt
        XCTAssertEqual(-1.0, pt.x)
        XCTAssertEqual(4.0, pt.y)
    }
    
    func testAugmentedOperatorMethods() {
        var pt:Point2F = Point2F(3.0, 9.0)
        pt += 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(pt.y, 13.0)
        
        pt += Point2F(-2.0, 1.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(pt.y, 14.0)
        
        pt -= 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt -= Point2F(-5.0, 3.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        
        pt *= 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt *= Point2F(3.0, -2.0)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        
        pt /= 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        
        pt /= Point2F(3.0, -1.0)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
    }
    
    func testAtMethod(){
        let pt:Point2F = Point2F(8.0, 9.0)
        XCTAssertEqual(pt[0], 8.0)
        XCTAssertEqual(pt[1], 9.0)
    }
    
    func testBasicGetterMethods() {
        let pt:Point2F = Point2F(3.0, 7.0)
        let pt2:Point2F = Point2F(-3.0, -7.0)
        
        XCTAssertEqual(pt.sum(), 10.0)
        XCTAssertEqual(pt.min(), 3.0)
        XCTAssertEqual(pt.max(), 7.0)
        XCTAssertEqual(pt2.absmin, -3.0)
        XCTAssertEqual(pt2.absmax, -7.0)
        XCTAssertEqual(pt.dominantAxis, 1)
        XCTAssertEqual(pt.subminantAxis, 0)
        
        let pt3:SIMD2<Double> = SIMD2<Double>(-3.0, -7.0)
        XCTAssertEqual(pt3.absmin, -3.0)
//        XCTAssertEqual(pt3.absmax(), -7.0)
    }
    
    func testBracketOperator() throws {
        var pt = Point2D(8.0, 9.0)
        XCTAssertEqual(pt[0], 8.0)
        XCTAssertEqual(pt[1], 9.0)
        
        pt[0] = 7.0
        pt[1] = 6.0
        XCTAssertEqual(pt[0], 7.0)
        XCTAssertEqual(pt[1], 6.0)
    }
    
    func testAssignmentOperator() {
        let pt:Point2F = Point2F(5.0, 1.0)
        var pt2:Point2F = Point2F(3.0, 3.0)
        pt2 = pt
        XCTAssertEqual(5.0, pt2.x)
        XCTAssertEqual(pt2.y, 1.0)
    }
    
    func testAugmentedOperators() {
        var pt:Point2F = Point2F(3.0, 9.0)
        pt += 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(pt.y, 13.0)
        
        pt += Point2F(-2.0, 1.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(pt.y, 14.0)
        
        pt -= 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt -= Point2F(-5.0, 3.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        
        pt *= 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt *= Point2F(3.0, -2.0)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        
        pt /= 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        
        pt /= Point2F(3.0, -1.0)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
    }
    
    func testEqualOperator(){
        var pt:Point2F = Point2F()
        let pt2:Point2F = Point2F(3.0, 7.0)
        let pt3:Point2F = Point2F(3.0, 5.0)
        let pt4:Point2F = Point2F(5.0, 1.0)
        pt = pt2
        XCTAssertTrue(pt == pt2)
        XCTAssertFalse(pt == pt3)
        XCTAssertFalse(pt != pt2)
        XCTAssertTrue(pt != pt3)
        XCTAssertTrue(pt != pt4)
    }
    
    func testMinMaxFunction() {
        let pt = Point2F(5.0, 1.0)
        let pt2 = Point2F(3.0, 3.0)
        let minPoint = min(pt, pt2)
        let maxPoint = max(pt, pt2)
        XCTAssertEqual(Point2F(3.0, 1.0), minPoint)
        XCTAssertEqual(Point2F(5.0, 3.0), maxPoint)
    }
    
    func testClampFunction() {
        let pt = Point2F(2.0, 4.0)
        let low = Point2F(3.0, -1.0)
        let high = Point2F(5.0, 2.0)
        let clampedVec = pt.clamped(lowerBound: low, upperBound: high)
        XCTAssertEqual(Point2F(3.0, 2.0), clampedVec)
    }
    
    func testCeilFloorFunction(){
        let pt = Point2F(2.2, 4.7)
        let ceilVec = pt.rounded(.up)
        XCTAssertEqual(Point2F(3.0, 5.0), ceilVec)
        
        let floorVec = pt.rounded(.down)
        XCTAssertEqual(Point2F(2.0, 4.0), floorVec)
    }
    
    func testBinaryOperators(){
        var pt = Point2F(3.0, 9.0)
        pt = pt + 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(pt.y, 13.0)
        
        pt = pt + Point2F(-2.0, 1.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(pt.y, 14.0)
        
        pt = pt - 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt = pt - Point2F(-5.0, 3.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        
        pt = pt * 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        
        pt = pt * Point2F(3.0, -2.0)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        
        pt = pt / 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        
        pt = pt / Point2F(3.0, -1.0)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
    }
}
