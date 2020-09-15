//
//  fdm_linear_system2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// The row of FdmMatrix2 where row corresponds to (i, j) grid point.
struct FdmMatrixRow2 : ZeroInit {
    func getKernelType() -> KernelType {
        .unsupported
    }
    
    /// Diagonal component of the matrix (row, row).
    var center:Float = 0.0
    
    /// Off-diagonal element where colum refers to (i+1, j) grid point.
    var right:Float = 0.0
    
    /// Off-diagonal element where column refers to (i, j+1) grid point.
    var up:Float = 0.0
}

/// Vector type for 2-D finite differencing.
typealias FdmVector2 = Array2<Float>
/// Matrix type for 2-D finite differencing.
typealias FdmMatrix2 = Array2<FdmMatrixRow2>

/// Linear system (Ax=b) for 2-D finite differencing.
struct FdmLinearSystem2 {
    /// System matrix.
    var A = FdmMatrix2()
    
    /// Solution vector.
    var x = FdmVector2()
    
    /// RHS vector.
    var b = FdmVector2()
    
    /// Clears all the data.
    mutating func clear() {
        A.clear()
        x.clear()
        b.clear()
    }
    
    /// Resizes the arrays with given grid size.
    mutating func resize(size:Size2) {
        A.resize(size: size)
        x.resize(size: size)
        b.resize(size: size)
    }
}

/// BLAS operator wrapper for 2-D finite differencing.
struct FdmBlas2 : Blas {
    typealias ScalarType = Float
    typealias VectorType = FdmVector2
    typealias MatrixType = FdmMatrix2
    
    /// Sets entire element of given vector \p result with scalar \p s.
    static func set(s:ScalarType, result: inout VectorType) {
        result.set(value: s)
    }
    
    /// Copies entire element of given vector \p result with other vector \p v.
    static func set(v:VectorType, result: inout VectorType) {
        result.set(other: v)
    }
    
    /// Sets entire element of given matrix \p result with scalar \p s.
    static func set(s:ScalarType, result: inout MatrixType) {
        var row = FdmMatrixRow2()
        row.center = s
        row.right = s
        row.up = s
        result.set(value: row)
    }
    
    /// Copies entire element of given matrix \p result with other matrix \p v.
    static func set(m:MatrixType, result: inout MatrixType) {
        result.set(other: m)
    }
    
    /// Performs dot product with vector \p a and \p b.
    static func dot(a:VectorType, b:VectorType)->Float {
        let size = a.size()
        
        if size != b.size() {
            fatalError()
        }
        
        var result:Float = 0.0
        
        for j in 0..<size.y {
            for i in 0..<size.x {
                result += a[i, j] * b[i, j]
            }
        }
        
        return result
    }
    
    /// Performs ax + y operation where \p a is a matrix and \p x and \p y are vectors.
    static func axpy(a:Float, x:VectorType, y:VectorType,
                     result: inout VectorType) {
        if Renderer.arch == .CPU {
            let size = x.size()
            
            if size != y.size() || size != result.size() {
                fatalError()
            }
            
            x.parallelForEachIndex(){(i:size_t, j:size_t) in
                result[i, j] = a * x[i, j] + y[i, j]
            }
        } else {
            axpy_GPU(a: a, x: x, y: y, result: &result)
        }
    }
    
    /// Performs matrix-vector multiplication.
    static func mvm(m:MatrixType, v:VectorType,
                    result: inout VectorType) {
        if Renderer.arch == .CPU {
            let size = m.size()
            
            if size != v.size() || size != result.size() {
                fatalError()
            }
            
            m.parallelForEachIndex(){(i:size_t, j:size_t) in
                result[i, j] =
                    m[i, j].center * v[i, j] +
                    ((i > 0) ? m[i - 1, j].right * v[i - 1, j] : 0.0) +
                    ((i + 1 < size.x) ? m[i, j].right * v[i + 1, j] : 0.0) +
                    ((j > 0) ? m[i, j - 1].up * v[i, j - 1] : 0.0) +
                    ((j + 1 < size.y) ? m[i, j].up * v[i, j + 1] : 0.0)
            }
        } else {
            mvm_GPU(m: m, v: v, result: &result)
        }
    }
    
    /// Computes residual vector (b - ax).
    static func residual(a:MatrixType, x:VectorType,
                         b:VectorType, result: inout VectorType) {
        if Renderer.arch == .CPU {
            let size = a.size()
            
            if size != x.size() || size != b.size() || size != result.size() {
                fatalError()
            }
            
            a.parallelForEachIndex(){(i:size_t, j:size_t) in
                result[i, j] =
                    b[i, j] - a[i, j].center * x[i, j] -
                    ((i > 0) ? a[i - 1, j].right * x[i - 1, j] : 0.0) -
                    ((i + 1 < size.x) ? a[i, j].right * x[i + 1, j] : 0.0) -
                    ((j > 0) ? a[i, j - 1].up * x[i, j - 1] : 0.0) -
                    ((j + 1 < size.y) ? a[i, j].up * x[i, j + 1] : 0.0)
            }
        } else {
            residual_GPU(a: a, x: x, b: b, result: &result)
        }
    }
    
    /// Returns L2-norm of the given vector \p v.
    static func l2Norm(v:VectorType)->ScalarType {
        return sqrt(dot(a: v, b: v))
    }
    
    /// Returns Linf-norm of the given vector \p v.
    static func lInfNorm(v:VectorType)->ScalarType {
        let size = v.size()
        
        var result:Float = 0.0
        
        for j in 0..<size.y {
            for i in 0..<size.x {
                result = Math.absmax(between: result, and: v[i, j])
            }
        }
        
        return abs(result)
    }
}

//MARK:- GPU Methods
extension FdmBlas2 {
    static func axpy_GPU(a:Float, x:VectorType, y:VectorType,
                         result: inout VectorType) {
        let size = x.size()
        
        if size != y.size() || size != result.size() {
            fatalError()
        }
        
        var x = x
        var a = a
        x.parallelForEachIndex(name: "FdmBlas2::axpy") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = y.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = result.loadGPUBuffer(encoder: &encode, index_begin: index)
            encode.setBytes(&a, length: MemoryLayout<Float>.stride, index: index)
        }
    }
    
    static func mvm_GPU(m:MatrixType, v:VectorType,
                        result: inout VectorType) {
        let size = m.size()
        
        if size != v.size() || size != result.size() {
            fatalError()
        }
        
        var m = m
        m.parallelForEachIndex(name: "FdmBlas2::mvm") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = v.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = result.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
    
    static func residual_GPU(a:MatrixType, x:VectorType,
                             b:VectorType, result: inout VectorType) {
        let size = a.size()
        
        if size != x.size() || size != b.size() || size != result.size() {
            fatalError()
        }
        
        var a = a
        a.parallelForEachIndex(name: "FdmBlas2::residual") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = x.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = b.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = result.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
}
