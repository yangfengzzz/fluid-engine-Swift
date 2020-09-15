//
//  math_utils.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation


/// math utility namespace
enum Math {
    //MARK:- similar
    /// Returns true if \p x and \p y are similar.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    ///   - eps: The tolerance.
    /// - Returns: True if similar.
    static func similar(x:Float, y:Float,
                        eps:Float = Float.leastNonzeroMagnitude )->Bool{
        return (abs(x - y) <= eps)
    }
    
    /// Returns true if \p x and \p y are similar.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    ///   - eps: The tolerance.
    /// - Returns: True if similar.
    static func similar(x:Double, y:Double,
                        eps:Double = Double.leastNonzeroMagnitude )->Bool{
        return (abs(x - y) <= eps)
    }
    
    //MARK:- absmin absmax
    /// Returns the absolute minimum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The absolute minimum.
    static func absmin(between x:Float, and y:Float)->Float{
        return (x*x < y*y) ? x : y
    }
    
    /// Returns the absolute minimum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The absolute minimum.
    static func absmin(between x:Double, and y:Double)->Double{
        return (x*x < y*y) ? x : y
    }
    
    /// Returns the absolute maximum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The absolute maximum.
    static func absmax(between x:Float, and y:Float)->Float{
        return (x*x > y*y) ? x : y
    }
    
    /// Returns the absolute maximum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The absolute maximum.
    static func absmax(between x:Double, and y:Double)->Double{
        return (x*x > y*y) ? x : y
    }
    
    /// Returns absolute minimum among n-elements.
    /// - Parameter x: The array value.
    /// - Returns: The absolute minimum.
    static func absminn(x:[Float])->Float{
        return x.reduce(0){absmin(between: $0, and: $1) }
    }
    
    /// Returns absolute minimum among n-elements.
    /// - Parameter x: The array value.
    /// - Returns: The absolute minimum.
    static func absminn(x:[Double])->Double{
        return x.reduce(0){absmin(between: $0, and: $1) }
    }
    
    /// Returns absolute maximum among n-elements.
    /// - Parameter x: The array value.
    /// - Returns: The absolute maximum.
    static func absmaxn(x:[Float])->Float{
        return x.reduce(0){absmax(between: $0, and: $1) }
    }
    
    /// Returns absolute maximum among n-elements.
    /// - Parameter x: The array value.
    /// - Returns: The absolute maximum.
    static func absmaxn(x:[Double])->Double{
        return x.reduce(0){absmax(between: $0, and: $1) }
    }
    
    //MARK:- argmin argmax
    /// Returns the index of minimum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The index of minimum
    static func argmin2<T:Comparable>(x:T, y:T)->UInt{
        return (x < y) ? 0 : 1
    }
    
    /// Returns the index of maximum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    /// - Returns: The index of maximum
    static func argmax2<T:Comparable>(x:T, y:T)->UInt{
        return (x > y) ? 0 : 1
    }
    
    /// Returns the index of minimum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    ///   - z: The third value.
    /// - Returns: The index of minimum
    static func argmin3<T:Comparable>(x:T, y:T, z:T)->UInt{
        if (x < y) {
            return (x < z) ? 0 : 2
        } else {
            return (y < z) ? 1 : 2
        }
    }
    
    /// Returns the index of maximum value among the two inputs.
    /// - Parameters:
    ///   - x: The first value.
    ///   - y: The second value.
    ///   - z: The third value.
    /// - Returns: The index of maximum
    static func argmax3<T:Comparable>(x:T, y:T, z:T)->UInt{
        if (x > y) {
            return (x > z) ? 0 : 2
        } else {
            return (y > z) ? 1 : 2
        }
    }
    
    //MARK:- square
    /// Returns the square of \p x.
    /// - Parameter x: The input.
    /// - Returns: The squared value.
    static func square(of x:Float)->Float{
        return x * x
    }
    
    /// Returns the square of \p x.
    /// - Parameter x: The input.
    /// - Returns: The squared value.
    static func square(of x:Double)->Double{
        return x * x
    }
    
    //MARK:- cubic
    /// Returns the cubic of \p x.
    /// - Parameter x: The input.
    /// - Returns: The cubic of \p x.
    static func cubic(of x:Float)->Float{
        return x * x * x
    }
    
