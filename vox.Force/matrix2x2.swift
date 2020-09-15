//
//  matrix2x2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/19.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension matrix_float2x2 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 2
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 2
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Float {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Float {
        return sum/4
    }
    
    /// Returns minimum among all elements.
    var min:Float {
        return Swift.min(reduce_min(columns.0),
                         reduce_min(columns.1))
    }
    
    /// Returns maximum among all elements.
    var max:Float {
        return Swift.max(reduce_max(columns.0),
                         reduce_max(columns.1))
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Float{
        return Math.absmin(between: Math.absmin(between: columns.0[0], and: columns.0[1]),
                           and: Math.absmin(between: columns.1[0], and: columns.1[1]))
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Float{
        return Math.absmax(between: Math.absmax(between: columns.0[0], and: columns.0[1]),
                           and: Math.absmax(between: columns.1[0], and: columns.1[1]))
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Float{
        return columns.0[0] + columns.1[1]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_float2x2{
        return matrix_float2x2(diagonal: SIMD2<Float>(columns.0[0],
                                                      columns.1[1]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(0, columns.0[1]),
                                      SIMD2<Float>(columns.1[0], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(0, 0),
                                      SIMD2<Float>(columns.1[0], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(0, columns.0[1]),
                                      SIMD2<Float>(0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(columns.0[0], 0),
                                      SIMD2<Float>(columns.1[0], columns.1[1])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(columns.0[0], columns.0[1]),
                                      SIMD2<Float>(0, columns.1[1])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Float{
        return sqrt(length_squared(columns.0) + length_squared(columns.1))
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(rad:Float)->matrix_float2x2{
        return matrix_float2x2(rows: [SIMD2<Float>(cos(rad), -sin(rad)),
                                      SIMD2<Float>(sin(rad), cos(rad))])
    }
}

extension matrix_double2x2 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 2
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 2
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Double {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Double {
        return sum/4
    }
    
    /// Returns minimum among all elements.
    var min:Double {
        return Swift.min(reduce_min(columns.0),
                         reduce_min(columns.1))
    }
    
    /// Returns maximum among all elements.
    var max:Double {
        return Swift.max(reduce_max(columns.0),
                         reduce_max(columns.1))
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Double{
        return Math.absmin(between: Math.absmin(between: columns.0[0], and: columns.0[1]),
                           and: Math.absmin(between: columns.1[0], and: columns.1[1]))
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Double{
        return Math.absmax(between: Math.absmax(between: columns.0[0], and: columns.0[1]),
                           and: Math.absmax(between: columns.1[0], and: columns.1[1]))
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Double{
        return columns.0[0] + columns.1[1]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_double2x2{
        return matrix_double2x2(diagonal: SIMD2<Double>(columns.0[0],
                                                        columns.1[1]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(0, columns.0[1]),
                                       SIMD2<Double>(columns.1[0], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(0, 0),
                                       SIMD2<Double>(columns.1[0], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(0, columns.0[1]),
                                       SIMD2<Double>(0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(columns.0[0], 0),
                                       SIMD2<Double>(columns.1[0], columns.1[1])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(columns.0[0], columns.0[1]),
                                       SIMD2<Double>(0, columns.1[1])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Double{
        return sqrt(length_squared(columns.0) + length_squared(columns.1))
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(rad:Double)->matrix_double2x2{
        return matrix_double2x2(rows: [SIMD2<Double>(cos(rad), -sin(rad)),
                                       SIMD2<Double>(sin(rad), cos(rad))])
    }
}
