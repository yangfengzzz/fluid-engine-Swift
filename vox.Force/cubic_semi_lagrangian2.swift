//
//  cubic_semi_lagrangian2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Implementation of 2-D cubic semi-Lagrangian advection solver.
///
/// This class implements 3rd-order cubic 2-D semi-Lagrangian advection solver.
class CubicSemiLagrangian2: SemiLagrangian2 {
    /// Returns spatial interpolation function object for given scalar
    /// grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getScalarSamplerFunc(input source:ScalarGrid2)->(Vector2F)->Float {
        let sourceSampler = CubicArraySampler2<Float, Float>(
            accessor: source.constDataAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.dataOrigin())
        return sourceSampler.functor()
    }
    
    /// Returns spatial interpolation function object for given
    /// collocated vector grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getVectorSamplerFunc(input source:CollocatedVectorGrid2)->(Vector2F)->Vector2F {
        let sourceSampler = CubicArraySampler2<Vector2F, Float>(
            accessor: source.constDataAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.dataOrigin())
        return sourceSampler.functor()
    }
    
    /// Returns spatial interpolation function object for given
    /// face-centered vector grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getVectorSamplerFunc(input source:FaceCenteredGrid2)->(Vector2F)->Vector2F {
        let uSourceSampler = CubicArraySampler2<Float, Float>(
            accessor: source.uConstAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.uOrigin())
        let vSourceSampler = CubicArraySampler2<Float, Float>(
            accessor: source.vConstAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.vOrigin())
        return {(x:Vector2F)->Vector2F in
            return Vector2F(uSourceSampler[pt: x], vSourceSampler[pt: x])
        }
    }
}
