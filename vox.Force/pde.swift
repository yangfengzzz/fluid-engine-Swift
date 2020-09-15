//
//  pde.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 1-st order upwind differencing.
/// - Parameters:
///   - D0: D0[1] is the origin.
/// - Returns: Returns two solutions for each side.
func upwind1(D0:[Float], dx:Float)->(Float, Float) {
    let invdx = 1/dx
    var dfx:(Float, Float) = (0, 0)
    dfx.0 = invdx*(D0[1] - D0[0])
    dfx.1 = invdx*(D0[2] - D0[1])
    return dfx
}

/// 1-st order upwind differencing.
/// - Parameters:
///   - D0: D0[1] is the origin.
func upwind1(D0:[Float], dx:Float,
             isDirectionPositive:Bool)->Float {
    let invdx = 1/dx
    return isDirectionPositive ? (invdx*(D0[1] - D0[0])) : invdx*(D0[2] - D0[1])
}


/// 2nd-order central differencing.
/// - Parameters:
///   - D0: D0[1] is the origin.
func cd2(D0:[Float], dx:Float)->Float {
    let hinvdx = 0.5/dx
    return hinvdx*(D0[2] - D0[0])
}

/// 3rd-order ENO.
/// - Parameters:
///   - D0: D0[3] is the origin.
/// - Returns: Returns two solutions for each side.
func eno3(D0:[Float], dx:Float)->(Float, Float) {
    let invdx = 1/dx
    let hinvdx = invdx/2
    let tinvdx = invdx/3
    var D1:[Float] = Array<Float>(repeating: 0, count: 6)
    var D2:[Float] = Array<Float>(repeating: 0, count: 5)
    var D3:[Float] = Array<Float>(repeating: 0, count: 2)
    var dQ1:Float = 0, dQ2:Float = 0, dQ3:Float = 0
    var c:Float = 0, cstar:Float = 0
    var Kstar:Int = 0
    var dfx:(Float, Float) = (0, 0)
    
    D1[0] = invdx*(D0[1] - D0[0])
    D1[1] = invdx*(D0[2] - D0[1])
    D1[2] = invdx*(D0[3] - D0[2])
    D1[3] = invdx*(D0[4] - D0[3])
    D1[4] = invdx*(D0[5] - D0[4])
    D1[5] = invdx*(D0[6] - D0[5])
    
    D2[0] = hinvdx*(D1[1] - D1[0])
    D2[1] = hinvdx*(D1[2] - D1[1])
    D2[2] = hinvdx*(D1[3] - D1[2])
    D2[3] = hinvdx*(D1[4] - D1[3])
    D2[4] = hinvdx*(D1[5] - D1[4])
    
    for K in 0..<2 {
        if (abs(D2[K+1]) < abs(D2[K+2])) {
            c = D2[K+1]
            Kstar = K-1
            D3[0] = tinvdx*(D2[K+1] - D2[K])
            D3[1] = tinvdx*(D2[K+2] - D2[K+1])
        } else {
            c = D2[K+2]
            Kstar = K
            D3[0] = tinvdx*(D2[K+2] - D2[K+1])
            D3[1] = tinvdx*(D2[K+3] - D2[K+2])
        }
        
        if (abs(D3[0]) < abs(D3[1])) {
            cstar = D3[0]
        } else {
            cstar = D3[1]
        }
        
        dQ1 = D1[K+2]
        dQ2 = c * (2.0 * (1.0 - Float(K)) - 1.0) * dx
        dQ3 = cstar * (3.0 * Math.square(of: 1.0-Float(Kstar))
            - 6.0 * (1.0 - Float(Kstar)) + 2.0) * dx * dx
        
        if K == 0 {
            dfx.0 = dQ1 + dQ2 + dQ3
        }else {
            dfx.1 = dQ1 + dQ2 + dQ3
        }
    }
    
    return dfx
}

/// 3rd-order ENO.
/// - Parameters:
///   - D0: D0[3] is the origin.
func eno3(D0:[Float], dx:Float, isDirectionPositive:Bool)->Float {
    let invdx = 1/dx
    let hinvdx = invdx/2
    let tinvdx = invdx/3
    var D1:[Float] = Array<Float>(repeating: 0, count: 6)
    var D2:[Float] = Array<Float>(repeating: 0, count: 5)
    var D3:[Float] = Array<Float>(repeating: 0, count: 2)
    var dQ1:Float = 0, dQ2:Float = 0, dQ3:Float = 0
    var c:Float = 0, cstar:Float = 0
    var Kstar:Int = 0
    
    D1[0] = invdx*(D0[1] - D0[0])
    D1[1] = invdx*(D0[2] - D0[1])
    D1[2] = invdx*(D0[3] - D0[2])
    D1[3] = invdx*(D0[4] - D0[3])
    D1[4] = invdx*(D0[5] - D0[4])
    D1[5] = invdx*(D0[6] - D0[5])
    
    D2[0] = hinvdx*(D1[1] - D1[0])
    D2[1] = hinvdx*(D1[2] - D1[1])
    D2[2] = hinvdx*(D1[3] - D1[2])
    D2[3] = hinvdx*(D1[4] - D1[3])
    D2[4] = hinvdx*(D1[5] - D1[4])
    
    let K = isDirectionPositive ? 0 : 1
    
    if (abs(D2[K+1]) < abs(D2[K+2])) {
        c = D2[K+1]
        Kstar = K-1
        D3[0] = tinvdx*(D2[K+1] - D2[K])
        D3[1] = tinvdx*(D2[K+2] - D2[K+1])
    } else {
        c = D2[K+2]
        Kstar = K
        D3[0] = tinvdx*(D2[K+2] - D2[K+1])
        D3[1] = tinvdx*(D2[K+3] - D2[K+2])
    }
    
    if (abs(D3[0]) < abs(D3[1])) {
        cstar = D3[0]
    } else {
        cstar = D3[1]
    }
    
    dQ1 = D1[K+2]
    dQ2 = c*(2*(1-Float(K))-1)*dx
    dQ3 = cstar*(3*Math.square(of: 1-Float(Kstar)) - 6*(1-Float(Kstar)) + 2)*dx*dx
    
    return dQ1 + dQ2 + dQ3
}

