//
//  constant_scalar_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D constant scalar field.
class ConstantScalarField2: ScalarField2 {
    var _value:Float = 0
    
    /// Constructs a constant scalar field with given \p value.
    init(value:Float) {
        self._value = value
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector2F) -> Float {
        return _value
    }
    
    //MARK:- Builder
    /// Front-end to create ConstantScalarField2 objects step by step.
    class Builder {
        var _value:Float = 0
        
        /// Returns builder with value.
        func withValue(value:Float)->Builder {
            _value = value
            return self
        }
        
        /// Builds ConstantScalarField2.
        func build()->ConstantScalarField2 {
            return ConstantScalarField2(value: _value)
        }
    }
    
    /// Returns builder fox ConstantScalarField2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension ConstantScalarField2 {
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
