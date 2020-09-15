//
//  fmm_level_set_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

let kUnknown:CChar = 0
let kKnown:CChar = 1
let kTrial:CChar = 2

/// Two-dimensional fast marching method (FMM) implementation.
///
/// This class implements 2-D FMM. First-order upwind-style differencing is used
/// to solve the PDE.
///
/// https://math.berkeley.edu/~sethian/2006/Explanations/fast_marching_explain.html
/// Sethian, James A. "A fast marching level set method for monotonically
/// advancing fronts." Proceedings of the National Academy of Sciences 93.4
/// (1996): 1591-1595.
class FmmLevelSetSolver2: LevelSetSolver2 {
    /// Reinitializes given scalar field to signed-distance field.
    /// - Parameters:
    ///   - inputSdf: Input signed-distance field which can be distorted.
    ///   - maxDistance: Max range of reinitialization.
    ///   - outputSdf: Output signed-distance field.
    func reinitialize(inputSdf: ScalarGrid2,
                      maxDistance: Float,
                      outputSdf: inout ScalarGrid2) {
        if !inputSdf.hasSameShape(other: outputSdf) {
            fatalError()
        }
        
        let size = inputSdf.dataSize()
        let gridSpacing = inputSdf.gridSpacing()
        let invGridSpacing = 1.0 / gridSpacing
        let invGridSpacingSqr = invGridSpacing * invGridSpacing
        var markers = Array2<CChar>(size: size)
        
        var output = outputSdf.dataAccessor()
        
        markers.parallelForEachIndex(){(i:size_t, j:size_t) in
            output[i, j] = inputSdf[i, j]
        }
        
        // Solve geometrically near the boundary
        markers.forEachIndex(){(i:size_t, j:size_t) in
            if (!isInsideSdf(phi: output[i, j])
                && ((i > 0 && isInsideSdf(phi: output[i - 1, j]))
                    || (i + 1 < size.x && isInsideSdf(phi: output[i + 1, j]))
                    || (j > 0 && isInsideSdf(phi: output[i, j - 1]))
                    || (j + 1 < size.y && isInsideSdf(phi: output[i, j + 1])))) {
                output[i, j] = solveQuadNearBoundary(
                    markers: markers,
                    output: output,
                    gridSpacing: gridSpacing,
                    invGridSpacingSqr: invGridSpacingSqr,
                    sign: 1.0, i: i, j: j)
            } else if (isInsideSdf(phi: output[i, j])
                && ((i > 0 && !isInsideSdf(phi: output[i - 1, j]))
                    || (i + 1 < size.x && !isInsideSdf(phi: output[i + 1, j]))
                    || (j > 0 && !isInsideSdf(phi: output[i, j - 1]))
                    || (j + 1 < size.y && !isInsideSdf(phi: output[i, j + 1])))) {
                output[i, j] = solveQuadNearBoundary(
                    markers: markers,
                    output: output,
                    gridSpacing: gridSpacing,
                    invGridSpacingSqr: invGridSpacingSqr,
                    sign: -1.0, i: i, j: j)
            }
        }
        
        for _ in 0..<2 {
            // Build markers
            markers.parallelForEachIndex(){(i:size_t, j:size_t) in
                if (isInsideSdf(phi: output[i, j])) {
                    markers[i, j] = kKnown
                } else {
                    markers[i, j] = kUnknown
                }
            }
            
            let compare = {(a:Point2UI, b:Point2UI)->Bool in
                return output[a.x, a.y] > output[b.x, b.y]
            }
            
            // Enqueue initial candidates
            var trial = PriorityQueue<Point2UI>(sort: compare)
            markers.forEachIndex(){(i:size_t, j:size_t) in
                if (markers[i, j] != kKnown
                    && ((i > 0 && markers[i - 1, j] == kKnown)
                        || (i + 1 < size.x && markers[i + 1, j] == kKnown)
                        || (j > 0 && markers[i, j - 1] == kKnown)
                        || (j + 1 < size.y && markers[i, j + 1] == kKnown))) {
                    trial.enqueue(Point2UI(i, j))
                    markers[i, j] = kTrial
                }
            }
            
            // Propagate
            while (!trial.isEmpty) {
                let idx = trial.peek()
                _ = trial.dequeue()
                
                let i = idx!.x
                let j = idx!.y
                
                markers[i, j] = kKnown
                output[i, j] = solveQuad(
                    markers: markers, output: output,
                    gridSpacing: gridSpacing,
                    invGridSpacingSqr: invGridSpacingSqr,
                    i: i, j: j)
                
                if (output[i, j] > maxDistance) {
                    break
                }
                
                if (i > 0) {
                    if (markers[i - 1, j] == kUnknown) {
                        markers[i - 1, j] = kTrial
                        output[i - 1, j] = solveQuad(
                            markers: markers,
                            output: output,
                            gridSpacing: gridSpacing,
                            invGridSpacingSqr: invGridSpacingSqr,
                            i: i - 1, j: j)
                        trial.enqueue(Point2UI(i - 1, j))
                    }
                }
                
                if (i + 1 < size.x) {
                    if (markers[i + 1, j] == kUnknown) {
                        markers[i + 1, j] = kTrial
                        output[i + 1, j] = solveQuad(
                            markers: markers,
                            output: output,
                            gridSpacing: gridSpacing,
                            invGridSpacingSqr: invGridSpacingSqr,
                            i: i + 1, j: j)
                        trial.enqueue(Point2UI(i + 1, j))
                    }
                }
                
                if (j > 0) {
                    if (markers[i, j - 1] == kUnknown) {
                        markers[i, j - 1] = kTrial
                        output[i, j - 1] = solveQuad(
                            markers: markers,
                            output: output,
                            gridSpacing: gridSpacing,
                            invGridSpacingSqr: invGridSpacingSqr,
                            i: i, j: j - 1)
                        trial.enqueue(Point2UI(i, j - 1))
                    }
                }
                
                if (j + 1 < size.y) {
                    if (markers[i, j + 1] == kUnknown) {
                        markers[i, j + 1] = kTrial
                        output[i, j + 1] = solveQuad(
                            markers: markers,
                            output: output,
                            gridSpacing: gridSpacing,
                            invGridSpacingSqr: invGridSpacingSqr,
                            i: i, j: j + 1)
                        trial.enqueue(Point2UI(i, j + 1))
                    }
                }
            }
            
            // Flip the sign
            markers.parallelForEachIndex(){(i:size_t, j:size_t) in
                output[i, j] = -output[i, j]
            }
        }
    }
    
