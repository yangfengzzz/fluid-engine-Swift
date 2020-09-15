//
//  constant_vector_field2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_CONSTANT_VECTOR_FIELD2_METAL_
#define INCLUDE_VOX_CONSTANT_VECTOR_FIELD2_METAL_

#include <metal_stdlib>
using namespace metal;

//MARK: ConstantVectorField2
/// 2-D constant vector field.
class ConstantVectorField2 {
public:
    class Builder;
    
    /// Constructs a constant vector field with given \p value.
    explicit ConstantVectorField2(const float2 value);
    
    /// Returns the sampled value at given position \p x.
    float2 sample(const float2 x) const;
    
    /// Returns divergence at given position \p x.
    float divergence(const float2 x) const;
    
    /// Returns curl at given position \p x.
    float curl(const float2 x) const;
    
    /// Returns builder fox ConstantVectorField2.
    static Builder builder();
    
private:
    float2 _value;
};

//MARK: ConstantVectorField2::Builder
///
/// \brief Front-end to create ConstantVectorField2 objects step by step.
///
class ConstantVectorField2::Builder {
public:
    /// Returns builder with value.
    thread Builder& withValue(const float2 value);
    
    /// Builds ConstantVectorField2.
    ConstantVectorField2 build() const;

private:
    float2 _value = float2(0, 0);
};

#endif  // INCLUDE_VOX_CONSTANT_VECTOR_FIELD2_METAL_
