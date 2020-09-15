//
//  point3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/4/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class point3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let pt = Point3F()
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(0.0, pt.y)
        XCTAssertEqual(0.0, pt.z)
        
        let pt2 = Point3F(5.0, 3.0, 8.0)
        XCTAssertEqual(5.0, pt2.x)
        XCTAssertEqual(3.0, pt2.y)
        XCTAssertEqual(8.0, pt2.z)
        
        let pt3 = Point2F(4.0, 7.0)
        let pt4 = Point3F(pt3, 9.0)
        XCTAssertEqual(4.0, pt4.x)
        XCTAssertEqual(7.0, pt4.y)
        XCTAssertEqual(9.0, pt4.z)
        
        let pt5 = Point3F([ 7.0, 6.0, 1.0 ])
        XCTAssertEqual(7.0, pt5.x)
        XCTAssertEqual(6.0, pt5.y)
        XCTAssertEqual(1.0, pt5.z)
        
        let pt6 = Point3F(pt5)
        XCTAssertEqual(7.0, pt6.x)
        XCTAssertEqual(6.0, pt6.y)
        XCTAssertEqual(1.0, pt6.z)
    }
    
    func testSetMethods() {
        var pt = Point3F()
        pt.replace(with: Point3F(4.0, 2.0, 8.0), where: [true, true, true])
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(2.0, pt.y)
        XCTAssertEqual(8.0, pt.z)
        
        pt.replace(with: Point3F(1.0, 3.0, 10.0), where: [true, true, true])
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(10.0, pt.z)
        
        let lst:[Float] = [0.0, 5.0, 6.0]
        pt.replace(with: Point3F(lst), where: [true, true, true])
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(5.0, pt.y)
        XCTAssertEqual(6.0, pt.z)
        
        pt.replace(with: Point3F(9.0, 8.0, 2.0), where: [true, true, true])
        XCTAssertEqual(9.0, pt.x)
        XCTAssertEqual(8.0, pt.y)
        XCTAssertEqual(2.0, pt.z)
    }
    
    func testBasicSetterMethods() {
        var pt = Point3F(3.0, 9.0, 4.0)
        pt = Point3F.zero
        XCTAssertEqual(0.0, pt.x)
        XCTAssertEqual(0.0, pt.y)
        XCTAssertEqual(0.0, pt.z)
    }
    
    func testBinaryOperatorMethods() {
        var pt = Point3F(3.0, 9.0, 4.0)
        pt = pt + 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(13.0, pt.y)
        XCTAssertEqual(8.0, pt.z)
        
        pt = pt + Point3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(14.0, pt.y)
        XCTAssertEqual(13.0, pt.z)
        
        pt = pt - 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
        
        pt = pt - Point3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt = pt * 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(-14.0,pt.z)
        
        pt = pt * Point3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt = pt / 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        XCTAssertEqual(-1.75, pt.z)
        
        pt = pt / Point3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
    }
    
    func testBinaryInverseOperatorMethods() {
        var pt = Point3F(5.0, 14.0, 13.0)
        pt = 8.0 - pt
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-6.0, pt.y)
        XCTAssertEqual(-5.0, pt.z)
        
        pt = Point3F(-5.0, 3.0, -1.0) - pt
        XCTAssertEqual(-8.0, pt.x)
        XCTAssertEqual(9.0, pt.y)
        XCTAssertEqual(4.0, pt.z)
        
        pt = Point3F(-12.0, -9.0, 8.0)
        pt = 36.0 / pt
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(-4.0, pt.y)
        XCTAssertEqual(4.5, pt.z)
        
        pt = Point3F(3.0, -16.0, 18.0) / pt
        XCTAssertEqual(-1.0, pt.x)
        XCTAssertEqual(4.0, pt.y)
        XCTAssertEqual(4.0, pt.z)
    }
    
    func testAugmentedOperatorMethods() {
        var pt = Point3F(3.0, 9.0, 4.0)
        pt += 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(13.0, pt.y)
        XCTAssertEqual(8.0, pt.z)
        
        pt += Point3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(14.0, pt.y)
        XCTAssertEqual(13.0, pt.z)
        
        pt -= 8.0
        XCTAssertEqual(-3.0,pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
        
        pt -= Point3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt *= 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(-14.0, pt.z)
        
        pt *= Point3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt /= 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        XCTAssertEqual(-1.75,pt.z)
        
        pt /= Point3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
    }
    
    func testAtMethods() {
        var pt = Point3F(8.0, 9.0, 1.0)
        XCTAssertEqual(8.0, pt[0])
        XCTAssertEqual(9.0, pt[1])
        XCTAssertEqual(1.0, pt[2])
        
        pt[0] = 7.0
        pt[1] = 6.0
        pt[2] = 5.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
    }
    
    func testBasicGetterMethods() {
        let pt = Point3F(3.0, 7.0, -1.0)
        let pt2 = Point3F(-3.0, -7.0, 1.0)
        
        XCTAssertEqual(9.0, pt.sum())
        XCTAssertEqual(-1.0, pt.min())
        XCTAssertEqual(7.0, pt.max())
        XCTAssertEqual(1.0, pt2.absmin)
        XCTAssertEqual(-7.0, pt2.absmax)
        XCTAssertEqual(1, pt.dominantAxis)
        XCTAssertEqual(2, pt.subminantAxis)
    }
    
    func testBracketOperators() {
        var pt = Point3F(8.0, 9.0, 1.0)
        XCTAssertEqual(8.0, pt[0])
        XCTAssertEqual(9.0, pt[1])
        XCTAssertEqual(1.0, pt[2])
        
        pt[0] = 7.0
        pt[1] = 6.0
        pt[2] = 5.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
    }
    
    func testAssignmentOperators() {
        let pt = Point3F(5.0, 1.0, 0.0)
        var pt2 = Point3F(3.0, 3.0, 3.0)
        pt2 = pt
        XCTAssertEqual(5.0, pt2.x)
        XCTAssertEqual(1.0, pt2.y)
        XCTAssertEqual(0.0, pt2.z)
    }
    
    func testAugmentedOperators() {
        var pt = Point3F(3.0, 9.0, -2.0)
        pt += 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(13.0, pt.y)
        XCTAssertEqual(2.0, pt.z)
        
        pt += Point3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(14.0, pt.y)
        XCTAssertEqual(7.0, pt.z)
        
        pt -= 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(-1.0, pt.z)
        
        pt -= Point3F(-5.0, 3.0, -6.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
        
        pt *= 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(10.0, pt.z)
        
        pt *= Point3F(3.0, -2.0, 0.4)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        XCTAssertEqual(4.0, pt.z)
        
        pt /= 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        XCTAssertEqual(1.0, pt.z)
        
        pt /= Point3F(3.0, -1.0, 2.0)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(0.5, pt.z)
    }
    
    func testEqualOperatators() {
        var pt = Point3F()
        let pt2 = Point3F(3.0, 7.0, 4.0)
        let pt3 = Point3F(3.0, 5.0, 4.0)
        let pt4 = Point3F(5.0, 1.0, 2.0)
        pt = pt2
        XCTAssertTrue(pt == pt2)
        XCTAssertFalse(pt == pt3)
        XCTAssertFalse(pt != pt2)
        XCTAssertTrue(pt != pt3)
        XCTAssertTrue(pt != pt4)
    }
    
    func testMinMaxFunctions() {
        let pt = Point3F(5.0, 1.0, 0.0)
        let pt2 = Point3F(3.0, 3.0, 3.0)
        let minPoint = min(pt, pt2)
        let maxPoint = max(pt, pt2)
        XCTAssertTrue(minPoint == Point3F(3.0, 1.0, 0.0))
        XCTAssertTrue(maxPoint == Point3F(5.0, 3.0, 3.0))
    }
    
    func testClampFunction() {
        let pt = Point3F(2.0, 4.0, 1.0)
        let low = Point3F(3.0, -1.0, 0.0)
        let high = Point3F(5.0, 2.0, 3.0)
        let clampedVec = pt.clamped(lowerBound: low, upperBound: high)
        XCTAssertTrue(clampedVec == Point3F(3.0, 2.0, 1.0))
    }
    
    func testCeilFloorFunctions() {
        let pt = Point3F(2.2, 4.7, -0.2)
        let ceilVec = ceil(pt)
        XCTAssertTrue(ceilVec == Point3F(3.0, 5.0, 0.0))
        
        let floorVec = floor(pt)
        XCTAssertTrue(floorVec == Point3F(2.0, 4.0, -1.0))
    }
    
    func testBinaryOperators() {
        var pt = Point3F(3.0, 9.0, 4.0)
        pt = pt + 4.0
        XCTAssertEqual(7.0, pt.x)
        XCTAssertEqual(13.0,pt.y)
        XCTAssertEqual(8.0, pt.z)
        
        pt = pt + Point3F(-2.0, 1.0, 5.0)
        XCTAssertEqual(5.0, pt.x)
        XCTAssertEqual(14.0, pt.y)
        XCTAssertEqual(13.0, pt.z)
        
        pt = pt - 8.0
        XCTAssertEqual(-3.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(5.0, pt.z)
        
        pt = pt - Point3F(-5.0, 3.0, 12.0)
        XCTAssertEqual(2.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt = pt * 2.0
        XCTAssertEqual(4.0, pt.x)
        XCTAssertEqual(6.0, pt.y)
        XCTAssertEqual(-14.0, pt.z)
        
        pt = pt * Point3F(3.0, -2.0, 0.5)
        XCTAssertEqual(12.0, pt.x)
        XCTAssertEqual(-12.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
        
        pt = pt / 4.0
        XCTAssertEqual(3.0, pt.x)
        XCTAssertEqual(-3.0, pt.y)
        XCTAssertEqual(-1.75, pt.z)
        
        pt = pt / Point3F(3.0, -1.0, 0.25)
        XCTAssertEqual(1.0, pt.x)
        XCTAssertEqual(3.0, pt.y)
        XCTAssertEqual(-7.0, pt.z)
    }

}