    /// Extrapolates given scalar field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input scalar field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output scalar field.
    func extrapolate(input: ScalarGrid2,
                     sdf: ScalarField2,
                     maxDistance: Float,
                     output: inout ScalarGrid2) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        
        var sdfGrid = Array2<Float>(size: input.dataSize())
        let pos = input.dataPosition()
        sdfGrid.parallelForEachIndex(){(i:size_t, j:size_t) in
            sdfGrid[i, j] = sdf.sample(x: pos(i, j))
        }
        
        var out = output.dataAccessor()
        extrapolate(
            input: input.constDataAccessor(),
            sdf: sdfGrid.constAccessor(),
            gridSpacing: input.gridSpacing(),
            maxDistance: maxDistance,
            output: &out)
    }
    
    /// Extrapolates given collocated vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input collocated vector field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output collocated vector field.
    func extrapolate(input: CollocatedVectorGrid2,
                     sdf: ScalarField2, maxDistance: Float,
                     output: inout CollocatedVectorGrid2) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        
        var sdfGrid = Array2<Float>(size: input.dataSize())
        let pos = input.dataPosition()
        sdfGrid.parallelForEachIndex(){(i:size_t, j:size_t) in
            sdfGrid[i, j] = sdf.sample(x: pos(i, j))
        }
        
        let gridSpacing = input.gridSpacing()
        
        var u = Array2<Float>(size: input.dataSize())
        let u0 = Array2<Float>(size: input.dataSize())
        var v = Array2<Float>(size: input.dataSize())
        let v0 = Array2<Float>(size: input.dataSize())
        
        input.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
            u[i, j] = input[i, j].x
            v[i, j] = input[i, j].y
        }
        
        var outU = u0.accessor()
        extrapolate(
            input: u.constAccessor(),
            sdf: sdfGrid.constAccessor(),
            gridSpacing: gridSpacing,
            maxDistance: maxDistance,
            output: &outU)
        
        var outV = v0.accessor()
        extrapolate(
            input: v.constAccessor(),
            sdf: sdfGrid.constAccessor(),
            gridSpacing: gridSpacing,
            maxDistance: maxDistance,
            output: &outV)
        
        output.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
            output[i, j].x = u[i, j]
            output[i, j].y = v[i, j]
        }
    }
    
    /// Extrapolates given face-centered vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input face-centered field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output face-centered vector field.
    func extrapolate(input: FaceCenteredGrid2,
                     sdf: ScalarField2, maxDistance: Float,
                     output: inout FaceCenteredGrid2) {
        if !input.hasSameShape(other: output) {
            fatalError()
        }
        let gridSpacing = input.gridSpacing()
        
        let u = input.uConstAccessor()
        let uPos = input.uPosition()
        var sdfAtU = Array2<Float>(size: u.size())
        input.parallelForEachUIndex(){(i:size_t, j:size_t) in
            sdfAtU[i, j] = sdf.sample(x: uPos(i, j))
        }
        
        var outU = output.uAccessor()
        extrapolate(
            input: u,
            sdf: sdfAtU.constAccessor(),
            gridSpacing: gridSpacing,
            maxDistance: maxDistance,
            output: &outU)
        
        let v = input.vConstAccessor()
        let vPos = input.vPosition()
        var sdfAtV = Array2<Float>(size: v.size())
        input.parallelForEachVIndex(){(i:size_t, j:size_t) in
            sdfAtV[i, j] = sdf.sample(x: vPos(i, j))
        }
        
        var outV = output.vAccessor()
        extrapolate(
            input: v,
            sdf: sdfAtV.constAccessor(),
            gridSpacing: gridSpacing,
            maxDistance: maxDistance,
            output: &outV)
    }
    
    func extrapolate(input:ConstArrayAccessor2<Float>,
                     sdf:ConstArrayAccessor2<Float>,
                     gridSpacing:Vector2F,
                     maxDistance:Float,
                     output: inout ArrayAccessor2<Float>) {
        let size = input.size()
        let invGridSpacing = 1.0 / gridSpacing
        
        // Build markers
        var markers = Array2<CChar>(size: size, initVal: kUnknown)
        markers.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: sdf[i, j])) {
                markers[i, j] = kKnown
            }
            output[i, j] = input[i, j]
        }
        
        let compare = {(a:Point2UI, b:Point2UI)->Bool in
            return sdf[a.x, a.y] > sdf[b.x, b.y]
        }
        
        // Enqueue initial candidates
        var trial = PriorityQueue<Point2UI>(sort: compare)
        markers.forEachIndex(){(i:size_t, j:size_t) in
            if (markers[i, j] == kKnown) {
                return
            }
            
            if (i > 0 && markers[i - 1, j] == kKnown) {
                trial.enqueue(Point2UI(i, j))
                markers[i, j] = kTrial
                return
            }
            
            if (i + 1 < size.x && markers[i + 1, j] == kKnown) {
                trial.enqueue(Point2UI(i, j))
                markers[i, j] = kTrial
                return
            }
            
            if (j > 0 && markers[i, j - 1] == kKnown) {
                trial.enqueue(Point2UI(i, j))
                markers[i, j] = kTrial
                return
            }
            
            if (j + 1 < size.y && markers[i, j + 1] == kKnown) {
                trial.enqueue(Point2UI(i, j))
                markers[i, j] = kTrial
                return
            }
        }
        
        // Propagate
        while (!trial.isEmpty) {
            let idx = trial.peek()
            _ = trial.dequeue()
            
            let i = idx!.x
            let j = idx!.y
            
            if (sdf[i, j] > maxDistance) {
                break
            }
            
            let grad = normalize(gradient2(data: sdf,
                                           gridSpacing: gridSpacing,
                                           i: i, j: j))
            
            var sum:Float = 0.0
            var count:Float = 0.0
            
            if (i > 0) {
                if (markers[i - 1, j] == kKnown) {
                    var weight = max(grad.x, 0.0) * invGridSpacing.x
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i - 1, j]
                    count += weight
                } else if (markers[i - 1, j] == kUnknown) {
                    markers[i - 1, j] = kTrial
                    trial.enqueue(Point2UI(i - 1, j))
                }
            }
            
            if (i + 1 < size.x) {
                if (markers[i + 1, j] == kKnown) {
                    var weight = -min(grad.x, 0.0) * invGridSpacing.x
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i + 1, j]
                    count += weight
                } else if (markers[i + 1, j] == kUnknown) {
                    markers[i + 1, j] = kTrial
                    trial.enqueue(Point2UI(i + 1, j))
                }
            }
            
            if (j > 0) {
                if (markers[i, j - 1] == kKnown) {
                    var weight = max(grad.y, 0.0) * invGridSpacing.y
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j - 1]
                    count += weight
                } else if (markers[i, j - 1] == kUnknown) {
                    markers[i, j - 1] = kTrial
                    trial.enqueue(Point2UI(i, j - 1))
                }
            }
            
            if (j + 1 < size.y) {
                if (markers[i, j + 1] == kKnown) {
                    var weight = -min(grad.y, 0.0) * invGridSpacing.y
                    
                    // If gradient is zero, then just assign 1 to weight
                    if (weight < Float.leastNonzeroMagnitude) {
                        weight = 1.0
                    }
                    
                    sum += weight * output[i, j + 1]
                    count += weight
                } else if (markers[i, j + 1] == kUnknown) {
                    markers[i, j + 1] = kTrial
                    trial.enqueue(Point2UI(i, j + 1))
                }
            }
            
            assert(count > 0.0)
            
            output[i, j] = sum / count
            markers[i, j] = kKnown
        }
    }
}

