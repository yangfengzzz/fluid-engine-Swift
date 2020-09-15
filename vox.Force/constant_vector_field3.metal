//
//  constant_vector_field3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_CONSTANT_VECTOR_FIELD3_METAL_
#define INCLUDE_VOX_CONSTANT_VECTOR_FIELD3_METAL_

#include <metal_stdlib>
using namespace metal;

//MARK: ConstantVectorField3
/// 3-D constant vector field.
class ConstantVectorField3 {
public:
    class Builder;
    
    /// Constructs a constant vector field with given \p value.
    explicit ConstantVectorField3(const float3 value);
    
    /// Returns the sampled value at given position \p x.
    float3 sample(const float3 x) const;
    
    /// Returns divergence at given position \p x.
    float divergence(const float3 x) const;
    
    /// Returns curl at given position \p x.
    float3 curl(const float3 x) const;
    
    /// Returns builder fox ConstantVectorField3.
    static Builder builder();
    
private:
    float3 _value;
};

//MARK: ConstantVectorField3::Builder
///
/// \brief Front-end to create ConstantVectorField3 objects step by step.
///
class ConstantVectorField3::Builder {
public:
    /// Returns builder with value.
    thread Builder& withValue(const float3 value);
    
    /// Builds ConstantVectorField3.
    ConstantVectorField3 build() const;
    
private:
    float3 _value = float3(0, 0, 0);
};

#endif  // INCLUDE_VOX_CONSTANT_VECTOR_FIELD3_METAL_
