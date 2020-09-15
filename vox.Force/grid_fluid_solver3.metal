//
//  grid_fluid_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "grid.metal"
#include "cell_centered_scalar_grid3.metal"
#include "vertex_centered_scalar_grid3.metal"
#include "cell_centered_vector_grid3.metal"
#include "vertex_centered_vector_grid3.metal"
#include "face_centered_grid3.metal"
#include "level_set_utils.metal"

namespace GridFluidSolver3 {
    namespace CellCenteredScalarGrid3 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float *_grid [[buffer(3)]],
                                            constant Grid3Descriptor &grid_descriptor [[buffer(4)]],
                                            uint3 id [[thread_position_in_grid]],
                                            uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, size, sdf_descriptor);
            class CellCenteredScalarGrid3 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
    }
    
    namespace VertexCenteredScalarGrid3 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float *_grid [[buffer(3)]],
                                            constant Grid3Descriptor &grid_descriptor [[buffer(4)]],
                                            uint3 id [[thread_position_in_grid]],
                                            uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, size, sdf_descriptor);
            class VertexCenteredScalarGrid3 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
    }
    
    namespace CellCenteredVectorGrid3 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float3 *_grid [[buffer(3)]],
                                            constant Grid3Descriptor &grid_descriptor [[buffer(4)]],
                                            uint3 id [[thread_position_in_grid]],
                                            uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, size, sdf_descriptor);
            class CellCenteredVectorGrid3 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
    }
    
    namespace VertexCenteredVectorGrid3 {
        kernel void extrapolateIntoCollider(device char *_marker [[buffer(0)]],
                                            device float *_sdf [[buffer(1)]],
                                            constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                            device float3 *_grid [[buffer(3)]],
                                            constant Grid3Descriptor &grid_descriptor [[buffer(4)]],
                                            uint3 id [[thread_position_in_grid]],
                                            uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, size, sdf_descriptor);
            class VertexCenteredVectorGrid3 grid(_grid, size, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.dataPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
    }
    
    namespace FaceCenteredGrid3 {
        kernel void extrapolateIntoColliderU(device char *_marker [[buffer(0)]],
                                             device float *_sdf [[buffer(1)]],
                                             constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                             device float *_dataU [[buffer(3)]],
                                             device float *_dataV [[buffer(4)]],
                                             device float *_dataW [[buffer(5)]],
                                             constant Grid3Descriptor &grid_descriptor [[buffer(6)]],
                                             constant uint3 &resolution [[buffer(7)]],
                                             uint3 id [[thread_position_in_grid]],
                                             uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
            class FaceCenteredGrid3 grid(_dataU, _dataV, _dataW, resolution, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.uPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
        
        kernel void extrapolateIntoColliderV(device char *_marker [[buffer(0)]],
                                             device float *_sdf [[buffer(1)]],
                                             constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                             device float *_dataU [[buffer(3)]],
                                             device float *_dataV [[buffer(4)]],
                                             device float *_dataW [[buffer(5)]],
                                             constant Grid3Descriptor &grid_descriptor [[buffer(6)]],
                                             constant uint3 &resolution [[buffer(7)]],
                                             uint3 id [[thread_position_in_grid]],
                                             uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
            class FaceCenteredGrid3 grid(_dataU, _dataV, _dataW, resolution, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.vPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
        
        kernel void extrapolateIntoColliderW(device char *_marker [[buffer(0)]],
                                             device float *_sdf [[buffer(1)]],
                                             constant Grid3Descriptor &sdf_descriptor [[buffer(2)]],
                                             device float *_dataU [[buffer(3)]],
                                             device float *_dataV [[buffer(4)]],
                                             device float *_dataW [[buffer(5)]],
                                             constant Grid3Descriptor &grid_descriptor [[buffer(6)]],
                                             constant uint3 &resolution [[buffer(7)]],
                                             uint3 id [[thread_position_in_grid]],
                                             uint3 size [[threads_per_grid]]) {
            ArrayAccessor3<char> marker(size, _marker);
            class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
            class FaceCenteredGrid3 grid(_dataU, _dataV, _dataW, resolution, grid_descriptor);
            uint i = id.x;
            uint j = id.y;
            uint k = id.z;
            
            if (isInsideSdf(sdf.sample(grid.wPosition(i, j, k)))) {
                marker(i, j, k) = 0;
            } else {
                marker(i, j, k) = 1;
            }
        }
    }
}
