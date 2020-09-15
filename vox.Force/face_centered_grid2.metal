//
//  face_centered_grid2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_FACE_CENTERED_GRID2_METAL_
#define INCLUDE_VOX_FACE_CENTERED_GRID2_METAL_

#include <metal_stdlib>
using namespace metal;
#include "grid.metal"
#include "array_accessor2.metal"
#include "array_samplers2.metal"
#include "fdm_utils.metal"

//!
//! \brief 2-D face-centered (a.k.a MAC or staggered) grid.
//!
//! This class implements face-centered grid which is also known as
//! marker-and-cell (MAC) or staggered grid. This vector grid stores each vector
//! component at face center. Thus, u and v components are not collocated.
//!
class FaceCenteredGrid2 {
public:
    //! Read-write scalar data accessor type.
    typedef ArrayAccessor2<float> ScalarDataAccessor;
    
    //! Read-only scalar data accessor type.
    typedef ConstArrayAccessor2<float> ConstScalarDataAccessor;
    
    //! Resizes the grid using given parameters.
    FaceCenteredGrid2(device float* dataU,
                      device float* dataV,
                      const uint2 resolution,
                      const Grid2Descriptor descriptor);
    
    //MARK: Accessor:-
    //! Returns the grid resolution.
    const uint2 resolution() const;
    
    //! Returns the grid origin.
    const float2 origin() const;
    
    //! Returns the grid spacing.
    const float2 gridSpacing() const;
    
    //! Returns the function that maps grid index to the cell-center position.
    float2 cellCenterPosition(size_t i, size_t j) const;
    
    //! Returns u-value at given data point.
    device float& u(size_t i, size_t j);
    
    //! Returns u-value at given data point.
    const float u(size_t i, size_t j) const;
    
    //! Returns v-value at given data point.
    device float& v(size_t i, size_t j);
    
    //! Returns v-value at given data point.
    const float v(size_t i, size_t j) const;
    
    //! Returns interpolated value at cell center.
    float2 valueAtCellCenter(size_t i, size_t j) const;
    
    //! Returns divergence at cell-center location.
    float divergenceAtCellCenter(size_t i, size_t j) const;
    
    //! Returns curl at cell-center location.
    float curlAtCellCenter(size_t i, size_t j) const;
    
    //! Returns u data accessor.
    ScalarDataAccessor uAccessor();
    
    //! Returns read-only u data accessor.
    ConstScalarDataAccessor uConstAccessor() const;
    
    //! Returns v data accessor.
    ScalarDataAccessor vAccessor();
    
    //! Returns read-only v data accessor.
    ConstScalarDataAccessor vConstAccessor() const;
    
    //! Returns function object that maps u data point to its actual position.
    float2 uPosition(size_t i, size_t j) const;
    
    //! Returns function object that maps v data point to its actual position.
    float2 vPosition(size_t i, size_t j) const;
    
    //! Returns data size of the u component.
    uint2 uSize() const;
    
    //! Returns data size of the v component.
    uint2 vSize() const;
    
    //!
    //! \brief Returns u-data position for the grid point at (0, 0).
    //!
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    //!
    float2 uOrigin() const;
    
    //!
    //! \brief Returns v-data position for the grid point at (0, 0).
    //!
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    //!
    float2 vOrigin() const;
    
    //! Returns sampled value at given position \p x.
    float2 sample(const float2 x) const;
    
    //! Returns divergence at given position \p x.
    float divergence(const float2 x) const;
    
    //! Returns curl at given position \p x.
    float curl(const float2 x) const;
    
private:
    uint2 _resolution;
    float2 _gridSpacing = float2(1, 1);
    float2 _origin;
    
    float2 _dataOriginU;
    device float* _dataU;
    ArrayAccessor2<float> _accessorU;
    ConstArrayAccessor2<float> _const_accessorU;
    LinearArraySampler2<float, float> _uLinearSampler;
    
    float2 _dataOriginV;
    device float* _dataV;
    ArrayAccessor2<float> _accessorV;
    ConstArrayAccessor2<float> _const_accessorV;
    LinearArraySampler2<float, float> _vLinearSampler;
    
    void resetSampler();
};

#endif  // INCLUDE_VOX_FACE_CENTERED_GRID2_METAL_
