//
//  fdm_linear_system_solver.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D finite difference-type linear system solver.
protocol FdmLinearSystemSolver2 {
    /// Solves the given linear system.
    func solve(system:inout FdmLinearSystem2)->Bool
}

/// Abstract base class for 3-D finite difference-type linear system solver.
protocol FdmLinearSystemSolver3 {
    /// Solves the given linear system.
    func solve(system:inout FdmLinearSystem3)->Bool
}
