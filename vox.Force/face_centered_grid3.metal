//
//  face_centered_grid3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_FACE_CENTERED_GRID3_METAL_
#define INCLUDE_VOX_FACE_CENTERED_GRID3_METAL_

#include <metal_stdlib>
using namespace metal;
#include "grid.metal"
#include "array_accessor3.metal"
#include "array_samplers3.metal"
#include "fdm_utils.metal"

//!
//! \brief 3-D face-centered (a.k.a MAC or staggered) grid.
//!
//! This class implements face-centered grid which is also known as
//! marker-and-cell (MAC) or staggered grid. This vector grid stores each vector
//! component at face center. Thus, u, v, and w components are not collocated.
//!
class FaceCenteredGrid3 {
public:
    //! Read-write scalar data accessor type.
    typedef ArrayAccessor3<float> ScalarDataAccessor;
    
    //! Read-only scalar data accessor type.
    typedef ConstArrayAccessor3<float> ConstScalarDataAccessor;
    
    //! Resizes the grid using given parameters.
    FaceCenteredGrid3(device float* dataU,
                      device float* dataV,
                      device float* dataW,
                      const uint3 resolution,
                      const Grid3Descriptor descriptor);
    
    //MARK: Accessor:-
    //! Returns the grid resolution.
    const uint3 resolution() const;
    
    //! Returns the grid origin.
    const float3 origin() const;
    
    //! Returns the grid spacing.
    const float3 gridSpacing() const;
    
    //! Returns the function that maps grid index to the cell-center position.
    float3 cellCenterPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns u-value at given data point.
    device float& u(size_t i, size_t j, size_t k);
    
    //! Returns u-value at given data point.
    const float u(size_t i, size_t j, size_t k) const;
    
    //! Returns v-value at given data point.
    device float& v(size_t i, size_t j, size_t k);
    
    //! Returns v-value at given data point.
    const float v(size_t i, size_t j, size_t k) const;
    
    //! Returns w-value at given data point.
    device float& w(size_t i, size_t j, size_t k);
    
    //! Returns w-value at given data point.
    const float w(size_t i, size_t j, size_t k) const;
    
    //! Returns interpolated value at cell center.
    float3 valueAtCellCenter(size_t i, size_t j, size_t k) const;
    
    //! Returns divergence at cell-center location.
    float divergenceAtCellCenter(size_t i, size_t j, size_t k) const;
    
    //! Returns curl at cell-center location.
    float3 curlAtCellCenter(size_t i, size_t j, size_t k) const;
    
    //! Returns u data accessor.
    ScalarDataAccessor uAccessor();
    
    //! Returns read-only u data accessor.
    ConstScalarDataAccessor uConstAccessor() const;
    
    //! Returns v data accessor.
    ScalarDataAccessor vAccessor();
    
    //! Returns read-only v data accessor.
    ConstScalarDataAccessor vConstAccessor() const;
    
    //! Returns w data accessor.
    ScalarDataAccessor wAccessor();
    
    //! Returns read-only w data accessor.
    ConstScalarDataAccessor wConstAccessor() const;
    
    //! Returns function object that maps u data point to its actual position.
    float3 uPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns function object that maps v data point to its actual position.
    float3 vPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns function object that maps w data point to its actual position.
    float3 wPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns data size of the u component.
    uint3 uSize() const;
    
    //! Returns data size of the v component.
    uint3 vSize() const;
    
    //! Returns data size of the w component.
    uint3 wSize() const;
    
    //!
    //! \brief Returns u-data position for the grid point at (0, 0, 0).
    //!
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    //!
    float3 uOrigin() const;
    
    //!
    //! \brief Returns v-data position for the grid point at (0, 0, 0).
    //!
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    //!
    float3 vOrigin() const;
    
    //!
    //! \brief Returns w-data position for the grid point at (0, 0, 0).
    //!
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    //!
    float3 wOrigin() const;
    
    //! Returns sampled value at given position \p x.
    float3 sample(const float3 x) const;
    
    //! Returns divergence at given position \p x.
    float divergence(const float3 x) const;
    
    //! Returns curl at given position \p x.
    float3 curl(const float3 x) const;
    
private:
    uint3 _resolution;
    float3 _gridSpacing = float3(1, 1, 1);
    float3 _origin;
    
    float3 _dataOriginU;
    device float* _dataU;
    ArrayAccessor3<float> _accessorU;
    ConstArrayAccessor3<float> _const_accessorU;
    LinearArraySampler3<float, float> _uLinearSampler;
    
    float3 _dataOriginV;
    device float* _dataV;
    ArrayAccessor3<float> _accessorV;
    ConstArrayAccessor3<float> _const_accessorV;
    LinearArraySampler3<float, float> _vLinearSampler;
    
    float3 _dataOriginW;
    device float* _dataW;
    ArrayAccessor3<float> _accessorW;
    ConstArrayAccessor3<float> _const_accessorW;
    LinearArraySampler3<float, float> _wLinearSampler;
    
    void resetSampler();
};

#endif  // INCLUDE_VOX_FACE_CENTERED_GRID3_METAL_
