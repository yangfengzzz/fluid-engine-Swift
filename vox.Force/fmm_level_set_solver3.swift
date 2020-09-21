//
//  fmm_level_set_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Three-dimensional fast marching method (FMM) implementation.
///
/// This class implements 3-D FMM. First-order upwind-style differencing is used
/// to solve the PDE.
///
/// https://math.berkeley.edu/~sethian/2006/Explanations/fast_marching_explain.html
/// Sethian, James A. "A fast marching level set method for monotonically
/// advancing fronts." Proceedings of the National Academy of Sciences 93.4
/// (1996): 1591-1595.
class FmmLevelSetSolver3: LevelSetSolver3 {
    func reinitialize(inputSdf: ScalarGrid3,
                      maxDistance: Float,
                      outputSdf: inout ScalarGrid3) {
        if !inputSdf.hasSameShape(other: outputSdf) {
            fatalError()
        }
        
        let size = inputSdf.dataSize()
        let gridSpacing = inputSdf.gridSpacing()
        let invGridSpacing = 1.0 / gridSpacing
        let invGridSpacingSqr = invGridSpacing * invGridSpacing
        var markers = Array3<CChar>(size: size)
        
        var output = outputSdf.dataAccessor()
        
        markers.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            output[i, j, k] = inputSdf[i, j, k]
        }
        
