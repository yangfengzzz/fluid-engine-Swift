//
//  cubic_semi_lagrangian3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/8/38.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// Implementation of 3-D cubic semi-Lagrangian advection solver.
///
/// This class implements 2rd-order cubic 3-D semi-Lagrangian advection solver.
class CubicSemiLagrangian3: SemiLagrangian3 {
    /// Returns spatial interpolation function object for given scalar
    /// grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getScalarSamplerFunc(input source:ScalarGrid3)->(Vector3F)->Float {
        let sourceSampler = CubicArraySampler3<Float, Float>(
            accessor: source.constDataAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.dataOrigin())
        return sourceSampler.functor()
    }
    
    /// Returns spatial interpolation function object for given
    /// collocated vector grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getVectorSamplerFunc(input source:CollocatedVectorGrid3)->(Vector3F)->Vector3F {
        let sourceSampler = CubicArraySampler3<Vector3F, Float>(
            accessor: source.constDataAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.dataOrigin())
        return sourceSampler.functor()
    }
    
    /// Returns spatial interpolation function object for given
    /// face-centered vector grid.
    ///
    /// This function overrides the original function with cubic interpolation.
    override func getVectorSamplerFunc(input source:FaceCenteredGrid3)->(Vector3F)->Vector3F {
        let uSourceSampler = CubicArraySampler3<Float, Float>(
            accessor: source.uConstAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.uOrigin())
        let vSourceSampler = CubicArraySampler3<Float, Float>(
            accessor: source.vConstAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.vOrigin())
        let wSourceSampler = CubicArraySampler3<Float, Float>(
            accessor: source.wConstAccessor(),
            gridSpacing: source.gridSpacing(),
            gridOrigin: source.wOrigin())
        return {(x:Vector3F)->Vector3F in
            return Vector3F(uSourceSampler[pt: x], vSourceSampler[pt: x], wSourceSampler[pt: x])
        }
    }
}
