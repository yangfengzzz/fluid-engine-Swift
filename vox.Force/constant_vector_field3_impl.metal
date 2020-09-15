//
//  constant_vector_field3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "constant_vector_field3.metal"

ConstantVectorField3::ConstantVectorField3(const float3 value) :
_value(value) {
}

float3 ConstantVectorField3::sample(const float3 x) const {
    return _value;
}

float ConstantVectorField3::divergence(const float3) const {
    return 0.0;
}

float3 ConstantVectorField3::curl(const float3) const {
    return float3();
}

ConstantVectorField3::Builder ConstantVectorField3::builder() {
    return Builder();
}

thread ConstantVectorField3::Builder&
ConstantVectorField3::Builder::withValue(const float3 value) {
    _value = value;
    return *this;
}

ConstantVectorField3 ConstantVectorField3::Builder::build() const {
    return ConstantVectorField3(_value);
}
