//
//  vector4.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension SIMD4 where Scalar:BinaryFloatingPoint{
    /// Returns true if \p other is the same as this vector.
    func isEqual(other:SIMD4)->Bool {
        return x == other.x && y == other.y && z == other.z && w == other.w
    }
    
    /// Returns true if \p other is similar to this vector.
    /// - Parameters:
    ///   - other: similar vector
    ///   - epsilon: tolerance
    /// - Returns: isSimilar
    func isSimilar(other:SIMD4, epsilon:Scalar = Scalar.leastNonzeroMagnitude)->Bool{
        return (abs(x - other.x) < epsilon) &&
            (abs(y - other.y) < epsilon) &&
            (abs(z - other.z) < epsilon) &&
            (abs(w - other.w) < epsilon)
    }
    
    /// Returns the index of the dominant axis.
    /// - Returns: index
    var dominantAxis:size_t{
        return (abs(x) > abs(y))
            ? ((abs(x) > abs(z))
                ? ((abs(x) > abs(w)) ? 0 : 3)
                : ((abs(z) > abs(w)) ? 2 : 3))
            : ((abs(y) > abs(z))
                ? ((abs(y) > abs(w)) ? 1 : 3)
                : ((abs(z) > abs(w)) ? 2 : 3))
    }
    
    /// Returns the index of the subminant axis.
    /// - Returns: index
    var subminantAxis:size_t{
        return (abs(x) < abs(y))
            ? ((abs(x) < abs(z))
                ? ((abs(x) < abs(w)) ? 0 : 3)
                : ((abs(z) < abs(w)) ? 2 : 3))
            : ((abs(y) < abs(z))
                ? ((abs(y) < abs(w)) ? 1 : 3)
                : ((abs(z) < abs(w)) ? 2 : 3))
    }
}

extension SIMD4 : ZeroInit {
    func getKernelType()->KernelType {
        if Scalar.self == Float.self {
            return .float4
        } else {
            return .unsupported
        }
    }
}

//MARK:- Float Extension
extension SIMD4 where Scalar == Float {
    // MARK:- Basic setters
    /// Normalizes this vector.
    mutating func normalized(){
        let l:Scalar = length(self)
        x /= l
        y /= l
        z /= l
        w /= l
    }
    
    // MARK:- Basic getters
    /// Returns the absolute minimum value among x and y.
    /// - Returns: absolute minimum of components
    var absmin:Scalar{
        return Math.absmin(between:Math.absmin(between: x, and: y),
                           and:Math.absmin(between: z, and: w))
    }
    
    /// Returns the absolute maximum value among x and y.
    /// - Returns: absolute maximum of components
    var absmax:Scalar{
        return Math.absmax(between:Math.absmax(between: x, and: y),
                           and:Math.absmax(between: z, and: w))
    }
    
    /// Returns the average of all the components.
    /// - Returns: average
    var avg:Scalar{
        return (x + y + z + w) / 4
    }
}

//MARK:- Double Extension
extension SIMD4 where Scalar == Double {
    // MARK:- Basic setters
    /// Normalizes this vector.
    mutating func normalized(){
        let l:Scalar = length(self)
        x /= l
        y /= l
        z /= l
        w /= l
    }
    
    // MARK:- Basic getters
    /// Returns the absolute minimum value among x and y.
    /// - Returns: absolute minimum of components
    var absmin:Scalar{
        return Math.absmin(between:Math.absmin(between: x, and: y),
                           and:Math.absmin(between: z, and: w))
    }
    
    /// Returns the absolute maximum value among x and y.
    /// - Returns: absolute maximum of components
    var absmax:Scalar{
        return Math.absmax(between:Math.absmax(between: x, and: y),
                           and:Math.absmax(between: z, and: w))
    }
    
    /// Returns the average of all the components.
    /// - Returns: average
    var avg:Scalar{
        return (x + y + z + w) / 4
    }
}

// MARK:- Utility Extensions
func monotonicCatmullRom(v0:SIMD4<Float>, v1:SIMD4<Float>,
                         v2:SIMD4<Float>, v3:SIMD4<Float>, f:Float)->SIMD4<Float>{
    let two:Float = 2
    let three:Float = 3
    
    var d1 = (v2 - v0) / two
    var d2 = (v3 - v1) / two
    let D1 = v2 - v1
    
    if (abs(D1.x) < Float.leastNonzeroMagnitude ||
        sign(D1.x) != sign(d1.x) ||
        sign(D1.x) != sign(d2.x)) {
        d1.x = 0
        d2.x = 0
    }
    
    if (abs(D1.y) < Float.leastNonzeroMagnitude ||
        sign(D1.y) != sign(d1.y) ||
        sign(D1.y) != sign(d2.y)) {
        d1.y = 0
        d2.y = 0
    }
    
    if (abs(D1.z) < Float.leastNonzeroMagnitude ||
        sign(D1.z) != sign(d1.z) ||
        sign(D1.z) != sign(d2.z)) {
        d1.z = 0
        d2.z = 0
    }
    
    if (abs(D1.w) < Float.leastNonzeroMagnitude ||
        sign(D1.w) != sign(d1.w) ||
        sign(D1.w) != sign(d2.w)) {
        d1.w = 0
        d2.w = 0
    }
    
    let a3 = d1 + d2 - two * D1
    let a2 = three * D1 - two * d1 - d2
    let a1 = d1
    let a0 = v1
    
    var result = a3 * Math.cubic(of:f)
    result += a2 * Math.square(of:f)
    result += a1 * f + a0
    
    return result
}

func monotonicCatmullRom(v0:SIMD4<Double>, v1:SIMD4<Double>,
                         v2:SIMD4<Double>, v3:SIMD4<Double>, f:Double)->SIMD4<Double>{
    let two:Double = 2
    let three:Double = 3
    
    var d1 = (v2 - v0) / two
    var d2 = (v3 - v1) / two
    let D1 = v2 - v1
    
    if (abs(D1.x) < Double.leastNonzeroMagnitude ||
        sign(D1.x) != sign(d1.x) ||
        sign(D1.x) != sign(d2.x)) {
        d1.x = 0
        d2.x = 0
    }
    
    if (abs(D1.y) < Double.leastNonzeroMagnitude ||
        sign(D1.y) != sign(d1.y) ||
        sign(D1.y) != sign(d2.y)) {
        d1.y = 0
        d2.y = 0
    }
    
    if (abs(D1.z) < Double.leastNonzeroMagnitude ||
        sign(D1.z) != sign(d1.z) ||
        sign(D1.z) != sign(d2.z)) {
        d1.z = 0
        d2.z = 0
    }
    
    if (abs(D1.w) < Double.leastNonzeroMagnitude ||
        sign(D1.w) != sign(d1.w) ||
        sign(D1.w) != sign(d2.w)) {
        d1.w = 0
        d2.w = 0
    }
    
    let a3 = d1 + d2 - two * D1
    let a2 = three * D1 - two * d1 - d2
    let a1 = d1
    let a0 = v1
    
    var result = a3 * Math.cubic(of:f)
    result += a2 * Math.square(of:f)
    result += a1 * f + a0
    
    return result
}

typealias Vector4 = SIMD4
typealias Vector4F = SIMD4<Float>
typealias Vector4D = SIMD4<Double>
