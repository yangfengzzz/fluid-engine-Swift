//
//  array_samplers3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_SAMPLERS3_METAL_
#define INCLUDE_VOX_ARRAY_SAMPLERS3_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_samplers.metal"
#include "array_accessor3.metal"
#include "math_utils.metal"
#include "macros.h"

//MARK: NearestArraySampler:-
//!
//! \brief 3-D nearest array sampler class.
//!
//! This class provides nearest sampling interface for a given 3-D array.
//!
//! \tparam T - The value type to sample.
//! \tparam R - The real number type.
//!
template <typename T, typename R>
class NearestArraySampler<T, R, 3> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    //!
    //! \brief      Constructs a sampler using array accessor, spacing between
    //!     the elements, and the position of the first array element.
    //!
    //! \param[in]  accessor    The array accessor.
    //! \param[in]  gridSpacing The grid spacing.
    //! \param[in]  gridOrigin  The grid origin.
    //!
    explicit NearestArraySampler(
                                 const thread ConstArrayAccessor3<T>& accessor,
                                 const float3 gridSpacing,
                                 const float3 gridOrigin);
    
    //! Copy constructor.
    NearestArraySampler(const thread NearestArraySampler& other);
    
    //! Returns sampled value at point \p pt.
    T operator()(const float3 pt) const;
    
    //! Returns the nearest array index for point \p x.
    void getCoordinate(const float3 pt, thread uint3* index) const;
    
private:
    float3 _gridSpacing;
    float3 _origin;
    ConstArrayAccessor3<T> _accessor;
};

//! Type alias for 3-D nearest array sampler.
template <typename T, typename R>
using NearestArraySampler3 = NearestArraySampler<T, R, 3>;

//MARK: LinearArraySampler:-
//!
//! \brief 2-D linear array sampler class.
//!
//! This class provides linear sampling interface for a given 2-D array.
//!
//! \tparam T - The value type to sample.
//! \tparam R - The real number type.
//!
template <typename T, typename R>
class LinearArraySampler<T, R, 3> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    //!
    //! \brief      Constructs a sampler using array accessor, spacing between
    //!     the elements, and the position of the first array element.
    //!
    //! \param[in]  accessor    The array accessor.
    //! \param[in]  gridSpacing The grid spacing.
    //! \param[in]  gridOrigin  The grid origin.
    //!
    explicit LinearArraySampler(
                                const thread ConstArrayAccessor3<T>& accessor,
                                const float3 gridSpacing,
                                const float3 gridOrigin);
    
    //! Copy constructor.
    LinearArraySampler(const thread LinearArraySampler& other);
    
    //! Returns sampled value at point \p pt.
    T operator()(const float3 pt) const;
    
    //! Returns the indices of points and their sampling weight for given point.
    void getCoordinatesAndWeights(
                                  const float3 pt,
                                  thread array<uint3, 8>* indices,
                                  thread array<R, 8>* weights) const;
    
    //! Returns the indices of points and their gradient of sampling weight for
    //! given point.
    void getCoordinatesAndGradientWeights(
                                          const float3 pt,
                                          thread array<uint3, 8>* indices,
                                          thread array<float3, 8>* weights) const;
    
private:
    float3 _gridSpacing;
    float3 _invGridSpacing;
    float3 _origin;
    ConstArrayAccessor3<T> _accessor;
};

//! Type alias for 3-D linear array sampler.
template <typename T, typename R>
using LinearArraySampler3 = LinearArraySampler<T, R, 3>;

//MARK: CubicArraySampler:-
//!
//! \brief 3-D cubic array sampler class.
//!
//! This class provides cubic sampling interface for a given 3-D array.
//!
//! \tparam T - The value type to sample.
//! \tparam R - The real number type.
//!
template <typename T, typename R>
class CubicArraySampler<T, R, 3> {
public:
    static_assert(
                  is_floating_point<R>::value,
                  "Samplers only can be instantiated with floating point types");
    
