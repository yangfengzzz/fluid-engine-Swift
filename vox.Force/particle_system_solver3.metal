//
//  particle_system_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "constant_vector_field3.metal"

namespace ParticleSystemSolver3 {
    kernel void accumulateExternalForces(device float3 *forces [[buffer(0)]],
                                         device float3 *velocities [[buffer(1)]],
                                         device float3 *positions [[buffer(2)]],
                                         constant float3 &vel_field [[buffer(3)]],
                                         constant float &mass [[buffer(4)]],
                                         constant float &_dragCoefficient [[buffer(5)]],
                                         constant float3 &_gravity [[buffer(6)]],
                                         uint id [[thread_position_in_grid]],
                                         uint size [[threads_per_grid]]) {
        float3 force = mass * _gravity;
        
        // Wind forces
        ConstantVectorField3 _wind(vel_field);
        float3 relativeVel = velocities[id] - _wind.sample(positions[id]);
        force += -_dragCoefficient * relativeVel;
        
        forces[id] += force;
    }
    
    kernel void timeIntegration(device float3 *_newVelocities [[buffer(0)]],
                                device float3 *_newPositions [[buffer(1)]],
                                device float3 *forces [[buffer(2)]],
                                device float3 *velocities [[buffer(3)]],
                                device float3 *positions [[buffer(4)]],
                                constant float &timeStepInSeconds [[buffer(5)]],
                                constant float &mass [[buffer(6)]],
                                uint id [[thread_position_in_grid]],
                                uint size [[threads_per_grid]]) {
        // Integrate velocity first
        _newVelocities[id] = velocities[id] + timeStepInSeconds * forces[id] / mass;
        
        // Integrate position.
        _newPositions[id] = positions[id] + timeStepInSeconds * _newVelocities[id];
    }
    
    kernel void endAdvanceTimeStep(device float3 *_newVelocities [[buffer(0)]],
                                   device float3 *_newPositions [[buffer(1)]],
                                   device float3 *velocities [[buffer(2)]],
                                   device float3 *positions [[buffer(3)]],
                                   uint id [[thread_position_in_grid]],
                                   uint size [[threads_per_grid]]) {
        positions[id] = _newPositions[id];
        velocities[id] = _newVelocities[id];
    }
}