        // Solve geometrically near the boundary
        markers.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: output[i, j, k]) &&
                    ((i > 0 && !isInsideSdf(phi: output[i - 1, j, k])) ||
                        (i + 1 < size.x && !isInsideSdf(phi: output[i + 1, j, k])) ||
                        (j > 0 && !isInsideSdf(phi: output[i, j - 1, k])) ||
                        (j + 1 < size.y && !isInsideSdf(phi: output[i, j + 1, k])) ||
                        (k > 0 && !isInsideSdf(phi: output[i, j, k - 1])) ||
                        (k + 1 < size.z && !isInsideSdf(phi: output[i, j, k + 1])))) {
                output[i, j, k] = solveQuadNearBoundary(
                    markers: markers, output: inputSdf.dataAccessor(),
                    gridSpacing: gridSpacing,
                    invGridSpacingSqr: invGridSpacingSqr,
                    sign: -1.0, i: i, j: j, k: k)
            }
        }
        markers.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (!isInsideSdf(phi: output[i, j, k]) &&
                    ((i > 0 && isInsideSdf(phi: output[i - 1, j, k])) ||
                        (i + 1 < size.x && isInsideSdf(phi: output[i + 1, j, k])) ||
                        (j > 0 && isInsideSdf(phi: output[i, j - 1, k])) ||
                        (j + 1 < size.y && isInsideSdf(phi: output[i, j + 1, k])) ||
                        (k > 0 && isInsideSdf(phi: output[i, j, k - 1])) ||
                        (k + 1 < size.z && isInsideSdf(phi: output[i, j, k + 1])))) {
                output[i, j, k] = solveQuadNearBoundary(
                    markers: markers, output: inputSdf.dataAccessor(),
                    gridSpacing: gridSpacing,
                    invGridSpacingSqr: invGridSpacingSqr,
                    sign: 1.0, i: i, j: j, k: k)
            }
        }
        
        for _ in 0..<2 {
            // Build markers
            markers.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                if (isInsideSdf(phi: output[i, j, k])) {
                    markers[i, j, k] = kKnown
                } else {
                    markers[i, j, k] = kUnknown
                }
            }
            
            let compare = {(a:Point3UI, b:Point3UI) in
                return output[a.x, a.y, a.z] > output[b.x, b.y, b.z]
            }
            
            // Enqueue initial candidates
            var trial = PriorityQueue<Point3UI>(sort: compare)
            markers.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
                if (markers[i, j, k] != kKnown &&
                        ((i > 0 && markers[i - 1, j, k] == kKnown) ||
                            (i + 1 < size.x && markers[i + 1, j, k] == kKnown) ||
                            (j > 0 && markers[i, j - 1, k] == kKnown) ||
                            (j + 1 < size.y && markers[i, j + 1, k] == kKnown) ||
                            (k > 0 && markers[i, j, k - 1] == kKnown) ||
                            (k + 1 < size.z && markers[i, j, k + 1] == kKnown))) {
                    trial.enqueue(Point3UI(i, j, k))
                    markers[i, j, k] = kTrial
                }
            }
            
            // Propagate
            while (!trial.isEmpty) {
                let idx = trial.peek()
                _ = trial.dequeue()
                
                let i = idx!.x
                let j = idx!.y
                let k = idx!.z
                
                markers[i, j, k] = kKnown
                output[i, j, k] = solveQuad(markers: markers, output: output,
                                            gridSpacing: gridSpacing,
                                            invGridSpacingSqr: invGridSpacingSqr,
                                            i: i, j: j, k: k)
                
                if (output[i, j, k] > maxDistance) {
                    break
                }
                
                if (i > 0) {
                    if (markers[i - 1, j, k] == kUnknown) {
                        markers[i - 1, j, k] = kTrial
                        output[i - 1, j, k] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i - 1, j: j, k: k)
                        trial.enqueue(Point3UI(i - 1, j, k))
                    }
                }
                
                if (i + 1 < size.x) {
                    if (markers[i + 1, j, k] == kUnknown) {
                        markers[i + 1, j, k] = kTrial
                        output[i + 1, j, k] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i + 1, j: j, k: k)
                        trial.enqueue(Point3UI(i + 1, j, k))
                    }
                }
                
                if (j > 0) {
                    if (markers[i, j - 1, k] == kUnknown) {
                        markers[i, j - 1, k] = kTrial
                        output[i, j - 1, k] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i, j: j - 1, k: k)
                        trial.enqueue(Point3UI(i, j - 1, k))
                    }
                }
                
                if (j + 1 < size.y) {
                    if (markers[i, j + 1, k] == kUnknown) {
                        markers[i, j + 1, k] = kTrial
                        output[i, j + 1, k] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i, j: j + 1, k: k)
                        trial.enqueue(Point3UI(i, j + 1, k))
                    }
                }
                
                if (k > 0) {
                    if (markers[i, j, k - 1] == kUnknown) {
                        markers[i, j, k - 1] = kTrial
                        output[i, j, k - 1] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i, j: j, k: k - 1)
                        trial.enqueue(Point3UI(i, j, k - 1))
                    }
                }
                
                if (k + 1 < size.z) {
                    if (markers[i, j, k + 1] == kUnknown) {
                        markers[i, j, k + 1] = kTrial
                        output[i, j, k + 1] =
                            solveQuad(markers: markers, output: output,
                                      gridSpacing: gridSpacing,
                                      invGridSpacingSqr: invGridSpacingSqr,
                                      i: i, j: j, k: k + 1)
                        trial.enqueue(Point3UI(i, j, k + 1))
                    }
                }
            }
            
            // Flip the sign
            markers.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
                output[i, j, k] = -output[i, j, k]
            }
        }
    }
    
    func extrapolate(input: ScalarGrid3,
                     sdf: ScalarField3, maxDistance: Float,
                     output: inout ScalarGrid3) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        
        var sdfGrid = Array3<Float>(size: input.dataSize())
        let pos = input.dataPosition()
        sdfGrid.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            sdfGrid[i, j, k] = sdf.sample(x: pos(i, j, k))
        }
        
        var out = output.dataAccessor()
        extrapolate(input: input.constDataAccessor(),
                    sdf: sdfGrid.constAccessor(),
                    gridSpacing: input.gridSpacing(),
                    maxDistance: maxDistance, output: &out)
    }
    
    func extrapolate(input: CollocatedVectorGrid3,
                     sdf: ScalarField3, maxDistance: Float,
                     output: inout CollocatedVectorGrid3) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        
        var sdfGrid = Array3<Float>(size: input.dataSize())
        let pos = input.dataPosition()
        sdfGrid.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            sdfGrid[i, j, k] = sdf.sample(x: pos(i, j, k))
        }
        
        let gridSpacing = input.gridSpacing()
        
        var u = Array3<Float>(size: input.dataSize())
        let u0 = Array3<Float>(size: input.dataSize())
        var v = Array3<Float>(size: input.dataSize())
        let v0 = Array3<Float>(size: input.dataSize())
        var w = Array3<Float>(size: input.dataSize())
        let w0 = Array3<Float>(size: input.dataSize())
        
        input.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            u[i, j, k] = input[i, j, k].x
            v[i, j, k] = input[i, j, k].y
            w[i, j, k] = input[i, j, k].z
        }
        
        var outU = u0.accessor()
        extrapolate(input: u.constAccessor(),
                    sdf: sdfGrid.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outU)
        
        var outV = v0.accessor()
        extrapolate(input: v.constAccessor(),
                    sdf: sdfGrid.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outV)
        
        var outW = w0.accessor()
        extrapolate(input: w.constAccessor(),
                    sdf: sdfGrid.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outW)
        
        output.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            output[i, j, k].x = u[i, j, k]
            output[i, j, k].y = v[i, j, k]
            output[i, j, k].z = w[i, j, k]
        }
    }
    
    func extrapolate(input: FaceCenteredGrid3,
                     sdf: ScalarField3, maxDistance: Float,
                     output: inout FaceCenteredGrid3) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        
        let gridSpacing = input.gridSpacing()
        
        let u = input.uConstAccessor()
        let uPos = input.uPosition()
        var sdfAtU = Array3<Float>(size: u.size())
        input.parallelForEachUIndex(){(i:size_t, j:size_t, k:size_t) in
            sdfAtU[i, j, k] = sdf.sample(x: uPos(i, j, k))
        }
        
        var outU = output.uAccessor()
        extrapolate(input: u, sdf: sdfAtU.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outU)
        
        let v = input.vConstAccessor()
        let vPos = input.vPosition()
        var sdfAtV = Array3<Float>(size: v.size())
        input.parallelForEachVIndex(){(i:size_t, j:size_t, k:size_t) in
            sdfAtV[i, j, k] = sdf.sample(x: vPos(i, j, k))
        }
        
        var outV = output.vAccessor()
        extrapolate(input: v, sdf: sdfAtV.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outV)
        
        let w = input.wConstAccessor()
        let wPos = input.wPosition()
        var sdfAtW = Array3<Float>(size: w.size())
        input.parallelForEachWIndex(){(i:size_t, j:size_t, k:size_t) in
            sdfAtW[i, j, k] = sdf.sample(x: wPos(i, j, k))
        }
        
        var outW = output.wAccessor()
        extrapolate(input: w, sdf: sdfAtW.constAccessor(),
                    gridSpacing: gridSpacing,
                    maxDistance: maxDistance,
                    output: &outW)
    }
    
    func extrapolate(input:ConstArrayAccessor3<Float>,
                     sdf:ConstArrayAccessor3<Float>,
                     gridSpacing:Vector3F,
                     maxDistance:Float,
                     output: inout ArrayAccessor3<Float>) {
        let size = input.size()
        let invGridSpacing = 1.0 / gridSpacing
        
        // Build markers
        var markers = Array3<CChar>(size: size, initVal: kUnknown)
        markers.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: sdf[i, j, k])) {
                markers[i, j, k] = kKnown
            }
            output[i, j, k] = input[i, j, k]
        }
        
        let compare = {(a:Point3UI, b:Point3UI)->Bool in
            return sdf[a.x, a.y, a.z] > sdf[b.x, b.y, b.z]
        }
        
        // Enqueue initial candidates
        var trial = PriorityQueue<Point3UI>(sort: compare)
        markers.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (markers[i, j, k] == kKnown) {
                return
            }
            
            if (i > 0 && markers[i - 1, j, k] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
            
            if (i + 1 < size.x && markers[i + 1, j, k] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
            
            if (j > 0 && markers[i, j - 1, k] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
            
            if (j + 1 < size.y && markers[i, j + 1, k] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
            
            if (k > 0 && markers[i, j, k - 1] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
            
            if (k + 1 < size.z && markers[i, j, k + 1] == kKnown) {
                trial.enqueue(Point3UI(i, j, k))
                markers[i, j, k] = kTrial
                return
            }
        }
        
        // Propagate
        while (!trial.isEmpty) {
            let idx = trial.peek()
            _ = trial.dequeue()
            
            let i = idx!.x
            let j = idx!.y
            let k = idx!.z
            
            if (sdf[i, j, k] > maxDistance) {
                break
            }
            
            let grad = normalize(gradient3(data: sdf, gridSpacing: gridSpacing,
                                           i: i, j: j, k: k))
            
            var sum:Float = 0.0
            var count:Float = 0.0
            
            if (i > 0) {
                if (markers[i - 1, j, k] == kKnown) {
                    var weight = max(grad.x, 0.0) * invGridSpacing.x
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i - 1, j, k]
                    count += weight
                } else if (markers[i - 1, j, k] == kUnknown) {
                    markers[i - 1, j, k] = kTrial
                    trial.enqueue(Point3UI(i - 1, j, k))
                }
            }
            
            if (i + 1 < size.x) {
                if (markers[i + 1, j, k] == kKnown) {
                    var weight = -min(grad.x, 0.0) * invGridSpacing.x
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i + 1, j, k]
                    count += weight
                } else if (markers[i + 1, j, k] == kUnknown) {
                    markers[i + 1, j, k] = kTrial
                    trial.enqueue(Point3UI(i + 1, j, k))
                }
            }
            
            if (j > 0) {
                if (markers[i, j - 1, k] == kKnown) {
                    var weight = max(grad.y, 0.0) * invGridSpacing.y
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j - 1, k]
                    count += weight
                } else if (markers[i, j - 1, k] == kUnknown) {
                    markers[i, j - 1, k] = kTrial
                    trial.enqueue(Point3UI(i, j - 1, k))
                }
            }
            
            if (j + 1 < size.y) {
                if (markers[i, j + 1, k] == kKnown) {
                    var weight = -min(grad.y, 0.0) * invGridSpacing.y
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j + 1, k]
                    count += weight
                } else if (markers[i, j + 1, k] == kUnknown) {
                    markers[i, j + 1, k] = kTrial
                    trial.enqueue(Point3UI(i, j + 1, k))
                }
            }
            
            if (k > 0) {
                if (markers[i, j, k - 1] == kKnown) {
                    var weight = max(grad.z, 0.0) * invGridSpacing.z
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j, k - 1]
                    count += weight
                } else if (markers[i, j, k - 1] == kUnknown) {
                    markers[i, j, k - 1] = kTrial
                    trial.enqueue(Point3UI(i, j, k - 1))
                }
            }
            
            if (k + 1 < size.z) {
                if (markers[i, j, k + 1] == kKnown) {
                    var weight = -min(grad.z, 0.0) * invGridSpacing.z
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j, k + 1]
                    count += weight
                } else if (markers[i, j, k + 1] == kUnknown) {
                    markers[i, j, k + 1] = kTrial
                    trial.enqueue(Point3UI(i, j, k + 1))
                }
            }
            
            VOX_ASSERT(count > 0.0)
            
            output[i, j, k] = sum / count
            markers[i, j, k] = kKnown
        }
    }
}

