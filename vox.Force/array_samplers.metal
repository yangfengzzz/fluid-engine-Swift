//
//  array_samplers.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_SAMPLERS_METAL_
#define INCLUDE_VOX_ARRAY_SAMPLERS_METAL_

#include <metal_stdlib>
using namespace metal;

///
/// \brief Generic N-D nearest array sampler class.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
/// \tparam N - Dimension.
///
template <typename T, typename R, size_t N>
class NearestArraySampler {
public:
    static_assert(
                  N < 1 || N > 3, "Not implemented - N should be either 1, 2 or 3.");
};

///
/// \brief Generic N-D linear array sampler class.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
/// \tparam N - Dimension.
///
template <typename T, typename R, size_t N>
class LinearArraySampler {
public:
    static_assert(
                  N < 1 || N > 3, "Not implemented - N should be either 1, 2 or 3.");
};

///
/// \brief Generic N-D cubic array sampler class.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
/// \tparam N - Dimension.
///
template <typename T, typename R, size_t N>
class CubicArraySampler {
public:
    static_assert(
                  N < 1 || N > 3, "Not implemented - N should be either 1, 2 or 3.");
};

#endif  // INCLUDE_VOX_ARRAY_SAMPLERS_METAL_
