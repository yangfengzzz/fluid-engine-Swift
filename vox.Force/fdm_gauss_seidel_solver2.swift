//
//  fdm_gauss_seidel_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D finite difference-type linear system solver using Gauss-Seidel method.
class FdmGaussSeidelSolver2: FdmLinearSystemSolver2 {
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _residualCheckInterval:UInt
    var _tolerance:Float
    var _lastResidual:Float
    var _sorFactor:Float
    var _useRedBlackOrdering:Bool
    
    /// Uncompressed vectors
    var _residual = FdmVector2()
    
    /// Constructs the solver with given parameters.
    init(maxNumberOfIterations:UInt,
         residualCheckInterval:UInt, tolerance:Float,
         sorFactor:Float = 1.0,
         useRedBlackOrdering:Bool = false) {
        self._maxNumberOfIterations = maxNumberOfIterations
        self._lastNumberOfIterations = 0
        self._residualCheckInterval = residualCheckInterval
        self._tolerance = tolerance
        self._lastResidual = Float.greatestFiniteMagnitude
        self._sorFactor = sorFactor
        self._useRedBlackOrdering = useRedBlackOrdering
    }
    
    /// Solves the given linear system.
    func solve(system: inout FdmLinearSystem2)->Bool {
        clearUncompressedVectors()
        
        _residual.resize(size: system.x.size())
        
        _lastNumberOfIterations = _maxNumberOfIterations
        
        for iter in 0..<_maxNumberOfIterations {
            if (_useRedBlackOrdering) {
                FdmGaussSeidelSolver2.relaxRedBlack(A: system.A, b: system.b,
                                                    sorFactor: _sorFactor, x: &system.x)
            } else {
                FdmGaussSeidelSolver2.relax(A: system.A, b: system.b,
                                            sorFactor: _sorFactor, x: &system.x)
            }
            
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
    
    /// Returns the max number of Gauss-Seidel iterations.
    func maxNumberOfIterations()->UInt {
        return _maxNumberOfIterations
    }
    
    /// Returns the last number of Gauss-Seidel iterations the solver made.
    func lastNumberOfIterations()->UInt {
        return _lastNumberOfIterations
    }
    
    /// Returns the max residual tolerance for the Gauss-Seidel method.
    func tolerance()->Float {
        return _tolerance
    }
    
    /// Returns the last residual after the Gauss-Seidel iterations.
    func lastResidual()->Float {
        return _lastResidual
    }
    
    /// Returns the SOR (Successive Over Relaxation) factor.
    func sorFactor()->Float {
        return _sorFactor
    }
    
    /// Returns true if red-black ordering is enabled.
    func useRedBlackOrdering()->Bool {
        return _useRedBlackOrdering
    }
    
    /// Performs single natural Gauss-Seidel relaxation step.
    static func relax(A:FdmMatrix2, b:FdmVector2,
                      sorFactor:Float, x:inout FdmVector2) {
        let size = A.size()
        
        A.forEachIndex(){(i:size_t, j:size_t) in
            let r = ((i > 0) ? A[i - 1, j].right * x[i - 1, j] : 0.0) +
                ((i + 1 < size.x) ? A[i, j].right * x[i + 1, j] : 0.0) +
                ((j > 0) ? A[i, j - 1].up * x[i, j - 1] : 0.0) +
                ((j + 1 < size.y) ? A[i, j].up * x[i, j + 1] : 0.0)
            
            x[i, j] = (1.0 - sorFactor) * x[i, j] +
                sorFactor * (b[i, j] - r) / A[i, j].center
        }
    }
    
    /// Performs single Red-Black Gauss-Seidel relaxation step.
    static func relaxRedBlack(A:FdmMatrix2, b:FdmVector2,
                              sorFactor:Float, x:inout FdmVector2) {
        if Renderer.arch == .CPU {
            let size = A.size()
            
            // Red update
            parallelRangeFor(beginIndexX: 0, endIndexX: size.x, beginIndexY: 0, endIndexY: size.y)
            {(iBegin:size_t, iEnd:size_t, jBegin:size_t, jEnd:size_t) in
                for j in jBegin..<jEnd {
                    for i in stride(from: j % 2 + iBegin, to: iEnd, by: 2) {
                        let r =
                            ((i > 0) ? A[i - 1, j].right * x[i - 1, j] : 0.0) +
                                ((i + 1 < size.x) ? A[i, j].right * x[i + 1, j] : 0.0) +
                                ((j > 0) ? A[i, j - 1].up * x[i, j - 1] : 0.0) +
                                ((j + 1 < size.y) ? A[i, j].up * x[i, j + 1] : 0.0)
                        
                        x[i, j] = (1.0 - sorFactor) * x[i, j] +
                            sorFactor * (b[i, j] - r) / A[i, j].center
                    }
                }
            }
            
            // Black update
            parallelRangeFor(beginIndexX: 0, endIndexX: size.x, beginIndexY: 0, endIndexY: size.y)
            {(iBegin:size_t, iEnd:size_t, jBegin:size_t, jEnd:size_t) in
                for j in jBegin..<jEnd {
                    for i in stride(from: 1 - j % 2 + iBegin, to: iEnd, by: 2) {
                        let r =
                            ((i > 0) ? A[i - 1, j].right * x[i - 1, j] : 0.0) +
                                ((i + 1 < size.x) ? A[i, j].right * x[i + 1, j] : 0.0) +
                                ((j > 0) ? A[i, j - 1].up * x[i, j - 1] : 0.0) +
                                ((j + 1 < size.y) ? A[i, j].up * x[i, j + 1] : 0.0)
                        
                        x[i, j] = (1.0 - sorFactor) * x[i, j] +
                            sorFactor * (b[i, j] - r) / A[i, j].center
                    }
                }
            }
        } else {
            relaxRedBlack_GPU(A: A, b: b, sorFactor: sorFactor, x: &x)
        }
    }
    
    func clearUncompressedVectors() {
        _residual.clear()
    }
}

//MARK:- GPU Methods
extension FdmGaussSeidelSolver2 {
    static func relaxRedBlack_GPU(A:FdmMatrix2, b:FdmVector2,
                                  sorFactor:Float, x:inout FdmVector2) {
        var sorFactor = sorFactor
        let size = A.size()
        
        // Red update
        parallelRangeFor(beginIndexX: 0, endIndexX: size.x,
                         beginIndexY: 0, endIndexY: size.y, name: "FdmGaussSeidelSolver2::red") {
                            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
                            index = A.loadGPUBuffer(encoder: &encode, index_begin: index)
                            index = b.loadGPUBuffer(encoder: &encode, index_begin: index)
                            index = x.loadGPUBuffer(encoder: &encode, index_begin: index)
                            encode.setBytes(&sorFactor, length: MemoryLayout<Float>.stride, index: index)
        }
        
        // Black update
        parallelRangeFor(beginIndexX: 0, endIndexX: size.x,
                         beginIndexY: 0, endIndexY: size.y, name: "FdmGaussSeidelSolver2::black") {
                            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
                            index = A.loadGPUBuffer(encoder: &encode, index_begin: index)
                            index = b.loadGPUBuffer(encoder: &encode, index_begin: index)
                            index = x.loadGPUBuffer(encoder: &encode, index_begin: index)
                            encode.setBytes(&sorFactor, length: MemoryLayout<Float>.stride, index: index)
        }
    }
}
