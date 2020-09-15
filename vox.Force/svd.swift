//
//  svd.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

func sign(a:Float, b:Float)->Float {
    return b >= 0.0 ? abs(a) : -abs(a)
}

func pythag(a:Float, b:Float)->Float {
    let at = abs(a)
    let bt = abs(b)
    var ct:Float = 0
    var result:Float = 0
    
    if (at > bt) {
        ct = bt / at
        result = at * sqrt(1 + ct * ct)
    } else if (bt > 0) {
        ct = at / bt
        result = bt * sqrt(1 + ct * ct)
    } else {
        result = 0
    }
    
    return result
}

//MARK:- 2D SVD
/// Singular value decomposition (SVD).
///
/// This function decompose the input matrix \p a to \p u * \p w * \p v^T.
/// - Parameters:
///   - a: The input matrix to decompose.
///   - u: Left-most output matrix.
///   - w: The vector of singular values.
///   - v: Right-most output matrix.
func svd(a:matrix_float2x2,
         u: inout matrix_float2x2,
         w: inout Vector2F,
         v: inout matrix_float2x2) {
    let m = 2
    let n = 2
    
    var flag:Int = 0, i:Int = 0, l:Int = 0, nm:Int = 0
    var c:Float = 0, f:Float = 0, h:Float = 0, s:Float = 0, x:Float = 0, y:Float = 0, z:Float = 0
    var anorm:Float = 0, g:Float = 0, scale:Float = 0
    
    // Prepare workspace
    var rv1 = Vector2F()
    u = a
    w = Vector2F()
    v = matrix_float2x2()
    
    // Householder reduction to bidiagonal form
    for i in 0..<n {
        // left-hand reduction
        l = i + 1
        rv1[i] = scale * g
        g = 0
        s = 0
        scale = 0
        if (i < m) {
            for k in i..<m {
                scale += abs(u[k, i])
            }
            if (scale != 0) {
                for k in i..<m {
                    u[k, i] /= scale
                    s += u[k, i] * u[k, i]
                }
                f = u[i, i]
                g = -sign(a: sqrt(s), b: f)
                h = f * g - s
                u[i, i] = f - g
                if (i != n - 1) {
                    for j in l..<n {
                        s = 0
                        for k in i..<m {
                            s += u[k, i] * u[k, j]
                        }
                        f = s / h
                        for k in i..<m {
                            u[k, j] += f * u[k, i]
                        }
                    }
                }
                for k in i..<m {
                    u[k, i] *= scale
                }
            }
        }
        w[i] = scale * g
        
        // right-hand reduction
        g = 0
        s = 0
        scale = 0
        if (i < m && i != n - 1) {
            for k in l..<n {
                scale += abs(u[i, k])
            }
            if (scale != 0) {
                for k in l..<n {
                    u[i, k] /= scale
                    s += u[i, k] * u[i, k]
                }
                f = u[i, l]
                g = -sign(a: sqrt(s), b: f)
                h = f * g - s
                u[i, l] = f - g
                for k in l..<n {
                    rv1[k] = u[i, k] / h
                }
                if (i != m - 1) {
                    for j in l..<m {
                        s = 0
                        for k in l..<n {
                            s += u[j, k] * u[i, k]
                        }
                        for k in l..<n {
                            u[j, k] += s * rv1[k]
                        }
                    }
                }
                for k in l..<n {
                    u[i, k] *= scale
                }
            }
        }
        anorm = max(anorm, (abs(w[i]) + abs(rv1[i])))
    }
    
    // accumulate the right-hand transformation
    for i in stride(from: n-1, to: 0, by: -1) {
        if (i < n - 1) {
            if (g != 0) {
                for j in l..<n {
                    v[j, i] = ((u[i, j] / u[i, l]) / g)
                }
                // T division to avoid underflow
                for j in l..<n {
                    s = 0
                    for k in l..<n {
                        s += u[i, k] * v[k, j]
                    }
                    for k in l..<n {
                        v[k, j] += s * v[k, i]
                    }
                }
            }
            for j in l..<n {
                v[i, j] = 0
                v[j, i] = 0
            }
        }
        v[i, i] = 1
        g = rv1[i]
        l = i
    }
    
    // accumulate the left-hand transformation
    for i in stride(from: n-1, to: 0, by: -1) {
        l = i + 1
        g = w[i]
        if (i < n - 1) {
            for j in l..<n {
                u[i, j] = 0
            }
        }
        if (g != 0) {
            g = 1 / g
            if (i != n - 1) {
                for j in l..<n {
                    s = 0
                    for k in l..<m {
                        s += u[k, i] * u[k, j]
                    }
                    f = (s / u[i, i]) * g
                    for k in i..<m {
                        u[k, j] += f * u[k, i]
                    }
                }
            }
            for j in i..<m {
                u[j, i] = u[j, i] * g
            }
        } else {
            for j in i..<m {
                u[j, i] = 0
            }
        }
        u[i, i] += 1
    }
    
    // diagonalize the bidiagonal form
    for k in stride(from: n-1, to: 0, by: -1) {
        // loop over singular values
        for its in 0..<30 {
            // loop over allowed iterations
            flag = 1
            for l in stride(from: k, to: 0, by: -1) {
                // test for splitting
                nm = l - 1
                if (abs(rv1[l]) + anorm == anorm) {
                    flag = 0
                    break
                }
                if (abs(w[nm]) + anorm == anorm) {
                    break
                }
            }
            if (flag != 0) {
                c = 0
                s = 1
                for i in l...k {
                    f = s * rv1[i]
                    if (abs(f) + anorm != anorm) {
                        g = w[i]
                        h = pythag(a: f, b: g)
                        w[i] = h
                        h = 1 / h
                        c = g * h
                        s = -f * h
                        for j in 0..<m {
                            y = u[j, nm]
                            z = u[j, i]
                            u[j, nm] = y * c + z * s
                            u[j, i] = z * c - y * s
                        }
                    }
                }
            }
            z = w[k]
            if (l == k) {
                // convergence
                if (z < 0) {
                    // make singular value nonnegative
                    w[k] = -z
                    for j in 0..<n {
                        v[j, k] = -v[j, k]
                    }
                }
                break
            }
            if (its >= 30) {
                fatalError("No convergence after 30 iterations")
            }
            
            // shift from bottom 2 x 2 minor
            x = w[l]
            nm = k - 1
            y = w[nm]
            g = rv1[nm]
            h = rv1[k]
            f = ((y - z) * (y + z) + (g - h) * (g + h)) / (2 * h * y)
            g = pythag(a: f, b: 1)
            f = ((x - z) * (x + z) + h * ((y / (f + sign(a: g, b: f))) - h)) / x
            
            // next QR transformation
            c = 1
            s = 1
            for j in l..<nm {
                i = j + 1
                g = rv1[i]
                y = w[i]
                h = s * g
                g = c * g
                z = pythag(a: f, b: h)
                rv1[j] = z
                c = f / z
                s = h / z
                f = x * c + g * s
                g = g * c - x * s
                h = y * s
                y = y * c
                for jj in 0..<n {
                    x = v[jj, j]
                    z = v[jj, i]
                    v[jj, j] = x * c + z * s
                    v[jj, i] = z * c - x * s
                }
                z = pythag(a: f, b: h)
                w[j] = z
                if (z != 0) {
                    z = 1 / z
                    c = f * z
                    s = h * z
                }
                f = (c * g) + (s * y)
                x = (c * y) - (s * g)
                for jj in 0..<m {
                    y = u[jj, j]
                    z = u[jj, i]
                    u[jj, j] = y * c + z * s
                    u[jj, i] = z * c - y * s
                }
            }
            rv1[l] = 0
            rv1[k] = f
            w[k] = x
        }
    }
}

