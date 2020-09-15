//
//  grid_diffusion_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D grid-based diffusion equation solver.
///
/// This class provides functions to solve the diffusion equation for different
/// types of fields. The target equation can be written as
/// \f$\frac{\partial f}{\partial t} = \mu\nabla^3 f\f$ where \f$\mu\f$ is
/// the diffusion coefficient. The field \f$f\f$ can be either scalar or vector
/// field.
protocol GridDiffusionSolver3 {
    /// Solves diffusion equation for a scalar field.
    /// - Parameters:
    ///   - source: Input scalar field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest: Output scalar field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source:ScalarGrid3,
               diffusionCoefficient:Float,
               timeIntervalInSeconds:Float,
               dest: inout ScalarGrid3,
               boundarySdf:ScalarField3,
               fluidSdf:ScalarField3)
    
    /// Solves diffusion equation for a collocated vector field.
    /// - Parameters:
    ///   - source: Input collocated vector field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest:  Output collocated vector field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source:CollocatedVectorGrid3,
               diffusionCoefficient:Float,
               timeIntervalInSeconds:Float,
               dest: inout CollocatedVectorGrid3,
               boundarySdf:ScalarField3,
               fluidSdf:ScalarField3)
    
    /// Solves diffusion equation for a face-centered vector field.
    /// - Parameters:
    ///   - source: Input face-centered vector field.
    ///   - diffusionCoefficient: Amount of diffusion.
    ///   - timeIntervalInSeconds: Small time-interval that diffusion occur.
    ///   - dest: Output face-centered vector field.
    ///   - boundarySdf: Shape of the solid boundary that is empty by default.
    ///   - fluidSdf: Shape of the fluid boundary that is full by default.
    func solve(source:FaceCenteredGrid3,
               diffusionCoefficient:Float,
               timeIntervalInSeconds:Float,
               dest: inout FaceCenteredGrid3,
               boundarySdf:ScalarField3,
               fluidSdf:ScalarField3)
}
