//
//  vertex_centered_vector_grid3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_VERTEX_CENTERED_VECTOR_GRID3_METAL_
#define INCLUDE_VOX_VERTEX_CENTERED_VECTOR_GRID3_METAL_

#include <metal_stdlib>
using namespace metal;
#include "grid.metal"
#include "array_accessor3.metal"
#include "array_samplers3.metal"
#include "fdm_utils.metal"

//!
//! \brief 3-D Cell-centered vector grid structure.
//!
//! This class represents 3-D cell-centered vector grid which extends
//! CollocatedVectorGrid3. As its name suggests, the class defines the data
//! point at the center of a grid cell. Thus, the dimension of data points are
//! equal to the dimension of the cells.
//!
class VertexCenteredVectorGrid3 {
public:
    //! Read-write array accessor type.
    typedef ArrayAccessor3<float3> VectorDataAccessor;
    
    //! Read-only array accessor type.
    typedef ConstArrayAccessor3<float3> ConstVectorDataAccessor;
    
    //! Constructs a grid with given resolution, grid spacing, origin and
    //! initial value.
    VertexCenteredVectorGrid3(device float3* data,
                              const uint3 resolution,
                              const Grid3Descriptor descriptor);
    
    //MARK: Accessor:-
    //! Returns the actual data point size.
    uint3 dataSize() const;
    
    //! Returns data position for the grid point at (0, 0).
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    float3 dataOrigin() const;
    
    //! Returns the function that maps data point to its position.
    float3 dataPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns the grid resolution.
    const uint3 resolution() const;
    
    //! Returns the grid origin.
    const float3 origin() const;
    
    //! Returns the grid spacing.
    const float3 gridSpacing() const;
    
    //! Returns the function that maps grid index to the cell-center position.
    float3 cellCenterPosition(size_t i, size_t j, size_t k) const;
    
    //! Returns the grid data at given data point.
    const float3 operator()(size_t i, size_t j, size_t k) const;
    
    //! Returns the grid data at given data point.
    device float3& operator()(size_t i, size_t j, size_t k);
    
    //! Returns divergence at data point location.
    float divergenceAtDataPoint(size_t i, size_t j, size_t k) const;
    
    //! Returns curl at data point location.
    float3 curlAtDataPoint(size_t i, size_t j, size_t k) const;
    
    //! Returns the read-write data array accessor.
    VectorDataAccessor dataAccessor();
    
    //! Returns the read-only data array accessor.
    ConstVectorDataAccessor constDataAccessor() const;
    
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
    
    device float3* _data;
    ArrayAccessor3<float3> _accessor;
    ConstArrayAccessor3<float3> _const_accessor;
    LinearArraySampler3<float3, float> _linearSampler;
    
    void resetSampler();
};

#endif  // INCLUDE_VOX_VERTEX_CENTERED_VECTOR_GRID3_METAL_
