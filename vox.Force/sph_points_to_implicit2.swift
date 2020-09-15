//
//  sph_points_to_implicit2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D points-to-implicit converter based on standard SPH kernel.
///
/// Müller, Matthias, David Charypar, and Markus Gross.
/// "Particle-based fluid simulation for interactive applications."
/// Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
/// animation. Eurographics Association, 2003.
class SphPointsToImplicit2: PointsToImplicit2 {
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
        
        let sphParticles = SphSystemData2()
        sphParticles.addParticles(newPositions: points)
        sphParticles.setKernelRadius(kernelRadius: _kernelRadius)
        sphParticles.buildNeighborSearcher()
        sphParticles.updateDensities()
        
        let constData = Array1<Float>(size: sphParticles.numberOfParticles(), initVal: 1.0)
        let temp = output.clone()
        temp.fill(){(x:Vector2F) in
            let d:Float = sphParticles.interpolate(origin: x,
                                                   values: constData.constAccessor())
            return _cutOffDensity - d
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
