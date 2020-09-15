//
//  size2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

extension SIMD2 where Scalar:BinaryInteger{
    /// Returns the index of the dominant axis.
    /// - Returns: index
    var dominantAxis:size_t{
        return (x > y) ? 0 : 1
    }
    
    /// Returns the index of the subminant axis.
    /// - Returns: index
    var subminantAxis:size_t{
        return (x < y) ? 0 : 1
    }
}

extension SIMD2 : ZeroInit {
    func getKernelType()->KernelType {
        if Scalar.self == Float.self {
            return .float2
        } else {
            return .unsupported
        }
    }
}

typealias Size2 = SIMD2<size_t>
typealias Point2I = SIMD2<ssize_t>
typealias Point2UI = SIMD2<size_t>
