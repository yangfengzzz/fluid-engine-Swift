//
//  grid_blocked_boundary_condition_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

let bryFluid:CChar = 1
let bryCollider:CChar = 0

class GridBlockedBoundaryConditionSolver2: GridFractionalBoundaryConditionSolver2 {
    var _marker = Array2<CChar>()
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    ///     velocity will get extrapolated.
    override func constrainVelocity(velocity:inout FaceCenteredGrid2,
                                    extrapolationDepth:UInt = 5) {
        super.constrainVelocity(
            velocity: &velocity, extrapolationDepth: extrapolationDepth)
        
        // No-flux: project the velocity at the marker interface
        let size = velocity.resolution()
        var u = velocity.uAccessor()
        var v = velocity.vAccessor()
        let uPos = velocity.uPosition()
        let vPos = velocity.vPosition()
        
        _marker.forEachIndex(){(i:size_t, j:size_t) in
            if (_marker[i, j] == bryCollider) {
                if (i > 0 && _marker[i - 1, j] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: uPos(i, j))
                    u[i, j] = colliderVel.x
                }
                if (i < size.x - 1 && _marker[i + 1, j] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: uPos(i + 1, j))
                    u[i + 1, j] = colliderVel.x
                }
                if (j > 0 && _marker[i, j - 1] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: vPos(i, j))
                    v[i, j] = colliderVel.y
                }
                if (j < size.y - 1 && _marker[i, j + 1] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: vPos(i, j + 1))
                    v[i, j + 1] = colliderVel.y
                }
            }
        }
    }
    
    /// Returns the marker which is 1 if occupied by the collider.
    func marker()->Array2<CChar> {
        return _marker
    }
    
    /// nvoked when a new collider is set.
    override func onColliderUpdated(gridSize:Size2,
                                    gridSpacing:Vector2F,
                                    gridOrigin:Vector2F) {
        super.onColliderUpdated(
            gridSize: gridSize, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let sdf = colliderSdf() as? CellCenteredScalarGrid2
        
        _marker.resize(size: gridSize)
        _marker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: sdf![i, j])) {
                _marker[i, j] = bryCollider
            } else {
                _marker[i, j] = bryFluid
            }
        }
    }
}
