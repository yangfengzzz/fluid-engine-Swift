//
//  advection_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract based class for 2-D grid-based advection solver.
///
/// The implementation of this abstract base class should solve 2-D advection
/// equation for scalar and vector fields.
protocol AdvectionSolver2 {
    /// Solves advection equation for given scalar grid.
    ///
    /// The implementation of this virtual function should solve advection
    /// equation for given scalar field \p input and underlying vector field
    /// \p flow that carries the input field. The solution after solving the
    /// equation for given time-step \p dt should be stored in scalar field
    /// \p output. The boundary interface is given by a signed-distance field.
    /// The field is negative inside the boundary. By default, a constant field
    /// with max double value (kMaxD) is used, meaning no boundary.
    /// - Parameters:
    ///   - input:  Input scalar grid.
    ///   - flow: Vector field that advects the input field.
    ///   - dt: Time-step for the advection.
    ///   - output: Output scalar grid.
    ///   - boundarySdf: Boundary interface defined by signed-distance field.
    func advect(input:ScalarGrid2,
                flow:VectorField2,
                dt:Float,
                output:inout ScalarGrid2,
                boundarySdf:ScalarField2)
    
    
    /// Solves advection equation for given collocated vector grid.
    ///
    /// The implementation of this virtual function should solve advection
    /// equation for given collocated vector grid \p input and underlying vector
    /// field \p flow that carries the input field. The solution after solving
    /// the equation for given time-step \p dt should be stored in vector field
    /// \p output. The boundary interface is given by a signed-distance field.
    /// The field is negative inside the boundary. By default, a constant field
    /// with max double value (kMaxD) is used, meaning no boundary.
    /// - Parameters:
    ///   - input: Input vector grid.
    ///   - flow: Vector field that advects the input field.
    ///   - dt: Time-step for the advection.
    ///   - output: Output vector grid.
    ///   - boundarySdf: Boundary interface defined by signed-distance field.
    func advect(input:CollocatedVectorGrid2,
                flow:VectorField2,
                dt:Float,
                output:inout CollocatedVectorGrid2,
                boundarySdf:ScalarField2)
    
    /// Solves advection equation for given face-centered vector grid.
    ///
    /// The implementation of this virtual function should solve advection
    /// equation for given face-centered vector field \p input and underlying
    /// vector field \p flow that carries the input field. The solution after
    /// solving the equation for given time-step \p dt should be stored in
    /// vector field \p output. The boundary interface is given by a
    /// signed-distance field. The field is negative inside the boundary. By
    /// default, a constant field with max double value (kMaxD) is used, meaning
    /// no boundary.
    /// - Parameters:
    ///   - input: Input vector grid.
    ///   - flow: Vector field that advects the input field.
    ///   - dt: Time-step for the advection.
    ///   - output: Output vector grid.
    ///   - boundarySdf: Boundary interface defined by signed-distance  field.
    func advect(input:FaceCenteredGrid2,
                flow:VectorField2,
                dt:Float,
                output: inout FaceCenteredGrid2,
                boundarySdf:ScalarField2)
}
