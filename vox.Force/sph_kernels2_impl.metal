//
//  sph_kernels2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "sph_kernels2.metal"
#include "constants.metal"

SphStdKernel2::SphStdKernel2()
: h(0), h2(0), h3(0), h4(0) {}

SphStdKernel2::SphStdKernel2(float h_)
: h(h_), h2(h * h), h3(h2 * h), h4(h2 * h2) {}

SphStdKernel2::SphStdKernel2(const thread SphStdKernel2& other)
: h(other.h), h2(other.h2), h3(other.h3), h4(other.h4) {}

float SphStdKernel2::operator()(float distance) const {
    float distanceSquared = distance * distance;
    
    if (distanceSquared >= h2) {
        return 0.0;
    } else {
        float x = 1.0 - distanceSquared / h2;
        return 4.0 / (kPiF * h2) * x * x * x;
    }
}

float SphStdKernel2::firstDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance * distance / h2;
        return -24.0 * distance / (kPiF * h4) * x * x;
    }
}

float2 SphStdKernel2::gradient(const float2 point) const {
    float dist = length(point);
    if (dist > 0.0) {
        return gradient(dist, point / dist);
    } else {
        return float2(0, 0);
    }
}

float2 SphStdKernel2::gradient(
                               float distance,
                               const float2 directionToCenter) const {
    return -firstDerivative(distance) * directionToCenter;
}

float SphStdKernel2::secondDerivative(float distance) const {
    float distanceSquared = distance * distance;
    
    if (distanceSquared >= h2) {
        return 0.0;
    } else {
        float x = distanceSquared / h2;
        return 24.0 / (kPiF * h4) * (1 - x) * (5 * x - 1);
    }
}

//MARK: SphSpikyKernel2:-
SphSpikyKernel2::SphSpikyKernel2()
: h(0), h2(0), h3(0), h4(0), h5(0) {}

SphSpikyKernel2::SphSpikyKernel2(float h_)
: h(h_), h2(h * h), h3(h2 * h), h4(h2 * h2), h5(h3 * h2) {}

SphSpikyKernel2::SphSpikyKernel2(const thread SphSpikyKernel2& other)
: h(other.h), h2(other.h2), h3(other.h3), h4(other.h4), h5(other.h5) {}

float SphSpikyKernel2::operator()(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return 10.0 / (kPiF * h2) * x * x * x;
    }
}

float SphSpikyKernel2::firstDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return -30.0 / (kPiF * h3) * x * x;
    }
}

float2 SphSpikyKernel2::gradient(
                                 const float2 point) const {
    float dist = length(point);
    if (dist > 0.0) {
        return gradient(dist, point / dist);
    } else {
        return float2(0, 0);
    }
}

float2 SphSpikyKernel2::gradient(
                                 float distance,
                                 const float2 directionToCenter) const {
    return -firstDerivative(distance) * directionToCenter;
}

float SphSpikyKernel2::secondDerivative(float distance) const {
    if (distance >= h) {
        return 0.0;
    } else {
        float x = 1.0 - distance / h;
        return 60.0 / (kPiF * h4) * x;
    }
}
