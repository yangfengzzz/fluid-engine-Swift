//
//  grid_blocked_boundary_condition_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

class GridBlockedBoundaryConditionSolver3: GridFractionalBoundaryConditionSolver3 {
    var _marker = Array3<CChar>()
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    ///     velocity will get extrapolated.
    override func constrainVelocity(velocity:inout FaceCenteredGrid3,
                                    extrapolationDepth:UInt = 5) {
        super.constrainVelocity(
            velocity: &velocity, extrapolationDepth: extrapolationDepth)
        
        // No-flux: project the velocity at the marker interface
        let size = velocity.resolution()
        var u = velocity.uAccessor()
        var v = velocity.vAccessor()
        var w = velocity.wAccessor()
        let uPos = velocity.uPosition()
        let vPos = velocity.vPosition()
        let wPos = velocity.wPosition()
        
        _marker.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (_marker[i, j, k] == bryCollider) {
                if (i > 0 && _marker[i - 1, j, k] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: uPos(i, j, k))
                    u[i, j, k] = colliderVel.x
                }
                if (i < size.x - 1 && _marker[i + 1, j, k] == bryFluid) {
                    let colliderVel
                        = collider()!.velocityAt(point: uPos(i + 1, j, k))
                    u[i + 1, j, k] = colliderVel.x
                }
                if (j > 0 && _marker[i, j - 1, k] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: vPos(i, j, k))
                    v[i, j, k] = colliderVel.y
                }
                if (j < size.y - 1 && _marker[i, j + 1, k] == bryFluid) {
                    let colliderVel
                        = collider()!.velocityAt(point: vPos(i, j + 1, k))
                    v[i, j + 1, k] = colliderVel.y
                }
                if (k > 0 && _marker[i, j, k - 1] == bryFluid) {
                    let colliderVel = collider()!.velocityAt(point: wPos(i, j, k))
                    w[i, j, k] = colliderVel.z
                }
                if (k < size.z - 1 && _marker[i, j, k + 1] == bryFluid) {
                    let colliderVel
                        = collider()!.velocityAt(point: wPos(i, j, k + 1))
                    w[i, j, k + 1] = colliderVel.z
                }
            }
        }
    }
    
    /// Returns the marker which is 1 if occupied by the collider.
    func marker()->Array3<CChar> {
        return _marker
    }
    
    /// nvoked when a new collider is set.
    override func onColliderUpdated(gridSize:Size3,
                                    gridSpacing:Vector3F,
                                    gridOrigin:Vector3F) {
        super.onColliderUpdated(
            gridSize: gridSize, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let sdf = colliderSdf() as? CellCenteredScalarGrid3
        
        _marker.resize(size: gridSize)
        _marker.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: sdf![i, j, k])) {
                _marker[i, j, k] = bryCollider
            } else {
                _marker[i, j, k] = bryFluid
            }
        }
    }
}
