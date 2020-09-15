//
//  constant_scalar_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D constant scalar field.
class ConstantScalarField3: ScalarField3 {
    var _value:Float = 0
    
    /// Constructs a constant scalar field with given \p value.
    init(value:Float) {
        self._value = value
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector3F) -> Float {
        return _value
    }
    
    //MARK:- Builder
    /// Front-end to create ConstantScalarField3 objects step by step.
    class Builder {
        var _value:Float = 0
        
        /// Returns builder with value.
        func withValue(value:Float)->Builder {
            _value = value
            return self
        }
        
        /// Builds ConstantScalarField3.
        func build()->ConstantScalarField3 {
            return ConstantScalarField3(value: _value)
        }
    }
    
    /// Returns builder fox ConstantScalarField3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension ConstantScalarField3 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBytes(&_value, length: MemoryLayout<Float>.stride, index: index_begin)
        return index_begin + 1
    }
}
