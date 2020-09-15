//
//  point3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension SIMD3 where Scalar:BinaryFloatingPoint{
    /// Returns the index of the dominant axis.
    /// - Returns: index
    var dominantAxis:size_t{
        return (abs(x) > abs(y))
            ? ((abs(x) > abs(z)) ? 0 : 2)
            : ((abs(y) > abs(z)) ? 1 : 2)
    }
    
    /// Returns the index of the subminant axis.
    /// - Returns: index
    var subminantAxis:size_t{
        return (abs(x) < abs(y))
            ? ((abs(x) < abs(z)) ? 0 : 2)
            : ((abs(y) < abs(z)) ? 1 : 2)
    }
}

//MARK:- Float Extension
extension SIMD3 where Scalar == Float {
    /// Returns the absolute minimum value among x and y.
    /// - Returns: absolute minimum of components
    var absmin:Float{
        return Math.absmin(between:Math.absmin(between: x, and: y),
                           and:z)
    }
    
    /// Returns the absolute maximum value among x and y.
    /// - Returns: absolute maximum of components
    var absmax:Float{
        return Math.absmax(between:Math.absmax(between: x, and: y),
                           and:z)
    }
}

//MARK:- Double Extension
extension SIMD3 where Scalar == Double {
    /// Returns the absolute minimum value among x and y.
    /// - Returns: absolute minimum of components
    var absmin:Double{
        return Math.absmin(between:Math.absmin(between: x, and: y),
                           and:z)
    }
    
    /// Returns the absolute maximum value among x and y.
    /// - Returns: absolute maximum of components
    var absmax:Double{
        return Math.absmax(between:Math.absmax(between: x, and: y),
                           and:z)
    }
}

typealias Point3F = SIMD3<Float>
typealias Point3D = SIMD3<Double>
