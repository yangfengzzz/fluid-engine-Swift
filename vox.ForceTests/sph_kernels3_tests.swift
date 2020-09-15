//
//  sph_kernels3_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class sph_kernels3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let kernel = SphStdKernel3()
        XCTAssertEqual(0.0, kernel.h)
        
        let kernel2 = SphStdKernel3(kernelRadius: 3.0)
        XCTAssertEqual(3.0, kernel2.h)
    }
    
    func testKernelFunction() {
        let kernel = SphStdKernel3(kernelRadius: 10.0)
        
        let prevValue = kernel[0.0]
        
        for i in 1...10 {
            let value = kernel[Float(i)]
            XCTAssertLessThan(value, prevValue)
        }
    }
    
    func testFirstDerivative() {
        let kernel = SphStdKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.firstDerivative(distance: 0.0)
        let value1 = kernel.firstDerivative(distance: 5.0)
        let value2 = kernel.firstDerivative(distance: 10.0)
        XCTAssertEqual(0.0, value0)
        XCTAssertEqual(0.0, value2)
        
        // Compare with finite difference
        let e:Float = 0.001
        let fdm = (kernel[5.0 + e] - kernel[5.0 - e]) / (2.0 * e)
        XCTAssertEqual(fdm, value1, accuracy: 1e-6)
    }
    
    func testSecondDerivative() {
        let kernel = SphStdKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.secondDerivative(distance: 0.0)
        let value1 = kernel.secondDerivative(distance: 5.0)
        let value2 = kernel.secondDerivative(distance: 10.0)
        
        let h5:Float = pow(10.0, 5.0)
        XCTAssertEqual(-945.0 / (32.0 * kPiF * h5), value0)
        XCTAssertEqual(0.0, value2)
        
        // Compare with finite difference
        let e:Float = 0.001
        let fdm = (kernel[5.0 + e] - 2.0 * kernel[5.0] + kernel[5.0 - e]) / (e * e)
        XCTAssertEqual(fdm, value1, accuracy: 1e-3)
    }
    
    func testGradient() {
        let kernel = SphStdKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.gradient(distance: 0.0, direction: Vector3F(1, 0, 0))
        XCTAssertEqual(0.0, value0.x)
        XCTAssertEqual(0.0, value0.y)
        XCTAssertEqual(0.0, value0.z)
        
        let value1 = kernel.gradient(distance: 5.0, direction: Vector3F(0, 1, 0))
        XCTAssertEqual(0.0, value1.x)
        XCTAssertLessThan(0.0, value1.y)
        XCTAssertEqual(0.0, value1.z)
        
        let value2 = kernel.gradient(point: Vector3F(0, 5, 0))
        XCTAssertEqual(value1, value2)
    }
}


class sph_spiky_kernels3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructors() throws {
        let kernel = SphSpikyKernel3()
        XCTAssertEqual(0.0, kernel.h)
        
        let kernel2 = SphSpikyKernel3(kernelRadius: 3.0)
        XCTAssertEqual(3.0, kernel2.h)
    }
    
    func testKernelFunction() {
        let kernel = SphSpikyKernel3(kernelRadius: 10.0)
        
        let prevValue = kernel[0.0]
        
        for i in 1...10 {
            let value = kernel[Float(i)]
            XCTAssertLessThan(value, prevValue)
        }
    }
    
    func testFirstDerivative() {
        let kernel = SphSpikyKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.firstDerivative(distance: 0.0)
        let value1 = kernel.firstDerivative(distance: 5.0)
        let value2 = kernel.firstDerivative(distance: 10.0)
        XCTAssertLessThan(value0, value1)
        XCTAssertLessThan(value1, value2)
        
        // Compare with finite difference
        let e:Float = 0.001
        let fdm = (kernel[5.0 + e] - kernel[5.0 - e]) / (2.0 * e)
        XCTAssertEqual(fdm, value1, accuracy: 1e-6)
    }
    
    func testGradient() {
        let kernel = SphSpikyKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.gradient(distance: 0.0, direction: Vector3F(1, 0, 0))
        XCTAssertLessThan(0.0, value0.x)
        XCTAssertEqual(0.0, value0.y)
        XCTAssertEqual(0.0, value0.z)
        
        let value1 = kernel.gradient(distance: 5.0, direction: Vector3F(0, 1, 0))
        XCTAssertEqual(0.0, value1.x)
        XCTAssertLessThan(0.0, value1.y)
        XCTAssertEqual(0.0, value1.z)
        
        let value2 = kernel.gradient(point: Vector3F(0, 5, 0))
        XCTAssertEqual(value1, value2)
    }
    
    func testSecondDerivative() {
        let kernel = SphSpikyKernel3(kernelRadius: 10.0)
        
        let value0 = kernel.secondDerivative(distance: 0.0)
        let value1 = kernel.secondDerivative(distance: 5.0)
        let value2 = kernel.secondDerivative(distance: 10.0)
        
        let h5:Float = pow(10.0, 5.0)
        XCTAssertEqual(90.0 / (kPiF * h5), value0)
        XCTAssertEqual(0.0, value2)
        
        // Compare with finite difference
        let e:Float = 0.001
        let fdm = (kernel[5.0 + e] - 2.0 * kernel[5.0] + kernel[5.0 - e]) / (e * e)
        XCTAssertEqual(fdm, value1, accuracy: 1e-3)
    }
}
