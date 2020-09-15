//
//  zhu_bridson_points_to_implicit2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D points-to-implicit converter based on Zhu and Bridson's method.
///
/// Zhu, Yongning, and Robert Bridson. "Animating sand as a fluid."
/// ACM Transactions on Graphics (TOG). Vol. 24. No. 3. ACM, 2005.
class ZhuBridsonPointsToImplicit2: PointsToImplicit2 {
    var _kernelRadius:Float = 1.0
    var _cutOffThreshold:Float = 0.25
    var _isOutputSdf:Bool = true
    
    /// Constructs the converter with given kernel radius and cut-off threshold.
    init(kernelRadius:Float = 1.0,
         cutOffThreshold:Float = 0.25,
         isOutputSdf:Bool = true) {
        self._kernelRadius = kernelRadius
        self._cutOffThreshold = cutOffThreshold
        self._isOutputSdf = isOutputSdf
    }
    
    /// Converts the given points to implicit surface scalar field.
    func convert(points:ConstArrayAccessor1<Vector2F>,
                 output: inout ScalarGrid2) {
        let res = output.resolution()
        if (res.x * res.y == 0) {
            logger.warning("Empty grid is provided.")
            return
        }
        
        let bbox = output.boundingBox()
        if (bbox.isEmpty()) {
            logger.warning("Empty domain is provided.")
            return
        }
        
        let particles = ParticleSystemData2()
        particles.addParticles(newPositions: points)
        particles.buildNeighborSearcher(maxSearchRadius: _kernelRadius)
        
        let neighborSearcher = particles.neighborSearcher()
        let isoContValue = _cutOffThreshold * _kernelRadius
        
        let temp = output.clone()
        temp.fill(){(x:Vector2F)->Float in
            var xAvg = Vector2F()
            var wSum:Float = 0.0
            let function = {(_:size_t, xi:Vector2F) in
                let wi = k(s: length(x - xi) / self._kernelRadius)
                
                wSum += wi
                xAvg += wi * xi
            }
            neighborSearcher.forEachNearbyPoint(origin: x, radius: _kernelRadius,
                                                callback: function)
            
            if (wSum > 0.0) {
                xAvg /= wSum
                return length(x - xAvg) - isoContValue
            } else {
                return output.boundingBox().diagonalLength()
            }
        }
        
        if (_isOutputSdf) {
            let solver = FmmLevelSetSolver2()
            solver.reinitialize(inputSdf: temp,
                                maxDistance: Float.greatestFiniteMagnitude,
                                outputSdf: &output)
        } else {
            var father_grid = output as Grid2
            temp.swap(other: &father_grid)
        }
    }
}

func k(s:Float)->Float {
    return max(0.0, Math.cubic(of: 1.0 - s * s))
}
