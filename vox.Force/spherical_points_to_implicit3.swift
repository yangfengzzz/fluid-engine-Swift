//
//  spherical_points_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D points-to-implicit converter based on simple sphere model.
class SphericalPointsToImplicit3: PointsToImplicit3 {
    var _kernelRadius:Float = 1.0
    var _isOutputSdf:Bool = true
    
    /// Constructs the converter with given sphere radius.
    init(kernelRadius:Float = 1.0,
         isOutputSdf:Bool = true) {
        self._kernelRadius = kernelRadius
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
        particles.buildNeighborSearcher(maxSearchRadius: 2.0 * _kernelRadius)
        
        let neighborSearcher = particles.neighborSearcher()
        
        let temp = output.clone()
        temp.fill(){(x:Vector3F) in
            var minDist = 2.0 * _kernelRadius
            neighborSearcher.forEachNearbyPoint(
            origin: x, radius: 2.0 * _kernelRadius){(i:size_t, xj:Vector3F) in
                minDist = min(minDist, length(x - xj))
            }
            
            return minDist - _kernelRadius
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
