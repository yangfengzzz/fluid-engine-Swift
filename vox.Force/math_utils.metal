//
//  math_utils.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_MATH_UTILS_METAL_
#define INCLUDE_VOX_MATH_UTILS_METAL_

#include <metal_stdlib>
using namespace metal;
#include "constants.metal"

///
/// \brief      Returns true if \p x and \p y are similar.
///
/// \param[in]  x     The first value.
/// \param[in]  y     The second value.
/// \param[in]  eps   The tolerance.
///
/// \tparam     T     Value type.
///
/// \return     True if similar.
///
template <typename T>
inline bool similar(T x, T y, T eps) {
    return (abs(x - y) <= eps);
}

///
/// \brief      Returns the sign of the value.
///
/// \param[in]  x     Input value.
///
/// \tparam     T     Value type.
///
/// \return     The sign.
///
template <typename T>
inline T sign(T x) {
    if (x >= 0) {
        return 1;
    } else {
        return -1;
    }
}

///
/// \brief      Returns the minimum value among three inputs.
///
/// \param[in]  x     The first value.
/// \param[in]  y     The second value.
/// \param[in]  z     The three value.
///
/// \tparam     T     Value type.
///
/// \return     The minimum value.
///
template <typename T>
inline T min3(T x, T y, T z) {
    return min(min(x, y), z);
}

///
/// \brief      Returns the maximum value among three inputs.
///
/// \param[in]  x     The first value.
/// \param[in]  y     The second value.
/// \param[in]  z     The three value.
///
/// \tparam     T     Value type.
///
/// \return     The maximum value.
///
template <typename T>
inline T max3(T x, T y, T z) {
    return max(max(x, y), z);
}

/// Returns minimum among n-elements.
template <typename T>
inline T minn(const thread T* x, size_t n) {
    T m = x[0];
    for (size_t i = 1; i < n; i++) {
        m = min(m, x[i]);
    }
    return m;
}

/// Returns maximum among n-elements.
template <typename T>
inline T maxn(const thread T* x, size_t n) {
    T m = x[0];
    for (size_t i = 1; i < n; i++) {
        m = max(m, x[i]);
    }
    return m;
}

///
/// \brief      Returns the absolute minimum value among the two inputs.
///
/// \param[in]  x     The first value.
/// \param[in]  y     The second value.
///
/// \tparam     T     Value type.
///
/// \return     The absolute minimum.
///
template <typename T>
inline T absmin(T x, T y) {
    return (x*x < y*y) ? x : y;
}

///
/// \brief      Returns the absolute maximum value among the two inputs.
///
/// \param[in]  x     The first value.
/// \param[in]  y     The second value.
///
/// \tparam     T     Value type.
///
/// \return     The absolute maximum.
///
template <typename T>
inline T absmax(T x, T y) {
    return (x*x > y*y) ? x : y;
}

/// Returns absolute minimum among n-elements.
template <typename T>
inline T absminn(const thread T* x, size_t n) {
    T m = x[0];
    for (size_t i = 1; i < n; i++) {
        m = absmin(m, x[i]);
    }
    return m;
}

/// Returns absolute maximum among n-elements.
template <typename T>
inline T absmaxn(const thread T* x, size_t n) {
    T m = x[0];
    for (size_t i = 1; i < n; i++) {
        m = absmax(m, x[i]);
    }
    return m;
}

template <typename T>
inline size_t argmin2(T x, T y) {
    return (x < y) ? 0 : 1;
}

template <typename T>
inline size_t argmax2(T x, T y) {
    return (x > y) ? 0 : 1;
}

template <typename T>
inline size_t argmin3(T x, T y, T z) {
    if (x < y) {
        return (x < z) ? 0 : 2;
    } else {
        return (y < z) ? 1 : 2;
    }
}

template <typename T>
inline size_t argmax3(T x, T y, T z) {
    if (x > y) {
        return (x > z) ? 0 : 2;
    } else {
        return (y > z) ? 1 : 2;
    }
}

///
/// \brief      Returns the square of \p x.
///
/// \param[in]  x     The input.
///
/// \tparam     T     Value type.
///
/// \return     The squared value.
///
template <typename T>
inline T square(T x) {
    return x * x;
}

///
/// \brief      Returns the cubic of \p x.
///
/// \param[in]  x     The input.
///
/// \tparam     T     Value type.
///
/// \return     The cubic of \p x.
///
template <typename T>
inline T cubic(T x) {
    return x * x * x;
}

