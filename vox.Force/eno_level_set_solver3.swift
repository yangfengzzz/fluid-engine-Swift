//
//  eno_level_set_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Three-dimensional third-order ENO-based iterative level set solver.
class EnoLevelSetSolver3: IterativeLevelSetSolver3 {
    /// Computes the derivatives for given grid point.
    override func getDerivatives(grid:ConstArrayAccessor3<Float>,
                                 gridSpacing:Vector3F,
                                 i:size_t, j:size_t, k:size_t,
                                 dx: inout (Float, Float),
                                 dy: inout (Float, Float),
                                 dz: inout (Float, Float)) {
        var D0 = Array<Float>(repeating: 0, count: 7)
        let size = grid.size()
        
        let im3 = (i < 3) ? 0 : i - 3
        let im2 = (i < 2) ? 0 : i - 2
        let im1 = (i < 1) ? 0 : i - 1
        let ip1 = min(i + 1, size.x - 1)
        let ip2 = min(i + 2, size.x - 1)
        let ip3 = min(i + 3, size.x - 1)
        let jm3 = (j < 3) ? 0 : j - 3
        let jm2 = (j < 2) ? 0 : j - 2
        let jm1 = (j < 1) ? 0 : j - 1
        let jp1 = min(j + 1, size.y - 1)
        let jp2 = min(j + 2, size.y - 1)
        let jp3 = min(j + 3, size.y - 1)
        let km3 = (k < 3) ? 0 : k - 3
        let km2 = (k < 2) ? 0 : k - 2
        let km1 = (k < 1) ? 0 : k - 1
        let kp1 = min(k + 1, size.z - 1)
        let kp2 = min(k + 2, size.z - 1)
        let kp3 = min(k + 3, size.z - 1)
        
        // 3rd-order ENO differencing
        D0[0] = grid[im3, j, k]
        D0[1] = grid[im2, j, k]
        D0[2] = grid[im1, j, k]
        D0[3] = grid[i, j, k]
        D0[4] = grid[ip1, j, k]
        D0[5] = grid[ip2, j, k]
        D0[6] = grid[ip3, j, k]
        dx = eno3(D0: D0, dx: gridSpacing.x)
        
        D0[0] = grid[i, jm3, k]
        D0[1] = grid[i, jm2, k]
        D0[2] = grid[i, jm1, k]
        D0[3] = grid[i, j, k]
        D0[4] = grid[i, jp1, k]
        D0[5] = grid[i, jp2, k]
        D0[6] = grid[i, jp3, k]
        dy = eno3(D0: D0, dx: gridSpacing.y)
        
        D0[0] = grid[i, j, km3]
        D0[1] = grid[i, j, km2]
        D0[2] = grid[i, j, km1]
        D0[3] = grid[i, j, k]
        D0[4] = grid[i, j, kp1]
        D0[5] = grid[i, j, kp2]
        D0[6] = grid[i, j, kp3]
        dz = eno3(D0: D0, dx: gridSpacing.z)
    }
}