//MARK:- Find geometric solution near the boundary
func solveQuadNearBoundary(markers:Array3<CChar>,
                           output:ArrayAccessor3<Float>,
                           gridSpacing:Vector3F,
                           invGridSpacingSqr:Vector3F,
                           sign:Float, i:size_t, j:size_t, k:size_t)->Float {
    let size = output.size()
    
    var hasX = false
    var phiX = Float.greatestFiniteMagnitude
    
    if (i > 0) {
        if (isInsideSdf(phi: sign * output[i - 1, j, k])) {
            hasX = true
            phiX = min(phiX, sign * output[i - 1, j, k])
        }
    }
    
    if (i + 1 < size.x) {
        if (isInsideSdf(phi: sign * output[i + 1, j, k])) {
            hasX = true
            phiX = min(phiX, sign * output[i + 1, j, k])
        }
    }
    
    var hasY = false
    var phiY = Float.greatestFiniteMagnitude
    
    if (j > 0) {
        if (isInsideSdf(phi: sign * output[i, j - 1, k])) {
            hasY = true
            phiY = min(phiY, sign * output[i, j - 1, k])
        }
    }
    
    if (j + 1 < size.y) {
        if (isInsideSdf(phi: sign * output[i, j + 1, k])) {
            hasY = true
            phiY = min(phiY, sign * output[i, j + 1, k])
        }
    }
    
    var hasZ = false
    var phiZ = Float.greatestFiniteMagnitude
    
    if (k > 0) {
        if (isInsideSdf(phi: sign * output[i, j, k - 1])) {
            hasZ = true
            phiZ = min(phiZ, sign * output[i, j, k - 1])
        }
    }
    
    if (k + 1 < size.z) {
        if (isInsideSdf(phi: sign * output[i, j, k + 1])) {
            hasZ = true
            phiZ = min(phiZ, sign * output[i, j, k + 1])
        }
    }
    
    VOX_ASSERT(hasX || hasY || hasZ)
    
    let absCenter = abs(output[i, j, k])
    
    let distToBndX =
        gridSpacing.x * absCenter / (absCenter + abs(phiX))
    
    let distToBndY =
        gridSpacing.y * absCenter / (absCenter + abs(phiY))
    
    let distToBndZ =
        gridSpacing.z * absCenter / (absCenter + abs(phiZ))
    
    var solution:Float = 0.0
    var denomSqr:Float = 0.0
    
    if (hasX) {
        denomSqr += 1.0 / Math.square(of: distToBndX)
    }
    if (hasY) {
        denomSqr += 1.0 / Math.square(of: distToBndY)
    }
    if (hasZ) {
        denomSqr += 1.0 / Math.square(of: distToBndZ)
    }
    
    solution = 1.0 / sqrt(denomSqr)
    
    return sign * solution
}