///
/// \brief      Returns the clamped value.
///
/// \param[in]  val   The value.
/// \param[in]  low   The low value.
/// \param[in]  high  The high value.
///
/// \tparam     T     Value type.
///
/// \return     The clamped value.
///
template <typename T>
inline T clamp(T val, T low, T high) {
    if (val < low) {
        return low;
    } else if (val > high) {
        return high;
    } else {
        return val;
    }
}

///
/// \brief      Converts degrees to radians.
///
/// \param[in]  angleInDegrees The angle in degrees.
///
/// \tparam     T              Value type.
///
/// \return     Angle in radians.
///
template <typename T>
inline T degreesToRadians(T angleInDegrees) {
    return angleInDegrees * pi<T>() / 180;
}

///
/// \brief      Converts radians to degrees.
///
/// \param[in]  angleInRadians The angle in radians.
///
/// \tparam     T              Value type.
///
/// \return     Angle in degrees.
///
template <typename T>
inline T radiansToDegrees(T angleInRadians) {
    return angleInRadians * 180 / pi<T>();
}

///
/// \brief      Gets the barycentric coordinate.
///
/// \param[in]  x     The input value.
/// \param[in]  iLow  The lowest index.
/// \param[in]  iHigh The highest index.
/// \param      i     The output index.
/// \param      t     The offset from \p i.
///
/// \tparam     T     Value type.
///
template<typename T>
inline void getBarycentric(
                           T x,
                           int iLow,
                           int iHigh,
                           thread int* i,
                           thread T* f) {
    T s = floor(x);
    *i = static_cast<int>(s);
    
    int offset = -iLow;
    iLow += offset;
    iHigh += offset;
    
    if (iLow == iHigh) {
        *i = iLow;
        *f = 0;
    } else if (*i < iLow) {
        *i = iLow;
        *f = 0;
    } else if (*i > iHigh - 1) {
        *i = iHigh - 1;
        *f = 1;
    } else {
        *f = static_cast<T>(x - s);
    }
    
    *i -= offset;
}

///
/// \brief      Computes linear interpolation.
///
/// \param[in]  f0    The first value.
/// \param[in]  f1    The second value.
/// \param[in]  t     Relative offset [0, 1] from the first value.
///
/// \tparam     S     Input value type.
/// \tparam     T     Offset type.
///
/// \return     The interpolated value.
///
template<typename S, typename T>
inline S lerp(const S value0, const S value1, T f) {
    return (1 - f) * value0 + f * value1;
}

/// \brief      Computes bilinear interpolation.
template<typename S, typename T>
inline S bilerp(
                const S f00,
                const S f10,
                const S f01,
                const S f11,
                T tx, T ty) {
    return lerp(
                lerp(f00, f10, tx),
                lerp(f01, f11, tx),
                ty);
}

/// \brief      Computes trilinear interpolation.
template<typename S, typename T>
inline S trilerp(
                 const S f000,
                 const S f100,
                 const S f010,
                 const S f110,
                 const S f001,
                 const S f101,
                 const S f011,
                 const S f111,
                 T tx,
                 T ty,
                 T fz) {
    return lerp(
                bilerp(f000, f100, f010, f110, tx, ty),
                bilerp(f001, f101, f011, f111, tx, ty),
                fz);
}

/// \brief      Computes Catmull-Rom interpolation.
template <typename S, typename T>
inline S catmullRom(
                    const S f0,
                    const S f1,
                    const S f2,
                    const S f3,
                    T f) {
    S d1 = (f2 - f0) / 2;
    S d2 = (f3 - f1) / 2;
    S D1 = f2 - f1;
    
    S a3 = d1 + d2 - 2 * D1;
    S a2 = 3 * D1 - 2 * d1 - d2;
    S a1 = d1;
    S a0 = f1;
    
    return a3 * cubic(f) + a2 * square(f) + a1 * f + a0;
}

//MARK: monotonicCatmullRom:-
/// \brief      Computes monotonic Catmull-Rom interpolation.
inline float monotonicCatmullRom(
                                 const float f0,
                                 const float f1,
                                 const float f2,
                                 const float f3,
                                 float f) {
    float d1 = (f2 - f0) / 2;
    float d2 = (f3 - f1) / 2;
    float D1 = f2 - f1;
    
    if (fabs(D1) < kEpsilonF) {
        d1 = d2 = 0;
    }
    
    if (sign(D1) != sign(d1)) {
        d1 = 0;
    }
    
    if (sign(D1) != sign(d2)) {
        d2 = 0;
    }
    
    float a3 = d1 + d2 - 2 * D1;
    float a2 = 3 * D1 - 2 * d1 - d2;
    float a1 = d1;
    float a0 = f1;
    
    return a3 * cubic(f) + a2 * square(f) + a1 * f + a0;
}

