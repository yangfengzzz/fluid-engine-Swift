//
//  level_set_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D level set solver.
protocol LevelSetSolver2 {
    /// Reinitializes given scalar field to signed-distance field.
    /// - Parameters:
    ///   - inputSdf: Input signed-distance field which can be distorted.
    ///   - maxDistance: Max range of reinitialization.
    ///   - outputSdf: Output signed-distance field.
    func reinitialize(inputSdf:ScalarGrid2,
                      maxDistance:Float,
                      outputSdf: inout ScalarGrid2)
    
    /// Extrapolates given scalar field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input scalar field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output scalar field.
    func extrapolate(input:ScalarGrid2,
                     sdf:ScalarField2,
                     maxDistance:Float,
                     output: inout ScalarGrid2)
    
    /// Extrapolates given collocated vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input collocated vector field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output collocated vector field.
    func extrapolate(input:CollocatedVectorGrid2,
                     sdf:ScalarField2,
                     maxDistance:Float,
                     output: inout CollocatedVectorGrid2)
    
    /// Extrapolates given face-centered vector field from negative to positive SDF region.
    /// - Parameters:
    ///   - input: Input face-centered field to be extrapolated.
    ///   - sdf: Reference signed-distance field.
    ///   - maxDistance: Max range of extrapolation.
    ///   - output: Output face-centered vector field.
    func extrapolate(input:FaceCenteredGrid2,
                     sdf:ScalarField2,
                     maxDistance:Float,
                     output: inout FaceCenteredGrid2)
}
