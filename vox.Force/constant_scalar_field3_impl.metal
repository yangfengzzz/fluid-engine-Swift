//
//  constant_scalar_field3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "constant_scalar_field3.metal"

ConstantScalarField3::ConstantScalarField3(float value) :
_value(value) {
}

float ConstantScalarField3::sample(const float3 x) const {
    return _value;
}

float3 ConstantScalarField3::gradient(const float3) const {
    return float3();
}

float ConstantScalarField3::laplacian(const float3) const {
    return 0.0;
}

ConstantScalarField3::Builder ConstantScalarField3::builder() {
    return Builder();
}


thread ConstantScalarField3::Builder&
ConstantScalarField3::Builder::withValue(float value) {
    _value = value;
    return *this;
}

ConstantScalarField3 ConstantScalarField3::Builder::build() const {
    return ConstantScalarField3(_value);
}
