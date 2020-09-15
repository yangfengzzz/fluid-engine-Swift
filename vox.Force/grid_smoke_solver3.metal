//
//  grid_smoke_solver3.metal
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

namespace GridSmokeSolver3 {
    kernel void den_scalar(device float *_den [[buffer(0)]],
                           constant Grid3Descriptor &den_descriptor [[buffer(1)]],
                           constant float &_smokeDecayFactor [[buffer(2)]],
                           uint3 id [[thread_position_in_grid]],
                           uint3 size [[threads_per_grid]]) {
        class CellCenteredScalarGrid3 den(_den, size, den_descriptor);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        den(i, j, k) *= 1.0 - _smokeDecayFactor;
    }
    
    kernel void temp_scalar(device float *_temp [[buffer(0)]],
                            constant Grid3Descriptor &temp_descriptor [[buffer(1)]],
                            constant float &_temperatureDecayFactor [[buffer(2)]],
                            uint3 id [[thread_position_in_grid]],
                            uint3 size [[threads_per_grid]]) {
        class CellCenteredScalarGrid3 temp(_temp, size, temp_descriptor);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        temp(i, j, k) *= 1.0 - _temperatureDecayFactor;
    }
    
    kernel void computeBuoyancyForceU(device float *_v [[buffer(0)]],
                                      device float *_dataU [[buffer(1)]],
                                      device float *_dataV [[buffer(2)]],
                                      device float *_dataW [[buffer(3)]],
                                      constant Grid3Descriptor &vel_descriptor [[buffer(4)]],
                                      device float *_den [[buffer(5)]],
                                      constant Grid3Descriptor &den_descriptor [[buffer(6)]],
                                      device float *_temp [[buffer(7)]],
                                      constant Grid3Descriptor &temp_descriptor [[buffer(8)]],
                                      constant float &tAmb [[buffer(9)]],
                                      constant float &timeIntervalInSeconds [[buffer(10)]],
                                      constant float &_buoyancySmokeDensityFactor [[buffer(11)]],
                                      constant float &_buoyancyTemperatureFactor [[buffer(12)]],
                                      constant float &upx [[buffer(13)]],
                                      constant uint3 &resolution [[buffer(14)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        class CellCenteredScalarGrid3 den(_den, resolution, den_descriptor);
        class CellCenteredScalarGrid3 temp(_temp, resolution, temp_descriptor);
        auto u = vel.uAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        float3 pt = vel.uPosition(i, j, k);
        float fBuoy =
        _buoyancySmokeDensityFactor * den.sample(pt) +
        _buoyancyTemperatureFactor * (temp.sample(pt) - tAmb);
        u(i, j, k) += timeIntervalInSeconds * fBuoy * upx;
    }
    
    kernel void computeBuoyancyForceV(device float *_v [[buffer(0)]],
                                      device float *_dataU [[buffer(1)]],
                                      device float *_dataV [[buffer(2)]],
                                      device float *_dataW [[buffer(3)]],
                                      constant Grid3Descriptor &vel_descriptor [[buffer(4)]],
                                      device float *_den [[buffer(5)]],
                                      constant Grid3Descriptor &den_descriptor [[buffer(6)]],
                                      device float *_temp [[buffer(7)]],
                                      constant Grid3Descriptor &temp_descriptor [[buffer(8)]],
                                      constant float &tAmb [[buffer(9)]],
                                      constant float &timeIntervalInSeconds [[buffer(10)]],
                                      constant float &_buoyancySmokeDensityFactor [[buffer(11)]],
                                      constant float &_buoyancyTemperatureFactor [[buffer(12)]],
                                      constant float &upy [[buffer(13)]],
                                      constant uint3 &resolution [[buffer(14)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        class CellCenteredScalarGrid3 den(_den, resolution, den_descriptor);
        class CellCenteredScalarGrid3 temp(_temp, resolution, temp_descriptor);
        auto v = vel.vAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        float3 pt = vel.vPosition(i, j, k);
        float fBuoy =
        _buoyancySmokeDensityFactor * den.sample(pt) +
        _buoyancyTemperatureFactor * (temp.sample(pt) - tAmb);
        v(i, j, k) += timeIntervalInSeconds * fBuoy * upy;
    }
    
    kernel void computeBuoyancyForceW(device float *_v [[buffer(0)]],
                                      device float *_dataU [[buffer(1)]],
                                      device float *_dataV [[buffer(2)]],
                                      device float *_dataW [[buffer(3)]],
                                      constant Grid3Descriptor &vel_descriptor [[buffer(4)]],
                                      device float *_den [[buffer(5)]],
                                      constant Grid3Descriptor &den_descriptor [[buffer(6)]],
                                      device float *_temp [[buffer(7)]],
                                      constant Grid3Descriptor &temp_descriptor [[buffer(8)]],
                                      constant float &tAmb [[buffer(9)]],
                                      constant float &timeIntervalInSeconds [[buffer(10)]],
                                      constant float &_buoyancySmokeDensityFactor [[buffer(11)]],
                                      constant float &_buoyancyTemperatureFactor [[buffer(12)]],
                                      constant float &upz [[buffer(13)]],
                                      constant uint3 &resolution [[buffer(14)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
        class FaceCenteredGrid3 vel(_dataU, _dataV, _dataW, resolution, vel_descriptor);
        class CellCenteredScalarGrid3 den(_den, resolution, den_descriptor);
        class CellCenteredScalarGrid3 temp(_temp, resolution, temp_descriptor);
        auto w = vel.wAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        float3 pt = vel.wPosition(i, j, k);
        float fBuoy =
        _buoyancySmokeDensityFactor * den.sample(pt) +
        _buoyancyTemperatureFactor * (temp.sample(pt) - tAmb);
        w(i, j, k) += timeIntervalInSeconds * fBuoy * upz;
    }
}
