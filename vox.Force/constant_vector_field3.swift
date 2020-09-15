//
//  constant_vector_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D constant vector field.
class ConstantVectorField3: VectorField3 {
    var _value:Vector3F
    
    /// Constructs a constant vector field with given \p value.
    init(value:Vector3F) {
        self._value = value
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector3F)->Vector3F {
        return _value
    }
    
    //MARK:- Builder
    /// Front-end to create ConstantVectorField3 objects step by step.
    class Builder {
        var _value:Vector3F = Vector3F(0, 0, 0)
        
        /// Returns builder with value.
        func withValue(value:Vector3F)->Builder {
            _value = value
            return self
        }
        
        /// Builds ConstantVectorField3.
        func build()->ConstantVectorField3 {
            return ConstantVectorField3(value: _value)
        }
    }
    
    /// Returns builder fox ConstantVectorField3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension ConstantVectorField3 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBytes(&_value, length: MemoryLayout<Vector3F>.stride, index: index_begin)
        return index_begin + 1
    }
}