    //!
    //! \brief      Constructs a sampler using array accessor, spacing between
    //!     the elements, and the position of the first array element.
    //!
    //! \param[in]  accessor    The array accessor.
    //! \param[in]  gridSpacing The grid spacing.
    //! \param[in]  gridOrigin  The grid origin.
    //!
    explicit CubicArraySampler(
                               const thread ConstArrayAccessor3<T>& accessor,
                               const float3 gridSpacing,
                               const float3 gridOrigin);
    
    //! Copy constructor.
    CubicArraySampler(const thread CubicArraySampler& other);
    
    //! Returns sampled value at point \p pt.
    T operator()(const float3 pt) const;
    
private:
    float3 _gridSpacing;
    float3 _origin;
    ConstArrayAccessor3<T> _accessor;
};

//! Type alias for 3-D cubic array sampler.
template <typename T, typename R>
using CubicArraySampler3 = CubicArraySampler<T, R, 3>;

//MARK: Implementation-NearestArraySampler3:-
template <typename T, typename R>
NearestArraySampler3<T, R>::NearestArraySampler(
                                                const thread ConstArrayAccessor3<T>& accessor,
                                                const float3 gridSpacing,
                                                const float3 gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
NearestArraySampler3<T, R>::NearestArraySampler(
                                                const thread NearestArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T NearestArraySampler3<T, R>::operator()(const float3 x) const {
    int i, j, k;
    R fx, fy, fz;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon() &&
               _gridSpacing.z > numeric_limits<R>::epsilon());
    float3 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    int kSize = static_cast<int>(_accessor.size().z);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    i = min(static_cast<int>(i + fx + 0.5), iSize - 1);
    j = min(static_cast<int>(j + fy + 0.5), jSize - 1);
    k = min(static_cast<int>(k + fz + 0.5), kSize - 1);
    
    return _accessor(i, j, k);
}

template <typename T, typename R>
void NearestArraySampler3<T, R>::getCoordinate(
                                               const float3 x, thread uint3* index) const {
    int i, j, k;
    R fx, fy, fz;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon() &&
               _gridSpacing.z > numeric_limits<R>::epsilon());
    float3 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    int kSize = static_cast<int>(_accessor.size().z);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    index[0].x = min(static_cast<int>(i + fx + 0.5), iSize - 1);
    index[0].y = min(static_cast<int>(j + fy + 0.5), jSize - 1);
    index[0].z = min(static_cast<int>(k + fz + 0.5), kSize - 1);
}

//MARK: Implementation-LinearArraySampler3:-
template <typename T, typename R>
LinearArraySampler3<T, R>::LinearArraySampler(
                                              const thread ConstArrayAccessor3<T>& accessor,
                                              const float3 gridSpacing,
                                              const float3 gridOrigin) {
    _gridSpacing = gridSpacing;
    _invGridSpacing = static_cast<R>(1) / _gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}

template <typename T, typename R>
LinearArraySampler3<T, R>::LinearArraySampler(
                                              const thread LinearArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _invGridSpacing = other._invGridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T LinearArraySampler3<T, R>::operator()(const float3 x) const {
    int i, j, k;
    R fx, fy, fz;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon() &&
               _gridSpacing.z > numeric_limits<R>::epsilon());
    float3 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    int kSize = static_cast<int>(_accessor.size().z);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    int ip1 = min(i + 1, iSize - 1);
    int jp1 = min(j + 1, jSize - 1);
    int kp1 = min(k + 1, kSize - 1);
    
    return trilerp(
                   _accessor(i, j, k),
                   _accessor(ip1, j, k),
                   _accessor(i, jp1, k),
                   _accessor(ip1, jp1, k),
                   _accessor(i, j, kp1),
                   _accessor(ip1, j, kp1),
                   _accessor(i, jp1, kp1),
                   _accessor(ip1, jp1, kp1),
                   fx,
                   fy,
                   fz);
}

