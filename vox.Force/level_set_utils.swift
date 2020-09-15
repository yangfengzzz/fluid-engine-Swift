//
//  level_set_utils.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Returns true if \p phi is inside the implicit surface (< 0).
/// - Parameter phi: The level set value.
/// - Returns: True if inside the implicit surface, false otherwise.
func isInsideSdf<T:FloatingPoint>(phi:T)->Bool {
    return phi < 0
}

/// Returns smeared Heaviside function.
///
/// This function returns smeared (or smooth) Heaviside (or step) function
/// between 0 and 1. If \p phi is less than -1.5, it will return 0. If \p phi
/// is greater than 1.5, it will return 1. Between -1.5 and 1.5, the function
/// will return smooth profile between 0 and 1. Derivative of this function is
/// smearedDeltaSdf.
/// - Parameter phi: The level set value.
/// - Returns: Smeared Heaviside function.
func smearedHeavisideSdf(phi:Float)->Float {
    if (phi > 1.5) {
        return 1
    } else {
        if (phi < -1.5) {
            return 0
        } else {
            return 0.5 + phi / 3.0 +
                   0.5 * kInvPiF * sin(kPiF * phi / 1.5)
        }
    }
}

/// Returns smeared delta function.
///
/// This function returns smeared (or smooth) delta function between 0 and 1.
/// If \p phi is less than -1.5, it will return 0. If \p phi is greater than
/// 1.5, it will also return 0. Between -1.5 and 1.5, the function will return
/// smooth delta function. Integral of this function is smearedHeavisideSdf.
/// - Parameter phi: The level set value.
/// - Returns: Smeared delta function.
func smearedDeltaSdf(phi:Float)->Float {
    if (abs(phi) > 1.5) {
        return 0
    } else {
        return 1.0 / 3.0 + 1.0 / 3.0 * cos(kPiF * phi / 1.5)
    }
}

/// Returns the fraction occupied by the implicit surface.
///
/// The input parameters, \p phi0 and \p phi1, are the level set values,
/// measured from two nearby points. This function computes how much the
/// implicit surface occupies the line between two points. For example, if both
/// \p phi0 and \p phi1 are negative, it means the points are both inside the
/// surface, thus the function will return 1. If both are positive, it will
/// return 0 because both are outside the surface. If the signs are different,
/// then only one of the points is inside the surface and the function will
/// return a value between 0 and 1.
/// - Parameters:
///   - phi0: The level set value from the first point.
///   - phi1: The level set value from the second point.
/// - Returns: The fraction occupied by the implicit surface.
func fractionInsideSdf(phi0:Float, phi1:Float)->Float {
    if (isInsideSdf(phi: phi0) && isInsideSdf(phi: phi1)) {
        return 1
    } else if (isInsideSdf(phi: phi0) && !isInsideSdf(phi: phi1)) {
        return phi0 / (phi0 - phi1)
    } else if (!isInsideSdf(phi: phi0) && isInsideSdf(phi: phi1)) {
        return phi1 / (phi1 - phi0)
    } else {
        return 0
    }
}

func cycleArray<T>(arr: inout [T], size:Int) {
    let t = arr[0]
    for i in 0..<size - 1 {
        arr[i] = arr[i + 1]
    }
    arr[size - 1] = t
}

/// Returns the fraction occupied by the implicit surface.
///
/// Given four signed distance values (square corners), determine what fraction
/// of the square is "inside". The original implementation can be found from
/// Christopher Batty's variational fluid code at
/// https://github.com/christopherbatty/Fluid3D.
/// - Parameters:
///   - phiBottomLeft: The level set value on the bottom-left corner.
///   - phiBottomRight: The level set value on the bottom-right corner.
///   - phiTopLeft: The level set value on the top-left corner.
///   - phiTopRight: The level set value on the top-right corner.
/// - Returns: The fraction occupied by the implicit surface.
func fractionInside(phiBottomLeft:Float, phiBottomRight:Float,
                    phiTopLeft:Float, phiTopRight:Float)->Float {
    let inside_count:Int = (phiBottomLeft < 0 ? 1 : 0) + (phiTopLeft < 0 ? 1 : 0) +
                       (phiBottomRight < 0 ? 1 : 0) + (phiTopRight < 0 ? 1 : 0)
    var list:[Float] = [phiBottomLeft, phiBottomRight, phiTopRight, phiTopLeft]

    if (inside_count == 4) {
        return 1
    } else if (inside_count == 3) {
        // rotate until the positive value is in the first position
        while (list[0] < 0) {
            cycleArray(arr: &list, size: 4)
        }

        // Work out the area of the exterior triangle
        let side0 = 1 - fractionInsideSdf(phi0: list[0], phi1: list[3])
        let side1 = 1 - fractionInsideSdf(phi0: list[0], phi1: list[1])
        return 1 - 0.5 * side0 * side1
    } else if (inside_count == 2) {
        // rotate until a negative value is in the first position, and the next
        // negative is in either slot 1 or 2.
        while (list[0] >= 0 || !(list[1] < 0 || list[2] < 0)) {
            cycleArray(arr: &list, size: 4)
        }

        if (list[1] < 0) {  // the matching signs are adjacent
            let side_left = fractionInsideSdf(phi0: list[0], phi1: list[3])
            let side_right = fractionInsideSdf(phi0: list[1], phi1: list[2])
            return 0.5 * (side_left + side_right)
        } else {  // matching signs are diagonally opposite
            // determine the centre point's sign to disambiguate this case
            let middle_point = 0.25 * (list[0] + list[1] + list[2] + list[3])
            if (middle_point < 0) {
                var area:Float = 0

                // first triangle (top left)
                let side1 = 1 - fractionInsideSdf(phi0: list[0], phi1: list[3])
                let side3 = 1 - fractionInsideSdf(phi0: list[2], phi1: list[3])

                area += 0.5 * side1 * side3

                // second triangle (top right)
                let side2 = 1 - fractionInsideSdf(phi0: list[2], phi1: list[1])
                let side0 = 1 - fractionInsideSdf(phi0: list[0], phi1: list[1])
                area += 0.5 * side0 * side2

                return 1 - area
            } else {
                var area:Float = 0

                // first triangle (bottom left)
                let side0 = fractionInsideSdf(phi0: list[0], phi1: list[1])
                let side1 = fractionInsideSdf(phi0: list[0], phi1: list[3])
                area += 0.5 * side0 * side1

                // second triangle (top right)
                let side2 = fractionInsideSdf(phi0: list[2], phi1: list[1])
                let side3 = fractionInsideSdf(phi0: list[2], phi1: list[3])
                area += 0.5 * side2 * side3
                return area
            }
        }
    } else if (inside_count == 1) {
        // rotate until the negative value is in the first position
        while (list[0] >= 0) {
            cycleArray(arr: &list, size: 4)
        }

        // Work out the area of the interior triangle, and subtract from 1.
        let side0 = fractionInsideSdf(phi0: list[0], phi1: list[3])
        let side1 = fractionInsideSdf(phi0: list[0], phi1: list[1])
        return 0.5 * side0 * side1
    } else {
        return 0
    }
}

func distanceToZeroLevelSet(phi0:Float, phi1:Float)->Float {
    if (abs(phi0) + abs(phi1) > Float.leastNonzeroMagnitude) {
        return abs(phi0) / (abs(phi0) + abs(phi1))
    } else {
        return 0.5
    }
}