func solveQuad(markers:Array3<CChar>,
               output:ArrayAccessor3<Float>,
               gridSpacing:Vector3F,
               invGridSpacingSqr:Vector3F,
               i:size_t, j:size_t, k:size_t)->Float {
    let size = output.size()
    
    var hasX = false
    var phiX = Float.greatestFiniteMagnitude
    
    if (i > 0) {
        if (markers[i - 1, j, k] == kKnown) {
            hasX = true
            phiX = min(phiX, output[i - 1, j, k])
        }
    }
    
    if (i + 1 < size.x) {
        if (markers[i + 1, j, k] == kKnown) {
            hasX = true
            phiX = min(phiX, output[i + 1, j, k])
        }
    }
    
    var hasY = false
    var phiY = Float.greatestFiniteMagnitude
    
    if (j > 0) {
        if (markers[i, j - 1, k] == kKnown) {
            hasY = true
            phiY = min(phiY, output[i, j - 1, k])
        }
    }
    
    if (j + 1 < size.y) {
        if (markers[i, j + 1, k] == kKnown) {
            hasY = true
            phiY = min(phiY, output[i, j + 1, k])
        }
    }
    
    var hasZ = false
    var phiZ = Float.greatestFiniteMagnitude
    
    if (k > 0) {
        if (markers[i, j, k - 1] == kKnown) {
            hasZ = true
            phiZ = min(phiZ, output[i, j, k - 1])
        }
    }
    
    if (k + 1 < size.z) {
        if (markers[i, j, k + 1] == kKnown) {
            hasZ = true
            phiZ = min(phiZ, output[i, j, k + 1])
        }
    }
    
    VOX_ASSERT(hasX || hasY || hasZ)
    
    var solution:Float = 0.0
    
    // Initial guess
    if (hasX) {
        solution = max(solution, phiX + gridSpacing.x)
    }
    if (hasY) {
        solution = max(solution, phiY + gridSpacing.y)
    }
    if (hasZ) {
        solution = max(solution, phiZ + gridSpacing.z)
    }
    
    // Solve quad
    var a:Float = 0.0
    var b:Float = 0.0
    var c:Float = -1.0
    
    if (hasX) {
        a += invGridSpacingSqr.x
        b -= phiX * invGridSpacingSqr.x
        c += Math.square(of: phiX) * invGridSpacingSqr.x
    }
    if (hasY) {
        a += invGridSpacingSqr.y
        b -= phiY * invGridSpacingSqr.y
        c += Math.square(of: phiY) * invGridSpacingSqr.y
    }
    if (hasZ) {
        a += invGridSpacingSqr.z
        b -= phiZ * invGridSpacingSqr.z
        c += Math.square(of: phiZ) * invGridSpacingSqr.z
    }
    
    let det = b * b - a * c
    
    if (det > 0.0) {
        solution = (-b + sqrt(det)) / a
    }
    
    return solution
}