/// 5th-order Weno.
/// - Parameters:
///   - v: D0[3] is the origin.
/// - Returns: Returns two solutions for each side.
func weno5(v:[Float], h:Float, eps:Float = 1.0e-8)->(Float, Float) {
    let c_1_3:Float = 1.0/3.0, c_1_4:Float = 0.25, c_1_6:Float = 1.0/6.0
    let c_5_6:Float = 5.0/6.0, c_7_6:Float = 7.0/6.0, c_11_6:Float = 11.0/6.0
    let c_13_12:Float = 13.0/12.0
    
    let hInv = 1/h
    var dfx:(Float, Float) = (0, 0)
    var vdev = Array<Float>(repeating: 0, count: 5)
    
    for K in 0..<2 {
        if (K == 0) {
            for m in 0..<5 {
                vdev[m] = (v[m+1] - v[m]) * hInv
            }
        } else {
            for m in 0..<5 {
                vdev[m] = (v[6-m] - v[5-m]) * hInv
            }
        }
        
        let phix1:Float =   vdev[0] * c_1_3  - vdev[1] * c_7_6 + vdev[2] * c_11_6
        let phix2:Float =  -vdev[1] * c_1_6  + vdev[2] * c_5_6 + vdev[3] * c_1_3
        let phix3:Float =   vdev[2] * c_1_3  + vdev[3] * c_5_6 - vdev[4] * c_1_6
        
        let s1:Float = c_13_12 * Math.square(of: vdev[0] - 2*vdev[1] + vdev[2])
            + c_1_4 * Math.square(of: vdev[0] - 4*vdev[1] + 3*vdev[2])
        let s2:Float = c_13_12 * Math.square(of: vdev[1] - 2*vdev[2] + vdev[3])
            + c_1_4 * Math.square(of: vdev[1] - vdev[3])
        let s3:Float = c_13_12 * Math.square(of: vdev[2] - 2*vdev[3] + vdev[4])
            + c_1_4 * Math.square(of: 3*vdev[2] - 4*vdev[3] + vdev[4])
        
        let alpha1 = 0.1 / Math.square(of: s1 + eps)
        let alpha2 = 0.6 / Math.square(of: s2 + eps)
        let alpha3 = 0.3 / Math.square(of: s3 + eps)
        
        let sum = alpha1 + alpha2 + alpha3
        
        if K == 0 {
            dfx.0 = (alpha1 * phix1 + alpha2 * phix2 + alpha3 * phix3) / sum
        } else {
            dfx.1 = (alpha1 * phix1 + alpha2 * phix2 + alpha3 * phix3) / sum
        }
    }
    
    return dfx
}

/// 5th-order Weno.
/// - Parameters:
///   - v: D0[3] is the origin.
func weno5(v:[Float], h:Float,
           is_velocity_positive isDirectionPositive:Bool,
           eps:Float = 1.0e-8)->Float {
    let c_1_3:Float = 1.0/3.0, c_1_4:Float = 0.25, c_1_6:Float = 1.0/6.0
    let c_5_6:Float = 5.0/6.0, c_7_6:Float = 7.0/6.0, c_11_6:Float = 11.0/6.0
    let c_13_12:Float = 13.0/12.0
    
    let hInv = 1/h
    var vdev = Array<Float>(repeating: 0, count: 5)
    
    if (isDirectionPositive) {
        for m in 0..<5 {
            vdev[m] = (v[m+1] - v[m  ]) * hInv
        }
    } else {
        for m in 0..<5 {
            vdev[m] = (v[6-m] - v[5-m]) * hInv
        }
    }
    
    let phix1:Float =   vdev[0] * c_1_3  - vdev[1] * c_7_6 + vdev[2] * c_11_6
    let phix2:Float =   -vdev[1] * c_1_6  + vdev[2] * c_5_6 + vdev[3] * c_1_3
    let phix3:Float =   vdev[2] * c_1_3  + vdev[3] * c_5_6 - vdev[4] * c_1_6
    
    let s1:Float = c_13_12 * Math.square(of: vdev[0] - 2*vdev[1] + vdev[2])
        + c_1_4 * Math.square(of: vdev[0] - 4*vdev[1] + 3*vdev[2])
    let s2:Float = c_13_12 * Math.square(of: vdev[1] - 2*vdev[2] + vdev[3])
        + c_1_4 * Math.square(of: vdev[1] - vdev[3])
    let s3:Float = c_13_12 * Math.square(of: vdev[2] - 2*vdev[3] + vdev[4])
        + c_1_4 * Math.square(of: 3*vdev[2] - 4*vdev[3] + vdev[4])
    
    let alpha1 = 0.1 / Math.square(of: s1 + eps)
    let alpha2 = 0.6 / Math.square(of: s2 + eps)
    let alpha3 = 0.3 / Math.square(of: s3 + eps)
    
    let sum = alpha1 + alpha2 + alpha3
    
    return (alpha1 * phix1 + alpha2 * phix2 + alpha3 * phix3) / sum
}
