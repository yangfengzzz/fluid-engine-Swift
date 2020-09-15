//
//  level_set_liquid_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "cell_centered_scalar_grid2.metal"
#include "face_centered_grid2.metal"
#include "level_set_utils.metal"

namespace LevelSetLiquidSolver2 {
    kernel void extrapolateVelocityToAirU(device char *_uMarker [[buffer(0)]],
                                          device float *_v [[buffer(1)]],
                                          device float *_dataU [[buffer(2)]],
                                          device float *_dataV [[buffer(3)]],
                                          constant Grid2Descriptor &vel_descriptor [[buffer(4)]],
                                          device float *_sdf [[buffer(5)]],
                                          constant Grid2Descriptor &sdf_descriptor [[buffer(6)]],
                                          constant uint2 &resolution [[buffer(7)]],
                                          uint2 id [[thread_position_in_grid]],
                                          uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<char> uMarker(size, _uMarker);
        class CellCenteredScalarGrid2 sdf(_sdf, resolution, sdf_descriptor);
        class FaceCenteredGrid2 vel(_dataU, _dataV, resolution, vel_descriptor);
        auto u = vel.uAccessor();
        uint i = id.x;
        uint j = id.y;
        
        if (isInsideSdf(sdf.sample(vel.uPosition(i, j)))) {
            uMarker(i, j) = 1;
        } else {
            uMarker(i, j) = 0;
            u(i, j) = 0.0;
        }
    }
    
    kernel void extrapolateVelocityToAirV(device char *_vMarker [[buffer(0)]],
                                          device float *_v [[buffer(1)]],
                                          device float *_dataU [[buffer(2)]],
                                          device float *_dataV [[buffer(3)]],
                                          constant Grid2Descriptor &vel_descriptor [[buffer(4)]],
                                          device float *_sdf [[buffer(5)]],
                                          constant Grid2Descriptor &sdf_descriptor [[buffer(6)]],
                                          constant uint2 &resolution [[buffer(7)]],
                                          uint2 id [[thread_position_in_grid]],
                                          uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<char> vMarker(size, _vMarker);
        class CellCenteredScalarGrid2 sdf(_sdf, resolution, sdf_descriptor);
        class FaceCenteredGrid2 vel(_dataU, _dataV, resolution, vel_descriptor);
        auto v = vel.vAccessor();
        uint i = id.x;
        uint j = id.y;
        
        if (isInsideSdf(sdf.sample(vel.vPosition(i, j)))) {
            vMarker(i, j) = 1;
        } else {
            vMarker(i, j) = 0;
            v(i, j) = 0.0;
        }
    }
}
