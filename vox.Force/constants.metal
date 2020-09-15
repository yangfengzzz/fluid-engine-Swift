//
//  constants.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_CONSTANTS_METAL_
#define INCLUDE_VOX_CONSTANTS_METAL_

#include <metal_stdlib>
using namespace metal;

// MARK: Zero:-

/// Zero size_t.
constant constexpr size_t kZeroSize = 0;

/// Zero ssize_t.
constant constexpr int kZeroSSize = 0;

/// Zero for type T.
template <typename T>
constexpr T zero() {
    return static_cast<T>(0);
}

/// Zero for float.
template <>
constexpr float zero<float>() {
    return 0.f;
}

// MARK: One:-

/// One size_t.
constant constexpr size_t kOneSize = 1;

/// One ssize_t.
constant constexpr int kOneSSize = 1;

/// One for type T.
template <typename T>
constexpr T one() {
    return 1;
}

/// One for float.
template <>
constexpr float one<float>() {
    return 1.f;
}

// MARK: Epsilon:-

/// Float-type epsilon.
constant constexpr float kEpsilonF = numeric_limits<float>::epsilon();

// MARK: Max:-

/// Max size_t.
constant constexpr size_t kMaxSize = numeric_limits<size_t>::max();

/// Max ssize_t.
constant constexpr int kMaxSSize = numeric_limits<int>::max();

/// Max float.
constant constexpr float kMaxF = numeric_limits<float>::max();

// MARK: Pi:-

/// Float-type pi.
constant constexpr float kPiF = 3.14159265358979323846264338327950288f;

/// Pi for type T.
template <typename T>
constexpr T pi() {
    return static_cast<T>(kPiF);
}

/// Pi for float.
template <>
constexpr float pi<float>() {
    return kPiF;
}

// MARK: Pi/2:-

/// Float-type pi/2.
constant constexpr float kHalfPiF = 1.57079632679489661923132169163975144f;

/// Pi/2 for type T.
template <typename T>
constexpr T halfPi() {
    return static_cast<T>(kHalfPiF);
}

/// Pi/2 for float.
template <>
constexpr float halfPi<float>() {
    return kHalfPiF;
}

// MARK: Pi/4:-

/// Float-type pi/4.
constant constexpr float kQuarterPiF = 0.785398163397448309615660845819875721f;

/// Pi/4 for type T.
template <typename T>
constexpr T quarterPi() {
    return static_cast<T>(kQuarterPiF);
}

/// Pi/2 for float.
template <>
constexpr float quarterPi<float>() {
    return kQuarterPiF;
}

// MARK: 2*Pi:-

/// Float-type 2*pi.
constant constexpr float kTwoPiF = static_cast<float>(2.0 * kPiF);

/// 2*pi for type T.
template <typename T>
constexpr T twoPi() {
    return static_cast<T>(kTwoPiF);
}

/// 2*pi for float.
template <>
constexpr float twoPi<float>() {
    return kTwoPiF;
}

// MARK: 4*Pi:-

/// Float-type 4*pi.
constant constexpr float kFourPiF = static_cast<float>(4.0 * kPiF);

/// 4*pi for type T.
template <typename T>
constexpr T fourPi() {
    return static_cast<T>(kFourPiF);
}

/// 4*pi for float.
template <>
constexpr float fourPi<float>() {
    return kFourPiF;
}

// MARK: 1/Pi:-

/// Float-type 1/pi.
constant constexpr float kInvPiF = static_cast<float>(1.0 / kPiF);

/// 1/pi for type T.
template <typename T>
constexpr T invPi() {
    return static_cast<T>(kInvPiF);
}

/// 1/pi for float.
template <>
constexpr float invPi<float>() {
    return kInvPiF;
}

// MARK: 1/2*Pi:-

/// Float-type 1/2*pi.
constant constexpr float kInvTwoPiF = static_cast<float>(0.5 / kPiF);

/// 1/2*pi for type T.
template <typename T>
constexpr T invTwoPi() {
    return static_cast<T>(kInvTwoPiF);
}

/// 1/2*pi for float.
template <>
constexpr float invTwoPi<float>() {
    return kInvTwoPiF;
}

// MARK: 1/4*Pi:-

/// Float-type 1/4*pi.
constant constexpr float kInvFourPiF = static_cast<float>(0.25 / kPiF);

/// 1/4*pi for type T.
template <typename T>
constexpr T invFourPi() {
    return static_cast<T>(kInvFourPiF);
}

/// 1/4*pi for float.
template <>
constexpr float invFourPi<float>() {
    return kInvFourPiF;
}

// MARK: Physics:-

/// Gravity.
constant constexpr float kGravity = -9.8;

/// Water density.
constant constexpr float kWaterDensity = 1000.0;

/// Speed of sound in water at 20 degrees celcius.
constant constexpr float kSpeedOfSoundInWater = 1482.0;

// MARK: Common enums:-

/// No direction.
constant constexpr int kDirectionNone = 0;

/// Left direction.
constant constexpr int kDirectionLeft = 1 << 0;

/// RIght direction.
constant constexpr int kDirectionRight = 1 << 1;

/// Down direction.
constant constexpr int kDirectionDown = 1 << 2;

/// Up direction.
constant constexpr int kDirectionUp = 1 << 3;

/// Back direction.
constant constexpr int kDirectionBack = 1 << 4;

/// Front direction.
constant constexpr int kDirectionFront = 1 << 5;

/// All direction.
constant constexpr int kDirectionAll = kDirectionLeft | kDirectionRight |
kDirectionDown | kDirectionUp | kDirectionBack |
kDirectionFront;

#endif  // INCLUDE_VOX_CONSTANTS_METAL_
