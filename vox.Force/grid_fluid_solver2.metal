//
//  grid_fluid_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "grid.metal"
#include "cell_centered_scalar_grid2.metal"
#include "vertex_centered_scalar_grid2.metal"
#include "cell_centered_vector_grid2.metal"
#include "vertex_centered_vector_grid2.metal"
#include "face_centered_grid2.metal"
#include "level_set_utils.metal"

namespace GridFluidSolver2 {
    namespace CellCenteredScalarGrid2 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float *_grid [[buffer(3)]],
                                            constant Grid2Descriptor &grid_descriptor [[buffer(4)]],
                                            uint2 id [[thread_position_in_grid]],
                                            uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, size, sdf_descriptor);
            class CellCenteredScalarGrid2 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
    }
    
    namespace VertexCenteredScalarGrid2 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float *_grid [[buffer(3)]],
                                            constant Grid2Descriptor &grid_descriptor [[buffer(4)]],
                                            uint2 id [[thread_position_in_grid]],
                                            uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, size, sdf_descriptor);
            class VertexCenteredScalarGrid2 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
    }
    
    namespace CellCenteredVectorGrid2 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float2 *_grid [[buffer(3)]],
                                            constant Grid2Descriptor &grid_descriptor [[buffer(4)]],
                                            uint2 id [[thread_position_in_grid]],
                                            uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, size, sdf_descriptor);
            class CellCenteredVectorGrid2 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
    }
    
    namespace VertexCenteredVectorGrid2 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float2 *_grid [[buffer(3)]],
                                            constant Grid2Descriptor &grid_descriptor [[buffer(4)]],
                                            uint2 id [[thread_position_in_grid]],
                                            uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, size, sdf_descriptor);
            class VertexCenteredVectorGrid2 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
    }
    
    namespace FaceCenteredGrid2 {
        kernel void extrapolateIntoColliderU(device char *_marker [[buffer(0)]],
                                             device float *_sdf [[buffer(1)]],
                                             constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                             device float *_dataU [[buffer(3)]],
                                             device float *_dataV [[buffer(4)]],
                                             constant Grid2Descriptor &grid_descriptor [[buffer(5)]],
                                             constant uint2 &resolution [[buffer(6)]],
                                             uint2 id [[thread_position_in_grid]],
                                             uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, resolution, sdf_descriptor);
            class FaceCenteredGrid2 grid(_dataU, _dataV, resolution, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.uPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
        
        kernel void extrapolateIntoColliderV(device char *_marker [[buffer(0)]],
                                             device float *_sdf [[buffer(1)]],
                                             constant Grid2Descriptor &sdf_descriptor [[buffer(2)]],
                                             device float *_dataU [[buffer(3)]],
                                             device float *_dataV [[buffer(4)]],
                                             constant Grid2Descriptor &grid_descriptor [[buffer(5)]],
                                             constant uint2 &resolution [[buffer(6)]],
                                             uint2 id [[thread_position_in_grid]],
                                             uint2 size [[threads_per_grid]]) {
            ArrayAccessor2<char> marker(size, _marker);
            class CellCenteredScalarGrid2 sdf(_sdf, resolution, sdf_descriptor);
            class FaceCenteredGrid2 grid(_dataU, _dataV, resolution, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            
            if (isInsideSdf(sdf.sample(grid.vPosition(i, j)))) {
                marker(i, j) = 0;
            } else {
                marker(i, j) = 1;
            }
        }
    }
}
