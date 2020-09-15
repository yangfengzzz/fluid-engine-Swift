//
//  constant_vector_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D constant vector field.
class ConstantVectorField2: VectorField2 {
    var _value:Vector2F
    
    /// Constructs a constant vector field with given \p value.
    init(value:Vector2F) {
        self._value = value
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector2F)->Vector2F {
        return _value
    }
    
    //MARK:- Builder
    /// Front-end to create ConstantVectorField2 objects step by step.
    class Builder {
        var _value:Vector2F = Vector2F(0, 0)
        
        /// Returns builder with value.
        func withValue(value:Vector2F)->Builder {
            _value = value
            return self
        }
        
        /// Builds ConstantVectorField2.
        func build()->ConstantVectorField2 {
            return ConstantVectorField2(value: _value)
        }
    }
    
    /// Returns builder fox ConstantVectorField2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension ConstantVectorField2 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBytes(&_value, length: MemoryLayout<Vector2F>.stride, index: index_begin)
        return index_begin + 1
    }
}
