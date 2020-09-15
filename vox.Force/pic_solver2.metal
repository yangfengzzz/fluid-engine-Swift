//
//  pic_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/14.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor1.metal"
#include "array_accessor2.metal"
#include "face_centered_grid2.metal"
#include "constants.metal"

namespace PicSolver2 {
    kernel void moveParticles(device float2 *_positions [[buffer(0)]],
                              device float2 *_velocities [[buffer(1)]],
                              device float *_dataU [[buffer(2)]],
                              device float *_dataV [[buffer(3)]],
                              constant Grid2Descriptor &flow_descriptor [[buffer(4)]],
                              constant int &domainBoundaryFlag [[buffer(5)]],
                              constant float &timeIntervalInSeconds [[buffer(6)]],
                              constant float &maxCfl [[buffer(7)]],
                              constant float2 &lowerCorner [[buffer(8)]],
                              constant float2 &upperCorner [[buffer(9)]],
                              constant uint2 &resolution [[buffer(10)]],
                              uint id [[thread_position_in_grid]],
                              uint size [[threads_per_grid]]) {
        ArrayAccessor1<float2> positions(size, _positions);
        ArrayAccessor1<float2> velocities(size, _velocities);
        class FaceCenteredGrid2 flow(_dataU, _dataV, resolution, flow_descriptor);
        uint i = id;
        
        float2 pt0 = positions[i];
        float2 pt1 = pt0;
        float2 vel = velocities[i];
        
        // Adaptive time-stepping
        unsigned int numSubSteps
        = static_cast<unsigned int>(max(maxCfl, 1.0));
        float dt = timeIntervalInSeconds / numSubSteps;
        for (unsigned int t = 0; t < numSubSteps; ++t) {
            float2 vel0 = flow.sample(pt0);
            
            // Mid-point rule
            float2 midPt = pt0 + 0.5 * dt * vel0;
            float2 midVel = flow.sample(midPt);
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
        
        positions[i] = pt1;
        velocities[i] = vel;
    }
    
    kernel void transferFromGridsToParticles(device float2 *_positions [[buffer(0)]],
                                             device float2 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             constant Grid2Descriptor &flow_descriptor [[buffer(4)]],
                                             constant uint2 &resolution [[buffer(5)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float2> positions(size, _positions);
        ArrayAccessor1<float2> velocities(size, _velocities);
        class FaceCenteredGrid2 flow(_dataU, _dataV, resolution, flow_descriptor);
        uint i = id;
        
        velocities[i] = flow.sample(positions[i]);
    }
}
