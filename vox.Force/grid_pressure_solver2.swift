//
//  grid_pressure_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D grid-based pressure solver.
///
/// This class represents a 2-D grid-based pressure solver interface which can
/// be used as a sub-step of GridFluidSolver2. Inheriting classes must implement
/// the core GridPressureSolver2::solve function as well as the helper function
/// GridPressureSolver2::suggestedBoundaryConditionSolver.
protocol GridPressureSolver2 {
    /// Solves the pressure term and apply it to the velocity field.
    ///
    /// This function takes input velocity field and outputs pressure-applied
    /// velocity field. It also accepts extra arguments such as \p boundarySdf
    /// and \p fluidSdf that represent signed-distance representation of the
    /// boundary and fluid area. The negative region of \p boundarySdf means
    /// it is occupied by solid object. Also, the positive / negative area of
    /// the \p fluidSdf means it is occupied by fluid / atmosphere. If not
    /// specified, constant scalar field with kMaxD will be used for
    /// \p boundarySdf meaning that no boundary at all. Similarly, a constant
    /// field with -kMaxD will be used for \p fluidSdf which means it's fully
    /// occupied with fluid without any atmosphere.
    /// - Parameters:
    ///   - input: The input velocity field.
    ///   - timeIntervalInSeconds: The time interval for the sim.
    ///   - output: The output velocity field.
    ///   - boundarySdf: The SDF of the boundary.
    ///   - fluidSdf:   The SDF of the fluid/atmosphere.
    func solve(input:FaceCenteredGrid2, timeIntervalInSeconds:Double,
               output: inout FaceCenteredGrid2,
               boundarySdf:ScalarField2,
               boundaryVelocity:VectorField2,
               fluidSdf:ScalarField2)
    
    /// Returns the best boundary condition solver for this solver.
    ///
    /// This function returns the best boundary condition solver that works well
    /// with this pressure solver. Depending on the pressure solver
    /// implementation, different boundary condition solver might be used.
    func suggestedBoundaryConditionSolver()->GridBoundaryConditionSolver2
}
