//
//  fdm_cg_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D finite difference-type linear system solver using conjugate gradient.
class FdmCgSolver2: FdmLinearSystemSolver2 {
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _tolerance:Float
    var _lastResidual:Float
    
    // Uncompressed vectors
    var _r = FdmVector2()
    var _d = FdmVector2()
    var _q = FdmVector2()
    var _s = FdmVector2()
    
    /// Constructs the solver with given parameters.
    init(maxNumberOfIterations:UInt, tolerance:Float) {
        self._maxNumberOfIterations = maxNumberOfIterations
        self._lastNumberOfIterations = 0
        self._tolerance = tolerance
        self._lastResidual = Float.greatestFiniteMagnitude
    }
    
    /// Solves the given linear system.
    func solve(system: inout FdmLinearSystem2)->Bool {
        let matrix = system.A
        var solution = system.x
        let rhs = system.b
        
        VOX_ASSERT(matrix.size() == rhs.size())
        VOX_ASSERT(matrix.size() == solution.size())
        
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
        
        var nullPrecondition = NullCgPreconditioner<FdmBlas2>()
        pcg(A: matrix, b: rhs,
            maxNumberOfIterations: _maxNumberOfIterations,
            tolerance: _tolerance,
            M: &nullPrecondition,
            x: &solution,
            r: &_r, d: &_d, q: &_q, s: &_s,
            lastNumberOfIterations: &_lastNumberOfIterations,
            lastResidualNorm: &_lastResidual)
        
        return _lastResidual <= _tolerance ||
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
        return _lastResidual
    }
    
    func clearUncompressedVectors() {
        _r.clear()
        _d.clear()
        _q.clear()
        _s.clear()
    }
}