    /// Returns the cubic of \p x.
    /// - Parameter x: The input.
    /// - Returns: The cubic of \p x.
    static func cubic(of x:Double)->Double{
        return x * x * x
    }
    
    //MARK:- clamp
    /// Returns the clamped value.
    /// - Parameters:
    ///   - val: The value.
    ///   - low: The low value.
    ///   - high: The high value.
    /// - Returns: The clamped value.
    static func clamp<T:Comparable>(val:T, low:T, high:T)->T{
        if (val < low) {
            return low
        } else if (val > high) {
            return high
        } else {
            return val
        }
    }
    
    //MARK:- degreesToRadians
    /// Converts degrees to radians.
    /// - Parameter angleInDegrees: The angle in degrees.
    /// - Returns: Angle in radians.
    static func degreesToRadians(angleInDegrees:Double)->Double{
        return angleInDegrees * pi() / 180.0
    }
    
    /// Converts degrees to radians.
    /// - Parameter angleInDegrees: The angle in degrees.
    /// - Returns: Angle in radians.
    static func degreesToRadians(angleInDegrees:Float)->Float{
        return angleInDegrees * pi() / 180.0
    }
    
    //MARK:- radiansToDegrees
    /// Converts radians to degrees.
    /// - Parameter angleInRadians: The angle in radians.
    /// - Returns: Angle in degrees.
    static func radiansToDegrees(angleInRadians:Double)->Double{
        return angleInRadians * 180.0 / pi()
    }
    
    /// Converts radians to degrees.
    /// - Parameter angleInRadians: The angle in radians.
    /// - Returns: Angle in degrees.
    static func radiansToDegrees(angleInRadians:Float)->Float{
        return angleInRadians * 180.0 / pi()
    }
    
    //MARK:- getBarycentric
    /// Gets the barycentric coordinate.
    /// - Parameters:
    ///   - x: The input value.
    ///   - iLow: The lowest index.
    ///   - iHigh: The highest index.
    ///   - i: The output index.
    ///   - t: The offset from \p i.
    /// - Returns: Value type.
    static func getBarycentric(x:Float, iLow:ssize_t, iHigh:ssize_t,
                               i: inout ssize_t, f: inout Float){
        let s:Float = floor(x)
        i = ssize_t(s)
        
        let offset:ssize_t = -iLow
        let imin = iLow + offset
        let imax = iHigh + offset
        
        if (imin == imax) {
            i = imin
            f = 0
        } else if (i < imin) {
            i = imin
            f = 0
        } else if (i > imax - 1) {
            i = imax - 1
            f = 1
        } else {
            f = Float(x - s)
        }
        
        i -= offset
    }
    
    /// Gets the barycentric coordinate.
    /// - Parameters:
    ///   - x: The input value.
    ///   - iLow: The lowest index.
    ///   - iHigh: The highest index.
    ///   - i: The output index.
    ///   - t: The offset from \p i.
    /// - Returns: Value type.
    static func getBarycentric(x:Double, iLow:ssize_t, iHigh:ssize_t,
                               i: inout ssize_t, f: inout Double){
        let s:Double = floor(x)
        i = ssize_t(s)
        
        let offset:ssize_t = -iLow
        let imin = iLow + offset
        let imax = iHigh + offset
        
        if (imin == imax) {
            i = imin
            f = 0
        } else if (i < imin) {
            i = imin
            f = 0
        } else if (i > imax - 1) {
            i = imax - 1
            f = 1
        } else {
            f = Double(x - s)
        }
        
        i -= offset
    }
    
    //MARK:- catmullRom
    /// Computes Catmull-Rom interpolation.
    static func catmullRom(f0:Float,
                           f1:Float,
                           f2:Float,
                           f3:Float,
                           f:Float)->Float{
        let d1 = (f2 - f0) / 2
        let d2 = (f3 - f1) / 2
        let D1 = f2 - f1
        
        let a3 = d1 + d2 - 2 * D1
        let a2 = 3 * D1 - 2 * d1 - d2
        let a1 = d1
        let a0 = f1
        
        return a3 * cubic(of: f) + a2 * square(of: f) + a1 * f + a0
    }
    
