//
//  level_set_solvers_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
@testable import vox_Force

class upwind_level_set_solvers2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        
        let solver = UpwindLevelSetSolver2()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(sdf[i, j], temp[i, j], accuracy: 0.5)
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        let field = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = UpwindLevelSetSolver2()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(5.0, temp[i, j])
            }
        }
    }
}

class upwind_level_set_solvers3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = UpwindLevelSetSolver3()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(sdf[i, j, k], temp[i, j, k], accuracy: 0.7)
                }
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        let field = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = UpwindLevelSetSolver3()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(5.0, temp[i, j, k])
                }
            }
        }
    }
}

class eno_level_set_solvers2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        
        let solver = EnoLevelSetSolver2()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(sdf[i, j], temp[i, j], accuracy: 0.2)
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        let field = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = EnoLevelSetSolver2()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(5.0, temp[i, j])
            }
        }
    }
}

class eno_level_set_solvers3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = EnoLevelSetSolver3()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(sdf[i, j, k], temp[i, j, k], accuracy: 0.5)
                }
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        let field = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = EnoLevelSetSolver3()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(5.0, temp[i, j, k])
                }
            }
        }
    }
}

class fmm_level_set_solvers2_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        
        let solver = FmmLevelSetSolver2()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(sdf[i, j], temp[i, j], accuracy: 2.9)
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        var temp: ScalarGrid2 = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        let field = CellCenteredScalarGrid2(resolutionX: 40, resolutionY: 30)
        
        sdf.fill(){(x:Vector2F)->Float in
            return length(x - Vector2F(20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = FmmLevelSetSolver2()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for j in 0..<30 {
            for i in 0..<40 {
                XCTAssertEqual(5.0, temp[i, j])
            }
        }
    }
}

class fmm_level_set_solvers3_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReinitialize() throws {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        
        let solver = FmmLevelSetSolver3()
        solver.reinitialize(inputSdf: sdf, maxDistance: 5.0, outputSdf: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(sdf[i, j, k], temp[i, j, k], accuracy: 4.9)
                }
            }
        }
    }
    
    func testExtrapolate() {
        let sdf = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        var temp: ScalarGrid3 = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        let field = CellCenteredScalarGrid3(resolutionX: 40, resolutionY: 30, resolutionZ: 50)
        
        sdf.fill(){(x:Vector3F)->Float in
            return length(x - Vector3F(20, 20, 20)) - 8.0
        }
        field.fill(value: 5.0)
        
        let solver = FmmLevelSetSolver3()
        solver.extrapolate(input: field, sdf: sdf, maxDistance: 5.0, output: &temp)
        
        for k in 0..<50 {
            for j in 0..<30 {
                for i in 0..<40 {
                    XCTAssertEqual(5.0, temp[i, j, k], accuracy: 1.0e-6)
                }
            }
        }
    }
}
