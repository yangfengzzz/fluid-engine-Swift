//
//  iterative_level_set_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D PDE-based iterative level set solver.
///
/// This class provides infrastructure for 3-D PDE-based iterative level set
/// solver. Internally, the class implements upwind-style wave propagation and
/// the inheriting classes must provide a way to compute the derivatives for
/// given grid points.
///
/// \see Osher, Stanley, and Ronald Fedkiw. Level set methods and dynamic
///     implicit surfaces. Vol. 153. Springer Science & Business Media, 3006.
class IterativeLevelSetSolver3: LevelSetSolver3 {
    var _maxCfl:Float = 0.5
    
    /// Reinitializes given scalar field to signed-distance field.
    /// - Parameters:
    ///   - inputSdf: Input signed-distance field which can be distorted.
    ///   - maxDistance: Max range of reinitialization.
    ///   - outputSdf: Output signed-distance field.
    func reinitialize(inputSdf: ScalarGrid3,
                      maxDistance: Float,
                      outputSdf: inout ScalarGrid3) {
        let size = inputSdf.dataSize()
        let gridSpacing = inputSdf.gridSpacing()
        
        if !inputSdf.hasSameShape(other: outputSdf) {
            fatalError()
        }
        
        var outputAcc = outputSdf.dataAccessor()
        
        let dtau = pseudoTimeStep(sdf: inputSdf.constDataAccessor(),
                                  gridSpacing: gridSpacing)
        let numberOfIterations = IterativeLevelSetSolver3.distanceToNumberOfIterations(distance: maxDistance,
                                                                                       dtau: dtau)
        
        copyRange3(input: inputSdf.constDataAccessor(),
                   sizeX: size.x, sizeY: size.y, sizeZ: size.z,
                   output: &outputAcc)
        
        let temp = Array3<Float>(size: size)
        var tempAcc = temp.accessor()
        
        logger.info("Reinitializing with pseudoTimeStep: \(dtau) numberOfIterations: \(numberOfIterations)")
        
        for _ in 0..<numberOfIterations {
            inputSdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                let s = IterativeLevelSetSolver3.sign(sdf: ConstArrayAccessor3<Float>(other: outputAcc),
                                                      gridSpacing: gridSpacing,
                                                      i: i, j: j, k: k)
                var dx:(Float, Float) = (0, 0)
                var dy:(Float, Float) = (0, 0)
                var dz:(Float, Float) = (0, 0)
                
                getDerivatives(grid: ConstArrayAccessor3<Float>(other: outputAcc),
                               gridSpacing: gridSpacing,
                               i: i, j: j, k: k,
                               dx: &dx, dy: &dy, dz: &dz)
                
                // Explicit Euler step
                var val:Float = outputAcc[i, j, k]
                    - dtau * max(s, 0.0)
                    * (sqrt(Math.square(of: max(dx.0, 0.0))
                        + Math.square(of: min(dx.1, 0.0))
                        + Math.square(of: max(dy.0, 0.0))
                        + Math.square(of: min(dy.1, 0.0))
                        + Math.square(of: max(dz.0, 0.0))
                        + Math.square(of: min(dz.1, 0.0))) - 1.0)
                val -= dtau * min(s, 0.0)
                    * (sqrt(Math.square(of: min(dx.0, 0.0))
                        + Math.square(of: max(dx.1, 0.0))
                        + Math.square(of: min(dy.0, 0.0))
                        + Math.square(of: max(dy.1, 0.0))
                        + Math.square(of: min(dz.0, 0.0))
                        + Math.square(of: max(dz.1, 0.0))) - 1.0)
                tempAcc[i, j, k] = val
            }
            
            swap(&tempAcc, &outputAcc)
        }
        
