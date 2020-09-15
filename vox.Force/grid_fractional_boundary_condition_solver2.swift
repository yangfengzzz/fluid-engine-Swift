//
//  grid_fractional_boundary_condition_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Fractional 2-D boundary condition solver for grids.
///
/// This class constrains the velocity field by projecting the flow to the
/// signed-distance field representation of the collider. This implementation
/// should pair up with GridFractionalSinglePhasePressureSolver2 to provide
/// sub-grid resolutional velocity projection.
class GridFractionalBoundaryConditionSolver2: GridBoundaryConditionSolver2 {
    var _collider:Collider2?
    var _gridSize = Size2()
    var _gridSpacing = Vector2F()
    var _gridOrigin = Vector2F()
    var _closedDomainBoundaryFlag: Int = kDirectionAll
    
    var _colliderSdf:CellCenteredScalarGrid2?
    var _colliderVel:CustomVectorField2?
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    /// velocity will get extrapolated.
    func constrainVelocity(velocity:inout FaceCenteredGrid2,
                           extrapolationDepth:UInt = 5) {
        let size = velocity.resolution()
        if (_colliderSdf == nil || _colliderSdf!.resolution() != size) {
            updateCollider(
                newCollider: collider()!,
                gridSize: size,
                gridSpacing: velocity.gridSpacing(),
                gridOrigin: velocity.origin())
        }
        
        var u = velocity.uAccessor()
        var v = velocity.vAccessor()
        let uPos = velocity.uPosition()
        let vPos = velocity.vPosition()
        
        var uTemp = Array2<Float>(size: u.size())
        var vTemp = Array2<Float>(size: v.size())
        var uMarker = Array2<CChar>(size: u.size(), initVal: 1)
        var vMarker = Array2<CChar>(size: v.size(), initVal: 1)
        
        let h = velocity.gridSpacing()
        
        // Assign collider's velocity first and initialize markers
        velocity.parallelForEachUIndex(){(i:size_t, j:size_t) in
            let pt = uPos(i, j)
            let phi0 = _colliderSdf!.sample(x: pt - Vector2F(0.5 * h.x, 0.0))
            let phi1 = _colliderSdf!.sample(x: pt + Vector2F(0.5 * h.x, 0.0))
            var frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
            frac = 1.0 - Math.clamp(val: frac, low: 0.0, high: 1.0)
            
            if (frac > 0.0) {
                uMarker[i, j] = 1
            } else {
                let colliderVel = collider()!.velocityAt(point: pt)
                u[i, j] = colliderVel.x
                uMarker[i, j] = 0
            }
        }
        
        velocity.parallelForEachVIndex(){(i:size_t, j:size_t) in
            let pt = vPos(i, j)
            let phi0 = _colliderSdf!.sample(x: pt - Vector2F(0.0, 0.5 * h.y))
            let phi1 = _colliderSdf!.sample(x: pt + Vector2F(0.0, 0.5 * h.y))
            var frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
            frac = 1.0 - Math.clamp(val: frac, low: 0.0, high: 1.0)
            
            if (frac > 0.0) {
                vMarker[i, j] = 1
            } else {
                let colliderVel = collider()!.velocityAt(point: pt)
                v[i, j] = colliderVel.y
                vMarker[i, j] = 0
            }
        }
        
        // Free-slip: Extrapolate fluid velocity into the collider
        extrapolateToRegion(input: velocity.uConstAccessor(),
                            valid: uMarker.constAccessor(),
                            numberOfIterations: extrapolationDepth, output: &u)
        extrapolateToRegion(input: velocity.vConstAccessor(),
                            valid: vMarker.constAccessor(),
                            numberOfIterations: extrapolationDepth, output: &v)
        
        // No-flux: project the extrapolated velocity to the collider's surface
        // normal
        velocity.parallelForEachUIndex(){(i:size_t, j:size_t) in
            let pt = uPos(i, j)
            if (isInsideSdf(phi: _colliderSdf!.sample(x: pt))) {
                let colliderVel = collider()!.velocityAt(point: pt)
                let vel = velocity.sample(x: pt)
                let g = _colliderSdf!.gradient(x: pt)
                if (length_squared(g) > 0.0) {
                    let n = normalize(g)
                    let velr = vel - colliderVel
                    let velt = projectAndApplyFriction(vel: velr, normal: n,
                                                       frictionCoefficient: collider()!.frictionCoefficient())
                    
                    let velp = velt + colliderVel
                    uTemp[i, j] = velp.x
                } else {
                    uTemp[i, j] = colliderVel.x
                }
            } else {
                uTemp[i, j] = u[i, j]
            }
        }
        
        velocity.parallelForEachVIndex(){(i:size_t, j:size_t) in
            let pt = vPos(i, j)
            if (isInsideSdf(phi: _colliderSdf!.sample(x: pt))) {
                let colliderVel = collider()!.velocityAt(point: pt)
                let vel = velocity.sample(x: pt)
                let g = _colliderSdf!.gradient(x: pt)
                if (length_squared(g) > 0.0) {
                    let n = normalize(g)
                    let velr = vel - colliderVel
                    let velt = projectAndApplyFriction(vel: velr, normal: n,
                                                       frictionCoefficient: collider()!.frictionCoefficient())
                    
                    let velp = velt + colliderVel
                    vTemp[i, j] = velp.y
                } else {
                    vTemp[i, j] = colliderVel.y
                }
            } else {
                vTemp[i, j] = v[i, j]
            }
        }
        
        // Transfer results
        u.parallelForEachIndex(){(i:size_t, j:size_t) in
            u[i, j] = uTemp[i, j]
        }
        v.parallelForEachIndex(){(i:size_t, j:size_t) in
            v[i, j] = vTemp[i, j]
        }
        
        // No-flux: Project velocity on the domain boundary if closed
        if (closedDomainBoundaryFlag() & kDirectionLeft != 0) {
            for j in 0..<u.size().y {
                u[0, j] = 0
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionRight != 0) {
            for j in 0..<u.size().y {
                u[u.size().x - 1, j] = 0
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionDown != 0) {
            for i in 0..<v.size().x {
                v[i, 0] = 0
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionUp != 0) {
            for i in 0..<v.size().x {
                v[i, v.size().y - 1] = 0
            }
        }
    }
    
    /// Returns the signed distance field of the collider.
    func colliderSdf()->ScalarField2 {
        return _colliderSdf!
    }
    
    /// Returns the velocity field of the collider.
    func colliderVelocityField()->VectorField2 {
        return _colliderVel!
    }
    
    /// Invoked when a new collider is set.
    func onColliderUpdated(gridSize:Size2,
                           gridSpacing:Vector2F,
                           gridOrigin:Vector2F) {
        if (_colliderSdf == nil) {
            _colliderSdf = CellCenteredScalarGrid2()
        }
        _colliderSdf!.resize(resolution: gridSize,
                             gridSpacing: gridSpacing,
                             origin: gridOrigin)
        
        if (collider() != nil) {
            let surface = collider()!.surface()
            var implicitSurface = surface as? ImplicitSurface2
            if (implicitSurface == nil) {
                implicitSurface = SurfaceToImplicit2(surface: surface)
            }
            
            _colliderSdf!.fill(){(pt:Vector2F)->Float in
                return implicitSurface!.signedDistance(otherPoint: pt)
            }
            
            _colliderVel = CustomVectorField2.builder()
                .withFunction(function: {(x:Vector2F)->Vector2F in
                    return self.collider()!.velocityAt(point: x)
                })
                .withDerivativeResolution(resolution: gridSpacing.x)
                .build()
        } else {
            _colliderSdf!.fill(value: Float.greatestFiniteMagnitude)
            
            _colliderVel = CustomVectorField2.builder()
                .withFunction(function: {(_:Vector2F)->Vector2F in
                    return Vector2F()
                })
                .withDerivativeResolution(resolution: gridSpacing.x)
                .build()
        }
    }
}
