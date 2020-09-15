//
//  fdm_jacobi_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D finite difference-type linear system solver using Jacobi method.
class FdmJacobiSolver2: FdmLinearSystemSolver2 {
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _residualCheckInterval:UInt
    var _tolerance:Float
    var _lastResidual:Float
    
    /// Uncompressed vectors
    var _xTemp = FdmVector2()
    var _residual = FdmVector2()
    
    /// Constructs the solver with given parameters.
    init(maxNumberOfIterations:UInt,
         residualCheckInterval:UInt, tolerance:Float) {
        self._maxNumberOfIterations = maxNumberOfIterations
        self._lastNumberOfIterations = 0
        self._residualCheckInterval = residualCheckInterval
        self._tolerance = tolerance
        self._lastResidual = Float.greatestFiniteMagnitude
    }
    
    /// Solves the given linear system.
    func solve(system: inout FdmLinearSystem2)->Bool {
        clearCompressedVectors()
        
        _xTemp.resize(size: system.x.size())
        _residual.resize(size: system.x.size())
        
        _lastNumberOfIterations = _maxNumberOfIterations
        
        for iter in 0..<_maxNumberOfIterations {
            FdmJacobiSolver2.relax(A: system.A, b: system.b, x: &system.x, xTemp: &_xTemp)
            
            _xTemp.swap(other: &system.x)
            
            if (iter != 0 && iter % _residualCheckInterval == 0) {
                FdmBlas2.residual(a: system.A, x: system.x, b: system.b, result: &_residual)
                
                if (FdmBlas2.l2Norm(v: _residual) < _tolerance) {
                    _lastNumberOfIterations = iter + 1
                    break
                }
            }
        }
        
        FdmBlas2.residual(a: system.A, x: system.x, b: system.b, result: &_residual)
        _lastResidual = FdmBlas2.l2Norm(v: _residual)
        
        return _lastResidual < _tolerance
    }
    
    /// Returns the max number of Jacobi iterations.
    func maxNumberOfIterations()->UInt {
        return _maxNumberOfIterations
    }
    
    /// Returns the last number of Jacobi iterations the solver made.
    func lastNumberOfIterations()->UInt {
        return _lastNumberOfIterations
    }
    
    /// Returns the max residual tolerance for the Jacobi method.
    func tolerance()->Float {
        return _tolerance
    }
    
    /// Returns the last residual after the Jacobi iterations.
    func lastResidual()->Float {
        return _lastResidual
    }
    
    /// Performs single Jacobi relaxation step.
    static func relax(A:FdmMatrix2, b:FdmVector2,
                      x:inout FdmVector2,
                      xTemp:inout FdmVector2) {
        if Renderer.arch == .CPU {
            let size = A.size()
            
            A.parallelForEachIndex(){(i:size_t, j:size_t) in
                let r = ((i > 0) ? A[i - 1, j].right * x[i - 1, j] : 0.0) +
                    ((i + 1 < size.x) ? A[i, j].right * x[i + 1, j] : 0.0) +
                    ((j > 0) ? A[i, j - 1].up * x[i, j - 1] : 0.0) +
                    ((j + 1 < size.y) ? A[i, j].up * x[i, j + 1] : 0.0)
                
                xTemp[i, j] = (b[i, j] - r) / A[i, j].center
            }
        } else {
            relax_GPU(A: A, b: b, x: &x, xTemp: &xTemp)
        }
    }
    
    func clearCompressedVectors() {
        _xTemp.clear()
        _residual.clear()
    }
}

//MARK:- GPU Methods
extension FdmJacobiSolver2 {
    static func relax_GPU(A:FdmMatrix2, b:FdmVector2,
                          x:inout FdmVector2,
                          xTemp:inout FdmVector2) {
        var A = A
        A.parallelForEachIndex(name: "FdmJacobiSolver2::relax") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = b.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = x.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = xTemp.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
}
