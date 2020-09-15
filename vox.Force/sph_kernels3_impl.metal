//
//  sph_kernels3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "sph_kernels3.metal"
#include "constants.metal"

SphStdKernel3::SphStdKernel3()
: h(0), h2(0), h3(0), h5(0) {}

SphStdKernel3::SphStdKernel3(float kernelRadius)
: h(kernelRadius), h2(h * h), h3(h2 * h), h5(h2 * h3) {}

SphStdKernel3::SphStdKernel3(const thread SphStdKernel3& other)
: h(other.h), h2(other.h2), h3(other.h3), h5(other.h5) {}

float SphStdKernel3::operator()(float distance) const {
    if (distance * distance >= h2) {
        return 0.0;
    } else {
        float x = 1.0 - distance * distance / h2;
        return 315.0 / (64.0 * kPiF * h3) * x * x * x;
    }
}

float SphStdKernel3::firstDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance * distance / h2;
        return -945.0 / (32.0 * kPiF * h5) * distance * x * x;
    }
}

float3 SphStdKernel3::gradient(
                               const float3 point) const {
    float dist = length(point);
    if (dist > 0.0) {
        return gradient(dist, point / dist);
    } else {
        return float3(0, 0, 0);
    }
}

float3 SphStdKernel3::gradient(
                               float distance,
                               const float3 directionToCenter) const {
    return -firstDerivative(distance) * directionToCenter;
}

float SphStdKernel3::secondDerivative(float distance) const {
    if (distance * distance >= h2) {
        return 0.0;
    } else {
        float x = distance * distance / h2;
        return 945.0 / (32.0 * kPiF * h5) * (1 - x) * (3 * x - 1);
    }
}

//MARK: SphSpikyKernel3:-
SphSpikyKernel3::SphSpikyKernel3()
: h(0), h2(0), h3(0), h4(0), h5(0) {}

SphSpikyKernel3::SphSpikyKernel3(float h_)
: h(h_), h2(h * h), h3(h2 * h), h4(h2 * h2), h5(h3 * h2) {}

SphSpikyKernel3::SphSpikyKernel3(const thread SphSpikyKernel3& other)
: h(other.h), h2(other.h2), h3(other.h3), h4(other.h4), h5(other.h5) {}

float SphSpikyKernel3::operator()(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return 15.0 / (kPiF * h3) * x * x * x;
    }
}

float SphSpikyKernel3::firstDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return -45.0 / (kPiF * h4) * x * x;
    }
}

float3 SphSpikyKernel3::gradient(
                                 const float3 point) const {
    float dist = length(point);
    if (dist > 0.0) {
        return gradient(dist, point / dist);
    } else {
        return float3(0, 0, 0);
    }
}

float3 SphSpikyKernel3::gradient(
                                 float distance,
                                 const float3 directionToCenter) const {
    return -firstDerivative(distance) * directionToCenter;
}

float SphSpikyKernel3::secondDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return 90.0 / (kPiF * h5) * x;
    }
}
