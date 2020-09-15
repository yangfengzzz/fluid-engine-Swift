//
//  constant_vector_field2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "constant_vector_field2.metal"

ConstantVectorField2::ConstantVectorField2(const float2 value) :
_value(value) {
}

float2 ConstantVectorField2::sample(const float2 x) const {
    return _value;
}

float ConstantVectorField2::divergence(const float2) const {
    return 0.0;
}

float ConstantVectorField2::curl(const float2) const {
    return 0.0;
}

ConstantVectorField2::Builder ConstantVectorField2::builder() {
    return Builder();
}


thread ConstantVectorField2::Builder&
ConstantVectorField2::Builder::withValue(const float2 value) {
    _value = value;
    return *this;
}

ConstantVectorField2 ConstantVectorField2::Builder::build() const {
    return ConstantVectorField2(_value);
}
