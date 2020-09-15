//
//  blas.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

protocol Blas {
    associatedtype ScalarType:ZeroInit&FloatingPoint
    associatedtype VectorType
    associatedtype MatrixType
    
    /// Sets entire element of given vector \p result with scalar \p s.
    static func set(s:ScalarType, result:inout VectorType)
    
    /// Copies entire element of given vector \p result with other vector \p v.
    static func set(v:VectorType, result:inout VectorType)
    
    /// Sets entire element of given matrix \p result with scalar \p s.
    static func set(s:ScalarType, result:inout MatrixType)
    
    /// Copies entire element of given matrix \p result with other matrix \p v.
    static func set(m:MatrixType, result:inout MatrixType)
    
    /// Performs dot product with vector \p a and \p b.
    static func dot(a:VectorType, b:VectorType)->ScalarType
    
    /// Performs ax + y operation where \p a is a matrix and \p x and \p y are vectors.
    static func axpy(a:ScalarType,
                     x:VectorType,
                     y:VectorType,
                     result:inout VectorType)
    
    /// Performs matrix-vector multiplication.
    static func mvm(m:MatrixType,
                    v:VectorType,
                    result:inout VectorType)
    
    /// Computes residual vector (b - ax).
    static func residual(a:MatrixType,
                         x:VectorType,
                         b:VectorType,
                         result:inout VectorType)
    
    /// Returns L2-norm of the given vector \p v.
    static func l2Norm(v:VectorType)->ScalarType
    
    /// Returns Linf-norm of the given vector \p v.
    static func lInfNorm(v:VectorType)->ScalarType
}

//MARK:- Float, Vector2F, matrix_float2x2
extension Blas where ScalarType == Float, VectorType == Vector2F, MatrixType == matrix_float2x2 {
    /// Sets entire element of given vector \p result with scalar \p s.
    static func set(s:ScalarType, result:inout VectorType) {
        result = VectorType(repeating: s)
    }
    
    /// Copies entire element of given vector \p result with other vector \p v.
    static func set(v:VectorType, result:inout VectorType) {
        result = v
    }
    
    /// Sets entire element of given matrix \p result with scalar \p s.
    static func set(s:ScalarType, result:inout MatrixType) {
        result = MatrixType(SIMD2<Float>(repeating: s),
                            SIMD2<Float>(repeating: s))
    }
    
    /// Copies entire element of given matrix \p result with other matrix \p v.
    static func set(m:MatrixType, result:inout MatrixType) {
        result = m
    }
    
    /// Performs dot product with vector \p a and \p b.
    static func dot(a:VectorType, b:VectorType)->ScalarType {
        return simd.dot(a, b)
    }
    
    /// Performs ax + y operation where \p a is a matrix and \p x and \p y are vectors.
    static func axpy(a:ScalarType,
                     x:VectorType,
                     y:VectorType,
                     result:inout VectorType) {
        result = a * x + y
    }
    
    /// Performs matrix-vector multiplication.
    static func mvm(m:MatrixType,
                    v:VectorType,
                    result:inout VectorType) {
        result = m * v
    }
    
    /// Computes residual vector (b - ax).
    static func residual(a:MatrixType,
                         x:VectorType,
                         b:VectorType,
                         result:inout VectorType) {
        result = b - a * x
    }
    
    /// Returns L2-norm of the given vector \p v.
    static func l2Norm(v:VectorType)->ScalarType {
        return sqrt(dot(a: v, b: v))
    }
    
    /// Returns Linf-norm of the given vector \p v.
    static func lInfNorm(v:VectorType)->ScalarType {
        return abs(v.absmax)
    }
}

//MARK:- Float, Vector3F, matrix_float3x3
extension Blas where ScalarType == Float, VectorType == Vector3F, MatrixType == matrix_float3x3 {
    /// Sets entire element of given vector \p result with scalar \p s.
    static func set(s:ScalarType, result:inout VectorType) {
        result = VectorType(repeating: s)
    }
    
