//
//  array_samplers2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_SAMPLERS2_METAL_
#define INCLUDE_VOX_ARRAY_SAMPLERS2_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_samplers.metal"
#include "array_accessor2.metal"
#include "math_utils.metal"
#include "macros.h"
//MARK: NearestArraySampler:-
///
/// \brief 2-D nearest array sampler class.
///
/// This class provides nearest sampling interface for a given 2-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class NearestArraySampler<T, R, 2> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    ///
    /// \brief      Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    ///
    /// \param[in]  accessor    The array accessor.
    /// \param[in]  gridSpacing The grid spacing.
    /// \param[in]  gridOrigin  The grid origin.
    ///
    explicit NearestArraySampler(
                                 const thread ConstArrayAccessor2<T>& accessor,
                                 const float2 gridSpacing,
                                 const float2 gridOrigin);
    
    /// Copy constructor.
    NearestArraySampler(const thread NearestArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(const float2 pt) const;
    
    /// Returns the nearest array index for point \p x.
    void getCoordinate(const float2 pt, thread uint2* index) const;
    
private:
    float2 _gridSpacing;
    float2 _origin;
    ConstArrayAccessor2<T> _accessor;
};

/// Type alias for 2-D nearest array sampler.
template <typename T, typename R>
using NearestArraySampler2 = NearestArraySampler<T, R, 2>;

//MARK: LinearArraySampler:-
///
/// \brief 2-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 2-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class LinearArraySampler<T, R, 2> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    ///
    /// \brief      Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    ///
    /// \param[in]  accessor    The array accessor.
    /// \param[in]  gridSpacing The grid spacing.
    /// \param[in]  gridOrigin  The grid origin.
    ///
    explicit LinearArraySampler(const thread ConstArrayAccessor2<T>& accessor,
                                const float2 gridSpacing,
                                const float2 gridOrigin);
    
    /// Copy constructor.
    LinearArraySampler(const thread LinearArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(const float2 pt) const;
    
    /// Returns the indices of points and their sampling weight for given point.
    void getCoordinatesAndWeights(const float2 pt,
                                  thread array<uint2, 4>* indices,
                                  thread array<float, 4>* weights) const;
    
    /// Returns the indices of points and their gradient of sampling weight for
    /// given point.
    void getCoordinatesAndGradientWeights(const float2 pt,
                                          thread array<uint2, 4>* indices,
                                          thread array<float2, 4>* weights) const;
    
private:
    float2 _gridSpacing;
    float2 _invGridSpacing;
    float2 _origin;
    ConstArrayAccessor2<T> _accessor;
};

/// Type alias for 2-D linear array sampler.
template <typename T, typename R>
using LinearArraySampler2 = LinearArraySampler<T, R, 2>;

//MARK: CubicArraySampler:-
///
/// \brief 2-D cubic array sampler class.
///
/// This class provides cubic sampling interface for a given 2-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class CubicArraySampler<T, R, 2> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    ///
    /// \brief      Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    ///
    /// \param[in]  accessor    The array accessor.
    /// \param[in]  gridSpacing The grid spacing.
    /// \param[in]  gridOrigin  The grid origin.
    ///
    explicit CubicArraySampler(
                               const thread ConstArrayAccessor2<T>& accessor,
                               const float2 gridSpacing,
                               const float2 gridOrigin);
    
    /// Copy constructor.
    CubicArraySampler(const thread CubicArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(const float2 pt) const;
    
private:
    float2 _gridSpacing;
    float2 _origin;
    ConstArrayAccessor2<T> _accessor;
};

/// Type alias for 2-D cubic array sampler.
template <typename T, typename R>
using CubicArraySampler2 = CubicArraySampler<T, R, 2>;

//MARK: Implementation-NearestArraySampler2:-
template <typename T, typename R>
NearestArraySampler2<T, R>::NearestArraySampler(
                                                const thread ConstArrayAccessor2<T>& accessor,
                                                const float2 gridSpacing,
                                                const float2 gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
NearestArraySampler2<T, R>::NearestArraySampler(
                                                const thread NearestArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T NearestArraySampler2<T, R>::operator()(const float2 x) const {
    int i = 0;
    int j = 0;
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon());
    float2 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    i = min(static_cast<int>(i + fx + 0.5), iSize - 1);
    j = min(static_cast<int>(j + fy + 0.5), jSize - 1);
    
    return _accessor(i, j);
}

template <typename T, typename R>
void NearestArraySampler2<T, R>::getCoordinate(
                                               const float2 x, thread uint2* index) const {
    int i, j;
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon());
    float2 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    index[0].x = min(static_cast<int>(i + fx + 0.5), iSize - 1);
    index[0].y = min(static_cast<int>(j + fy + 0.5), jSize - 1);
}