//MARK:- Find geometric solution near the boundary
func solveQuadNearBoundary(markers:Array2<CChar>,
                           output:ArrayAccessor2<Float>,
                           gridSpacing:Vector2F,
                           invGridSpacingSqr:Vector2F,
                           sign:Float, i:size_t, j:size_t)->Float {
    let size = output.size()
    
    var hasX = false
    var phiX = Float.greatestFiniteMagnitude
    
    if (i > 0) {
        if (isInsideSdf(phi: sign * output[i - 1, j])) {
            hasX = true
            phiX = min(phiX, sign * output[i - 1, j])
        }
    }
    
    if (i + 1 < size.x) {
        if (isInsideSdf(phi: sign * output[i + 1, j])) {
            hasX = true
            phiX = min(phiX, sign * output[i + 1, j])
        }
    }
    
    var hasY = false
    var phiY = Float.greatestFiniteMagnitude
    
    if (j > 0) {
        if (isInsideSdf(phi: sign * output[i, j - 1])) {
            hasY = true
            phiY = min(phiY, sign * output[i, j - 1])
        }
    }
    
    if (j + 1 < size.y) {
        if (isInsideSdf(phi: sign * output[i, j + 1])) {
            hasY = true
            phiY = min(phiY, sign * output[i, j + 1])
        }
    }
    
    assert(hasX || hasY)
    
    let distToBndX
        = gridSpacing.x * abs(output[i, j])
            / (abs(output[i, j]) + abs(phiX))
    
    let distToBndY
        = gridSpacing.y * abs(output[i, j])
            / (abs(output[i, j]) + abs(phiY))
    
    var solution:Float = 0
    var denomSqr:Float = 0.0
    
    if (hasX) {
        denomSqr += 1.0 / Math.square(of: distToBndX)
    }
    if (hasY) {
        denomSqr += 1.0 / Math.square(of: distToBndY)
    }
    
    solution = 1.0 / sqrt(denomSqr)
    
    return sign * solution
}

