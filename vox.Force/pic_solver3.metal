//
//  pic_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor1.metal"
#include "array_accessor3.metal"
#include "face_centered_grid3.metal"
#include "constants.metal"

namespace PicSolver3 {
    kernel void moveParticles(device float3 *_positions [[buffer(0)]],
                              device float3 *_velocities [[buffer(1)]],
                              device float *_dataU [[buffer(2)]],
                              device float *_dataV [[buffer(3)]],
                              device float *_dataW [[buffer(4)]],
                              constant Grid3Descriptor &flow_descriptor [[buffer(5)]],
                              constant int &domainBoundaryFlag [[buffer(6)]],
                              constant float &timeIntervalInSeconds [[buffer(7)]],
                              constant float &maxCfl [[buffer(8)]],
                              constant float3 &lowerCorner [[buffer(9)]],
                              constant float3 &upperCorner [[buffer(10)]],
                              constant uint3 &resolution [[buffer(11)]],
                              uint id [[thread_position_in_grid]],
                              uint size [[threads_per_grid]]) {
        ArrayAccessor1<float3> positions(size, _positions);
        ArrayAccessor1<float3> velocities(size, _velocities);
        class FaceCenteredGrid3 flow(_dataU, _dataV, _dataW, resolution, flow_descriptor);
        uint i = id;
        
        float3 pt0 = positions[i];
        float3 pt1 = pt0;
        float3 vel = velocities[i];
        
        // Adaptive time-stepping
        unsigned int numSubSteps
        = static_cast<unsigned int>(max(maxCfl, 1.0));
        float dt = timeIntervalInSeconds / numSubSteps;
        for (unsigned int t = 0; t < numSubSteps; ++t) {
            float3 vel0 = flow.sample(pt0);
            
            // Mid-point rule
            float3 midPt = pt0 + 0.5 * dt * vel0;
            float3 midVel = flow.sample(midPt);
            pt1 = pt0 + dt * midVel;
            
            pt0 = pt1;
        }
        
        if ((domainBoundaryFlag & kDirectionLeft)
            && pt1.x <= lowerCorner.x) {
            pt1.x = lowerCorner.x;
            vel.x = 0.0;
        }
        if ((domainBoundaryFlag & kDirectionRight)
            && pt1.x >= upperCorner.x) {
            pt1.x = upperCorner.x;
            vel.x = 0.0;
        }
        if ((domainBoundaryFlag & kDirectionDown)
            && pt1.y <= lowerCorner.y) {
            pt1.y = lowerCorner.y;
            vel.y = 0.0;
        }
        if ((domainBoundaryFlag & kDirectionUp)
            && pt1.y >= upperCorner.y) {
            pt1.y = upperCorner.y;
            vel.y = 0.0;
        }
        if ((domainBoundaryFlag & kDirectionBack)
            && pt1.z <= lowerCorner.z) {
            pt1.z = lowerCorner.z;
            vel.z = 0.0;
        }
        if ((domainBoundaryFlag & kDirectionFront)
            && pt1.z >= upperCorner.z) {
            pt1.z = upperCorner.z;
            vel.z = 0.0;
        }
        
        positions[i] = pt1;
        velocities[i] = vel;
    }
    
    kernel void transferFromGridsToParticles(device float3 *_positions [[buffer(0)]],
                                             device float3 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             device float *_dataW [[buffer(4)]],
                                             constant Grid3Descriptor &flow_descriptor [[buffer(5)]],
                                             constant uint3 &resolution [[buffer(6)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float3> positions(size, _positions);
        ArrayAccessor1<float3> velocities(size, _velocities);
        class FaceCenteredGrid3 flow(_dataU, _dataV, _dataW, resolution, flow_descriptor);
        uint i = id;
        
        velocities[i] = flow.sample(positions[i]);
    }
}
