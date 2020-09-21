//
//  fdm_utils.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_FDM_UTILS_METAL_
#define INCLUDE_VOX_FDM_UTILS_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "array_accessor3.metal"
#include "math_utils.metal"
#include "macros.h"

/// \brief Returns 2-D gradient vector from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
inline float2 gradient2(
                        const thread ConstArrayAccessor2<float>& data,
                        const float2 gridSpacing,
                        size_t i,
                        size_t j) {
    const uint2 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float left = data((i > 0) ? i - 1 : i, j);
    float right = data((i + 1 < ds.x) ? i + 1 : i, j);
    float down = data(i, (j > 0) ? j - 1 : j);
    float up = data(i, (j + 1 < ds.y) ? j + 1 : j);
    
    return 0.5 * float2(right - left, up - down) / gridSpacing;
}

/// \brief Returns 2-D gradient vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
inline array<float2, 2> gradient2(
                                  const thread ConstArrayAccessor2<float2>& data,
                                  const float2 gridSpacing,
                                  size_t i,
                                  size_t j) {
    const uint2 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float2 left = data((i > 0) ? i - 1 : i, j);
    float2 right = data((i + 1 < ds.x) ? i + 1 : i, j);
    float2 down = data(i, (j > 0) ? j - 1 : j);
    float2 up = data(i, (j + 1 < ds.y) ? j + 1 : j);
    
    array<float2, 2> result;
    result[0] = 0.5 * float2(right.x - left.x, up.x - down.x) / gridSpacing;
    result[1] = 0.5 * float2(right.y - left.y, up.y - down.y) / gridSpacing;
    return result;
}

/// \brief Returns 3-D gradient vector from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
inline float3 gradient3(
                        const thread ConstArrayAccessor3<float>& data,
                        const float3 gridSpacing,
                        size_t i,
                        size_t j,
                        size_t k) {
    const uint3 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float left = data((i > 0) ? i - 1 : i, j, k);
    float right = data((i + 1 < ds.x) ? i + 1 : i, j, k);
    float down = data(i, (j > 0) ? j - 1 : j, k);
    float up = data(i, (j + 1 < ds.y) ? j + 1 : j, k);
    float back = data(i, j, (k > 0) ? k - 1 : k);
    float front = data(i, j, (k + 1 < ds.z) ? k + 1 : k);
    
    return 0.5 * float3(right - left, up - down, front - back) / gridSpacing;
}

/// \brief Returns 3-D gradient vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
inline array<float3, 3> gradient3(
                                  const thread ConstArrayAccessor3<float3>& data,
                                  const float3 gridSpacing,
                                  size_t i,
                                  size_t j,
                                  size_t k) {
    const uint3 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float3 left = data((i > 0) ? i - 1 : i, j, k);
    float3 right = data((i + 1 < ds.x) ? i + 1 : i, j, k);
    float3 down = data(i, (j > 0) ? j - 1 : j, k);
    float3 up = data(i, (j + 1 < ds.y) ? j + 1 : j, k);
    float3 back = data(i, j, (k > 0) ? k - 1 : k);
    float3 front = data(i, j, (k + 1 < ds.z) ? k + 1 : k);
    
    array<float3, 3> result;
    result[0] = 0.5 * float3(
                             right.x - left.x, up.x - down.x, front.x - back.x) / gridSpacing;
    result[1] = 0.5 * float3(
                             right.y - left.y, up.y - down.y, front.y - back.y) / gridSpacing;
    result[2] = 0.5 * float3(
                             right.z - left.z, up.z - down.z, front.z - back.z) / gridSpacing;
    return result;
}

/// \brief Returns Laplacian value from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
inline float laplacian2(
                        const thread ConstArrayAccessor2<float>& data,
                        const float2 gridSpacing,
                        size_t i,
                        size_t j) {
    const float center = data(i, j);
    const uint2 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float dleft = 0.0;
    float dright = 0.0;
    float ddown = 0.0;
    float dup = 0.0;
    
    if (i > 0) {
        dleft = center - data(i - 1, j);
    }
    if (i + 1 < ds.x) {
        dright = data(i + 1, j) - center;
    }
    
    if (j > 0) {
        ddown = center - data(i, j - 1);
    }
    if (j + 1 < ds.y) {
        dup = data(i, j + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y);
}

/// \brief Returns 2-D Laplacian vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
inline float2 laplacian2(
                         const thread ConstArrayAccessor2<float2>& data,
                         const float2 gridSpacing,
                         size_t i,
                         size_t j) {
    const float2 center = data(i, j);
    const uint2 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float2 dleft = float2();
    float2 dright = float2();
    float2 ddown = float2();
    float2 dup = float2();
    
    if (i > 0) {
        dleft = center - data(i - 1, j);
    }
    if (i + 1 < ds.x) {
        dright = data(i + 1, j) - center;
    }
    
    if (j > 0) {
        ddown = center - data(i, j - 1);
    }
    if (j + 1 < ds.y) {
        dup = data(i, j + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y);
}

/// \brief Returns Laplacian value from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
inline float laplacian3(
                        const thread ConstArrayAccessor3<float>& data,
                        const float3 gridSpacing,
                        size_t i,
                        size_t j,
                        size_t k) {
    const float center = data(i, j, k);
    const uint3 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float dleft = 0.0;
    float dright = 0.0;
    float ddown = 0.0;
    float dup = 0.0;
    float dback = 0.0;
    float dfront = 0.0;
    
    if (i > 0) {
        dleft = center - data(i - 1, j, k);
    }
    if (i + 1 < ds.x) {
        dright = data(i + 1, j, k) - center;
    }
    
    if (j > 0) {
        ddown = center - data(i, j - 1, k);
    }
    if (j + 1 < ds.y) {
        dup = data(i, j + 1, k) - center;
    }
    
    if (k > 0) {
        dback = center - data(i, j, k - 1);
    }
    if (k + 1 < ds.z) {
        dfront = data(i, j, k + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y)
    + (dfront - dback) / square(gridSpacing.z);
}

/// \brief Returns 3-D Laplacian vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
inline float3 laplacian3(
                         const thread ConstArrayAccessor3<float3>& data,
                         const float3 gridSpacing,
                         size_t i,
                         size_t j,
                         size_t k) {
    const float3 center = data(i, j, k);
    const uint3 ds = data.size();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float3 dleft = float3();
    float3 dright = float3();
    float3 ddown = float3();
    float3 dup = float3();
    float3 dback = float3();
    float3 dfront = float3();
    
    if (i > 0) {
        dleft = center - data(i - 1, j, k);
    }
    if (i + 1 < ds.x) {
        dright = data(i + 1, j, k) - center;
    }
    
    if (j > 0) {
        ddown = center - data(i, j - 1, k);
    }
    if (j + 1 < ds.y) {
        dup = data(i, j + 1, k) - center;
    }
    
    if (k > 0) {
        dback = center - data(i, j, k - 1);
    }
    if (k + 1 < ds.z) {
        dfront = data(i, j, k + 1) - center;
    }
    
    return (dright - dleft) / square(gridSpacing.x)
    + (dup - ddown) / square(gridSpacing.y)
    + (dfront - dback) / square(gridSpacing.z);
}

#endif  // INCLUDE_VOX_FDM_UTILS_METAL_