        var outputSdfAcc = outputSdf.dataAccessor()
        copyRange3(input: ConstArrayAccessor3<Float>(other: outputAcc),
                   sizeX: size.x, sizeY: size.y, sizeZ: size.z,
                   output: &outputSdfAcc)
    }
    
    /// Extrapolates given scalar field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input scalar field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output scalar field.
    func extrapolate(input: ScalarGrid3,
                     sdf: ScalarField3,
                     maxDistance: Float,
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
        
        var outW = w0.accessor()
        extrapolate(
            input: w.constAccessor(),
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
    
    /// Extrapolates given face-centered vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input face-centered field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output face-centered vector field.
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
        extrapolate(
            input: u,
            sdf: sdfAtU.constAccessor(),
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
        extrapolate(
            input: v,
            sdf: sdfAtV.constAccessor(),
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
        extrapolate(
            input: w,
            sdf: sdfAtW.constAccessor(),
            gridSpacing: gridSpacing,
            maxDistance: maxDistance,
            output: &outW)
    }
    
    /// Returns the maximum CFL limit.
    func maxCfl()->Float {
        return _maxCfl
    }
    
    /// Sets the maximum CFL limit.
    ///
    /// This function sets the maximum CFL limit for the internal upwind-style
    /// PDE calculation. The negative input will be clamped to 0.
    func setMaxCfl(newMaxCfl:Float) {
        _maxCfl = max(newMaxCfl, 0.0)
    }
    
    /// Computes the derivatives for given grid point.
    func getDerivatives(grid:ConstArrayAccessor3<Float>,
                        gridSpacing:Vector3F,
                        i:size_t, j:size_t, k:size_t,
                        dx: inout (Float, Float),
                        dy: inout (Float, Float),
                        dz: inout (Float, Float)) {
        fatalError()
    }
    
    func extrapolate(input:ConstArrayAccessor3<Float>,
                     sdf:ConstArrayAccessor3<Float>,
                     gridSpacing:Vector3F,
                     maxDistance:Float,
                     output: inout ArrayAccessor3<Float>) {
        let size = input.size()
        
        var outputAcc = output
        
        let dtau = pseudoTimeStep(sdf: sdf,gridSpacing: gridSpacing)
        let numberOfIterations
            = IterativeLevelSetSolver3.distanceToNumberOfIterations(distance: maxDistance, dtau: dtau)
        
        copyRange3(input: input,
                   sizeX: size.x, sizeY: size.y, sizeZ: size.z,
                   output: &outputAcc)
        
        let temp = Array3<Float>(size: size)
        var tempAcc = temp.accessor()
        
        for _ in 0..<numberOfIterations {
            parallelFor(beginIndexX: 0, endIndexX: size.x,
                        beginIndexY: 0, endIndexY: size.y,
                        beginIndexZ: 0, endIndexZ: size.z){
                            (i:size_t, j:size_t, k:size_t) in
                            if (sdf[i, j, k] >= 0) {
                                var dx:(Float, Float) = (0, 0)
                                var dy:(Float, Float) = (0, 0)
                                var dz:(Float, Float) = (0, 0)
                                let grad = gradient3(data: sdf, gridSpacing: gridSpacing, i: i, j: j, k: k)
                                
                                getDerivatives(grid: ConstArrayAccessor3<Float>(other: outputAcc),
                                               gridSpacing: gridSpacing,
                                               i: i, j: j, k: k,
                                               dx: &dx, dy: &dy, dz: &dz)
                                
                                tempAcc[i, j, k] = outputAcc[i, j, k]
                                    - dtau * (max(grad.x, 0.0) * dx.0
                                        + min(grad.x, 0.0) * dx.1
                                        + max(grad.y, 0.0) * dy.0
                                        + min(grad.y, 0.0) * dy.1
                                        + max(grad.z, 0.0) * dz.0
                                        + min(grad.z, 0.0) * dz.1)
                            } else {
                                tempAcc[i, j, k] = outputAcc[i, j, k]
                            }
            }
            
            swap(&tempAcc, &outputAcc)
        }
        
        copyRange3(input: ConstArrayAccessor3<Float>(other: outputAcc),
                   sizeX: size.x, sizeY: size.y, sizeZ: size.z,
                   output: &output)
    }
    
    static func distanceToNumberOfIterations(distance:Float,
                                             dtau:Float)->UInt {
        return UInt(ceil(distance / dtau))
    }
    
    static func sign(sdf:ConstArrayAccessor3<Float>,
                     gridSpacing:Vector3F,
                     i:size_t, j:size_t, k:size_t)->Float {
        let d = sdf[i, j, k]
        let e = min(gridSpacing.x, gridSpacing.y, gridSpacing.z)
        return d / sqrt(d * d + e * e)
    }
    
    func pseudoTimeStep(sdf:ConstArrayAccessor3<Float>,
                        gridSpacing:Vector3F)->Float {
        let size = sdf.size()
        
        let h = max(gridSpacing.x, gridSpacing.y)
        
        var maxS = -Float.greatestFiniteMagnitude
        var dtau = _maxCfl * h
        
        for k in 0..<size.z {
            for j in 0..<size.y {
                for i in 0..<size.x {
                    let s = IterativeLevelSetSolver3.sign(sdf: sdf, gridSpacing: gridSpacing,
                                                          i: i, j: j, k: k)
                    maxS = max(s, maxS)
                }
            }
        }
        
        while (dtau * maxS / h > _maxCfl) {
            dtau *= 0.5
        }
        
        return dtau
    }
}
