//
//  pci_sph_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "sph_kernels2.metal"

namespace PciSphSolver2 {
    kernel void accumulatePressureForce1(device float *pressures [[buffer(0)]],
                                         device float2 *_pressureForces [[buffer(1)]],
                                         device float *_densityErrors [[buffer(2)]],
                                         device float *ds [[buffer(3)]],
                                         device float *densities [[buffer(4)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        pressures[id] = 0.0;
        _pressureForces[id] = float2();
        _densityErrors[id] = 0.0;
        ds[id] = densities[id];
    }
    
    kernel void accumulatePressureForce2(device float2 *_tempVelocities [[buffer(0)]],
                                         device float2 *velocities [[buffer(1)]],
                                         device float2 *forces [[buffer(2)]],
                                         device float2 *_pressureForces [[buffer(3)]],
                                         device float2 *_tempPositions [[buffer(4)]],
                                         device float2 *positions [[buffer(5)]],
                                         constant float &timeIntervalInSeconds [[buffer(6)]],
                                         constant float &mass [[buffer(7)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        _tempVelocities[id]
        = velocities[id]
        + timeIntervalInSeconds / mass
        * (forces[id] + _pressureForces[id]);
        _tempPositions[id]
        = positions[id] + timeIntervalInSeconds * _tempVelocities[id];
    }
    
    kernel void accumulatePressureForce3(device int *_neighborLists_buffer [[buffer(0)]],
                                         device int *_neighborLists_index [[buffer(1)]],
                                         device float2 *_tempPositions [[buffer(2)]],
                                         device float *pressures [[buffer(3)]],
                                         device float *ds [[buffer(4)]],
                                         device float *_densityErrors [[buffer(5)]],
                                         constant float &radius [[buffer(6)]],
                                         constant float &mass [[buffer(7)]],
                                         constant float &targetDensity [[buffer(8)]],
                                         constant float &delta [[buffer(9)]],
                                         constant float &negScale [[buffer(10)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        SphStdKernel2 Sphkernel(radius);
        
        float weightSum = 0.0;
        int index_begin = _neighborLists_index[id];
        int index_end = _neighborLists_index[id+1];
        for(int index = index_begin; index < index_end; index++) {
            int j = _neighborLists_buffer[index];
            float dist = length(_tempPositions[j] - _tempPositions[id]);
            weightSum += Sphkernel(dist);
        }
        weightSum += Sphkernel(0);
        
        float density = mass * weightSum;
        float densityError = (density - targetDensity);
        float pressure = delta * densityError;
        
        if (pressure < 0.0) {
            pressure *= negScale;
            densityError *= negScale;
        }
        
        pressures[id] += pressure;
        ds[id] = density;
        _densityErrors[id] = densityError;
    }
    
    kernel void accumulatePressureForce4(device float2 *forces [[buffer(0)]],
                                         device float2 *_pressureForces [[buffer(1)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        forces[id] += _pressureForces[id];
    }
}
