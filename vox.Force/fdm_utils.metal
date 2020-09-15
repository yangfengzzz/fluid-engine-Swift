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

/// \brief Returns 2-D gradient vector from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
float2 gradient2(
                 const thread ConstArrayAccessor2<float>& data,
                 const float2 gridSpacing,
                 size_t i,
                 size_t j);

/// \brief Returns 2-D gradient vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
array<float2, 2> gradient2(
                           const thread ConstArrayAccessor2<float2>& data,
                           const float2 gridSpacing,
                           size_t i,
                           size_t j);

/// \brief Returns 3-D gradient vector from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
float3 gradient3(
                 const thread ConstArrayAccessor3<float>& data,
                 const float3 gridSpacing,
                 size_t i,
                 size_t j,
                 size_t k);

/// \brief Returns 3-D gradient vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
array<float3, 3> gradient3(
                           const thread ConstArrayAccessor3<float3>& data,
                           const float3 gridSpacing,
                           size_t i,
                           size_t j,
                           size_t k);

/// \brief Returns Laplacian value from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
float laplacian2(
                 const thread ConstArrayAccessor2<float>& data,
                 const float2 gridSpacing,
                 size_t i,
                 size_t j);

/// \brief Returns 2-D Laplacian vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
float2 laplacian2(
                  const thread ConstArrayAccessor2<float2>& data,
                  const float2 gridSpacing,
                  size_t i,
                  size_t j);

/// \brief Returns Laplacian value from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
float laplacian3(
                 const thread ConstArrayAccessor3<float>& data,
                 const float3 gridSpacing,
                 size_t i,
                 size_t j,
                 size_t k);

/// \brief Returns 3-D Laplacian vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
float3 laplacian3(
                  const thread ConstArrayAccessor3<float3>& data,
                  const float3 gridSpacing,
                  size_t i,
                  size_t j,
                  size_t k);

#endif  // INCLUDE_VOX_FDM_UTILS_METAL_
