//
//  grid_forward_euler_diffusion_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "constants.metal"
#include "math_utils.metal"
#include "grid.metal"
#include "macros.h"

constant char kFluid = 0;

template <typename T>
inline T laplacian(
                   const ConstArrayAccessor2<T> data,
                   const ConstArrayAccessor2<char> marker,
                   const float2 gridSpacing,
                   size_t i,
                   size_t j) {
    const T center = data(i, j);
    const uint2 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    T dleft = zero<T>();
    T dright = zero<T>();
    T ddown = zero<T>();
    T dup = zero<T>();
    
    if (i > 0 && marker(i - 1, j) == kFluid) {
        dleft = center - data(i - 1, j);
    }
    if (i + 1 < ds.x && marker(i + 1, j) == kFluid) {
        dright = data(i + 1, j) - center;
    }
    
    if (j > 0 && marker(i, j - 1) == kFluid) {
        ddown = center - data(i, j - 1);
    }
    if (j + 1 < ds.y && marker(i, j + 1) == kFluid) {
        dup = data(i, j + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y);
}

namespace GridForwardEulerDiffusionSolver2 {
    kernel void solve_scalar(device float *_source [[buffer(0)]],
                             device char *__markers [[buffer(1)]],
                             device float *_dest [[buffer(2)]],
                             constant Grid2Descriptor &descriptor [[buffer(3)]],
                             constant float &diffusionCoefficient [[buffer(4)]],
                             constant float &timeIntervalInSeconds [[buffer(5)]],
                             constant float2 &h [[buffer(6)]],
                             uint2 id [[thread_position_in_grid]],
                             uint2 size [[threads_per_grid]]) {
        ConstArrayAccessor2<float> source(size, _source);
        ConstArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        
        if (_markers(i, j) == kFluid) {
            dest(i, j)
            = source(i, j)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j);
        } else {
            dest(i, j) = source(i, j);
        }
    }
    
    kernel void solve_collocated(device float2 *_source [[buffer(0)]],
                                 device char *__markers [[buffer(1)]],
                                 device float2 *_dest [[buffer(2)]],
                                 constant Grid2Descriptor &descriptor [[buffer(3)]],
                                 constant float &diffusionCoefficient [[buffer(4)]],
                                 constant float &timeIntervalInSeconds [[buffer(5)]],
                                 constant float2 &h [[buffer(6)]],
                                 uint2 id [[thread_position_in_grid]],
                                 uint2 size [[threads_per_grid]]) {
        ConstArrayAccessor2<float2> source(size, _source);
        ConstArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float2> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        
        if (_markers(i, j) == kFluid) {
            dest(i, j)
            = source(i, j)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j);
        } else {
            dest(i, j) = source(i, j);
        }
    }
    
    kernel void solve_face(device float *_source [[buffer(0)]],
                           device char *__markers [[buffer(1)]],
                           device float *_dest [[buffer(2)]],
                           constant float &diffusionCoefficient [[buffer(3)]],
                           constant float &timeIntervalInSeconds [[buffer(4)]],
                           constant float2 &h [[buffer(5)]],
                           uint2 id [[thread_position_in_grid]],
                           uint2 size [[threads_per_grid]]) {
        ConstArrayAccessor2<float> source(size, _source);
        ConstArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float> dest(size, _dest);
        uint i = id.x;
        uint j = id.y;
        
        if (_markers(i, j) == kFluid) {
            dest(i, j)
            = source(i, j)
            + diffusionCoefficient
            * timeIntervalInSeconds
            * laplacian(source, _markers, h, i, j);
        } else {
            dest(i, j) = source(i, j);
        }
    }
}
