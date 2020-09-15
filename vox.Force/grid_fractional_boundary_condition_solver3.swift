//
//  grid_fractional_boundary_condition_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Fractional 3-D boundary condition solver for grids.
///
/// This class constrains the velocity field by projecting the flow to the
/// signed-distance field representation of the collider. This implementation
/// should pair up with GridFractionalSinglePhasePressureSolver3 to provide
/// sub-grid resolutional velocity projection.
class GridFractionalBoundaryConditionSolver3: GridBoundaryConditionSolver3 {
    var _collider:Collider3?
    var _gridSize = Size3()
    var _gridSpacing = Vector3F()
    var _gridOrigin = Vector3F()
    var _closedDomainBoundaryFlag: Int = kDirectionAll
    
    var _colliderSdf:CellCenteredScalarGrid3?
    var _colliderVel:CustomVectorField3?
    
    /// Constrains the velocity field to conform the collider boundary.
    /// - Parameters:
    ///   - velocity: Input and output velocity grid.
    ///   - extrapolationDepth: Number of inner-collider grid cells that
    /// velocity will get extrapolated.
    func constrainVelocity(velocity:inout FaceCenteredGrid3,
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
        var w = velocity.wAccessor()
        let uPos = velocity.uPosition()
        let vPos = velocity.vPosition()
        let wPos = velocity.wPosition()
        
        var uTemp = Array3<Float>(size: u.size())
        var vTemp = Array3<Float>(size: v.size())
        var wTemp = Array3<Float>(size: w.size())
        var uMarker = Array3<CChar>(size: u.size(), initVal: 1)
        var vMarker = Array3<CChar>(size: v.size(), initVal: 1)
        var wMarker = Array3<CChar>(size: w.size(), initVal: 1)
        
        let h = velocity.gridSpacing()
        
        // Assign collider's velocity first and initialize markers
        velocity.parallelForEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = uPos(i, j, k)
            let phi0 = _colliderSdf!.sample(x: pt - Vector3F(0.5 * h.x, 0.0, 0.0))
            let phi1 = _colliderSdf!.sample(x: pt + Vector3F(0.5 * h.x, 0.0, 0.0))
            var frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
            frac = 1.0 - Math.clamp(val: frac, low: 0.0, high: 1.0)
            
            if (frac > 0.0) {
                uMarker[i, j, k] = 1
            } else {
                let colliderVel = collider()!.velocityAt(point: pt)
                u[i, j, k] = colliderVel.x
                uMarker[i, j, k] = 0
            }
        }
        
        velocity.parallelForEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = vPos(i, j, k)
            let phi0 = _colliderSdf!.sample(x: pt - Vector3F(0.0, 0.5 * h.y, 0.0))
            let phi1 = _colliderSdf!.sample(x: pt + Vector3F(0.0, 0.5 * h.y, 0.0))
            var frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
            frac = 1.0 - Math.clamp(val: frac, low: 0.0, high: 1.0)
            
