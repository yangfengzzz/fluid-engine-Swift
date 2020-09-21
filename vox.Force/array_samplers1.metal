//
//  array_samplers1.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_SAMPLERS1_METAL_
#define INCLUDE_VOX_ARRAY_SAMPLERS1_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_samplers.metal"
#include "array_accessor1.metal"
#include "math_utils.metal"

//MARK: NearestArraySampler:-
///
/// \brief 1-D nearest array sampler class.
///
/// This class provides nearest sampling interface for a given 1-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class NearestArraySampler<T, R, 1> {
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
    explicit NearestArraySampler(const thread ConstArrayAccessor1<T>& accessor,
                                 R gridSpacing,
                                 R gridOrigin);
    
    /// Copy constructor.
    NearestArraySampler(const thread NearestArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(R pt) const;
    
    /// Returns the nearest array index for point \p x.
    void getCoordinate(R x, thread size_t* i) const;
    
private:
    R _gridSpacing;
    R _origin;
    ConstArrayAccessor1<T> _accessor;
};

/// Type alias for 1-D nearest array sampler.
template <typename T, typename R>
using NearestArraySampler1 = NearestArraySampler<T, R, 1>;

//MARK: LinearArraySampler:-
///
/// \brief 1-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 1-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class LinearArraySampler<T, R, 1> {
public:
    static_assert(is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    ///
    /// \brief      Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    ///
    /// \param[in]  accessor    The array accessor.
    /// \param[in]  gridSpacing The grid spacing.
    /// \param[in]  gridOrigin  The grid origin.
    ///
    explicit LinearArraySampler(const thread ConstArrayAccessor1<T>& accessor,
                                R gridSpacing,
                                R gridOrigin);
    
    /// Copy constructor.
    LinearArraySampler(const thread LinearArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(R pt) const;
    
    /// Returns the indices of points and their sampling weight for given point.
    void getCoordinatesAndWeights(R x, thread size_t* i0, thread size_t* i1,
                                  thread T* weight0, thread T* weight1) const;
    
private:
    R _gridSpacing;
    R _origin;
    ConstArrayAccessor1<T> _accessor;
};

/// Type alias for 1-D linear array sampler.
template <typename T, typename R>
using LinearArraySampler1 = LinearArraySampler<T, R, 1>;

//MARK: CubicArraySampler:-
///
/// \brief 1-D cubic array sampler class.
///
/// This class provides cubic sampling interface for a given 1-D array.
///
/// \tparam T - The value type to sample.
/// \tparam R - The real number type.
///
template <typename T, typename R>
class CubicArraySampler<T, R, 1> {
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
                               const thread ConstArrayAccessor1<T>& accessor,
                               R gridSpacing,
                               R gridOrigin);
    
    /// Copy constructor.
    CubicArraySampler(const thread CubicArraySampler& other);
    
    /// Returns sampled value at point \p pt.
    T operator()(R pt) const;
    
private:
    R _gridSpacing;
    R _origin;
    ConstArrayAccessor1<T> _accessor;
};

/// Type alias for 1-D cubic array sampler.
template <typename T, typename R>
using CubicArraySampler1 = CubicArraySampler<T, R, 1>;

//MARK: Implementation-NearestArraySampler1:-
template <typename T, typename R>
NearestArraySampler1<T, R>::NearestArraySampler(
                                                const thread ConstArrayAccessor1<T>& accessor,
                                                R gridSpacing,
                                                R gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
NearestArraySampler1<T, R>::NearestArraySampler(
                                                const thread NearestArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T NearestArraySampler1<T, R>::operator()(R x) const {
    int i;
    R fx;
    
    VOX_ASSERT(_gridSpacing > std::numeric_limits<R>::epsilon());
    R normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size());
    
    getBarycentric(normalizedX, 0, iSize - 1, &i, &fx);
    
    i = min(static_cast<int>(i + fx + 0.5), iSize - 1);
    
    return _accessor[i];
}

template <typename T, typename R>
void NearestArraySampler1<T, R>::getCoordinate(R x, thread size_t* i) const {
    R fx;
    
    VOX_ASSERT(_gridSpacing > numeric_limits<R>::epsilon());
    R normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size());
    
    int _i;
    getBarycentric(normalizedX, 0, iSize - 1, &_i, &fx);
    
    *i = min(static_cast<int>(_i + fx + 0.5), iSize - 1);
}

//MARK: Implementation-LinearArraySampler1:-
template <typename T, typename R>
LinearArraySampler1<T, R>::LinearArraySampler(
                                              const thread ConstArrayAccessor1<T>& accessor,
                                              R gridSpacing,
                                              R gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
LinearArraySampler1<T, R>::LinearArraySampler(
                                              const thread LinearArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T LinearArraySampler1<T, R>::operator()(R x) const {
    int i;
    R fx;
    
    VOX_ASSERT(_gridSpacing > numeric_limits<R>::epsilon());
    R normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size());
    
    getBarycentric(normalizedX, 0, iSize - 1, &i, &fx);
    
    int ip1 = min(i + 1, iSize - 1);
    
    return lerp(
                _accessor[i],
                _accessor[ip1],
                fx);
}

template <typename T, typename R>
void LinearArraySampler1<T, R>::getCoordinatesAndWeights(R x, thread size_t* i0, thread size_t* i1,
                                                         thread T* weight0, thread T* weight1) const {
    int i;
    R fx;
    
    VOX_ASSERT(_gridSpacing > numeric_limits<R>::epsilon());
    R normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size());
    
    getBarycentric(normalizedX, 0, iSize - 1, &i, &fx);
    
    int ip1 = min(i + 1, iSize - 1);
    
    *i0 = i;
    *i1 = ip1;
    *weight0 = 1 - fx;
    *weight1 = fx;
}

//MARK: Implementation-CubicArraySampler1:-
template <typename T, typename R>
CubicArraySampler1<T, R>::CubicArraySampler(
                                            const thread ConstArrayAccessor1<T>& accessor,
                                            R gridSpacing,
                                            R gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
CubicArraySampler1<T, R>::CubicArraySampler(
                                            const thread CubicArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T CubicArraySampler1<T, R>::operator()(R x) const {
    int i;
    int iSize = static_cast<int>(_accessor.size());
    R fx;
    
    VOX_ASSERT(_gridSpacing > numeric_limits<R>::epsilon());
    R normalizedX = (x - _origin) / _gridSpacing;
    
    getBarycentric(normalizedX, 0, iSize - 1, &i, &fx);
    
    int im1 = max(i - 1, 0);
    int ip1 = min(i + 1, iSize - 1);
    int ip2 = min(i + 2, iSize - 1);
    
    return monotonicCatmullRom(
                               _accessor[im1],
                               _accessor[i],
                               _accessor[ip1],
                               _accessor[ip2],
                               fx);
}

template class NearestArraySampler<float, float, 1>;
template class LinearArraySampler<float, float, 1>;
template class CubicArraySampler<float, float, 1>;

#endif  // INCLUDE_VOX_ARRAY_SAMPLERS1_METAL_
