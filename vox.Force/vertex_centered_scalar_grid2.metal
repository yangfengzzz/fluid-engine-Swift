//
//  vertex_centered_scalar_grid2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_VERTEX_CENTERED_SCALAR_GRID2_METAL_
#define INCLUDE_VOX_VERTEX_CENTERED_SCALAR_GRID2_METAL_

#include <metal_stdlib>
using namespace metal;
#include "grid.metal"
#include "array_accessor2.metal"
#include "array_samplers2.metal"
#include "fdm_utils.metal"

//!
//! \brief 2-D Cell-centered scalar grid structure.
//!
//! This class represents 2-D cell-centered scalar grid which extends
//! ScalarGrid2. As its name suggests, the class defines the data point at the
//! center of a grid cell. Thus, the dimension of data points are equal to the
//! dimension of the cells.
//!
class VertexCenteredScalarGrid2 {
public:
    //! Read-write array accessor type.
    typedef ArrayAccessor2<float> ScalarDataAccessor;
    
    //! Read-only array accessor type.
    typedef ConstArrayAccessor2<float> ConstScalarDataAccessor;
    
    //! Constructs a grid with given resolution, grid spacing, origin and
    //! initial value.
    VertexCenteredScalarGrid2(device float* data,
                              const uint2 resolution,
                              const Grid2Descriptor descriptor);
    
    //MARK: Accessor:-
    //! Returns the actual data point size.
    uint2 dataSize() const;
    
    //! Returns data position for the grid point at (0, 0).
    //! Note that this is different from origin() since origin() returns
    //! the lower corner point of the bounding box.
    float2 dataOrigin() const;
    
    //! Returns the function that maps data point to its position.
    float2 dataPosition(size_t i, size_t j) const;
    
    //! Returns the grid resolution.
    const uint2 resolution() const;
    
    //! Returns the grid origin.
    const float2 origin() const;
    
    //! Returns the grid spacing.
    const float2 gridSpacing() const;
    
    //! Returns the function that maps grid index to the cell-center position.
    float2 cellCenterPosition(size_t i, size_t j) const;
    
    //! Returns the grid data at given data point.
    const float operator()(size_t i, size_t j) const;
    
    //! Returns the grid data at given data point.
    device float& operator()(size_t i, size_t j);
    
    //! Returns the gradient vector at given data point.
    float2 gradientAtDataPoint(size_t i, size_t j) const;
    
    //! Returns the Laplacian at given data point.
    float laplacianAtDataPoint(size_t i, size_t j) const;
    
    //! Returns the read-write data array accessor.
    ScalarDataAccessor dataAccessor();
    
    //! Returns the read-only data array accessor.
    ConstScalarDataAccessor constDataAccessor() const;
    
    //!
    //! \brief Returns the sampled value at given position \p x.
    //!
    //! This function returns the data sampled at arbitrary position \p x.
    //! The sampling function is linear.
    //!
    float sample(const float2 x) const;
    
    //! Returns the gradient vector at given position \p x.
    float2 gradient(const float2 x) const;
    
    //! Returns the Laplacian at given position \p x.
    float laplacian(const float2 x) const;
    
private:
    uint2 _resolution;
    float2 _gridSpacing = float2(1, 1);
    float2 _origin;
    
    device float* _data;
    ArrayAccessor2<float> _accessor;
    ConstArrayAccessor2<float> _const_accessor;
    LinearArraySampler2<float, float> _linearSampler;
    
    void resetSampler();
};

#endif  // INCLUDE_VOX_VERTEX_CENTERED_SCALAR_GRID2_METAL_
