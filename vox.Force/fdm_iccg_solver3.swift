//
//  fdm_iccg_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D finite difference-type linear system solver using incomplete
///        Cholesky conjugate gradient (ICCG).
class FdmIccgSolver3: FdmLinearSystemSolver3 {
    struct Preconditioner : PrecondTypeProtocol {
        typealias BlasType = FdmBlas3
        
        var A = ConstArrayAccessor3<FdmMatrixRow3>()
        var d = FdmVector3()
        var y = FdmVector3()
        
        mutating func build(matrix:FdmMatrix3) {
            let size = matrix.size()
            A = matrix.constAccessor()
            
            d.resize(size: size, initVal: 0.0)
            y.resize(size: size, initVal: 0.0)
            
            matrix.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let denom = matrix[i, j, k].center -
                    ((i > 0) ? Math.square(of: matrix[i - 1, j, k].right) * d[i - 1, j, k] : 0.0) -
                    ((j > 0) ? Math.square(of: matrix[i, j - 1, k].up) * d[i, j - 1, k] : 0.0) -
                    ((k > 0) ? Math.square(of: matrix[i, j, k - 1].front) * d[i, j, k - 1] : 0.0)
                
                if (abs(denom) > 0.0) {
                    d[i, j, k] = 1.0 / denom
                } else {
                    d[i, j, k] = 0.0
                }
            }
        }
        
        mutating func solve(b:FdmVector3, x:inout FdmVector3) {
            let size = b.size()
            let sx:ssize_t = size.x
            let sy:ssize_t = size.y
            let sz:ssize_t = size.z
            
            b.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
                y[i, j, k] = (b[i, j, k] -
                    ((i > 0) ? A[i - 1, j, k].right * y[i - 1, j, k] : 0.0) -
                    ((j > 0) ? A[i, j - 1, k].up * y[i, j - 1, k] : 0.0) -
                    ((k > 0) ? A[i, j, k - 1].front * y[i, j, k - 1] : 0.0)) * d[i, j, k]
            }
            
            for k in stride(from: sz - 1, to: -1, by: -1) {
                for j in stride(from: sy - 1, to: -1, by: -1) {
                    for i in stride(from: sx - 1, to: -1, by: -1) {
                        x[i, j, k] = (y[i, j, k] -
                            ((i + 1 < sx) ? A[i, j, k].right * x[i + 1, j, k] : 0.0) -
                            ((j + 1 < sy) ? A[i, j, k].up * x[i, j + 1, k] : 0.0) -
                            ((k + 1 < sz) ? A[i, j, k].front * x[i, j, k + 1] : 0.0)) * d[i, j, k]
                    }
                }
            }
        }
    }
    
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _tolerance:Float
    var _lastResidualNorm:Float
    
    // Uncompressed vectors and preconditioner
    var _r = FdmVector3()
    var _d = FdmVector3()
    var _q = FdmVector3()
    var _s = FdmVector3()
    var _precond = Preconditioner()
    
    /// Constructs the solver with given parameters.
    init(maxNumberOfIterations:UInt, tolerance:Float) {
        self._maxNumberOfIterations = maxNumberOfIterations
        self._lastNumberOfIterations = 0
        self._tolerance = tolerance
        self._lastResidualNorm = Float.greatestFiniteMagnitude
    }
    
    /// Solves the given linear system.
    func solve(system: inout FdmLinearSystem3)->Bool {
        let matrix = system.A
        var solution = system.x
        let rhs = system.b
        
        assert(matrix.size() == rhs.size())
        assert(matrix.size() == solution.size())
        
        clearUncompressedVectors()
        
        let size = matrix.size()
        _r.resize(size: size)
        _d.resize(size: size)
        _q.resize(size: size)
        _s.resize(size: size)
        
        system.x.set(value: 0.0)
        _r.set(value: 0.0)
        _d.set(value: 0.0)
        _q.set(value: 0.0)
        _s.set(value: 0.0)
        
        _precond.build(matrix: matrix)
        
        pcg(
            A: matrix, b: rhs,
            maxNumberOfIterations: _maxNumberOfIterations,
            tolerance: _tolerance, M: &_precond, x: &solution,
            r: &_r, d: &_d, q: &_q, s: &_s,
            lastNumberOfIterations: &_lastNumberOfIterations,
            lastResidualNorm: &_lastResidualNorm)
        
        logger.info("Residual after solving ICCG: \(_lastResidualNorm) Number of ICCG iterations: \(_lastNumberOfIterations)")
        
        return _lastResidualNorm <= _tolerance ||
            _lastNumberOfIterations < _maxNumberOfIterations
    }
    
    /// Returns the max number of CG iterations.
    func maxNumberOfIterations()->UInt {
        return _maxNumberOfIterations
    }
    
    /// Returns the last number of CG iterations the solver made.
    func lastNumberOfIterations()->UInt {
        return _lastNumberOfIterations
    }
    
    /// Returns the max residual tolerance for the CG method.
    func tolerance()->Float {
        return _tolerance
    }
    
    /// Returns the last residual after the CG iterations.
    func lastResidual()->Float {
        return _lastResidualNorm
    }
    
    func clearUncompressedVectors() {
        _r.clear()
        _d.clear()
        _q.clear()
        _s.clear()
    }
}
