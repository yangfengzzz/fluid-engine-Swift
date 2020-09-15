//
//  constant_scalar_field2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "constant_scalar_field2.metal"

ConstantScalarField2::ConstantScalarField2(float value) :
_value(value) {
}

float ConstantScalarField2::sample(const float2 x) const {
    return _value;
}

float2 ConstantScalarField2::gradient(const float2) const {
    return float2();
}

float ConstantScalarField2::laplacian(const float2) const {
    return 0.0;
}

ConstantScalarField2::Builder ConstantScalarField2::builder() {
    return Builder();
}


thread ConstantScalarField2::Builder&
ConstantScalarField2::Builder::withValue(float value) {
    _value = value;
    return *this;
}

ConstantScalarField2 ConstantScalarField2::Builder::build() const {
    return ConstantScalarField2(_value);
}