//MARK:- 3D SVD
/// Singular value decomposition (SVD).
///
/// This function decompose the input matrix \p a to \p u * \p w * \p v^T.
/// - Parameters:
///   - a: The input matrix to decompose.
///   - u: Left-most output matrix.
///   - w: The vector of singular values.
///   - v: Right-most output matrix.
func svd(a:matrix_float3x3,
         u: inout matrix_float3x3,
         w: inout Vector3F,
         v: inout matrix_float3x3) {
    let m = 3
    let n = 3
    
    var flag:Int = 0, i:Int = 0, l:Int = 0, nm:Int = 0
    var c:Float = 0, f:Float = 0, h:Float = 0, s:Float = 0, x:Float = 0, y:Float = 0, z:Float = 0
    var anorm:Float = 0, g:Float = 0, scale:Float = 0
    
    // Prepare workspace
    var rv1 = Vector3F()
    u = a
    w = Vector3F()
    v = matrix_float3x3()
    
    // Householder reduction to bidiagonal form
    for i in 0..<n {
        // left-hand reduction
        l = i + 1
        rv1[i] = scale * g
        g = 0
        s = 0
        scale = 0
        if (i < m) {
            for k in i..<m {
                scale += abs(u[k, i])
            }
            if (scale != 0) {
                for k in i..<m {
                    u[k, i] /= scale
                    s += u[k, i] * u[k, i]
                }
                f = u[i, i]
                g = -sign(a: sqrt(s), b: f)
                h = f * g - s
                u[i, i] = f - g
                if (i != n - 1) {
                    for j in l..<n {
                        s = 0
                        for k in i..<m {
                            s += u[k, i] * u[k, j]
                        }
                        f = s / h
                        for k in i..<m {
                            u[k, j] += f * u[k, i]
                        }
                    }
                }
                for k in i..<m {
                    u[k, i] *= scale
                }
            }
        }
        w[i] = scale * g
        
        // right-hand reduction
        g = 0
        s = 0
        scale = 0
        if (i < m && i != n - 1) {
            for k in l..<n {
                scale += abs(u[i, k])
            }
            if (scale != 0) {
                for k in l..<n {
                    u[i, k] /= scale
                    s += u[i, k] * u[i, k]
                }
                f = u[i, l]
                g = -sign(a: sqrt(s), b: f)
                h = f * g - s
                u[i, l] = f - g
                for k in l..<n {
                    rv1[k] = u[i, k] / h
                }
                if (i != m - 1) {
                    for j in l..<m {
                        s = 0
                        for k in l..<n {
                            s += u[j, k] * u[i, k]
                        }
                        for k in l..<n {
                            u[j, k] += s * rv1[k]
                        }
                    }
                }
                for k in l..<n {
                    u[i, k] *= scale
                }
            }
        }
        anorm = max(anorm, (abs(w[i]) + abs(rv1[i])))
    }
    
    // accumulate the right-hand transformation
    for i in stride(from: n-1, to: 0, by: -1) {
        if (i < n - 1) {
            if (g != 0) {
                for j in l..<n {
                    v[j, i] = ((u[i, j] / u[i, l]) / g)
                }
                // T division to avoid underflow
                for j in l..<n {
                    s = 0
                    for k in l..<n {
                        s += u[i, k] * v[k, j]
                    }
                    for k in l..<n {
                        v[k, j] += s * v[k, i]
                    }
                }
            }
            for j in l..<n {
                v[i, j] = 0
                v[j, i] = 0
            }
        }
        v[i, i] = 1
        g = rv1[i]
        l = i
    }
    
    // accumulate the left-hand transformation
    for i in stride(from: n-1, to: 0, by: -1) {
        l = i + 1
        g = w[i]
        if (i < n - 1) {
            for j in l..<n {
                u[i, j] = 0
            }
        }
        if (g != 0) {
            g = 1 / g
            if (i != n - 1) {
                for j in l..<n {
                    s = 0
                    for k in l..<m {
                        s += u[k, i] * u[k, j]
                    }
                    f = (s / u[i, i]) * g
                    for k in i..<m {
                        u[k, j] += f * u[k, i]
                    }
                }
            }
            for j in i..<m {
                u[j, i] = u[j, i] * g
            }
        } else {
            for j in i..<m {
                u[j, i] = 0
            }
        }
        u[i, i] += 1
    }
    
    // diagonalize the bidiagonal form
    for k in stride(from: n-1, to: 0, by: -1) {
        // loop over singular values
        for its in 0..<30 {
            // loop over allowed iterations
            flag = 1
            for l in stride(from: k, to: 0, by: -1) {
                // test for splitting
                nm = l - 1
                if (abs(rv1[l]) + anorm == anorm) {
                    flag = 0
                    break
                }
                if (abs(w[nm]) + anorm == anorm) {
                    break
                }
            }
            if (flag != 0) {
                c = 0
                s = 1
                for i in l...k {
                    f = s * rv1[i]
                    if (abs(f) + anorm != anorm) {
                        g = w[i]
                        h = pythag(a: f, b: g)
                        w[i] = h
                        h = 1 / h
                        c = g * h
                        s = -f * h
                        for j in 0..<m {
                            y = u[j, nm]
                            z = u[j, i]
                            u[j, nm] = y * c + z * s
                            u[j, i] = z * c - y * s
                        }
                    }
                }
            }
            z = w[k]
            if (l == k) {
                // convergence
                if (z < 0) {
                    // make singular value nonnegative
                    w[k] = -z
                    for j in 0..<n {
                        v[j, k] = -v[j, k]
                    }
                }
                break
            }
            if (its >= 30) {
                fatalError("No convergence after 30 iterations")
            }
            
            // shift from bottom 2 x 2 minor
            x = w[l]
            nm = k - 1
            y = w[nm]
            g = rv1[nm]
            h = rv1[k]
            f = ((y - z) * (y + z) + (g - h) * (g + h)) / (2 * h * y)
            g = pythag(a: f, b: 1)
            f = ((x - z) * (x + z) + h * ((y / (f + sign(a: g, b: f))) - h)) / x
            
            // next QR transformation
            c = 1
            s = 1
            for j in l..<nm {
                i = j + 1
                g = rv1[i]
                y = w[i]
                h = s * g
                g = c * g
                z = pythag(a: f, b: h)
                rv1[j] = z
                c = f / z
                s = h / z
                f = x * c + g * s
                g = g * c - x * s
                h = y * s
                y = y * c
                for jj in 0..<n {
                    x = v[jj, j]
                    z = v[jj, i]
                    v[jj, j] = x * c + z * s
                    v[jj, i] = z * c - x * s
                }
                z = pythag(a: f, b: h)
                w[j] = z
                if (z != 0) {
                    z = 1 / z
                    c = f * z
                    s = h * z
                }
                f = (c * g) + (s * y)
                x = (c * y) - (s * g)
                for jj in 0..<m {
                    y = u[jj, j]
                    z = u[jj, i]
                    u[jj, j] = y * c + z * s
                    u[jj, i] = z * c - y * s
                }
            }
            rv1[l] = 0
            rv1[k] = f
            w[k] = x
        }
    }
}