    /// Computes Catmull-Rom interpolation.
    static func catmullRom(f0:Double,
                           f1:Double,
                           f2:Double,
                           f3:Double,
                           f:Double)->Double{
        let d1 = (f2 - f0) / 2
        let d2 = (f3 - f1) / 2
        let D1 = f2 - f1
        
        let a3 = d1 + d2 - 2 * D1
        let a2 = 3 * D1 - 2 * d1 - d2
        let a1 = d1
        let a0 = f1
        
        return a3 * cubic(of: f) + a2 * square(of: f) + a1 * f + a0
    }
    
    //MARK:- monotonicCatmullRom
    /// Computes monotonic Catmull-Rom interpolation.
    static func monotonicCatmullRom(f0:Float,
                                    f1:Float,
                                    f2:Float,
                                    f3:Float,
                                    f:Float) ->Float{
        var d1 = (f2 - f0) / 2
        var d2 = (f3 - f1) / 2
        let D1 = f2 - f1
        
        if (abs(D1) < Float.leastNonzeroMagnitude) {
            d1 = 0
            d2 = 0
        }
        
        if (sign(D1) != sign(d1)) {
            d1 = 0
        }
        
        if (sign(D1) != sign(d2)) {
            d2 = 0
        }
        
        let a3 = d1 + d2 - 2 * D1
        let a2 = 3 * D1 - 2 * d1 - d2
        let a1 = d1
        let a0 = f1
        
        return a3 * cubic(of: f) + a2 * square(of: f) + a1 * f + a0
    }
    
    /// Computes monotonic Catmull-Rom interpolation.
    static func monotonicCatmullRom(f0:Double,
                                    f1:Double,
                                    f2:Double,
                                    f3:Double,
                                    f:Double) ->Double{
        var d1 = (f2 - f0) / 2
        var d2 = (f3 - f1) / 2
        let D1 = f2 - f1
        
        if (abs(D1) < Double.leastNonzeroMagnitude) {
            d1 = 0
            d2 = 0
        }
        
        if (sign(D1) != sign(d1)) {
            d1 = 0
        }
        
        if (sign(D1) != sign(d2)) {
            d2 = 0
        }
        
        let a3 = d1 + d2 - 2 * D1
        let a2 = 3 * D1 - 2 * d1 - d2
        let a1 = d1
        let a0 = f1
        
        return a3 * cubic(of: f) + a2 * square(of: f) + a1 * f + a0
    }
}

//MARK:- lerp
extension Math{
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:Float, value1:Float, f:Float)->Float{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:Double, value1:Double, f:Double)->Double{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD2<Float>, value1:SIMD2<Float>,
                     f:Float)->SIMD2<Float>{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD2<Double>, value1:SIMD2<Double>,
                     f:Double)->SIMD2<Double>{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD3<Float>, value1:SIMD3<Float>,
                     f:Float)->SIMD3<Float>{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD3<Double>, value1:SIMD3<Double>,
                     f:Double)->SIMD3<Double>{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD4<Float>, value1:SIMD4<Float>,
                     f:Float)->SIMD4<Float>{
        return (1 - f) * value0 + f * value1
    }
    
    ///  Computes linear interpolation.
    /// - Parameters:
    ///   - value0: The first value.
    ///   - value1: The second value.
    ///   - f: Relative offset [0, 1] from the first value.
    /// - Returns: The interpolated value.
    static func lerp(value0:SIMD4<Double>, value1:SIMD4<Double>,
                     f:Double)->SIMD4<Double>{
        return (1 - f) * value0 + f * value1
    }
}

