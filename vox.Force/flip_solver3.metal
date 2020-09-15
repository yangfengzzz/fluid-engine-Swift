//
//  flip_solver3.metal
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

namespace FlipSolver3 {
    kernel void deltaU(device float *_u [[buffer(0)]],
                       device float *__uDelta [[buffer(1)]],
                       uint3 id [[thread_position_in_grid]],
                       uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> u(size, _u);
        ArrayAccessor3<float> _uDelta(size, __uDelta);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        _uDelta(i, j, k) = static_cast<float>(u(i, j, k)) - _uDelta(i, j, k);
    }
    
    kernel void deltaV(device float *_v [[buffer(0)]],
                       device float *__vDelta [[buffer(1)]],
                       uint3 id [[thread_position_in_grid]],
                       uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> v(size, _v);
        ArrayAccessor3<float> _vDelta(size, __vDelta);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        _vDelta(i, j, k) = static_cast<float>(v(i, j, k)) - _vDelta(i, j, k);
    }
    
    kernel void deltaW(device float *_w [[buffer(0)]],
                       device float *__wDelta [[buffer(1)]],
                       uint3 id [[thread_position_in_grid]],
                       uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> w(size, _w);
        ArrayAccessor3<float> _wDelta(size, __wDelta);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        _wDelta(i, j, k) = static_cast<float>(w(i, j, k)) - _wDelta(i, j, k);
    }
    
    kernel void transferFromGridsToParticles(device float3 *_positions [[buffer(0)]],
                                             device float3 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             device float *_dataW [[buffer(4)]],
                                             constant Grid3Descriptor &flow_descriptor [[buffer(5)]],
                                             device float *__uDelta [[buffer(6)]],
                                             device float *__vDelta [[buffer(7)]],
                                             device float *__wDelta [[buffer(8)]],
                                             constant uint3 &resolution [[buffer(9)]],
                                             constant uint3 &usize [[buffer(10)]],
                                             constant uint3 &vsize [[buffer(11)]],
                                             constant uint3 &wsize [[buffer(12)]],
                                             constant float &_picBlendingFactor [[buffer(13)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float3> positions(size, _positions);
        ArrayAccessor1<float3> velocities(size, _velocities);
        class FaceCenteredGrid3 flow(_dataU, _dataV, _dataW, resolution, flow_descriptor);
        ConstArrayAccessor3<float> _uDelta(usize, __uDelta);
        ConstArrayAccessor3<float> _vDelta(vsize, __vDelta);
        ConstArrayAccessor3<float> _wDelta(wsize, __wDelta);
        uint i = id;
        
        LinearArraySampler3<float, float> uSampler(
                                                   _uDelta,
                                                   flow.gridSpacing(),
                                                   flow.uOrigin());
        LinearArraySampler3<float, float> vSampler(
                                                   _vDelta,
                                                   flow.gridSpacing(),
                                                   flow.vOrigin());
        LinearArraySampler3<float, float> wSampler(
                                                   _wDelta,
                                                   flow.gridSpacing(),
                                                   flow.wOrigin());
        
        float3 xf = positions[i];
        float u = uSampler(xf);
        float v = vSampler(xf);
        float w = wSampler(xf);
        
        float3 flipVel = velocities[i] + float3(u, v, w);
        if (_picBlendingFactor > 0.0) {
            float3 picVel = flow.sample(positions[i]);
            flipVel = lerp(flipVel, picVel, _picBlendingFactor);
        }
        velocities[i] = flipVel;
    }
}
