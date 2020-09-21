//
//  constants.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

#if DEBUG
func VOX_ASSERT(_ condition:Bool) {
    assert(condition)
}
#else
func VOX_ASSERT(_ condition:Bool) {
}
#endif

enum KernelType: Int {
    case float = 0
    case float2 = 1
    case float3 = 2
    case float4 = 3
    
    case unsupported = 10
}

//MARK:- Zero
protocol ZeroInit {
    init()
    
    func getKernelType()->KernelType
}

extension Float : ZeroInit {
    func getKernelType()->KernelType {
        return .float
    }
}
extension Double : ZeroInit {
    func getKernelType()->KernelType {
        return .unsupported
    }
}

extension CChar : ZeroInit {
    func getKernelType()->KernelType {
        return .unsupported
    }
}

extension Int32 : ZeroInit {
    func getKernelType()->KernelType {
        return .unsupported
    }
}

extension UInt32 : ZeroInit {
    func getKernelType()->KernelType {
        return .unsupported
    }
}

// MARK:- Pi

/// Float-type pi.
let kPiF:Float = 3.14159265358979323846264338327950288

/// Double-type pi.
let kPiD:Double = 3.14159265358979323846264338327950288

/// Pi for type T.
/// - Returns: Pi
func pi() -> Double{
    return kPiD
}

/// Pi for type T.
/// - Returns: Pi
func pi() -> Float{
    return kPiF
}

// MARK:- Pi/2

/// Float-type pi/2.
let kHalfPiF:Float = 1.57079632679489661923132169163975144

/// Double-type pi/2.
let kHalfPiD:Double = 1.57079632679489661923132169163975144

/// Pi/2 for type T.
/// - Returns: Pi/2
func halfPi() -> Double{
    return kHalfPiD
}

/// Pi/2 for type T.
/// - Returns: Pi/2
func halfPi() -> Float{
    return kHalfPiF
}

// MARK:- Pi/4

/// Float-type pi/4.
let kQuarterPiF:Float = 0.785398163397448309615660845819875721

/// Double-type pi/4.
let kQuarterPiD:Double = 0.785398163397448309615660845819875721

/// Pi/4 for type T.
/// - Returns: Pi/4
func quarterPi() -> Double{
    return kQuarterPiD
}

/// Pi/4 for type T.
/// - Returns: Pi/4
func quarterPi() -> Float{
    return kQuarterPiF
}

// MARK:- 2*Pi

/// Float-type 2*pi.
let kTwoPiF:Float = Float(2.0 * kPiD)

/// Double-type 2*pi.
let kTwoPiD:Double = 2.0 * kPiD

/// 2*pi for type T.
/// - Returns: 2*Pi
func twoPi() -> Double{
    return kTwoPiD
}

/// 2*pi for type T.
/// - Returns: 2*Pi
func twoPi() -> Float{
    return kTwoPiF
}

// MARK:- 4*Pi

/// Float-type 4*pi.
let kFourPiF:Float = Float(4.0 * kPiD)

/// Double-type 4*pi.
let kFourPiD:Double = 4.0 * kPiD

/// 4*pi for type T.
/// - Returns: 4*Pi
func fourPi() -> Double{
    return kFourPiD
}

/// 4*pi for type T.
/// - Returns: 4*Pi
func fourPi() -> Float{
    return kFourPiF
}

// MARK:- 1/Pi

/// Float-type 1/pi.
let kInvPiF:Float = Float(1.0 / kPiD)

/// Double-type 1/pi.
let kInvPiD:Double = 1.0 / kPiD

/// 1/pi for type T.
/// - Returns: 1/pi
func invPi() -> Double{
    return kInvPiD
}

/// 1/pi for type T.
/// - Returns: 1/pi
func invPi() -> Float{
    return kInvPiF
}

// MARK:- 1/2*Pi

/// Float-type 1/2*pi.
let kInvTwoPiF:Float = Float(0.5 / kPiD)

/// Double-type 1/2*pi.
let kInvTwoPiD:Double = 0.5 / kPiD

/// 1/2*pi for type T.
/// - Returns: 1/2*pi
func invTwoPi() -> Double{
    return kInvTwoPiD
}

/// 1/2*pi for type T.
/// - Returns: 1/2*pi
func invTwoPi() -> Float{
    return kInvTwoPiF
}

// MARK:- 1/4*Pi

/// Float-type 1/4*pi.
let kInvFourPiF:Float = Float(0.25 / kPiD)

/// Double-type 1/4*pi.
let kInvFourPiD:Double = 0.25 / kPiD

/// 1/4*pi for type T.
/// - Returns: 1/4*pi
func invFourPi() -> Double{
    return kInvFourPiD
}

/// 1/4*pi for type T.
/// - Returns: 1/4*pi
func invFourPi() -> Float{
    return kInvFourPiF
}

// MARK:- Physics

//! Gravity.
let kGravity:Float = -9.8

//! Water density.
let kWaterDensity:Float = 1000.0

//! Speed of sound in water at 20 degrees celcius.
let kSpeedOfSoundInWater:Float = 1482.0

// MARK:- Common enums

//! No direction.
let kDirectionNone:Int = 0

//! Left direction.
let kDirectionLeft:Int = 1 << 0

//! RIght direction.
let kDirectionRight:Int = 1 << 1

//! Down direction.
let kDirectionDown:Int = 1 << 2

//! Up direction.
let kDirectionUp:Int = 1 << 3

//! Back direction.
let kDirectionBack:Int = 1 << 4

//! Front direction.
let kDirectionFront:Int = 1 << 5

//! All direction.
let kDirectionAll:Int = kDirectionLeft | kDirectionRight |
    kDirectionDown | kDirectionUp | kDirectionBack |
    kDirectionFront
