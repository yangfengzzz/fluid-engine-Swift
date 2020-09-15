//
//  apic_solver3.metal
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

namespace ApicSolver3 {
    kernel void transferFromGridsToParticles(device float3 *_positions [[buffer(0)]],
                                             device float3 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             device float *_dataW [[buffer(4)]],
                                             constant Grid3Descriptor &flow_descriptor [[buffer(5)]],
                                             device float3 *__cX [[buffer(6)]],
                                             device float3 *__cY [[buffer(7)]],
                                             device float3 *__cZ [[buffer(8)]],
                                             constant uint3 &resolution [[buffer(9)]],
                                             constant float3 &hh [[buffer(10)]],
                                             constant float3 &lowerCorner [[buffer(11)]],
                                             constant float3 &upperCorner [[buffer(12)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float3> positions(size, _positions);
        ArrayAccessor1<float3> velocities(size, _velocities);
        class FaceCenteredGrid3 flow(_dataU, _dataV, _dataW, resolution, flow_descriptor);
        ArrayAccessor1<float3> _cX(size, __cX);
        ArrayAccessor1<float3> _cY(size, __cY);
        ArrayAccessor1<float3> _cZ(size, __cZ);
        uint i = id;
        
        auto u = flow.uAccessor();
        auto v = flow.vAccessor();
        auto w = flow.wAccessor();
        LinearArraySampler3<float, float> uSampler(
                                                   u, flow.gridSpacing(), flow.uOrigin());
        LinearArraySampler3<float, float> vSampler(
                                                   v, flow.gridSpacing(), flow.vOrigin());
        LinearArraySampler3<float, float> wSampler(
                                                   w, flow.gridSpacing(), flow.wOrigin());
        velocities[i] = flow.sample(positions[i]);
        
        array<uint3, 8> indices;
        array<float3, 8> gradWeights;
        
        // x
        auto uPosClamped = positions[i];
        uPosClamped.y = clamp(
                              uPosClamped.y,
                              lowerCorner.y + hh.y,
                              upperCorner.y - hh.y);
        uPosClamped.z = clamp(
                              uPosClamped.z,
                              lowerCorner.z + hh.z,
                              upperCorner.z - hh.z);
        uSampler.getCoordinatesAndGradientWeights(
                                                  uPosClamped, &indices, &gradWeights);
        for (int j = 0; j < 8; ++j) {
            _cX[i] += gradWeights[j] * u(indices[j]);
        }
        
        // y
        auto vPosClamped = positions[i];
        vPosClamped.x = clamp(
                              vPosClamped.x,
                              lowerCorner.x + hh.x,
                              upperCorner.x - hh.x);
        vPosClamped.z = clamp(
                              vPosClamped.z,
                              lowerCorner.z + hh.z,
                              upperCorner.z - hh.z);
        vSampler.getCoordinatesAndGradientWeights(
                                                  vPosClamped, &indices, &gradWeights);
        for (int j = 0; j < 8; ++j) {
            _cY[i] += gradWeights[j] * v(indices[j]);
        }
        
        // z
        auto wPosClamped = positions[i];
        wPosClamped.x = clamp(
                              wPosClamped.x,
                              lowerCorner.x + hh.x,
                              upperCorner.x - hh.x);
        wPosClamped.y = clamp(
                              wPosClamped.y,
                              lowerCorner.y + hh.y,
                              upperCorner.y - hh.y);
        wSampler.getCoordinatesAndGradientWeights(
                                                  wPosClamped, &indices, &gradWeights);
        for (int j = 0; j < 8; ++j) {
            _cZ[i] += gradWeights[j] * w(indices[j]);
        }
    }
}
