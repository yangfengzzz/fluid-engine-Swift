//
//  anisotropic_points_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D points-to-implicit converter using Anisotropic kernels.
///
/// This class converts 3-D points to implicit surface using anisotropic kernels
/// so that the kernels are oriented and stretched to reflect the point
/// distribution more naturally (thus less bumps). The implementation is based
/// on Yu and Turk's 3013 paper with some modifications.
///
/// Yu, Jihun, and Greg Turk. "Reconstructing surfaces of particle-based
/// fluids using anisotropic kernels." ACM Transactions on Graphics (TOG)
/// 32.1 (2013): 5.
class AnisotropicPointsToImplicit3: PointsToImplicit3 {
    var _kernelRadius:Float = 1.0
    var _cutOffDensity:Float = 0.5
    var _positionSmoothingFactor:Float = 0.0
    var _minNumNeighbors:size_t = 8
    var _isOutputSdf:Bool = true
    
    /// Constructs the converter with given parameters.
    /// - Parameters:
    ///   - kernelRadius: Kernel radius for interpolations.
    ///   - cutOffDensity: Iso-contour density value.
    ///   - positionSmoothingFactor: Position smoothing factor.
    ///   - minNumNeighbors: Minimum number of neighbors to enable anisotropic kernel.
    init(kernelRadius:Float = 1.0,
         cutOffDensity:Float = 0.5,
         positionSmoothingFactor:Float = 0.5,
         minNumNeighbors:size_t = 8,
         isOutputSdf:Bool = true) {
        self._kernelRadius = kernelRadius
        self._cutOffDensity = cutOffDensity
        self._positionSmoothingFactor = positionSmoothingFactor
        self._minNumNeighbors = minNumNeighbors
        self._isOutputSdf = isOutputSdf
    }
    
    /// Converts the given points to implicit surface scalar field.
    func convert(points:ConstArrayAccessor1<Vector3F>,
                 output: inout ScalarGrid3) {
        let res = output.resolution()
        if (res.x * res.y * res.z == 0) {
            logger.warning("Empty grid is provided.")
            return
        }
        
        let bbox = output.boundingBox()
        if (bbox.isEmpty()) {
            logger.warning("Empty domain is provided.")
            return
        }
        
        let h = _kernelRadius
        let invH = 1 / h
        let r = 2.0 * h
        
        // Mean estimator for cov. mat.
        let meanNeighborSearcher = PointParallelHashGridSearcher3.builder().build()
        meanNeighborSearcher.build(points: points)
        
        logger.info("Built neighbor searcher.")
        
        let meanParticles = SphSystemData3()
        meanParticles.addParticles(newPositions: points)
        meanParticles.setNeighborSearcher(newNeighborSearcher: meanNeighborSearcher)
        meanParticles.setKernelRadius(kernelRadius: r)
        
        // Compute G and xMean
        var gs = Array<matrix_float3x3>(repeating: matrix_float3x3(1), count: points.size())
        var xMeans = Array1<Vector3F>(size: points.size())
        
        parallelFor(beginIndex: 0, endIndex: points.size()){(i:size_t) in
            let x = points[i]
            
            // Compute xMean
            var xMean = Vector3F()
            var wSum:Float = 0.0
            var numNeighbors:size_t = 0
            let getXMean = {(_:size_t, xj:Vector3F) in
                let wj = wij(distance: length(x - xj), r: r)
                wSum += wj
                xMean += wj * xj
                numNeighbors += 1
            }
            meanNeighborSearcher.forEachNearbyPoint(origin: x, radius: r, callback: getXMean)
            
            VOX_ASSERT(wSum > 0.0)
            xMean /= wSum
            
            xMeans[i] = Math.lerp(value0: x, value1: xMean, f: _positionSmoothingFactor)
            
            if (numNeighbors < _minNumNeighbors) {
                let g = matrix_float3x3(invH)
                gs[i] = g
            } else {
                // Compute covariance matrix
                // We start with small scale matrix (h*h) in order to
                // prevent zero covariance matrix when points are all
                // perfectly lined up.
                var cov = matrix_float3x3(h * h)
                wSum = 0.0
                let getCov = {(_:size_t, xj:Vector3F) in
                    let wj = wij(distance: length(xMean - xj), r: r)
                    wSum += wj
                    cov += wj * vvt(v: xj - xMean)
                }
                meanNeighborSearcher.forEachNearbyPoint(origin: x, radius: r, callback: getCov)
                
                cov *= 1.0/wSum
                
                // SVD
                var u = matrix_float3x3(1)
                var v = Vector3F()
                var w = matrix_float3x3(1)
                svd(a: cov, u: &u, w: &v, v: &w)
                
                // Take off the sign
                v.x = abs(v.x)
                v.y = abs(v.y)
                v.z = abs(v.z)
                
                // Constrain Sigma
                let maxSingularVal = v.max()
                let kr = 4.0
                v.x = max(v.x, maxSingularVal / Float(kr))
                v.y = max(v.y, maxSingularVal / Float(kr))
                v.z = max(v.z, maxSingularVal / Float(kr))
                let invSigma = matrix_float3x3(diagonal: 1.0 / v)
                
                // Compute G
                let scale = pow(v.x * v.y * v.z, 1.0 / 3.0);  // volume preservation
                let g = invH * scale * (w * invSigma * u.transpose)
                gs[i] = g
            }
        }
        
        logger.info("Computed G and means.")
        
        // SPH estimator
        meanParticles.setKernelRadius(kernelRadius: h)
        meanParticles.updateDensities()
        let d:ArrayAccessor1<Float> = meanParticles.densities()
        let m = meanParticles.mass()
        
        let meanNeighborSearcher3 = PointSimpleListSearcher3()
        meanNeighborSearcher3.build(points: xMeans.constAccessor())
        
        // Compute SDF
        let temp = output.clone()
        temp.fill(){(x:Vector3F) in
            var sum:Float = 0.0
            meanNeighborSearcher3.forEachNearbyPoint(origin: x, radius: r){
                (i:size_t, neighborPosition:Vector3F) in
                sum += m / d[i] * w(r: neighborPosition - x, g: gs[i], gDet: gs[i].determinant)
            }
            
            return _cutOffDensity - sum
        }
        
        logger.info("Computed SDF.")
        
        if (_isOutputSdf) {
            let solver = FmmLevelSetSolver3()
            solver.reinitialize(inputSdf: temp,
                                maxDistance: Float.greatestFiniteMagnitude,
                                outputSdf: &output)
            
            logger.info("Completed einitialization.")
        } else {
            var father_grid = output as Grid3
            temp.swap(other: &father_grid)
        }
        
        logger.info("Done converting points to implicit surface.")
    }
}

// MARK:- Utility
func vvt(v:Vector3F)->matrix_float3x3 {
    return matrix_float3x3(rows: [SIMD3<Float>(v.x * v.x, v.x * v.y, v.x * v.z),
                                  SIMD3<Float>(v.y * v.x, v.y * v.y, v.y * v.z),
                                  SIMD3<Float>(v.z * v.x, v.z * v.y, v.z * v.z)])
}

func w(r:Vector3F, g:matrix_float3x3, gDet:Float)->Float {
    let sigma = 315.0 / (64 * kPiF)
    return sigma * gDet * p(distance: length(g * r))
}
