//
//  fdm_jacobi_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D finite difference-type linear system solver using Jacobi method.
class FdmJacobiSolver3: FdmLinearSystemSolver3 {
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _residualCheckInterval:UInt
    var _tolerance:Float
    var _lastResidual:Float
    
    /// Uncompressed vectors
    var _xTemp = FdmVector3()
    var _residual = FdmVector3()
    
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
    func solve(system: inout FdmLinearSystem3)->Bool {
        clearUncompressedVectors()
        
        _xTemp.resize(size: system.x.size())
        _residual.resize(size: system.x.size())
        
        _lastNumberOfIterations = _maxNumberOfIterations
        
        for iter in 0..<_maxNumberOfIterations {
            FdmJacobiSolver3.relax(A: system.A, b: system.b, x: &system.x, xTemp: &_xTemp)
            
            _xTemp.swap(other: &system.x)
            
            if (iter != 0 && iter % _residualCheckInterval == 0) {
                FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &_residual)
                
                if (FdmBlas3.l2Norm(v: _residual) < _tolerance) {
                    _lastNumberOfIterations = iter + 1
                    break
                }
            }
        }
        
        FdmBlas3.residual(a: system.A, x: system.x, b: system.b, result: &_residual)
        _lastResidual = FdmBlas3.l2Norm(v: _residual)
        
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
    static func relax(A:FdmMatrix3, b:FdmVector3,
                      x:inout FdmVector3,
                      xTemp:inout FdmVector3) {
        if Renderer.arch == .CPU {
            let size = A.size()
            
            A.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                let r =
                    ((i > 0) ? A[i - 1, j, k].right * x[i - 1, j, k] : 0.0) +
                        ((i + 1 < size.x) ? A[i, j, k].right * x[i + 1, j, k] : 0.0) +
                        ((j > 0) ? A[i, j - 1, k].up * x[i, j - 1, k] : 0.0) +
                        ((j + 1 < size.y) ? A[i, j, k].up * x[i, j + 1, k] : 0.0) +
                        ((k > 0) ? A[i, j, k - 1].front * x[i, j, k - 1] : 0.0) +
                        ((k + 1 < size.z) ? A[i, j, k].front * x[i, j, k + 1] : 0.0)
                
                xTemp[i, j, k] = (b[i, j, k] - r) / A[i, j, k].center
            }
        } else {
            relax_GPU(A: A, b: b, x: &x, xTemp: &xTemp)
        }
    }
    
    func clearUncompressedVectors() {
        _xTemp.clear()
        _residual.clear()
    }
}

//MARK:- GPU Methods
extension FdmJacobiSolver3 {
    static func relax_GPU(A:FdmMatrix3, b:FdmVector3,
                          x:inout FdmVector3,
                          xTemp:inout FdmVector3) {
        var A = A
        A.parallelForEachIndex(name: "FdmJacobiSolver3::relax") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = b.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = x.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = xTemp.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
}
