//
//  level_set_liquid_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "cell_centered_scalar_grid3.metal"
#include "face_centered_grid3.metal"
#include "level_set_utils.metal"

namespace LevelSetLiquidSolver3 {
    kernel void extrapolateVelocityToAirU(device char *_uMarker [[buffer(0)]],
                                          device float *_v [[buffer(1)]],
                                          device float *_dataU [[buffer(2)]],
                                          device float *_dataV [[buffer(3)]],
                                          device float *_dataW [[buffer(4)]],
                                          constant Grid3Descriptor &vel_descriptor [[buffer(5)]],
                                          device float *_sdf [[buffer(6)]],
                                          constant Grid3Descriptor &sdf_descriptor [[buffer(7)]],
                                          constant uint3 &resolution [[buffer(8)]],
                                          uint3 id [[thread_position_in_grid]],
                                          uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<char> uMarker(size, _uMarker);
        class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        auto u = vel.uAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (isInsideSdf(sdf.sample(vel.uPosition(i, j, k)))) {
            uMarker(i, j, k) = 1;
        } else {
            uMarker(i, j, k) = 0;
            u(i, j, k) = 0.0;
        }
    }
    
    kernel void extrapolateVelocityToAirV(device char *_vMarker [[buffer(0)]],
                                          device float *_v [[buffer(1)]],
                                          device float *_dataU [[buffer(2)]],
                                          device float *_dataV [[buffer(3)]],
                                          device float *_dataW [[buffer(4)]],
                                          constant Grid3Descriptor &vel_descriptor [[buffer(5)]],
                                          device float *_sdf [[buffer(6)]],
                                          constant Grid3Descriptor &sdf_descriptor [[buffer(7)]],
                                          constant uint3 &resolution [[buffer(8)]],
                                          uint3 id [[thread_position_in_grid]],
                                          uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<char> vMarker(size, _vMarker);
        class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        auto v = vel.vAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (isInsideSdf(sdf.sample(vel.vPosition(i, j, k)))) {
            vMarker(i, j, k) = 1;
        } else {
            vMarker(i, j, k) = 0;
            v(i, j, k) = 0.0;
        }
    }
    
    kernel void extrapolateVelocityToAirW(device char *_wMarker [[buffer(0)]],
                                          device float *_v [[buffer(1)]],
                                          device float *_dataU [[buffer(2)]],
                                          device float *_dataV [[buffer(3)]],
                                          device float *_dataW [[buffer(4)]],
                                          constant Grid3Descriptor &vel_descriptor [[buffer(5)]],
                                          device float *_sdf [[buffer(6)]],
                                          constant Grid3Descriptor &sdf_descriptor [[buffer(7)]],
                                          constant uint3 &resolution [[buffer(8)]],
                                          uint3 id [[thread_position_in_grid]],
                                          uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<char> wMarker(size, _wMarker);
        class CellCenteredScalarGrid3 sdf(_sdf, resolution, sdf_descriptor);
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        auto w = vel.wAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (isInsideSdf(sdf.sample(vel.wPosition(i, j, k)))) {
            wMarker(i, j, k) = 1;
        } else {
            wMarker(i, j, k) = 0;
            w(i, j, k) = 0.0;
        }
    }
}