//MARK:- bilerp
extension Math{
    /// Computes bilinear interpolation.
    static func bilerp(f00:Float, f10:Float,
                       f01:Float, f11:Float,
                       tx:Float, ty:Float)->Float{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:Double, f10:Double,
                       f01:Double, f11:Double,
                       tx:Double, ty:Double)->Double{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD2<Float>, f10:SIMD2<Float>,
                       f01:SIMD2<Float>, f11:SIMD2<Float>,
                       tx:Float, ty:Float)->SIMD2<Float>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD2<Double>, f10:SIMD2<Double>,
                       f01:SIMD2<Double>, f11:SIMD2<Double>,
                       tx:Double, ty:Double)->SIMD2<Double>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD3<Float>, f10:SIMD3<Float>,
                       f01:SIMD3<Float>, f11:SIMD3<Float>,
                       tx:Float, ty:Float)->SIMD3<Float>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD3<Double>, f10:SIMD3<Double>,
                       f01:SIMD3<Double>, f11:SIMD3<Double>,
                       tx:Double, ty:Double)->SIMD3<Double>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD4<Float>, f10:SIMD4<Float>,
                       f01:SIMD4<Float>, f11:SIMD4<Float>,
                       tx:Float, ty:Float)->SIMD4<Float>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
    
    /// Computes bilinear interpolation.
    static func bilerp(f00:SIMD4<Double>, f10:SIMD4<Double>,
                       f01:SIMD4<Double>, f11:SIMD4<Double>,
                       tx:Double, ty:Double)->SIMD4<Double>{
        return lerp(value0: lerp(value0: f00, value1: f10, f: tx),
                    value1: lerp(value0: f01, value1: f11, f: tx),
                    f: ty)
    }
}

//MARK:- trilerp
extension Math{
    /// Computes trilinear interpolation.
    static func trilerp(f000:Float, f100:Float, f010:Float, f110:Float,
                        f001:Float, f101:Float, f011:Float, f111:Float,
                        tx:Float, ty:Float, fz:Float)->Float{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:Double, f100:Double, f010:Double, f110:Double,
                        f001:Double, f101:Double, f011:Double, f111:Double,
                        tx:Double, ty:Double, fz:Double)->Double{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD2<Float>, f100:SIMD2<Float>,
                        f010:SIMD2<Float>, f110:SIMD2<Float>,
                        f001:SIMD2<Float>, f101:SIMD2<Float>,
                        f011:SIMD2<Float>, f111:SIMD2<Float>,
                        tx:Float, ty:Float, fz:Float)->SIMD2<Float>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD2<Double>, f100:SIMD2<Double>,
                        f010:SIMD2<Double>, f110:SIMD2<Double>,
                        f001:SIMD2<Double>, f101:SIMD2<Double>,
                        f011:SIMD2<Double>, f111:SIMD2<Double>,
                        tx:Double, ty:Double, fz:Double)->SIMD2<Double>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD3<Float>, f100:SIMD3<Float>,
                        f010:SIMD3<Float>, f110:SIMD3<Float>,
                        f001:SIMD3<Float>, f101:SIMD3<Float>,
                        f011:SIMD3<Float>, f111:SIMD3<Float>,
                        tx:Float, ty:Float, fz:Float)->SIMD3<Float>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD3<Double>, f100:SIMD3<Double>,
                        f010:SIMD3<Double>, f110:SIMD3<Double>,
                        f001:SIMD3<Double>, f101:SIMD3<Double>,
                        f011:SIMD3<Double>, f111:SIMD3<Double>,
                        tx:Double, ty:Double, fz:Double)->SIMD3<Double>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD4<Float>, f100:SIMD4<Float>,
                        f010:SIMD4<Float>, f110:SIMD4<Float>,
                        f001:SIMD4<Float>, f101:SIMD4<Float>,
                        f011:SIMD4<Float>, f111:SIMD4<Float>,
                        tx:Float, ty:Float, fz:Float)->SIMD4<Float>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
    
    /// Computes trilinear interpolation.
    static func trilerp(f000:SIMD4<Double>, f100:SIMD4<Double>,
                        f010:SIMD4<Double>, f110:SIMD4<Double>,
                        f001:SIMD4<Double>, f101:SIMD4<Double>,
                        f011:SIMD4<Double>, f111:SIMD4<Double>,
                        tx:Double, ty:Double, fz:Double)->SIMD4<Double>{
        return lerp(value0: bilerp(f00: f000, f10: f100, f01: f010, f11: f110, tx: tx, ty: ty),
                    value1: bilerp(f00: f001, f10: f101, f01: f011, f11: f111, tx: tx, ty: ty),
                    f: fz)
    }
}
