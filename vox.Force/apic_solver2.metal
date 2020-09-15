//
//  apic_solver2.metal
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

namespace ApicSolver2 {
    kernel void transferFromGridsToParticles(device float2 *_positions [[buffer(0)]],
                                             device float2 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             constant Grid2Descriptor &flow_descriptor [[buffer(4)]],
                                             device float2 *__cX [[buffer(5)]],
                                             device float2 *__cY [[buffer(6)]],
                                             constant uint2 &resolution [[buffer(7)]],
                                             constant float2 &hh [[buffer(8)]],
                                             constant float2 &lowerCorner [[buffer(9)]],
                                             constant float2 &upperCorner [[buffer(10)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float2> positions(size, _positions);
        ArrayAccessor1<float2> velocities(size, _velocities);
        class FaceCenteredGrid2 flow(_dataU, _dataV, resolution, flow_descriptor);
        ArrayAccessor1<float2> _cX(size, __cX);
        ArrayAccessor1<float2> _cY(size, __cY);
        uint i = id;
        
        auto u = flow.uAccessor();
        auto v = flow.vAccessor();
        LinearArraySampler2<float, float> uSampler(
                                                   u, flow.gridSpacing(), flow.uOrigin());
        LinearArraySampler2<float, float> vSampler(
                                                   v, flow.gridSpacing(), flow.vOrigin());
        velocities[i] = flow.sample(positions[i]);
        
        array<uint2, 4> indices;
        array<float2, 4> gradWeights;
        
        // x
        auto uPosClamped = positions[i];
        uPosClamped.y = clamp(
                              uPosClamped.y,
                              lowerCorner.y + hh.y,
                              upperCorner.y - hh.y);
        uSampler.getCoordinatesAndGradientWeights(
                                                  uPosClamped, &indices, &gradWeights);
        for (int j = 0; j < 4; ++j) {
            _cX[i] += gradWeights[j] * u(indices[j]);
        }
        
        // y
        auto vPosClamped = positions[i];
        vPosClamped.x = clamp(
                              vPosClamped.x,
                              lowerCorner.x + hh.x,
                              upperCorner.x - hh.x);
        vSampler.getCoordinatesAndGradientWeights(
                                                  vPosClamped, &indices, &gradWeights);
        for (int j = 0; j < 4; ++j) {
            _cY[i] += gradWeights[j] * v(indices[j]);
        }
    }
}
