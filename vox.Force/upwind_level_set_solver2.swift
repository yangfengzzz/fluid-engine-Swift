//
//  upwind_level_set_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Two-dimensional first-order upwind-based iterative level set solver.
class UpwindLevelSetSolver2: IterativeLevelSetSolver2 {
    /// Computes the derivatives for given grid point.
    override func getDerivatives(grid:ConstArrayAccessor2<Float>,
                                 gridSpacing:Vector2F,
                                 i:size_t, j:size_t,
                                 dx: inout (Float, Float),
                                 dy: inout (Float, Float)) {
        var D0 = Array<Float>(repeating: 0, count: 3)
        let size = grid.size()
        
        let im1 = (i < 1) ? 0 : i - 1
        let ip1 = min(i + 1, size.x - 1)
        let jm1 = (j < 1) ? 0 : j - 1
        let jp1 = min(j + 1, size.y - 1)
        
        D0[0] = grid[im1, j]
        D0[1] = grid[i, j]
        D0[2] = grid[ip1, j]
        dx = upwind1(D0: D0, dx: gridSpacing.x)
        
        D0[0] = grid[i, jm1]
        D0[1] = grid[i, j]
        D0[2] = grid[i, jp1]
        dy = upwind1(D0: D0, dx: gridSpacing.y)
    }
}
