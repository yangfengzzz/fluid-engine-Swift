//
//  constant_scalar_field3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_CONSTANT_SCALAR_FIELD3_METAL_
#define INCLUDE_VOX_CONSTANT_SCALAR_FIELD3_METAL_

#include <metal_stdlib>
using namespace metal;

//MARK: ConstantScalarField3
/// 3-D constant scalar field.
class ConstantScalarField3 {
public:
    class Builder;
    
    /// Constructs a constant scalar field with given \p value.
    explicit ConstantScalarField3(float value);
    
    /// Returns the sampled value at given position \p x.
    float sample(const float3 x) const;
    
    /// Returns gradient vector at given position \p x.
    float3 gradient(const float3 x) const;
    
    /// Returns Laplacian at given position \p x.
    float laplacian(const float3 x) const;
    
    /// Returns builder fox ConstantScalarField3.
    static Builder builder();
    
private:
    float _value = 0.0;
};

//MARK: ConstantScalarField3::Builder
///
/// \brief Front-end to create ConstantScalarField3 objects step by step.
///
class ConstantScalarField3::Builder {
public:
    /// Returns builder with value.
    thread Builder& withValue(float value);
    
    /// Builds ConstantScalarField3.
    ConstantScalarField3 build() const;
    
private:
    float _value = 0.0;
};

#endif  // INCLUDE_VOX_CONSTANT_SCALAR_FIELD3_METAL_
