//
//  zhu_bridson_points_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D points-to-implicit converter based on Zhu and Bridson's method.
///
/// Zhu, Yongning, and Robert Bridson. "Animating sand as a fluid."
/// ACM Transactions on Graphics (TOG). Vol. 24. No. 3. ACM, 2005.
class ZhuBridsonPointsToImplicit3: PointsToImplicit3 {
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
        
        let particles = ParticleSystemData3()
        particles.addParticles(newPositions: points)
        particles.buildNeighborSearcher(maxSearchRadius: _kernelRadius)
        
        let neighborSearcher = particles.neighborSearcher()
        let isoContValue = _cutOffThreshold * _kernelRadius
        
        let temp = output.clone()
        temp.fill(){(x:Vector3F)->Float in
            var xAvg = Vector3F()
            var wSum:Float = 0.0
            let function = {(_:size_t, xi:Vector3F) in
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
            let solver = FmmLevelSetSolver3()
            solver.reinitialize(inputSdf: temp,
                                maxDistance: Float.greatestFiniteMagnitude,
                                outputSdf: &output)
        } else {
            var father_grid = output as Grid3
            temp.swap(other: &father_grid)
        }
    }
}