inline float2 monotonicCatmullRom(const float2 v0, const float2 v1,
                                  const float2 v2, const float2 v3,
                                  float f) {
    const float two = static_cast<float>(2);
    const float three = static_cast<float>(3);
    
    float2 d1 = (v2 - v0) / two;
    float2 d2 = (v3 - v1) / two;
    float2 D1 = v2 - v1;
    
    if (fabs(D1.x) < numeric_limits<float>::epsilon() ||
        sign(D1.x) != sign(d1.x) || sign(D1.x) != sign(d2.x)) {
        d1.x = d2.x = 0;
    }
    
    if (fabs(D1.y) < numeric_limits<float>::epsilon() ||
        sign(D1.y) != sign(d1.y) || sign(D1.y) != sign(d2.y)) {
        d1.y = d2.y = 0;
    }
    
    float2 a3 = d1 + d2 - two * D1;
    float2 a2 = three * D1 - two * d1 - d2;
    float2 a1 = d1;
    float2 a0 = v1;
    
    return a3 * cubic(f) + a2 * square(f) + a1 * f + a0;
}

inline float3 monotonicCatmullRom(const float3 v0, const float3 v1,
                                  const float3 v2, const float3 v3,
                                  float f) {
    const float two = static_cast<float>(2);
    const float three = static_cast<float>(3);
    
    float3 d1 = (v2 - v0) / two;
    float3 d2 = (v3 - v1) / two;
    float3 D1 = v2 - v1;
    
    if (fabs(D1.x) < numeric_limits<float>::epsilon() ||
        sign(D1.x) != sign(d1.x) || sign(D1.x) != sign(d2.x)) {
        d1.x = d2.x = 0;
    }
    
    if (fabs(D1.y) < numeric_limits<float>::epsilon() ||
        sign(D1.y) != sign(d1.y) || sign(D1.y) != sign(d2.y)) {
        d1.y = d2.y = 0;
    }
    
    if (fabs(D1.z) < numeric_limits<float>::epsilon() ||
        sign(D1.z) != sign(d1.z) || sign(D1.z) != sign(d2.z)) {
        d1.z = d2.z = 0;
    }
    
    float3 a3 = d1 + d2 - two * D1;
    float3 a2 = three * D1 - two * d1 - d2;
    float3 a1 = d1;
    float3 a0 = v1;
    
    return a3 * cubic(f) + a2 * square(f) + a1 * f + a0;
}

inline float4 monotonicCatmullRom(const float4 v0, const float4 v1,
                                  const float4 v2, const float4 v3,
                                  float f) {
    const float two = static_cast<float>(2);
    const float three = static_cast<float>(3);
    
    float4 d1 = (v2 - v0) / two;
    float4 d2 = (v3 - v1) / two;
    float4 D1 = v2 - v1;
    
    if (fabs(D1.x) < numeric_limits<float>::epsilon() ||
        sign(D1.x) != sign(d1.x) || sign(D1.x) != sign(d2.x)) {
        d1.x = d2.x = 0;
    }
    
    if (fabs(D1.y) < numeric_limits<float>::epsilon() ||
        sign(D1.y) != sign(d1.y) || sign(D1.y) != sign(d2.y)) {
        d1.y = d2.y = 0;
    }
    
    if (fabs(D1.z) < numeric_limits<float>::epsilon() ||
        sign(D1.z) != sign(d1.z) || sign(D1.z) != sign(d2.z)) {
        d1.z = d2.z = 0;
    }
    
    if (fabs(D1.w) < numeric_limits<float>::epsilon() ||
        sign(D1.w) != sign(d1.w) || sign(D1.w) != sign(d2.w)) {
        d1.w = d2.w = 0;
    }
    
    float4 a3 = d1 + d2 - two * D1;
    float4 a2 = three * D1 - two * d1 - d2;
    float4 a1 = d1;
    float4 a0 = v1;
    
    return a3 * cubic(f) + a2 * square(f) + a1 * f + a0;
}

#endif  // INCLUDE_VOX_MATH_UTILS_METAL_
