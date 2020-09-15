//
//  matrix4x4.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/19.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension matrix_float4x4 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 4
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 4
    }
    
    /// Returns 3x3 part of this matrix.
    var matrix3:matrix_float3x3 {
        return matrix_float3x3(rows: [SIMD3<Float>(columns.0[0], columns.0[1], columns.0[2]),
                                      SIMD3<Float>(columns.1[0], columns.1[1], columns.1[2]),
                                      SIMD3<Float>(columns.2[0], columns.2[1], columns.2[2])])
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Float {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
            + reduce_add(columns.2)
            + reduce_add(columns.3)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Float {
        return sum/16
    }
    
    /// Returns minimum among all elements.
    var min:Float {
        return Math.absminn(x: [reduce_min(columns.0),
                                reduce_min(columns.1),
                                reduce_min(columns.2),
                                reduce_min(columns.3)])
    }
    
    /// Returns maximum among all elements.
    var max:Float {
        return Math.absmaxn(x: [reduce_max(columns.0),
                                reduce_max(columns.1),
                                reduce_max(columns.2),
                                reduce_max(columns.3)])
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Float{
        let min = [Math.absminn(x: [columns.0[0], columns.0[1], columns.0[2], columns.0[3]]),
                   Math.absminn(x: [columns.1[0], columns.1[1], columns.1[2], columns.1[3]]),
                   Math.absminn(x: [columns.2[0], columns.2[1], columns.2[2], columns.2[3]]),
                   Math.absminn(x: [columns.3[0], columns.3[1], columns.3[2], columns.3[3]])]
        return Math.absminn(x: min)
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Float{
        let max = [Math.absmaxn(x: [columns.0[0], columns.0[1], columns.0[2], columns.0[3]]),
                   Math.absmaxn(x: [columns.1[0], columns.1[1], columns.1[2], columns.1[3]]),
                   Math.absmaxn(x: [columns.2[0], columns.2[1], columns.2[2], columns.2[3]]),
                   Math.absmaxn(x: [columns.3[0], columns.3[1], columns.3[2], columns.3[3]])]
        return Math.absmaxn(x: max)
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Float{
        return columns.0[0] + columns.1[1]
            + columns.2[2] +  columns.3[3]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_float4x4{
        return matrix_float4x4(diagonal: SIMD4<Float>(columns.0[0],
                                                      columns.1[1],
                                                      columns.2[2],
                                                      columns.3[3]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(0, columns.0[1], columns.0[2], columns.0[3]),
                                      SIMD4<Float>(columns.1[0], 0, columns.1[2], columns.1[3]),
                                      SIMD4<Float>(columns.2[0], columns.2[1], 0, columns.2[3]),
                                      SIMD4<Float>(columns.3[0], columns.3[1], columns.3[2], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(0, 0, 0, 0),
                                      SIMD4<Float>(columns.1[0], 0, 0, 0),
                                      SIMD4<Float>(columns.2[0], columns.2[1], 0, 0),
                                      SIMD4<Float>(columns.3[0], columns.3[1], columns.3[2], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(0, columns.0[1], columns.0[2], columns.0[3]),
                                      SIMD4<Float>(0, 0, columns.1[2], columns.1[3]),
                                      SIMD4<Float>(0, 0, 0, columns.2[3]),
                                      SIMD4<Float>(0, 0, 0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(columns.0[0], 0, 0, 0),
                                      SIMD4<Float>(columns.1[0], columns.1[1], 0, 0),
                                      SIMD4<Float>(columns.2[0], columns.2[1], columns.2[2], 0),
                                      SIMD4<Float>(columns.3[0], columns.3[1], columns.3[2], columns.3[3])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(columns.0[0], columns.0[1], columns.0[2], columns.0[3]),
                                      SIMD4<Float>(0, columns.1[1], columns.1[2], columns.1[3]),
                                      SIMD4<Float>(0, 0, columns.2[2], columns.2[3]),
                                      SIMD4<Float>(0, 0, 0, columns.3[3])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Float{
        return sqrt(length_squared(columns.0)
            + length_squared(columns.1)
            + length_squared(columns.2)
            + length_squared(columns.3))
    }
    
    static func makeTranslationMatrix(t:SIMD3<Float>)->matrix_float4x4{
        return matrix_float4x4(rows: [SIMD4<Float>(1, 0, 0, t.x),
                                      SIMD4<Float>(0, 1, 0, t.y),
                                      SIMD4<Float>(0, 0, 1, t.z),
                                      SIMD4<Float>(0, 0, 0, 1)])
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(axis:SIMD3<Float>, rad:Float)->matrix_float4x4{
        let rotation = matrix_float3x3.makeRotationMatrix(axis: axis, rad: rad)
        return matrix_float4x4(rows: [SIMD4<Float>(rotation.columns.0[0],
                                                   rotation.columns.0[1],
                                                   rotation.columns.0[2],
                                                   rotation.columns.0[3]),
                                      SIMD4<Float>(rotation.columns.1[0],
                                                   rotation.columns.1[1],
                                                   rotation.columns.1[2],
                                                   rotation.columns.1[3]),
                                      SIMD4<Float>(rotation.columns.2[0],
                                                   rotation.columns.2[1],
                                                   rotation.columns.2[2],
                                                   rotation.columns.2[3]),
                                      SIMD4<Float>(0,0,0,1)])
    }
}

extension matrix_double4x4 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 4
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 4
    }
    
    /// Returns 3x3 part of this matrix.
    var matrix3:matrix_double3x3 {
        return matrix_double3x3(rows: [SIMD3<Double>(columns.0[0], columns.0[1], columns.0[2]),
                                       SIMD3<Double>(columns.1[0], columns.1[1], columns.1[2]),
                                       SIMD3<Double>(columns.2[0], columns.2[1], columns.2[2])])
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Double {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
            + reduce_add(columns.2)
            + reduce_add(columns.3)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Double {
        return sum/16
    }
    
    /// Returns minimum among all elements.
    var min:Double {
        return Math.absminn(x: [reduce_min(columns.0),
                                reduce_min(columns.1),
                                reduce_min(columns.2),
                                reduce_min(columns.3)])
    }
    
    /// Returns maximum among all elements.
    var max:Double {
        return Math.absmaxn(x: [reduce_max(columns.0),
                                reduce_max(columns.1),
                                reduce_max(columns.2),
                                reduce_max(columns.3)])
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Double{
        let min = [Math.absminn(x: [columns.0[0], columns.0[1], columns.0[2], columns.0[3]]),
                   Math.absminn(x: [columns.1[0], columns.1[1], columns.1[2], columns.1[3]]),
                   Math.absminn(x: [columns.2[0], columns.2[1], columns.2[2], columns.2[3]]),
                   Math.absminn(x: [columns.3[0], columns.3[1], columns.3[2], columns.3[3]])]
        return Math.absminn(x: min)
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Double{
        let max = [Math.absmaxn(x: [columns.0[0], columns.0[1], columns.0[2], columns.0[3]]),
                   Math.absmaxn(x: [columns.1[0], columns.1[1], columns.1[2], columns.1[3]]),
                   Math.absmaxn(x: [columns.2[0], columns.2[1], columns.2[2], columns.2[3]]),
                   Math.absmaxn(x: [columns.3[0], columns.3[1], columns.3[2], columns.3[3]])]
        return Math.absmaxn(x: max)
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Double{
        return columns.0[0] + columns.1[1]
            + columns.2[2] +  columns.3[3]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_double4x4{
        return matrix_double4x4(diagonal: SIMD4<Double>(columns.0[0],
                                                        columns.1[1],
                                                        columns.2[2],
                                                        columns.3[3]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(0, columns.0[1], columns.0[2], columns.0[3]),
                                       SIMD4<Double>(columns.1[0], 0, columns.1[2], columns.1[3]),
                                       SIMD4<Double>(columns.2[0], columns.2[1], 0, columns.2[3]),
                                       SIMD4<Double>(columns.3[0], columns.3[1], columns.3[2], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(0, 0, 0, 0),
                                       SIMD4<Double>(columns.1[0], 0, 0, 0),
                                       SIMD4<Double>(columns.2[0], columns.2[1], 0, 0),
                                       SIMD4<Double>(columns.3[0], columns.3[1], columns.3[2], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(0, columns.0[1], columns.0[2], columns.0[3]),
                                       SIMD4<Double>(0, 0, columns.1[2], columns.1[3]),
                                       SIMD4<Double>(0, 0, 0, columns.2[3]),
                                       SIMD4<Double>(0, 0, 0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(columns.0[0], 0, 0, 0),
                                       SIMD4<Double>(columns.1[0], columns.1[1], 0, 0),
                                       SIMD4<Double>(columns.2[0], columns.2[1], columns.2[2], 0),
                                       SIMD4<Double>(columns.3[0], columns.3[1], columns.3[2], columns.3[3])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(columns.0[0], columns.0[1], columns.0[2], columns.0[3]),
                                       SIMD4<Double>(0, columns.1[1], columns.1[2], columns.1[3]),
                                       SIMD4<Double>(0, 0, columns.2[2], columns.2[3]),
                                       SIMD4<Double>(0, 0, 0, columns.3[3])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Double{
        return sqrt(length_squared(columns.0)
            + length_squared(columns.1)
            + length_squared(columns.2)
            + length_squared(columns.3))
    }
    
    static func makeTranslationMatrix(t:SIMD3<Double>)->matrix_double4x4{
        return matrix_double4x4(rows: [SIMD4<Double>(1, 0, 0, t.x),
                                       SIMD4<Double>(0, 1, 0, t.y),
                                       SIMD4<Double>(0, 0, 1, t.z),
                                       SIMD4<Double>(0, 0, 0, 1)])
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(axis:SIMD3<Double>, rad:Double)->matrix_double4x4{
        let rotation = matrix_double3x3.makeRotationMatrix(axis: axis, rad: rad)
        return matrix_double4x4(rows: [SIMD4<Double>(rotation.columns.0[0],
                                                     rotation.columns.0[1],
                                                     rotation.columns.0[2],
                                                     rotation.columns.0[3]),
                                       SIMD4<Double>(rotation.columns.1[0],
                                                     rotation.columns.1[1],
                                                     rotation.columns.1[2],
                                                     rotation.columns.1[3]),
                                       SIMD4<Double>(rotation.columns.2[0],
                                                     rotation.columns.2[1],
                                                     rotation.columns.2[2],
                                                     rotation.columns.2[3]),
                                       SIMD4<Double>(0,0,0,1)])
    }
}
