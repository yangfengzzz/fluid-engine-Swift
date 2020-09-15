//
//  physics_helpers.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef SRC_VOX_PHYSICS_HELPERS_METAL_
#define SRC_VOX_PHYSICS_HELPERS_METAL_

#include <metal_stdlib>
using namespace metal;
#include "constants.metal"

inline float2 computeDragForce(
                               float dragCoefficient,
                               float radius,
                               const float2 velocity) {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * kPiF * dragCoefficient * radius * velocity;
}

inline float3 computeDragForce(
                               float dragCoefficient,
                               float radius,
                               const float3 velocity) {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * kPiF * dragCoefficient * radius * velocity;
}

inline float2 projected(const float2 vel, const float2 normal) {
    return vel - normal * dot(vel, normal);
}

inline float3 projected(const float3 vel, const float3 normal) {
    return vel - normal * dot(vel, normal);
}

inline float2 projectAndApplyFriction(
                                      const float2 vel,
                                      const float2 normal,
                                      float frictionCoefficient) {
    
    float2 velt = projected(vel, normal);
    if (length_squared(velt) > 0) {
        float veln = max(-dot(vel, normal), 0.0);
        velt *= max(1.0 - frictionCoefficient * veln / length(velt), 0.0);
    }
    
    return velt;
}

inline float3 projectAndApplyFriction(
                                      const float3 vel,
                                      const float3 normal,
                                      float frictionCoefficient) {
    
    float3 velt = projected(vel, normal);
    if (length_squared(velt) > 0) {
        float veln = max(-dot(vel, normal), 0.0);
        velt *= max(1.0 - frictionCoefficient * veln / length(velt), 0.0);
    }
    
    return velt;
}

inline float computePressureFromEos(
                                    float density,
                                    float targetDensity,
                                    float eosScale,
                                    float eosExponent,
                                    float negativePressureScale) {
    // See Murnaghan-Tait equation of state from
    // https://en.wikipedia.org/wiki/Tait_equation
    float p = eosScale / eosExponent * (pow((density / targetDensity), eosExponent) - 1.0);
    
    // Negative pressure scaling
    if (p < 0) {
        p *= negativePressureScale;
    }
    
    return p;
}

#endif  // SRC_VOX_PHYSICS_HELPERS_METAL_
