//
//  samplers.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Returns randomly sampled direction within a cone.
///
/// For a given cone, defined by axis and angle, this function returns a sampled
/// direction vector within the cone.
/// - Parameters:
///   - u1: First random sample.
///   - u2: Second random sample.
///   - axis: The axis of the cone.
///   - angle: The angle of the cone.
/// - Returns: Sampled direction vector.
func uniformSampleCone(u1:Float, u2:Float,
                       axis:Vector3F,
                       angle:Float)->Vector3F {
    let cosAngle_2 = cos(angle / 2)
    let y:Float = 1 - (1 - cosAngle_2) * u1
    let r = sqrt(max(0, 1 - y * y))
    let phi = kTwoPiF * u2
    let x = r * cos(phi)
    let z = r * sin(phi)
    let ts = axis.tangential
    
    let result = ts[0] * x + axis * y
    return result + ts[1] * z
}

/// Returns randomly sampled point within a unit hemisphere.
///
/// For a given unit hemisphere, defined by center normal vector, this function
/// returns a point within the hemisphere.
/// - Parameters:
///   - u1: First random sample.
///   - u2: Second random sample.
///   - normal: The center normal of the hemisphere.
/// - Returns: Sampled point.
func uniformSampleHemisphere(u1:Float, u2:Float,
                             normal:Vector3F)->Vector3F {
    let y = u1
    let r = sqrt(max(0, 1 - y*y))
    let phi = kTwoPiF * u2
    let x = r * cos(phi)
    let z = r * sin(phi)
    let ts = normal.tangential
    
    let result = ts[0] * x + normal * y
    return result + ts[1] * z
}

/// Returns weighted sampled point on a hemisphere.
///
/// For a given hemisphere, defined by center normal vector, this function
/// returns a point on the hemisphere, where the probability is
/// consine-weighted.
/// - Parameters:
///   - u1: First random sample.
///   - u2: Second random sample.
///   - normal: The center normal of the hemisphere.
/// - Returns: Sampled point.
func cosineWeightedSampleHemisphere(u1:Float, u2:Float,
                                    normal:Vector3F)->Vector3F {
    let phi = kTwoPiF*u1
    let y = sqrt(u2)
    let theta = acos(y)
    let x = cos(phi) * sin(theta)
    let z = sin(phi) * sin(theta)
    let ts = normal.tangential
    
    let result = ts[0] * x + normal * y
    return result + ts[1] * z
}

/// Returns randomly a point on a sphere.
///
/// For a given sphere, defined by center normal vector, this function returns a
/// point on the sphere.
/// - Parameters:
///   - u1: First random sample.
///   - u2: Second random sample.
/// - Returns: Sampled point.
func uniformSampleSphere(u1:Float, u2:Float)->Vector3F {
    let y = 1 - 2 * u1
    let r = sqrt(max(0, 1 - y * y))
    let phi = kTwoPiF * u2
    let x = r * cos(phi)
    let z = r * sin(phi)
    return Vector3F(x, y, z)
}

/// Returns randomly a point on a disk.
///
/// For a given disk, this function returns a point on the disk.
/// - Parameters:
///   - u1: First random sample.
///   - u2: Second random sample.
/// - Returns: Sampled point.
func uniformSampleDisk(u1:Float, u2:Float)->Vector2F {
    let r = sqrt(u1)
    let theta = kTwoPiF * u2
    
    return Vector2F(r * cos(theta), r * sin(theta))
}
