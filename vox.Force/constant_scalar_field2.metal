//
//  constant_scalar_field2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_CONSTANT_SCALAR_FIELD2_METAL_
#define INCLUDE_VOX_CONSTANT_SCALAR_FIELD2_METAL_

#include <metal_stdlib>
using namespace metal;

//MARK: ConstantScalarField2
/// 2-D constant scalar field.
class ConstantScalarField2 {
public:
    class Builder;
    
    /// Constructs a constant scalar field with given \p value.
    explicit ConstantScalarField2(float value);
    
    /// Returns the sampled value at given position \p x.
    float sample(const float2 x) const;
    
    /// Returns gradient vector at given position \p x.
    float2 gradient(const float2 x) const;
    
    /// Returns Laplacian at given position \p x.
    float laplacian(const float2 x) const;
    
    /// Returns builder fox ConstantScalarField2.
    static Builder builder();
    
private:
    float _value = 0.0;
};

//MARK: ConstantScalarField2::Builder
///
/// \brief Front-end to create ConstantScalarField2 objects step by step.
///
class ConstantScalarField2::Builder {
public:
    /// Returns builder with value.
    thread Builder& withValue(float value);
    
    /// Builds ConstantScalarField2.
    ConstantScalarField2 build() const;
    
private:
    float _value = 0.0;
};

#endif  // INCLUDE_VOX_CONSTANT_SCALAR_FIELD2_METAL_
