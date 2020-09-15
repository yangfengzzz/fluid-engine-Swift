//
//  mg.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Multigrid matrix wrapper.
struct MgMatrix<BlasType:Blas> {
    var levels:[BlasType.MatrixType] = []
    
    func finest()->BlasType.MatrixType {
        return levels.first!
    }
    
    subscript(i:size_t)->BlasType.MatrixType{
        get{
            return levels[i]
        }
        set{
            return levels[i] = newValue
        }
    }
}

/// Multigrid vector wrapper.
struct MgVector<BlasType:Blas> {
    var levels:[BlasType.VectorType] = []
    
    func finest()->BlasType.VectorType {
        return levels.first!
    }
    
    subscript(i:size_t)->BlasType.VectorType{
        get{
            return levels[i]
        }
        set{
            return levels[i] = newValue
        }
    }
}

/// Multigrid relax function type.
typealias MgRelaxFunc<BlasType:Blas> = (BlasType.MatrixType,
    BlasType.VectorType, UInt,
    Float, inout BlasType.VectorType,
    inout BlasType.VectorType)->Void

/// Multigrid restriction function type.
typealias MgRestrictFunc<BlasType:Blas> = (BlasType.VectorType,
    inout BlasType.VectorType)->Void

typealias MgCorrectFunc<BlasType:Blas> = (BlasType.VectorType,
    inout BlasType.VectorType)->Void

/// Multigrid input parameter set.
struct MgParameters<BlasType:Blas> {
    /// Max number of multigrid levels.
    var maxNumberOfLevels:size_t = 1
    
    /// Number of iteration at restriction step.
    var numberOfRestrictionIter:UInt = 5
    
    /// Number of iteration at correction step.
    var numberOfCorrectionIter:UInt = 5
    
    /// Number of iteration at coarsest step.
    var numberOfCoarsestIter:UInt = 20
    
    /// Number of iteration at final step.
    var numberOfFinalIter:UInt = 20
    
    /// Relaxation function such as Jacobi or Gauss-Seidel.
    var relaxFunc:MgRelaxFunc<BlasType>?
    
    /// Restrict function that maps finer to coarser grid.
    var restrictFunc:MgRestrictFunc<BlasType>?
    
    /// Correction function that maps coarser to finer grid.
    var correctFunc:MgCorrectFunc<BlasType>?
    
    /// Max error tolerance.
    var maxTolerance:Float = 1e-6
}

/// Multigrid result type.
struct MgResult {
    /// Lastly measured norm of residual.
    var lastResidualNorm:Float = 0
}

//MARK:- mgVCycle
/// Performs Multigrid with V-cycle.
///
/// For given linear system matrix \p A and RHS vector \p b, this function
/// computes the solution \p x using Multigrid method with V-cycle.
func mgVCycle<BlasType:Blas>(A:MgMatrix<BlasType>, params:MgParameters<BlasType>,
                             x:inout MgVector<BlasType>, b:inout MgVector<BlasType>,
                             buffer:inout MgVector<BlasType>)->MgResult {
    return mgVCycle(A: A, params: params, currentLevel: 0, x: &x, b: &b, buffer: &buffer)
}

func mgVCycle<BlasType:Blas>(A:MgMatrix<BlasType>, params:MgParameters<BlasType>,
                             currentLevel:size_t, x:inout MgVector<BlasType>,
                             b:inout MgVector<BlasType>,
                             buffer:inout MgVector<BlasType>)->MgResult {
    var params = params
    // 1) Relax a few times on Ax = b, with arbitrary x
    params.relaxFunc!(A[currentLevel], b[currentLevel],
                      params.numberOfRestrictionIter, params.maxTolerance,
                      &(x[currentLevel]), &(buffer[currentLevel]))
    
    // 2) if currentLevel is the coarsest grid, goto 5)
    if (currentLevel < A.levels.count - 1) {
        var r = buffer
        BlasType.residual(a: A[currentLevel], x: x[currentLevel],
                          b: b[currentLevel], result: &r[currentLevel])
        params.restrictFunc!(r[currentLevel], &b[currentLevel + 1])
        
        BlasType.set(s: BlasType.ScalarType(), result: &x[currentLevel + 1])
        
        params.maxTolerance *= 0.5
        // Solve Ae = r
        _ = mgVCycle(A: A, params: params, currentLevel: currentLevel + 1,
                     x: &x, b: &b, buffer: &buffer)
        params.maxTolerance *= 2.0
        
        // 3) correct
        params.correctFunc!(x[currentLevel + 1], &x[currentLevel])
        
        // 4) relax nItr times on Ax = b, with initial guess x
        if (currentLevel > 0) {
            params.relaxFunc!(A[currentLevel], b[currentLevel],
                              params.numberOfCorrectionIter, params.maxTolerance,
                              &(x[currentLevel]), &(buffer[currentLevel]))
        } else {
            params.relaxFunc!(A[currentLevel], b[currentLevel],
                              params.numberOfFinalIter, params.maxTolerance,
                              &(x[currentLevel]), &(buffer[currentLevel]))
        }
    } else {
        // 5) solve directly with initial guess x
        params.relaxFunc!(A[currentLevel], b[currentLevel],
                          params.numberOfCoarsestIter, params.maxTolerance,
                          &(x[currentLevel]), &(buffer[currentLevel]))
        
        BlasType.residual(a: A[currentLevel], x: x[currentLevel],
                          b: b[currentLevel], result: &buffer[currentLevel])
    }
    
    BlasType.residual(a: A[currentLevel], x: x[currentLevel], b: b[currentLevel],
                      result: &buffer[currentLevel])
    
    var result = MgResult()
    result.lastResidualNorm = BlasType.l2Norm(v: buffer[currentLevel]) as! Float
    return result
}