    /// Copies entire element of given vector \p result with other vector \p v.
    static func set(v:VectorType, result:inout VectorType) {
        result = v
    }
    
    /// Sets entire element of given matrix \p result with scalar \p s.
    static func set(s:ScalarType, result:inout MatrixType) {
        result = MatrixType(SIMD3<Float>(repeating: s),
                            SIMD3<Float>(repeating: s),
                            SIMD3<Float>(repeating: s))
    }
    
    /// Copies entire element of given matrix \p result with other matrix \p v.
    static func set(m:MatrixType, result:inout MatrixType) {
        result = m
    }
    
    /// Performs dot product with vector \p a and \p b.
    static func dot(a:VectorType, b:VectorType)->ScalarType {
        return simd.dot(a, b)
    }
    
    /// Performs ax + y operation where \p a is a matrix and \p x and \p y are vectors.
    static func axpy(a:ScalarType,
                     x:VectorType,
                     y:VectorType,
                     result:inout VectorType) {
        result = a * x + y
    }
    
    /// Performs matrix-vector multiplication.
    static func mvm(m:MatrixType,
                    v:VectorType,
                    result:inout VectorType) {
        result = m * v
    }
    
    /// Computes residual vector (b - ax).
    static func residual(a:MatrixType,
                         x:VectorType,
                         b:VectorType,
                         result:inout VectorType) {
        result = b - a * x
    }
    
    /// Returns L2-norm of the given vector \p v.
    static func l2Norm(v:VectorType)->ScalarType {
        return sqrt(dot(a: v, b: v))
    }
    
    /// Returns Linf-norm of the given vector \p v.
    static func lInfNorm(v:VectorType)->ScalarType {
        return abs(v.absmax)
    }
}

//MARK:- Float, Vector4F, matrix_float4x4
extension Blas where ScalarType == Float, VectorType == Vector4F, MatrixType == matrix_float4x4 {
    /// Sets entire element of given vector \p result with scalar \p s.
    static func set(s:ScalarType, result:inout VectorType) {
        result = VectorType(repeating: s)
    }
    
    /// Copies entire element of given vector \p result with other vector \p v.
    static func set(v:VectorType, result:inout VectorType) {
        result = v
    }
    
    /// Sets entire element of given matrix \p result with scalar \p s.
    static func set(s:ScalarType, result:inout MatrixType) {
        result = MatrixType(SIMD4<Float>(repeating: s),
                            SIMD4<Float>(repeating: s),
                            SIMD4<Float>(repeating: s),
                            SIMD4<Float>(repeating: s))
    }
    
    /// Copies entire element of given matrix \p result with other matrix \p v.
    static func set(m:MatrixType, result:inout MatrixType) {
        result = m
    }
    
    /// Performs dot product with vector \p a and \p b.
    static func dot(a:VectorType, b:VectorType)->ScalarType {
        return simd.dot(a, b)
    }
    
    /// Performs ax + y operation where \p a is a matrix and \p x and \p y are vectors.
    static func axpy(a:ScalarType,
                     x:VectorType,
                     y:VectorType,
                     result:inout VectorType) {
        result = a * x + y
    }
    
    /// Performs matrix-vector multiplication.
    static func mvm(m:MatrixType,
                    v:VectorType,
                    result:inout VectorType) {
        result = m * v
    }
    
    /// Computes residual vector (b - ax).
    static func residual(a:MatrixType,
                         x:VectorType,
                         b:VectorType,
                         result:inout VectorType) {
        result = b - a * x
    }
    
    /// Returns L2-norm of the given vector \p v.
    static func l2Norm(v:VectorType)->ScalarType {
        return sqrt(dot(a: v, b: v))
    }
    
    /// Returns Linf-norm of the given vector \p v.
    static func lInfNorm(v:VectorType)->ScalarType {
        return abs(v.absmax)
    }
}
