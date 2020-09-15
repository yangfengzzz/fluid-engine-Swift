//
//  semi_lagrangian2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Implementation of 2-D semi-Lagrangian advection solver.
///
/// This class implements 2-D semi-Lagrangian advection solver. By default, the
/// class implements 1st-order (linear) algorithm for the spatial interpolation.
/// For the back-tracing, this class uses 2nd-order mid-point rule with adaptive time-stepping (CFL *<=* 1).
///
/// To extend the class using higher-order spatial interpolation, the inheriting
/// classes can override SemiLagrangian2::getScalarSamplerFunc and
/// SemiLagrangian2::getVectorSamplerFunc. See CubicSemiLagrangian2 for example.
class SemiLagrangian2: AdvectionSolver2 {
    /// Computes semi-Lagrangian for given scalar grid.
    ///
    /// This function computes semi-Lagrangian method to solve advection
    /// equation for given scalar field \p input and underlying vector field
    /// \p flow that carries the input field. The solution after solving the
    /// equation for given time-step \p dt should be stored in scalar field
    /// \p output. The boundary interface is given by a signed-distance field.
    /// The field is negative inside the boundary. By default, a constant field
    /// with max double value (kMaxD) is used, meaning no boundary.
    /// - Parameters:
    ///   - input: Input scalar grid.
    ///   - flow: Vector field that advects the input field.
    ///   - dt: Time-step for the advection.
    ///   - output: Output scalar grid.
    ///   - boundarySdf: Boundary interface defined by signed-distance field.
    func advect(input: ScalarGrid2, flow: VectorField2,
                dt: Float, output: inout ScalarGrid2,
                boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude)) {
        let outputDataPos = output.dataPosition()
        var outputDataAcc = output.dataAccessor()
        let inputSamplerFunc = getScalarSamplerFunc(input: input)
        let inputDataPos = input.dataPosition()
        
        let h = min(output.gridSpacing().x, output.gridSpacing().y)
        
        output.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
            if (boundarySdf.sample(x: inputDataPos(i, j)) > 0.0) {
                let pt = backTrace(
                    flow: flow, dt: dt, h: h,
                    pt0: outputDataPos(i, j),
                    boundarySdf: boundarySdf)
                outputDataAcc[i, j] = inputSamplerFunc(pt)
            }
        }
    }
    
    /// Computes semi-Lagrangian for given collocated vector grid.
    ///
    /// This function computes semi-Lagrangian method to solve advection
    /// equation for given collocated vector grid \p input and underlying vector
    /// field \p flow that carries the input field. The solution after solving
    /// the equation for given time-step \p dt should be stored in scalar field
    /// \p output. The boundary interface is given by a signed-distance field.
    /// The field is negative inside the boundary. By default, a constant field
    /// with max double value (kMaxD) is used, meaning no boundary.
    /// - Parameters:
    ///   - input: Input vector grid.
    ///   - flow: Vector field that advects the input field.
    ///   - dt: Time-step for the advection.
    ///   - output: Output vector grid.
    ///   - boundarySdf: Boundary interface defined by signed-distance field.
    func advect(input: CollocatedVectorGrid2, flow: VectorField2,
                dt: Float, output: inout CollocatedVectorGrid2,
                boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude)) {
        let inputSamplerFunc = getVectorSamplerFunc(input: input)
        
        let h = min(output.gridSpacing().x, output.gridSpacing().y)
        
        let outputDataPos = output.dataPosition()
        var outputDataAcc = output.dataAccessor()
        let inputDataPos = input.dataPosition()
        
        output.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
            if (boundarySdf.sample(x: inputDataPos(i, j)) > 0.0) {
                let pt = backTrace(
                    flow: flow, dt: dt, h: h,
                    pt0: outputDataPos(i, j),
                    boundarySdf: boundarySdf)
                outputDataAcc[i, j] = inputSamplerFunc(pt)
            }
        }
    }
    
    /// Computes semi-Lagrangian for given face-centered vector grid.
    ///
    /// This function computes semi-Lagrangian method to solve advection
    /// equation for given face-centered vector grid \p input and underlying
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
    ///   - boundarySdf: Boundary interface defined by signed-distance field.
    func advect(input: FaceCenteredGrid2, flow: VectorField2,
                dt: Float, output: inout FaceCenteredGrid2,
                boundarySdf: ScalarField2 = ConstantScalarField2(value: Float.greatestFiniteMagnitude)) {
        let inputSamplerFunc = getVectorSamplerFunc(input: input)
        
        let h = min(output.gridSpacing().x, output.gridSpacing().y)
        
        let uTargetDataPos = output.uPosition()
        var uTargetDataAcc = output.uAccessor()
        let uSourceDataPos = input.uPosition()
        
        output.parallelForEachUIndex(){(i:size_t, j:size_t) in
            if (boundarySdf.sample(x: uSourceDataPos(i, j)) > 0.0) {
                let pt = backTrace(
                    flow: flow, dt: dt, h: h,
                    pt0: uTargetDataPos(i, j),
                    boundarySdf: boundarySdf)
                uTargetDataAcc[i, j] = inputSamplerFunc(pt).x
            }
        }
        
        let vTargetDataPos = output.vPosition()
        var vTargetDataAcc = output.vAccessor()
        let vSourceDataPos = input.vPosition()
        
        output.parallelForEachVIndex(){(i:size_t, j:size_t) in
            if (boundarySdf.sample(x: vSourceDataPos(i, j)) > 0.0) {
                let pt = backTrace(
                    flow: flow, dt: dt, h: h,
                    pt0: vTargetDataPos(i, j),
                    boundarySdf: boundarySdf)
                vTargetDataAcc[i, j] = inputSamplerFunc(pt).y
            }
        }
    }
    
    /// Returns spatial interpolation function object for given scalar
    /// grid.
    ///
    /// This function returns spatial interpolation function (sampler) for given
    /// scalar grid \p input. By default, this function returns linear
    /// interpolation function. Override this function to have custom
    /// interpolation for semi-Lagrangian process.
    func getScalarSamplerFunc(input:ScalarGrid2)->(Vector2F)->Float {
        return input.sampler()
    }
    
    /// Returns spatial interpolation function object for given
    /// collocated vector grid.
    ///
    /// This function returns spatial interpolation function (sampler) for given
    /// collocated vector grid \p input. By default, this function returns
    /// linear interpolation function. Override this function to have custom
    /// interpolation for semi-Lagrangian process.
    func getVectorSamplerFunc(input:CollocatedVectorGrid2)->(Vector2F)->Vector2F {
        return input.sampler()
    }
    
    /// Returns spatial interpolation function object for given
    /// face-centered vector grid.
    ///
    /// This function returns spatial interpolation function (sampler) for given
    /// face-centered vector grid \p input. By default, this function returns
    /// linear interpolation function. Override this function to have custom
    /// interpolation for semi-Lagrangian process.
    func getVectorSamplerFunc(input:FaceCenteredGrid2)->(Vector2F)->Vector2F {
        return input.sampler()
    }
    
    func backTrace(flow:VectorField2,
                   dt:Float, h:Float,
                   pt0 startPt:Vector2F,
                   boundarySdf:ScalarField2)->Vector2F {
        var remainingT:Float = dt
        var pt0 = startPt
        var pt1 = startPt
        
        while (remainingT > Float.leastNonzeroMagnitude) {
            // Adaptive time-stepping
            let vel0 = flow.sample(x: pt0)
            let numSubSteps = max(ceil(length(vel0) * remainingT / h), 1.0)
            let dt = remainingT / numSubSteps
            
            // Mid-point rule
            let midPt = pt0 - 0.5 * dt * vel0
            let midVel = flow.sample(x: midPt)
            pt1 = pt0 - dt * midVel
            
            // Boundary handling
            let phi0 = boundarySdf.sample(x: pt0)
            let phi1 = boundarySdf.sample(x: pt1)
            
            if (phi0 * phi1 < 0.0) {
                let w = abs(phi1) / (abs(phi0) + abs(phi1))
                pt1 = w * pt0 + (1.0 - w) * pt1
                break
            }
            
            remainingT -= dt
            pt0 = pt1
        }
        
        return pt1
    }
}