template <typename T, typename R>
void LinearArraySampler3<T, R>::getCoordinatesAndWeights(
                                                         const float3 x,
                                                         thread array<uint3, 8>* indices,
                                                         thread array<R, 8>* weights) const {
    int i, j, k;
    R fx, fy, fz;
    
    VOX_ASSERT(
               _gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0);
    
    const float3 normalizedX = (x - _origin) * _invGridSpacing;
    
    const int iSize = static_cast<int>(_accessor.size().x);
    const int jSize = static_cast<int>(_accessor.size().y);
    const int kSize = static_cast<int>(_accessor.size().z);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    const int ip1 = min(i + 1, iSize - 1);
    const int jp1 = min(j + 1, jSize - 1);
    const int kp1 = min(k + 1, kSize - 1);
    
    (*indices)[0] = uint3(i, j, k);
    (*indices)[1] = uint3(ip1, j, k);
    (*indices)[2] = uint3(i, jp1, k);
    (*indices)[3] = uint3(ip1, jp1, k);
    (*indices)[4] = uint3(i, j, kp1);
    (*indices)[5] = uint3(ip1, j, kp1);
    (*indices)[6] = uint3(i, jp1, kp1);
    (*indices)[7] = uint3(ip1, jp1, kp1);
    
    (*weights)[0] = (1 - fx) * (1 - fy) * (1 - fz);
    (*weights)[1] = fx * (1 - fy) * (1 - fz);
    (*weights)[2] = (1 - fx) * fy * (1 - fz);
    (*weights)[3] = fx * fy * (1 - fz);
    (*weights)[4] = (1 - fx) * (1 - fy) * fz;
    (*weights)[5] = fx * (1 - fy) * fz;
    (*weights)[6] = (1 - fx) * fy * fz;
    (*weights)[7] = fx * fy * fz;
}

template <typename T, typename R>
void LinearArraySampler3<T, R>::getCoordinatesAndGradientWeights(
                                                                 const float3 x,
                                                                 thread array<uint3, 8>* indices,
                                                                 thread array<float3, 8>* weights) const {
    int i, j, k;
    R fx, fy, fz;
    
    VOX_ASSERT(
               _gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0);
    
    float3 normalizedX = (x - _origin) / _gridSpacing;
    
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    int kSize = static_cast<int>(_accessor.size().z);
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    int ip1 = min(i + 1, iSize - 1);
    int jp1 = min(j + 1, jSize - 1);
    int kp1 = min(k + 1, kSize - 1);
    
    (*indices)[0] = uint3(i, j, k);
    (*indices)[1] = uint3(ip1, j, k);
    (*indices)[2] = uint3(i, jp1, k);
    (*indices)[3] = uint3(ip1, jp1, k);
    (*indices)[4] = uint3(i, j, kp1);
    (*indices)[5] = uint3(ip1, j, kp1);
    (*indices)[6] = uint3(i, jp1, kp1);
    (*indices)[7] = uint3(ip1, jp1, kp1);
    
    (*weights)[0] = float3(
                           -_invGridSpacing.x * (1 - fy) * (1 - fz),
                           -_invGridSpacing.y * (1 - fx) * (1 - fz),
                           -_invGridSpacing.z * (1 - fx) * (1 - fy));
    (*weights)[1] = float3(
                           _invGridSpacing.x * (1 - fy) * (1 - fz),
                           fx * (-_invGridSpacing.y) * (1 - fz),
                           fx * (1 - fy) * (-_invGridSpacing.z));
    (*weights)[2] = float3(
                           (-_invGridSpacing.x) * fy * (1 - fz),
                           (1 - fx) * _invGridSpacing.y * (1 - fz),
                           (1 - fx) * fy * (-_invGridSpacing.z));
    (*weights)[3] = float3(
                           _invGridSpacing.x * fy * (1 - fz),
                           fx * _invGridSpacing.y * (1 - fz),
                           fx * fy * (-_invGridSpacing.z));
    (*weights)[4] = float3(
                           (-_invGridSpacing.x) * (1 - fy) * fz,
                           (1 - fx) * (-_invGridSpacing.y) * fz,
                           (1 - fx) * (1 - fy) * _invGridSpacing.z);
    (*weights)[5] = float3(
                           _invGridSpacing.x * (1 - fy) * fz,
                           fx * (-_invGridSpacing.y) * fz,
                           fx * (1 - fy) * _invGridSpacing.z);
    (*weights)[6] = float3(
                           (-_invGridSpacing.x) * fy * fz,
                           (1 - fx) * _invGridSpacing.y * fz,
                           (1 - fx) * fy * _invGridSpacing.z);
    (*weights)[7] = float3(
                           _invGridSpacing.x * fy * fz,
                           fx * _invGridSpacing.y * fz,
                           fx * fy * _invGridSpacing.z);
}