//MARK: Implementation-LinearArraySampler2:-
template <typename T, typename R>
LinearArraySampler2<T, R>::LinearArraySampler(
                                              const thread ConstArrayAccessor2<T>& accessor,
                                              const float2 gridSpacing,
                                              const float2 gridOrigin) {
    _gridSpacing = gridSpacing;
    _invGridSpacing = static_cast<R>(1) / _gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
LinearArraySampler2<T, R>::LinearArraySampler(
                                              const thread LinearArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _invGridSpacing = other._invGridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T LinearArraySampler2<T, R>::operator()(const float2 x) const {
    int i, j;
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon());
    float2 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    int ip1 = min(i + 1, iSize - 1);
    int jp1 = min(j + 1, jSize - 1);
    
    return bilerp(
                  _accessor(i, j),
                  _accessor(ip1, j),
                  _accessor(i, jp1),
                  _accessor(ip1, jp1),
                  fx,
                  fy);
}

template <typename T, typename R>
void LinearArraySampler2<T, R>::getCoordinatesAndWeights(
                                                         const float2 x,
                                                         thread array<uint2, 4>* indices,
                                                         thread array<float, 4>* weights) const {
    int i, j;
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0);
    
    float2 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    int ip1 = min(i + 1, iSize - 1);
    int jp1 = min(j + 1, jSize - 1);
    
    (*indices)[0] = uint2(i, j);
    (*indices)[1] = uint2(ip1, j);
    (*indices)[2] = uint2(i, jp1);
    (*indices)[3] = uint2(ip1, jp1);
    
    (*weights)[0] = (1 - fx) * (1 - fy);
    (*weights)[1] = fx * (1 - fy);
    (*weights)[2] = (1 - fx) * fy;
    (*weights)[3] = fx * fy;
}

template <typename T, typename R>
void LinearArraySampler2<T, R>::getCoordinatesAndGradientWeights(const float2 x,
                                                                 thread array<uint2, 4>* indices,
                                                                 thread array<float2, 4>* weights) const {
    int i, j;
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0);
    
    const float2 normalizedX = (x - _origin) * _invGridSpacing;
    
    const int iSize = static_cast<int>(_accessor.size().x);
    const int jSize = static_cast<int>(_accessor.size().y);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    const int ip1 = min(i + 1, iSize - 1);
    const int jp1 = min(j + 1, jSize - 1);
    
    (*indices)[0] = uint2(i, j);
    (*indices)[1] = uint2(ip1, j);
    (*indices)[2] = uint2(i, jp1);
    (*indices)[3] = uint2(ip1, jp1);
    
    (*weights)[0] = float2(
                           fy * _invGridSpacing.x - _invGridSpacing.x,
                           fx * _invGridSpacing.y - _invGridSpacing.y);
    (*weights)[1] = float2(
                           -fy * _invGridSpacing.x + _invGridSpacing.x,
                           -fx * _invGridSpacing.y);
    (*weights)[2] = float2(
                           -fy * _invGridSpacing.x,
                           -fx * _invGridSpacing.y + _invGridSpacing.y);
    (*weights)[3] = float2(
                           fy * _invGridSpacing.x,
                           fx * _invGridSpacing.y);
}

//MARK: Implementation-CubicArraySampler:-
template <typename T, typename R>
CubicArraySampler2<T, R>::CubicArraySampler(
                                            const thread ConstArrayAccessor2<T>& accessor,
                                            const float2 gridSpacing,
                                            const float2 gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
CubicArraySampler2<T, R>::CubicArraySampler(
                                            const thread CubicArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T CubicArraySampler2<T, R>::operator()(const float2 x) const {
    int i, j;
    const int iSize = static_cast<int>(_accessor.size().x);
    const int jSize = static_cast<int>(_accessor.size().y);
    R fx, fy;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon());
    const float2 normalizedX = (x - _origin) / _gridSpacing;
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    
    int is[4] = {
        max(i - 1, 0),
        i,
        min(i + 1, iSize - 1),
        min(i + 2, iSize - 1)
    };
    int js[4] = {
        max(j - 1, 0),
        j,
        min(j + 1, jSize - 1),
        min(j + 2, jSize - 1)
    };
    
    // Calculate in i direction first
    T values[4];
    for (int n = 0; n < 4; ++n) {
        values[n] = monotonicCatmullRom(
                                        _accessor(is[0], js[n]),
                                        _accessor(is[1], js[n]),
                                        _accessor(is[2], js[n]),
                                        _accessor(is[3], js[n]),
                                        fx);
    }
    
    return monotonicCatmullRom(values[0], values[1], values[2], values[3], fy);
}

template class NearestArraySampler<float, float, 2>;
template class LinearArraySampler<float, float, 2>;
template class LinearArraySampler<float2, float, 2>;
template class CubicArraySampler<float, float, 2>;
template class CubicArraySampler<float2, float, 2>;

#endif  // INCLUDE_VOX_ARRAY_SAMPLERS2_METAL_
