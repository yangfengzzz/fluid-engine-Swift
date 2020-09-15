//
//  sph_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "physics_helpers.metal"
#include "sph_kernels3.metal"
#include "math_utils.metal"

namespace SphSolver3 {
    kernel void computePressure(device float *densities [[buffer(0)]],
                                device float *pressures [[buffer(1)]],
                                constant float &targetDensity [[buffer(2)]],
                                constant float &eosScale [[buffer(3)]],
                                constant float &eosExponent [[buffer(4)]],
                                constant float &negativePressureScale [[buffer(5)]],
                                uint id [[thread_position_in_grid]],
                                uint size [[threads_per_grid]]) {
        pressures[id] = computePressureFromEos(densities[id],
                                               targetDensity,
                                               eosScale,
                                               eosExponent,
                                               negativePressureScale);
    }
    
    kernel void accumulatePressureForce(device float3 *positions [[buffer(0)]],
                                        device float *densities [[buffer(1)]],
                                        device float *pressures [[buffer(2)]],
                                        device float3 *pressureForces [[buffer(3)]],
                                        device int *_neighborLists_buffer [[buffer(4)]],
                                        device int *_neighborLists_index [[buffer(5)]],
                                        constant float &massSquared [[buffer(6)]],
                                        constant float &radius [[buffer(7)]],
                                        uint id [[thread_position_in_grid]],
                                        uint size [[threads_per_grid]]) {
        SphSpikyKernel3 Sphkernel(radius);
        int index_begin = _neighborLists_index[id];
        int index_end = _neighborLists_index[id+1];
        for(int index = index_begin; index < index_end; index++) {
            int j = _neighborLists_buffer[index];
            float dist = length(positions[id] - positions[j]);
            
            if (dist > 0.0) {
                float3 dir = (positions[j] - positions[id]) / dist;
                pressureForces[id] -= massSquared
                * (pressures[id] / (densities[id] * densities[id])
                   + pressures[j] / (densities[j] * densities[j]))
                * Sphkernel.gradient(dist, dir);
            }
        }
    }
    
    kernel void accumulateViscosityForce(device float3 *positions [[buffer(0)]],
                                         device float3 *velocities [[buffer(1)]],
                                         device float *densities [[buffer(2)]],
                                         device float3 *pressureForces [[buffer(3)]],
                                         device int *_neighborLists_buffer [[buffer(4)]],
                                         device int *_neighborLists_index [[buffer(5)]],
                                         constant float &massSquared [[buffer(6)]],
                                         constant float &radius [[buffer(7)]],
                                         constant float &viscosityCoefficient [[buffer(8)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        SphSpikyKernel3 Sphkernel(radius);
        int index_begin = _neighborLists_index[id];
        int index_end = _neighborLists_index[id+1];
        for(int index = index_begin; index < index_end; index++) {
            int j = _neighborLists_buffer[index];
            
            float dist = length(positions[id] - positions[j]);
            
            pressureForces[id] += viscosityCoefficient * massSquared
            * (velocities[j] - velocities[id]) / densities[j]
            * Sphkernel.secondDerivative(dist);
        }
    }
    
    kernel void computePseudoViscosity(device float3 *positions [[buffer(0)]],
                                       device float3 *velocities [[buffer(1)]],
                                       device float *densities [[buffer(2)]],
                                       device int *_neighborLists_buffer [[buffer(3)]],
                                       device int *_neighborLists_index [[buffer(4)]],
                                       constant float &mass [[buffer(5)]],
                                       constant float &radius [[buffer(6)]],
                                       constant float &factor [[buffer(7)]],
                                       uint id [[thread_position_in_grid]],
                                       uint size [[threads_per_grid]]) {
        float weightSum = 0.0;
        float3 smoothedVelocity = float3();
        float3 smoothedVelocities = float3();
        
        SphSpikyKernel3 Sphkernel(radius);
        int index_begin = _neighborLists_index[id];
        int index_end = _neighborLists_index[id+1];
        for(int index = index_begin; index < index_end; index++) {
            int j = _neighborLists_buffer[index];
            
            float dist = length(positions[id] - positions[j]);
            float wj = mass / densities[j] * Sphkernel(dist);
            weightSum += wj;
            smoothedVelocity += wj * velocities[j];
        }
        
        float wi = mass / densities[id];
        weightSum += wi;
        smoothedVelocity += wi * velocities[id];
        
        if (weightSum > 0.0) {
            smoothedVelocity /= weightSum;
        }
        
        smoothedVelocities = smoothedVelocity;
        
        velocities[id] = lerp(velocities[id], smoothedVelocities, factor);
    }
}