            if (frac > 0.0) {
                vMarker[i, j, k] = 1
            } else {
                let colliderVel = collider()!.velocityAt(point: pt)
                v[i, j, k] = colliderVel.y
                vMarker[i, j, k] = 0
            }
        }
        
        velocity.parallelForEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = wPos(i, j, k)
            let phi0 = _colliderSdf!.sample(x: pt - Vector3F(0.0, 0.0, 0.5 * h.z))
            let phi1 = _colliderSdf!.sample(x: pt + Vector3F(0.0, 0.0, 0.5 * h.z))
            var frac = fractionInsideSdf(phi0: phi0, phi1: phi1)
            frac = 1.0 - Math.clamp(val: frac, low: 0.0, high: 1.0)
            
            if (frac > 0.0) {
                wMarker[i, j, k] = 1
            } else {
                let colliderVel = collider()!.velocityAt(point: pt)
                w[i, j, k] = colliderVel.z
                wMarker[i, j, k] = 0
            }
        }
        
        // Free-slip: Extrapolate fluid velocity into the collider
        extrapolateToRegion(input: velocity.uConstAccessor(),
                            valid: uMarker.constAccessor(),
                            numberOfIterations: extrapolationDepth, output: &u)
        extrapolateToRegion(input: velocity.vConstAccessor(),
                            valid: vMarker.constAccessor(),
                            numberOfIterations: extrapolationDepth, output: &v)
        extrapolateToRegion(input: velocity.wConstAccessor(),
                            valid: wMarker.constAccessor(),
                            numberOfIterations: extrapolationDepth, output: &w)
        
        // No-flux: project the extrapolated velocity to the collider's surface
        // normal
        velocity.parallelForEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = uPos(i, j, k)
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
                    uTemp[i, j, k] = velp.x
                } else {
                    uTemp[i, j, k] = colliderVel.x
                }
            } else {
                uTemp[i, j, k] = u[i, j, k]
            }
        }
        
        velocity.parallelForEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = vPos(i, j, k)
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
                    vTemp[i, j, k] = velp.y
                } else {
                    vTemp[i, j, k] = colliderVel.y
                }
            } else {
                vTemp[i, j, k] = v[i, j, k]
            }
        }
        
        velocity.parallelForEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = wPos(i, j, k)
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
                    wTemp[i, j, k] = velp.z
                } else {
                    wTemp[i, j, k] = colliderVel.z
                }
            } else {
                wTemp[i, j, k] = w[i, j, k]
            }
        }
        
        // Transfer results
        u.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            u[i, j, k] = uTemp[i, j, k]
        }
        v.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            v[i, j, k] = vTemp[i, j, k]
        }
        w.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            w[i, j, k] = wTemp[i, j, k]
        }
        
        // No-flux: Project velocity on the domain boundary if closed
        if (closedDomainBoundaryFlag() & kDirectionLeft != 0) {
            for k in 0..<u.size().z {
                for j in 0..<u.size().y {
                    u[0, j, k] = 0
                }
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionRight != 0) {
            for k in 0..<u.size().z {
                for j in 0..<u.size().y {
                    u[u.size().x - 1, j, k] = 0
                }
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionDown != 0) {
            for k in 0..<v.size().z {
                for i in 0..<v.size().x {
                    v[i, 0, k] = 0
                }
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionUp != 0) {
            for k in 0..<v.size().z {
                for i in 0..<v.size().x {
                    v[i, v.size().y - 1, k] = 0
                }
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionBack != 0) {
            for j in 0..<w.size().y {
                for i in 0..<w.size().x {
                    w[i, j, 0] = 0
                }
            }
        }
        if (closedDomainBoundaryFlag() & kDirectionFront != 0) {
            for j in 0..<w.size().y {
                for i in 0..<w.size().x {
                    w[i, j, w.size().z - 1] = 0
                }
            }
        }
    }
    
    /// Returns the signed distance field of the collider.
    func colliderSdf()->ScalarField3 {
        return _colliderSdf!
    }
    
    /// Returns the velocity field of the collider.
    func colliderVelocityField()->VectorField3 {
        return _colliderVel!
    }
    
    /// Invoked when a new collider is set.
    func onColliderUpdated(gridSize:Size3,
                           gridSpacing:Vector3F,
                           gridOrigin:Vector3F) {
        if (_colliderSdf == nil) {
            _colliderSdf = CellCenteredScalarGrid3()
        }
        _colliderSdf!.resize(resolution: gridSize,
                             gridSpacing: gridSpacing,
                             origin: gridOrigin)
        
        if (collider() != nil) {
            let surface = collider()!.surface()
            var implicitSurface = surface as? ImplicitSurface3
            if (implicitSurface == nil) {
                implicitSurface = SurfaceToImplicit3(surface: surface)
            }
            
            _colliderSdf!.fill(){(pt:Vector3F)->Float in
                return implicitSurface!.signedDistance(otherPoint: pt)
            }
            
            _colliderVel = CustomVectorField3.builder()
                .withFunction(function: {(x:Vector3F)->Vector3F in
                    return self.collider()!.velocityAt(point: x)
                })
                .withDerivativeResolution(resolution: gridSpacing.x)
                .build()
        } else {
            _colliderSdf!.fill(value: Float.greatestFiniteMagnitude)
            
            _colliderVel = CustomVectorField3.builder()
                .withFunction(function: {(_:Vector3F)->Vector3F in
                    return Vector3F()
                })
                .withDerivativeResolution(resolution: gridSpacing.x)
                .build()
        }
    }
}