//MARK: Implementation-CubicArraySampler3:-
template <typename T, typename R>
CubicArraySampler3<T, R>::CubicArraySampler(
                                            const thread ConstArrayAccessor3<T>& accessor,
                                            const float3 gridSpacing,
                                            const float3 gridOrigin) {
    _gridSpacing = gridSpacing;
    _origin = gridOrigin;
    _accessor = accessor;
}


template <typename T, typename R>
CubicArraySampler3<T, R>::CubicArraySampler(
                                            const thread CubicArraySampler& other) {
    _gridSpacing = other._gridSpacing;
    _origin = other._origin;
    _accessor = other._accessor;
}

template <typename T, typename R>
T CubicArraySampler3<T, R>::operator()(const float3 x) const {
    int i, j, k;
    int iSize = static_cast<int>(_accessor.size().x);
    int jSize = static_cast<int>(_accessor.size().y);
    int kSize = static_cast<int>(_accessor.size().z);
    R fx, fy, fz;
    
    VOX_ASSERT(_gridSpacing.x > numeric_limits<R>::epsilon() &&
               _gridSpacing.y > numeric_limits<R>::epsilon() &&
               _gridSpacing.z > numeric_limits<R>::epsilon());
    float3 normalizedX = (x - _origin) / _gridSpacing;
    
    getBarycentric(normalizedX.x, 0, iSize - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, jSize - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, kSize - 1, &k, &fz);
    
    int is[4] = {
        max(i - 1, kZeroSSize),
        i,
        min(i + 1, iSize - 1),
        min(i + 2, iSize - 1)
    };
    int js[4] = {
        max(j - 1, kZeroSSize),
        j,
        min(j + 1, jSize - 1),
        min(j + 2, jSize - 1)
    };
    int ks[4] = {
        max(k - 1, kZeroSSize),
        k,
        min(k + 1, kSize - 1),
        min(k + 2, kSize - 1)
    };
    
    T kValues[4];
    
    for (int kk = 0; kk < 4; ++kk) {
        T jValues[4];
        
        for (int jj = 0; jj < 4; ++jj) {
            jValues[jj] = monotonicCatmullRom(
                                              _accessor(is[0], js[jj], ks[kk]),
                                              _accessor(is[1], js[jj], ks[kk]),
                                              _accessor(is[2], js[jj], ks[kk]),
                                              _accessor(is[3], js[jj], ks[kk]),
                                              fx);
        }
        
        kValues[kk] = monotonicCatmullRom(
                                          jValues[0], jValues[1], jValues[2], jValues[3], fy);
    }
    
    return monotonicCatmullRom(
                               kValues[0], kValues[1], kValues[2], kValues[3], fz);
}

template class NearestArraySampler<float, float, 3>;
template class LinearArraySampler<float, float, 3>;
template class LinearArraySampler<float3, float, 3>;
template class CubicArraySampler<float, float, 3>;
template class CubicArraySampler<float3, float, 3>;

#endif  // INCLUDE_VOX_ARRAY_SAMPLERS3_METAL_
