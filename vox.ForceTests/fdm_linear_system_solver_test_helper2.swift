//
//  fdm_linear_system_solver_test_helper2.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
@testable import vox_Force

class FdmLinearSystemSolverTestHelper2 {
    static func buildTestLinearSystem(system:inout FdmLinearSystem2,
                                      size:Size2) {
        system.A.resize(size: size)
        system.x.resize(size: size)
        system.b.resize(size: size)
        
        system.A.forEachIndex(){(i:size_t, j:size_t) in
            if (i > 0) {
                system.A[i, j].center += 1.0
            }
            if (i < system.A.width() - 1) {
                system.A[i, j].center += 1.0
                system.A[i, j].right -= 1.0
            }
            
            if (j > 0) {
                system.A[i, j].center += 1.0
            } else {
                system.b[i, j] += 1.0
            }
            
            if (j < system.A.height() - 1) {
                system.A[i, j].center += 1.0
                system.A[i, j].up -= 1.0
            } else {
                system.b[i, j] -= 1.0
            }
        }
    }
    
}
