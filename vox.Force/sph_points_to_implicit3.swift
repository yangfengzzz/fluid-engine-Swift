//
//  sph_points_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D points-to-implicit converter based on standard SPH kernel.
///
/// Müller, Matthias, David Charypar, and Markus Gross.
/// "Particle-based fluid simulation for interactive applications."
/// Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
/// animation. Eurographics Association, 2003.
class SphPointsToImplicit3: PointsToImplicit3 {
    var _kernelRadius:Float = 1.0
    var _cutOffDensity:Float = 0.5
    var _isOutputSdf:Bool = true
    
    /// Constructs the converter with given kernel radius and cut-off density.
    init(kernelRadius:Float = 1.0,
         cutOffDensity:Float = 0.5,
         isOutputSdf:Bool = true) {
        self._kernelRadius = kernelRadius
        self._cutOffDensity = cutOffDensity
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
        
        let sphParticles = SphSystemData3()
        sphParticles.addParticles(newPositions: points)
        sphParticles.setKernelRadius(kernelRadius: _kernelRadius)
        sphParticles.buildNeighborSearcher()
        sphParticles.updateDensities()
        
        let constData = Array1<Float>(size: sphParticles.numberOfParticles(), initVal: 1.0)
        let temp = output.clone()
        temp.fill(){(x:Vector3F) in
            let d:Float = sphParticles.interpolate(origin: x,
                                                   values: constData.constAccessor())
            return _cutOffDensity - d
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
