//
//  grid_boundary_condition_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D boundary condition solver for grids.
///
/// This is a helper class to constrain the 3-D velocity field with given
/// collider object. It also determines whether to open any domain boundaries.
/// To control the friction level, tune the collider parameter.
protocol GridBoundaryConditionSolver3 : class{
    var _collider:Collider3? { get set }
    var _gridSize:Size3 { get set }
    var _gridSpacing:Vector3F { get set }
    var _gridOrigin:Vector3F { get set }
    var _closedDomainBoundaryFlag:Int { get set }
    
    /// Returns associated collider.
    func collider()->Collider3?
    
    /// Applies new collider and build the internals.
    ///
    /// This function is called to apply new collider and build the internal
    /// cache. To provide a hint to the cache, info for the expected velocity
    /// grid that will be constrained is provided.
    /// - Parameters:
    ///   - newCollider: New collider to apply.
    ///   - gridSize: Size of the velocity grid to be constrained.
    ///   - gridSpacing: Grid spacing of the velocity grid to be constrained.
    ///   - gridOrigin: Origin of the velocity grid to be constrained.
    func updateCollider(newCollider:Collider3?,
                        gridSize:Size3,
                        gridSpacing:Vector3F,
                        gridOrigin:Vector3F)
    
    /// Returns the closed domain boundary flag.
    func closedDomainBoundaryFlag()->Int
    
    /// Sets the closed domain boundary flag.
    func setClosedDomainBoundaryFlag(flag:Int)
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    ///     velocity will get extrapolated.
    func constrainVelocity(velocity: inout FaceCenteredGrid3,
                           extrapolationDepth:UInt)
    
    /// Returns the signed distance field of the collider.
    func colliderSdf()->ScalarField3
    
    /// Returns the velocity field of the collider.
    func colliderVelocityField()->VectorField3
    
    /// Invoked when a new collider is set.
    func onColliderUpdated(gridSize:Size3,
                           gridSpacing:Vector3F,
                           gridOrigin:Vector3F)
    
    /// Returns the size of the velocity grid to be constrained.
    func gridSize()->Size3
    
    /// Returns the spacing of the velocity grid to be constrained.
    func gridSpacing()->Vector3F
    
    /// Returns the origin of the velocity grid to be constrained.
    func gridOrigin()->Vector3F
}

extension GridBoundaryConditionSolver3 {
    func collider()->Collider3? {
        return _collider
    }
    
    func updateCollider(newCollider:Collider3?,
                        gridSize:Size3,
                        gridSpacing:Vector3F,
                        gridOrigin:Vector3F) {
        _collider = newCollider
        _gridSize = gridSize
        _gridSpacing = gridSpacing
        _gridOrigin = gridOrigin
        
        onColliderUpdated(gridSize: gridSize,
                          gridSpacing: gridSpacing,
                          gridOrigin: gridOrigin)
    }
    
    func closedDomainBoundaryFlag()->Int {
        return _closedDomainBoundaryFlag
    }
    
    func setClosedDomainBoundaryFlag(flag:Int) {
        _closedDomainBoundaryFlag = flag
    }
    
    func gridSize()->Size3 {
        return _gridSize
    }
    
    func gridSpacing()->Vector3F {
        return _gridSpacing
    }
    
    func gridOrigin()->Vector3F {
        return _gridOrigin
    }
}
