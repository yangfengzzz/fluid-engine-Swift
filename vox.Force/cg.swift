//
//  cg.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

protocol PrecondTypeProtocol {
    associatedtype BlasType:Blas
    mutating func solve(b:BlasType.VectorType,
                        x:inout BlasType.VectorType)
}

/// No-op preconditioner for conjugate gradient.
///
/// This preconditioner does nothing but simply copies the input vector to the
/// output vector. Thus, it can be considered as an identity matrix.
struct NullCgPreconditioner<BlasType:Blas> : PrecondTypeProtocol {
    func build(_:BlasType.MatrixType) {}
    
    func solve(b:BlasType.VectorType,
               x:inout BlasType.VectorType) {
        BlasType.set(v: b, result: &x)
    }
}

func pcg<PrecondType:PrecondTypeProtocol>(A:PrecondType.BlasType.MatrixType,
                                          b:PrecondType.BlasType.VectorType,
                                          maxNumberOfIterations:UInt,
                                          tolerance:Float,
                                          M:inout PrecondType,
                                          x:inout PrecondType.BlasType.VectorType,
                                          r:inout PrecondType.BlasType.VectorType,
                                          d:inout PrecondType.BlasType.VectorType,
                                          q:inout PrecondType.BlasType.VectorType,
                                          s:inout PrecondType.BlasType.VectorType,
                                          lastNumberOfIterations:inout UInt,
                                          lastResidualNorm:inout PrecondType.BlasType.ScalarType) {
    // Clear
    PrecondType.BlasType.set(s: PrecondType.BlasType.ScalarType(), result: &r)
    PrecondType.BlasType.set(s: PrecondType.BlasType.ScalarType(), result: &d)
    PrecondType.BlasType.set(s: PrecondType.BlasType.ScalarType(), result: &q)
    PrecondType.BlasType.set(s: PrecondType.BlasType.ScalarType(), result: &s)
    
    // r = b - Ax
    PrecondType.BlasType.residual(a: A, x: x, b: b, result: &r)
    
    // d = M^-1r
    M.solve(b: r, x: &d)
    
    // sigmaNew = r.d
    var sigmaNew = PrecondType.BlasType.dot(a: r, b: d)
    
    var iter:UInt = 0
    var trigger = false
    while (sigmaNew as! Float > Math.square(of: tolerance) && iter < maxNumberOfIterations) {
        // q = Ad
        PrecondType.BlasType.mvm(m: A, v: d, result: &q)
        
        // alpha = sigmaNew/d.q
        let alpha = sigmaNew / PrecondType.BlasType.dot(a: d, b: q)
        
        // x = x + alpha*d
        PrecondType.BlasType.axpy(a: alpha, x: d, y: x, result: &x)
        
        // if i is divisible by 50...
        if (trigger || (iter % 50 == 0 && iter > 0)) {
            // r = b - Ax
            PrecondType.BlasType.residual(a: A, x: x, b: b, result: &r)
            trigger = false
        } else {
            // r = r - alpha*q
            PrecondType.BlasType.axpy(a: -alpha, x: q, y: r, result: &r)
        }
        
        // s = M^-1r
        M.solve(b: r, x: &s)
        
        // sigmaOld = sigmaNew
        let sigmaOld = sigmaNew
        
        // sigmaNew = r.s
        sigmaNew = PrecondType.BlasType.dot(a: r, b: s)
        
        if (sigmaNew > sigmaOld) {
            trigger = true
        }
        
        // beta = sigmaNew/sigmaOld
        let beta = sigmaNew / sigmaOld
        
        // d = s + beta*d
        PrecondType.BlasType.axpy(a: beta, x: d, y: s, result: &d)
        
        iter += 1
    }
    
    lastNumberOfIterations = iter
    
    // std::fabs(sigmaNew) - Workaround for negative zero
    lastResidualNorm = sqrt(abs(sigmaNew))
}
