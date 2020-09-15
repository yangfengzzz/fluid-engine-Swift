//
//  iterative_level_set_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D PDE-based iterative level set solver.
///
/// This class provides infrastructure for 2-D PDE-based iterative level set
/// solver. Internally, the class implements upwind-style wave propagation and
/// the inheriting classes must provide a way to compute the derivatives for
/// given grid points.
///
/// \see Osher, Stanley, and Ronald Fedkiw. Level set methods and dynamic
///     implicit surfaces. Vol. 153. Springer Science & Business Media, 2006.
class IterativeLevelSetSolver2: LevelSetSolver2 {
    var _maxCfl:Float = 0.5
    
    /// Reinitializes given scalar field to signed-distance field.
    /// - Parameters:
    ///   - inputSdf: Input signed-distance field which can be distorted.
    ///   - maxDistance: Max range of reinitialization.
    ///   - outputSdf: Output signed-distance field.
    func reinitialize(inputSdf: ScalarGrid2,
                      maxDistance: Float,
                      outputSdf: inout ScalarGrid2) {
        let size = inputSdf.dataSize()
        let gridSpacing = inputSdf.gridSpacing()
        
        if !inputSdf.hasSameShape(other: outputSdf) {
            fatalError()
        }
        
        var outputAcc = outputSdf.dataAccessor()
        
        let dtau = pseudoTimeStep(sdf: inputSdf.constDataAccessor(),
                                  gridSpacing: gridSpacing)
        let numberOfIterations = IterativeLevelSetSolver2.distanceToNumberOfIterations(distance: maxDistance,
                                                                                       dtau: dtau)
        
        copyRange2(input: inputSdf.constDataAccessor(),
                   sizeX: size.x, sizeY: size.y,
                   output: &outputAcc)
        
        let temp = Array2<Float>(size: size)
        var tempAcc = temp.accessor()
        
        logger.info("Reinitializing with pseudoTimeStep: \(dtau) numberOfIterations: \(numberOfIterations)")
        
        for _ in 0..<numberOfIterations {
            inputSdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                let s = IterativeLevelSetSolver2.sign(sdf: ConstArrayAccessor2<Float>(other: outputAcc),
                                                      gridSpacing: gridSpacing,
                                                      i: i, j: j)
                var dx:(Float, Float) = (0, 0)
                var dy:(Float, Float) = (0, 0)
                
                getDerivatives(grid: ConstArrayAccessor2<Float>(other: outputAcc),
                               gridSpacing: gridSpacing,
                               i: i, j: j, dx: &dx, dy: &dy)
                
                // Explicit Euler step
                let val:Float = outputAcc[i, j]
                    - dtau * max(s, 0.0)
                    * (sqrt(Math.square(of: max(dx.0, 0.0))
                        + Math.square(of: min(dx.1, 0.0))
                        + Math.square(of: max(dy.0, 0.0))
                        + Math.square(of: min(dy.1, 0.0))) - 1.0)
                    - dtau * min(s, 0.0)
                    * (sqrt(Math.square(of: min(dx.0, 0.0))
                        + Math.square(of: max(dx.1, 0.0))
                        + Math.square(of: min(dy.0, 0.0))
                        + Math.square(of: max(dy.1, 0.0))) - 1.0)
                tempAcc[i, j] = val
            }
            
            swap(&tempAcc, &outputAcc)
        }
        
        var outputSdfAcc = outputSdf.dataAccessor()
        copyRange2(input: ConstArrayAccessor2<Float>(other: outputAcc),
                   sizeX: size.x, sizeY: size.y,
                   output: &outputSdfAcc)
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
    func getDerivatives(grid:ConstArrayAccessor2<Float>,
                        gridSpacing:Vector2F,
                        i:size_t, j:size_t,
                        dx: inout (Float, Float),
                        dy: inout (Float, Float)) {
        fatalError()
    }
    
    func extrapolate(input:ConstArrayAccessor2<Float>,
                     sdf:ConstArrayAccessor2<Float>,
                     gridSpacing:Vector2F,
                     maxDistance:Float,
                     output: inout ArrayAccessor2<Float>) {
        let size = input.size()
        
        var outputAcc = output
        
        let dtau = pseudoTimeStep(sdf: sdf,gridSpacing: gridSpacing)
        let numberOfIterations
            = IterativeLevelSetSolver2.distanceToNumberOfIterations(distance: maxDistance, dtau: dtau)
        
        copyRange2(input: input, sizeX: size.x, sizeY: size.y, output: &outputAcc)
        
        let temp = Array2<Float>(size: size)
        var tempAcc = temp.accessor()
        
        for _ in 0..<numberOfIterations {
            parallelFor(beginIndexX: 0, endIndexX: size.x,
                        beginIndexY: 0, endIndexY: size.y){
                            (i:size_t, j:size_t) in
                            if (sdf[i, j] >= 0) {
                                var dx:(Float, Float) = (0, 0)
                                var dy:(Float, Float) = (0, 0)
                                let grad = gradient2(data: sdf, gridSpacing: gridSpacing, i: i, j: j)
                                
                                getDerivatives(grid: ConstArrayAccessor2<Float>(other: outputAcc),
                                               gridSpacing: gridSpacing,
                                               i: i, j: j,
                                               dx: &dx, dy: &dy)
                                
                                tempAcc[i, j] = outputAcc[i, j]
                                    - dtau * (max(grad.x, 0.0) * dx.0
                                        + min(grad.x, 0.0) * dx.1
                                        + max(grad.y, 0.0) * dy.0
                                        + min(grad.y, 0.0) * dy.1)
                            } else {
                                tempAcc[i, j] = outputAcc[i, j]
                            }
            }
            
            swap(&tempAcc, &outputAcc)
        }
        
        copyRange2(input: ConstArrayAccessor2<Float>(other: outputAcc),
                   sizeX: size.x, sizeY: size.y,
                   output: &output)
    }
    
    static func distanceToNumberOfIterations(distance:Float,
                                             dtau:Float)->UInt {
        return UInt(ceil(distance / dtau))
    }
    
    static func sign(sdf:ConstArrayAccessor2<Float>,
                     gridSpacing:Vector2F,
                     i:size_t, j:size_t)->Float {
        let d = sdf[i, j]
        let e = min(gridSpacing.x, gridSpacing.y)
        return d / sqrt(d * d + e * e)
    }
    
    func pseudoTimeStep(sdf:ConstArrayAccessor2<Float>,
                        gridSpacing:Vector2F)->Float {
        let size = sdf.size()
        
        let h = max(gridSpacing.x, gridSpacing.y)
        
        var maxS = -Float.greatestFiniteMagnitude
        var dtau = _maxCfl * h
        
        for j in 0..<size.y {
            for i in 0..<size.x {
                let s = IterativeLevelSetSolver2.sign(sdf: sdf, gridSpacing: gridSpacing,
                                                      i: i, j: j)
                maxS = max(s, maxS)
            }
        }
        
        while (dtau * maxS / h > _maxCfl) {
            dtau *= 0.5
        }
        
        return dtau
    }
}
