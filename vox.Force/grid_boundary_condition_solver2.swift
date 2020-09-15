//
//  grid_boundary_condition_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D boundary condition solver for grids.
///
/// This is a helper class to constrain the 2-D velocity field with given
/// collider object. It also determines whether to open any domain boundaries.
/// To control the friction level, tune the collider parameter.
protocol GridBoundaryConditionSolver2 : class{
    var _collider:Collider2? { get set }
    var _gridSize:Size2 { get set }
    var _gridSpacing:Vector2F { get set }
    var _gridOrigin:Vector2F { get set }
    var _closedDomainBoundaryFlag:Int { get set }
    
    /// Returns associated collider.
    func collider()->Collider2?
    
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
    func updateCollider(newCollider:Collider2?,
                        gridSize:Size2,
                        gridSpacing:Vector2F,
                        gridOrigin:Vector2F)
    
    /// Returns the closed domain boundary flag.
    func closedDomainBoundaryFlag()->Int
    
    /// Sets the closed domain boundary flag.
    func setClosedDomainBoundaryFlag(flag:Int)
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    ///     velocity will get extrapolated.
    func constrainVelocity(velocity: inout FaceCenteredGrid2,
                           extrapolationDepth:UInt)
    
    /// Returns the signed distance field of the collider.
    func colliderSdf()->ScalarField2
    
    /// Returns the velocity field of the collider.
    func colliderVelocityField()->VectorField2
    
    /// Invoked when a new collider is set.
    func onColliderUpdated(gridSize:Size2,
                           gridSpacing:Vector2F,
                           gridOrigin:Vector2F)
    
    /// Returns the size of the velocity grid to be constrained.
    func gridSize()->Size2
    
    /// Returns the spacing of the velocity grid to be constrained.
    func gridSpacing()->Vector2F
    
    /// Returns the origin of the velocity grid to be constrained.
    func gridOrigin()->Vector2F
}

extension GridBoundaryConditionSolver2 {
    func collider()->Collider2? {
        return _collider
    }
    
    func updateCollider(newCollider:Collider2?,
                        gridSize:Size2,
                        gridSpacing:Vector2F,
                        gridOrigin:Vector2F) {
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
    
    func gridSize()->Size2 {
        return _gridSize
    }
    
    func gridSpacing()->Vector2F {
        return _gridSpacing
    }
    
    func gridOrigin()->Vector2F {
        return _gridOrigin
    }
}
