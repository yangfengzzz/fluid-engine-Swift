//
//  matrix3x3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/19.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension matrix_float3x3 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 3
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 3
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Float {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
            + reduce_add(columns.2)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Float {
        return sum/9
    }
    
    /// Returns minimum among all elements.
    var min:Float {
        return Swift.min(Swift.min(reduce_min(columns.0),
                                   reduce_min(columns.1)),
                         reduce_min(columns.1))
    }
    
    /// Returns maximum among all elements.
    var max:Float {
        return Swift.max(Swift.max(reduce_max(columns.0),
                                   reduce_max(columns.1)),
                         reduce_max(columns.2))
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Float{
        let min = [Math.absminn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absminn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absminn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absminn(x: min)
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Float{
        let max = [Math.absmaxn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absmaxn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absmaxn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absmaxn(x: max)
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Float{
        return columns.0[0] + columns.1[1] + columns.2[2]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_float3x3{
        return matrix_float3x3(diagonal: SIMD3<Float>(columns.0[0],
                                                      columns.1[1],
                                                      columns.2[2]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(0, columns.0[1], columns.0[2]),
                                      SIMD3<Float>(columns.1[0], 0, columns.1[2]),
                                      SIMD3<Float>(columns.2[0], columns.2[1], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(0, 0, 0),
                                      SIMD3<Float>(columns.1[0], 0, 0),
                                      SIMD3<Float>(columns.2[0], columns.2[1], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(0, columns.0[1], columns.0[2]),
                                      SIMD3<Float>(0, 0, columns.1[2]),
                                      SIMD3<Float>(0, 0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(columns.0[0], 0, 0),
                                      SIMD3<Float>(columns.1[0], columns.1[1], 0),
                                      SIMD3<Float>(columns.2[0], columns.2[1], columns.2[2])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(columns.0[0], columns.0[1], columns.0[2]),
                                      SIMD3<Float>(0, columns.1[1], columns.1[2]),
                                      SIMD3<Float>(0, 0, columns.2[2])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Float{
        return sqrt(length_squared(columns.0)
            + length_squared(columns.1)
            + length_squared(columns.2))
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(axis:SIMD3<Float>, rad:Float)->matrix_float3x3{
        return matrix_float3x3(rows: [SIMD3<Float>(1 + (1 - cos(rad)) * (axis.x * axis.x - 1),
                                                   -axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                                                   axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z),
                                      SIMD3<Float>(axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                                                   1 + (1 - cos(rad)) * (axis.y * axis.y - 1),
                                                   -axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z),
                                      SIMD3<Float>(-axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z,
                                                   axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z,
                                                   1 + (1 - cos(rad)) * (axis.z * axis.z - 1))])
    }
}

extension matrix_double3x3 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    var isSquare:Bool {
        return true
    }
    
    /// Returns number of rows of this matrix.
    var rows:size_t {
        return 3
    }
    
    /// Returns number of columns of this matrix.
    var cols:size_t {
        return 3
    }
    
    // MARK:- Complex getters
    /// Returns sum of all elements.
    var sum:Double {
        return reduce_add(columns.0)
            + reduce_add(columns.1)
            + reduce_add(columns.2)
    }
    
    /// Returns average of all elements.
    /// - Returns: average
    var avg:Double {
        return sum/9
    }
    
    /// Returns minimum among all elements.
    var min:Double {
        return Swift.min(Swift.min(reduce_min(columns.0),
                                   reduce_min(columns.1)),
                         reduce_min(columns.1))
    }
    
    /// Returns maximum among all elements.
    var max:Double {
        return Swift.max(Swift.max(reduce_max(columns.0),
                                   reduce_max(columns.1)),
                         reduce_max(columns.2))
    }
    
    /// Returns absolute minimum among all elements.
    var absmin:Double{
        let min = [Math.absminn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absminn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absminn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absminn(x: min)
    }
    
    /// Returns absolute maximum among all elements.
    var absmax:Double{
        let max = [Math.absmaxn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absmaxn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absmaxn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absmaxn(x: max)
    }
    
    /// Returns sum of all diagonal elements.
    var trace:Double{
        return columns.0[0] + columns.1[1] + columns.2[2]
    }
    
    /// Returns diagonal part of this matrix.
    var diagonal:matrix_double3x3{
        return matrix_double3x3(diagonal: SIMD3<Double>(columns.0[0],
                                                        columns.1[1],
                                                        columns.2[2]))
    }
    
    /// Returns off-diagonal part of this matrix.
    var offDiagonal:matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(0, columns.0[1], columns.0[2]),
                                       SIMD3<Double>(columns.1[0], 0, columns.1[2]),
                                       SIMD3<Double>(columns.2[0], columns.2[1], 0)])
    }
    
    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri:matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(0, 0, 0),
                                       SIMD3<Double>(columns.1[0], 0, 0),
                                       SIMD3<Double>(columns.2[0], columns.2[1], 0)])
    }
    
    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri:matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(0, columns.0[1], columns.0[2]),
                                       SIMD3<Double>(0, 0, columns.1[2]),
                                       SIMD3<Double>(0, 0, 0)])
    }
    
    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri:matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(columns.0[0], 0, 0),
                                       SIMD3<Double>(columns.1[0], columns.1[1], 0),
                                       SIMD3<Double>(columns.2[0], columns.2[1], columns.2[2])])
    }
    
    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri:matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(columns.0[0], columns.0[1], columns.0[2]),
                                       SIMD3<Double>(0, columns.1[1], columns.1[2]),
                                       SIMD3<Double>(0, 0, columns.2[2])])
    }
    
    /// Returns Frobenius norm.
    var frobeniusNorm:Double{
        return sqrt(length_squared(columns.0)
            + length_squared(columns.1)
            + length_squared(columns.2))
    }
    
    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(axis:SIMD3<Double>, rad:Double)->matrix_double3x3{
        return matrix_double3x3(rows: [SIMD3<Double>(1 + (1 - cos(rad)) * (axis.x * axis.x - 1),
                                                     -axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                                                     axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z),
                                       SIMD3<Double>(axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                                                     1 + (1 - cos(rad)) * (axis.y * axis.y - 1),
                                                     -axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z),
                                       SIMD3<Double>(-axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z,
                                                     axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z,
                                                     1 + (1 - cos(rad)) * (axis.z * axis.z - 1))])
    }
}
