//
//  fdm_iccg_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D finite difference-type linear system solver using incomplete
///        Cholesky conjugate gradient (ICCG).
class FdmIccgSolver2: FdmLinearSystemSolver2 {
    struct Preconditioner : PrecondTypeProtocol {
        typealias BlasType = FdmBlas2
        
        var A = ConstArrayAccessor2<FdmMatrixRow2>()
        var d = FdmVector2()
        var y = FdmVector2()
        
        mutating func build(matrix:FdmMatrix2) {
            let size = matrix.size()
            A = matrix.constAccessor()
            
            d.resize(size: size, initVal: 0.0)
            y.resize(size: size, initVal: 0.0)
            
            matrix.forEachIndex(){(i:size_t, j:size_t) in
                let denom =
                    matrix[i, j].center -
                    ((i > 0) ? Math.square(of: matrix[i - 1, j].right) * d[i - 1, j] : 0.0) -
                    ((j > 0) ? Math.square(of: matrix[i, j - 1].up) * d[i, j - 1] : 0.0)
                
                if (abs(denom) > 0.0) {
                    d[i, j] = 1.0 / denom
                } else {
                    d[i, j] = 0.0
                }
            }
        }
        
        mutating func solve(b:FdmVector2, x:inout FdmVector2) {
            let size = b.size()
            let sx:ssize_t = size.x
            let sy:ssize_t = size.y
            
            b.forEachIndex(){(i:size_t, j:size_t) in
                y[i, j] = (b[i, j] -
                            ((i > 0) ? A[i - 1, j].right * y[i - 1, j] : 0.0) -
                            ((j > 0) ? A[i, j - 1].up * y[i, j - 1] : 0.0)) * d[i, j]
            }
            
            for j in stride(from: sy - 1, to: -1, by: -1) {
                for i in stride(from: sx - 1, to: -1, by: -1) {
                    x[i, j] = (y[i, j] -
                                ((i + 1 < sx) ? A[i, j].right * x[i + 1, j] : 0.0) -
                                ((j + 1 < sy) ? A[i, j].up * x[i, j + 1] : 0.0)) * d[i, j]
                }
            }
        }
    }
    
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _tolerance:Float
    var _lastResidualNorm:Float
    
    // Uncompressed vectors and preconditioner
    var _r = FdmVector2()
    var _d = FdmVector2()
    var _q = FdmVector2()
    var _s = FdmVector2()
    var _precond = Preconditioner()
    
    /// Constructs the solver with given parameters.
    init(maxNumberOfIterations:UInt, tolerance:Float) {
        self._maxNumberOfIterations = maxNumberOfIterations
        self._lastNumberOfIterations = 0
        self._tolerance = tolerance
        self._lastResidualNorm = Float.greatestFiniteMagnitude
    }
    
    /// Solves the given linear system.
    func solve(system: inout FdmLinearSystem2)->Bool {
        let matrix = system.A;
        var solution = system.x;
        let rhs = system.b;
        
        VOX_ASSERT(matrix.size() == rhs.size());
        VOX_ASSERT(matrix.size() == solution.size());
        
        clearUncompressedVectors();
        
        let size = matrix.size();
        _r.resize(size: size);
        _d.resize(size: size);
        _q.resize(size: size);
        _s.resize(size: size);
        
        system.x.set(value: 0.0);
        _r.set(value: 0.0);
        _d.set(value: 0.0);
        _q.set(value: 0.0);
        _s.set(value: 0.0);
        
        _precond.build(matrix: matrix);
        
        pcg(
            A: matrix, b: rhs,
            maxNumberOfIterations: _maxNumberOfIterations,
            tolerance: _tolerance, M: &_precond, x: &solution,
            r: &_r, d: &_d, q: &_q, s: &_s,
            lastNumberOfIterations: &_lastNumberOfIterations,
            lastResidualNorm: &_lastResidualNorm);
        
        logger.info("Residual after solving ICCG: \(_lastResidualNorm) Number of ICCG iterations: \(_lastNumberOfIterations)")
        
        return _lastResidualNorm <= _tolerance ||
            _lastNumberOfIterations < _maxNumberOfIterations;
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
