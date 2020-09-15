//
//  physics_helpers.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

//MARK:- computeDragForce
func computeDragForce(dragCoefficient:Float,
                      radius:Float,
                      velocity:Vector2F)->Vector2F {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * kPiF * dragCoefficient * radius * velocity
}

func computeDragForce(dragCoefficient:Float,
                      radius:Float,
                      velocity:Vector3F)->Vector3F {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * kPiF * dragCoefficient * radius * velocity
}

//MARK:- projectAndApplyFriction
func projectAndApplyFriction(vel:Vector2F,
                             normal:Vector2F,
                             frictionCoefficient:Float)->Vector2F {
    var velt = vel.projected(with: normal)
    if (length_squared(velt) > 0) {
        let veln = max(-dot(vel, normal), 0.0)
        velt *= max(1.0 - frictionCoefficient * veln / length(velt), 0.0)
    }
    
    return velt
}

func projectAndApplyFriction(vel:Vector3F,
                             normal:Vector3F,
                             frictionCoefficient:Float)->Vector3F {
    var velt = vel.projected(with: normal)
    if (length_squared(velt) > 0) {
        let veln = max(-dot(vel, normal), 0.0)
        velt *= max(1.0 - frictionCoefficient * veln / length(velt), 0.0)
    }
    
    return velt
}

//MARK:- computePressureFromEos
func computePressureFromEos(density:Float,
                            targetDensity:Float,
                            eosScale:Float,
                            eosExponent:Float,
                            negativePressureScale:Float)->Float {
    // See Murnaghan-Tait equation of state from
    // https://en.wikipedia.org/wiki/Tait_equation
    var p = eosScale / eosExponent * (pow((density / targetDensity), eosExponent) - 1.0)
    
    // Negative pressure scaling
    if (p < 0) {
        p *= negativePressureScale
    }
    
    return p
}
