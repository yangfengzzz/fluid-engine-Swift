//
//  grid_forward_euler_diffusion_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "constants.metal"
#include "math_utils.metal"
#include "grid.metal"
#include "macros.h"

constant char kFluid = 0;

template <typename T>
T laplacian(
            const ConstArrayAccessor3<T> data,
            const ConstArrayAccessor3<char> marker,
            const float3 gridSpacing,
            size_t i,
            size_t j,
            size_t k) {
    const T center = data(i, j, k);
    const uint3 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    T dleft = zero<T>();
    T dright = zero<T>();
    T ddown = zero<T>();
    T dup = zero<T>();
    T dback = zero<T>();
    T dfront = zero<T>();
    
    if (i > 0 && marker(i - 1, j, k) == kFluid) {
        dleft = center - data(i - 1, j, k);
    }
    if (i + 1 < ds.x && marker(i + 1, j, k) == kFluid) {
        dright = data(i + 1, j, k) - center;
    }
    
    if (j > 0 && marker(i, j - 1, k) == kFluid) {
        ddown = center - data(i, j - 1, k);
    }
    if (j + 1 < ds.y && marker(i, j + 1, k) == kFluid) {
        dup = data(i, j + 1, k) - center;
    }
    
    if (k > 0 && marker(i, j, k - 1) == kFluid) {
        dback = center - data(i, j, k - 1);
    }
    if (k + 1 < ds.z && marker(i, j, k + 1) == kFluid) {
        dfront = data(i, j, k + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y)
    + (dfront - dback) / square(gridSpacing.z);
}

namespace GridForwardEulerDiffusionSolver3 {
    kernel void solve_scalar(device float *_source [[buffer(0)]],
                             device char *__markers [[buffer(1)]],
                             device float *_dest [[buffer(2)]],
                             constant Grid3Descriptor &descriptor [[buffer(3)]],
                             constant float &diffusionCoefficient [[buffer(4)]],
                             constant float &timeIntervalInSeconds [[buffer(5)]],
                             constant float3 &h [[buffer(6)]],
                             uint3 id [[thread_position_in_grid]],
                             uint3 size [[threads_per_grid]]) {
        ConstArrayAccessor3<float> source(size, _source);
        ConstArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (_markers(i, j, k) == kFluid) {
            dest(i, j, k)
            = source(i, j, k)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j, k);
        } else {
            dest(i, j, k) = source(i, j, k);
        }
    }
    
    kernel void solve_collocated(device float3 *_source [[buffer(0)]],
                                 device char *__markers [[buffer(1)]],
                                 device float3 *_dest [[buffer(2)]],
                                 constant Grid3Descriptor &descriptor [[buffer(3)]],
                                 constant float &diffusionCoefficient [[buffer(4)]],
                                 constant float &timeIntervalInSeconds [[buffer(5)]],
                                 constant float3 &h [[buffer(6)]],
                                 uint3 id [[thread_position_in_grid]],
                                 uint3 size [[threads_per_grid]]) {
        ConstArrayAccessor3<float3> source(size, _source);
        ConstArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float3> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (_markers(i, j, k) == kFluid) {
            dest(i, j, k)
            = source(i, j, k)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j, k);
        } else {
            dest(i, j, k) = source(i, j, k);
        }
    }
    
    kernel void solve_face(device float *_source [[buffer(0)]],
                           device char *__markers [[buffer(1)]],
                           device float *_dest [[buffer(2)]],
                           constant float &diffusionCoefficient [[buffer(3)]],
                           constant float &timeIntervalInSeconds [[buffer(4)]],
                           constant float3 &h [[buffer(5)]],
                           uint3 id [[thread_position_in_grid]],
                           uint3 size [[threads_per_grid]]) {
        ConstArrayAccessor3<float> source(size, _source);
        ConstArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (_markers(i, j, k) == kFluid) {
            dest(i, j, k)
            = source(i, j, k)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j, k);
        } else {
            dest(i, j, k) = source(i, j, k);
        }
    }
}
