//
//  vector2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension SIMD2 where Scalar:BinaryFloatingPoint{
    /// Returns true if \p other is the same as this vector.
    func isEqual(other:SIMD2)->Bool {
        return x == other.x && y == other.y
    }
    
    /// Returns true if \p other is similar to this vector.
    /// - Parameters:
    ///   - other: similar vector
    ///   - epsilon: tolerance
    /// - Returns: isSimilar
    func isSimilar(other:SIMD2, epsilon:Scalar = Scalar.leastNonzeroMagnitude)->Bool{
        return (abs(x - other.x) < epsilon) &&
            (abs(y - other.y) < epsilon)
    }
}

//MARK:- Float Extension
extension SIMD2 where Scalar == Float {
    // MARK:- Basic setters
    /// Normalizes this vector.
    mutating func normalized(){
        let l:Scalar = length(self)
        x /= l
        y /= l
    }
    
    // MARK:- Basic getters
    /// Returns the average of all the components.
    /// - Returns: average
    var avg:Scalar{
        return (x + y) / 2
    }
    
    /// Returns the reflection vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: reflection vector
    func reflected(with normal:SIMD2)->SIMD2{
        return self - 2*normal*(dot(self, normal))
    }
    
    /// Returns the projected vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: projected vector
    func projected(with normal:SIMD2)->SIMD2{
        return self - normal*(dot(self, normal))
    }
    
    /// Returns the tangential vector for this vector.
    /// - Returns: tangential vector
    var tangential:SIMD2{
        return SIMD2(-y, x)
    }
}

//MARK:- Double Extension
extension SIMD2 where Scalar == Double{
    // MARK:- Basic setters
    /// Normalizes this vector.
    mutating func normalize(){
        let l:Scalar = length(self)
        x /= l
        y /= l
    }
    
    // MARK:- Basic getters
    /// Returns the average of all the components.
    /// - Returns: average
    var avg:Scalar{
        return (x + y) / 2
    }
    
    /// Returns the reflection vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: reflection vector
    func reflected(with normal:SIMD2)->SIMD2{
        return self - 2*normal*(dot(self, normal))
    }
    
    /// Returns the projected vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: projected vector
    func projected(with normal:SIMD2)->SIMD2{
        return self - normal*(dot(self, normal))
    }
    
    /// Returns the tangential vector for this vector.
    /// - Returns: tangential vector
    var tangential:SIMD2{
        return SIMD2(-y, x)
    }
}

// MARK:- Utility Extensions
func monotonicCatmullRom(v0:SIMD2<Float>, v1:SIMD2<Float>,
                         v2:SIMD2<Float>, v3:SIMD2<Float>, f:Float)->SIMD2<Float>{
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
    
    let a3 = d1 + d2 - two * D1
    let a2 = three * D1 - two * d1 - d2
    let a1 = d1
    let a0 = v1
    
    var result = a3 * Math.cubic(of:f)
    result += a2 * Math.square(of:f)
    result += a1 * f + a0
    
    return result
}

func monotonicCatmullRom(v0:SIMD2<Double>, v1:SIMD2<Double>,
                         v2:SIMD2<Double>, v3:SIMD2<Double>, f:Double)->SIMD2<Double>{
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
    
    let a3 = d1 + d2 - two * D1
    let a2 = three * D1 - two * d1 - d2
    let a1 = d1
    let a0 = v1
    
    var result = a3 * Math.cubic(of:f)
    result += a2 * Math.square(of:f)
    result += a1 * f + a0
    
    return result
}

typealias Vector2 = SIMD2
typealias Vector2F = SIMD2<Float>
typealias Vector2D = SIMD2<Double>
