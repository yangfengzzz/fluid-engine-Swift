//
//  level_set_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D level set solver.
protocol LevelSetSolver3 {
    /// Reinitializes given scalar field to signed-distance field.
    /// - Parameters:
    ///   - inputSdf: Input signed-distance field which can be distorted.
    ///   - maxDistance: Max range of reinitialization.
    ///   - outputSdf: Output signed-distance field.
    func reinitialize(inputSdf:ScalarGrid3,
                      maxDistance:Float,
                      outputSdf: inout ScalarGrid3)
    
    /// Extrapolates given scalar field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input scalar field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output scalar field.
    func extrapolate(input:ScalarGrid3,
                     sdf:ScalarField3,
                     maxDistance:Float,
                     output: inout ScalarGrid3)
    
    /// Extrapolates given collocated vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input collocated vector field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output collocated vector field.
    func extrapolate(input:CollocatedVectorGrid3,
                     sdf:ScalarField3,
                     maxDistance:Float,
                     output: inout CollocatedVectorGrid3)
    
    /// Extrapolates given face-centered vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input face-centered field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output face-centered vector field.
    func extrapolate(input:FaceCenteredGrid3,
                     sdf:ScalarField3,
                     maxDistance:Float,
                     output: inout FaceCenteredGrid3)
}
