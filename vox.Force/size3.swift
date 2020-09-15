//
//  size3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension SIMD3 where Scalar:BinaryInteger{
    /// Returns the index of the dominant axis.
    /// - Returns: index
    var dominantAxis:size_t{
        return (x > y) ? ((x > z) ? 0 : 2) : ((y > z) ? 1 : 2)
    }
    
    /// Returns the index of the subminant axis.
    /// - Returns: index
    var subminantAxis:size_t{
        return (x < y) ? ((x < z) ? 0 : 2) : ((y < z) ? 1 : 2)
    }
}

extension SIMD3 : ZeroInit {
    func getKernelType()->KernelType {
        if Scalar.self == Float.self {
            return .float3
        } else {
            return .unsupported
        }
    }
}

typealias Size3 = SIMD3<size_t>
typealias Point3I = SIMD3<ssize_t>
typealias Point3UI = SIMD3<size_t>