func solveQuad(markers:Array2<CChar>,
               output:ArrayAccessor2<Float>,
               gridSpacing:Vector2F,
               invGridSpacingSqr:Vector2F,
               i:size_t, j:size_t)->Float {
    let size = output.size()
    
    var hasX = false
    var phiX = Float.greatestFiniteMagnitude
    
    if (i > 0) {
        if (markers[i - 1, j] == kKnown) {
            hasX = true
            phiX = min(phiX, output[i - 1, j])
        }
    }
    
    if (i + 1 < size.x) {
        if (markers[i + 1, j] == kKnown) {
            hasX = true
            phiX = min(phiX, output[i + 1, j])
        }
    }
    
    var hasY = false
    var phiY = Float.greatestFiniteMagnitude
    
    if (j > 0) {
        if (markers[i, j - 1] == kKnown) {
            hasY = true
            phiY = min(phiY, output[i, j - 1])
        }
    }
    
    if (j + 1 < size.y) {
        if (markers[i, j + 1] == kKnown) {
            hasY = true
            phiY = min(phiY, output[i, j + 1])
        }
    }
    
    assert(hasX || hasY)
    
    var solution:Float = 0.0
    
    // Initial guess
    if (hasX) {
        solution = phiX + gridSpacing.x
    }
    if (hasY) {
        solution = max(solution, phiY + gridSpacing.y)
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
    
    let det = b * b - a * c
    
    if (det > 0.0) {
        solution = (-b + sqrt(det)) / a
    }
    
    return solution
}
