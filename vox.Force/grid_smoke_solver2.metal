//
//  grid_smoke_solver2.metal
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

namespace GridSmokeSolver2 {
    kernel void den_scalar(device float *_den [[buffer(0)]],
                           constant Grid2Descriptor &den_descriptor [[buffer(1)]],
                           constant float &_smokeDecayFactor [[buffer(2)]],
                           uint2 id [[thread_position_in_grid]],
                           uint2 size [[threads_per_grid]]) {
        class CellCenteredScalarGrid2 den(_den, size, den_descriptor);
        uint i = id.x;
        uint j = id.y;
        
        den(i, j) *= 1.0 - _smokeDecayFactor;
    }
    
    kernel void temp_scalar(device float *_temp [[buffer(0)]],
                            constant Grid2Descriptor &temp_descriptor [[buffer(1)]],
                            constant float &_temperatureDecayFactor [[buffer(2)]],
                            uint2 id [[thread_position_in_grid]],
                            uint2 size [[threads_per_grid]]) {
        class CellCenteredScalarGrid2 temp(_temp, size, temp_descriptor);
        uint i = id.x;
        uint j = id.y;
        
        temp(i, j) *= 1.0 - _temperatureDecayFactor;
    }
    
    kernel void computeBuoyancyForceU(device float *_v [[buffer(0)]],
                                      device float *_dataU [[buffer(1)]],
                                      device float *_dataV [[buffer(2)]],
                                      constant Grid2Descriptor &vel_descriptor [[buffer(3)]],
                                      device float *_den [[buffer(4)]],
                                      constant Grid2Descriptor &den_descriptor [[buffer(5)]],
                                      device float *_temp [[buffer(6)]],
                                      constant Grid2Descriptor &temp_descriptor [[buffer(7)]],
                                      constant float &tAmb [[buffer(8)]],
                                      constant float &timeIntervalInSeconds [[buffer(9)]],
                                      constant float &_buoyancySmokeDensityFactor [[buffer(10)]],
                                      constant float &_buoyancyTemperatureFactor [[buffer(11)]],
                                      constant float &upx [[buffer(12)]],
                                      constant uint2 &resolution [[buffer(13)]],
                                      uint2 id [[thread_position_in_grid]],
                                      uint2 size [[threads_per_grid]]) {
        class FaceCenteredGrid2 vel(_dataU, _dataV, resolution, vel_descriptor);
        class CellCenteredScalarGrid2 den(_den, resolution, den_descriptor);
        class CellCenteredScalarGrid2 temp(_temp, resolution, temp_descriptor);
        auto u = vel.uAccessor();
        uint i = id.x;
        uint j = id.y;
        
        float2 pt = vel.uPosition(i, j);
        float fBuoy =
        _buoyancySmokeDensityFactor * den.sample(pt) +
        _buoyancyTemperatureFactor * (temp.sample(pt) - tAmb);
        u(i, j) += timeIntervalInSeconds * fBuoy * upx;
    }
    
    kernel void computeBuoyancyForceV(device float *_v [[buffer(0)]],
                                      device float *_dataU [[buffer(1)]],
                                      device float *_dataV [[buffer(2)]],
                                      constant Grid2Descriptor &vel_descriptor [[buffer(3)]],
                                      device float *_den [[buffer(4)]],
                                      constant Grid2Descriptor &den_descriptor [[buffer(5)]],
                                      device float *_temp [[buffer(6)]],
                                      constant Grid2Descriptor &temp_descriptor [[buffer(7)]],
                                      constant float &tAmb [[buffer(8)]],
                                      constant float &timeIntervalInSeconds [[buffer(9)]],
                                      constant float &_buoyancySmokeDensityFactor [[buffer(10)]],
                                      constant float &_buoyancyTemperatureFactor [[buffer(11)]],
                                      constant float &upy [[buffer(12)]],
                                      constant uint2 &resolution [[buffer(13)]],
                                      uint2 id [[thread_position_in_grid]],
                                      uint2 size [[threads_per_grid]]) {
        class FaceCenteredGrid2 vel(_dataU, _dataV, resolution, vel_descriptor);
        class CellCenteredScalarGrid2 den(_den, resolution, den_descriptor);
        class CellCenteredScalarGrid2 temp(_temp, resolution, temp_descriptor);
        auto v = vel.vAccessor();
        uint i = id.x;
        uint j = id.y;
        
        float2 pt = vel.vPosition(i, j);
        float fBuoy =
        _buoyancySmokeDensityFactor * den.sample(pt) +
        _buoyancyTemperatureFactor * (temp.sample(pt) - tAmb);
        v(i, j) += timeIntervalInSeconds * fBuoy * upy;
    }
}
