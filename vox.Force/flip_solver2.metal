//
//  flip_solver2.metal
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

namespace FlipSolver2 {
    kernel void deltaU(device float *_u [[buffer(0)]],
                       device float *__uDelta [[buffer(1)]],
                       uint2 id [[thread_position_in_grid]],
                       uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> u(size, _u);
        ArrayAccessor2<float> _uDelta(size, __uDelta);
        uint i = id.x;
        uint j = id.y;
        
        _uDelta(i, j) = static_cast<float>(u(i, j)) - _uDelta(i, j);
    }
    
    kernel void deltaV(device float *_v [[buffer(0)]],
                       device float *__vDelta [[buffer(1)]],
                       uint2 id [[thread_position_in_grid]],
                       uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> v(size, _v);
        ArrayAccessor2<float> _vDelta(size, __vDelta);
        uint i = id.x;
        uint j = id.y;
        
        _vDelta(i, j) = static_cast<float>(v(i, j)) - _vDelta(i, j);
    }
    
    kernel void transferFromGridsToParticles(device float2 *_positions [[buffer(0)]],
                                             device float2 *_velocities [[buffer(1)]],
                                             device float *_dataU [[buffer(2)]],
                                             device float *_dataV [[buffer(3)]],
                                             constant Grid2Descriptor &flow_descriptor [[buffer(4)]],
                                             device float *__uDelta [[buffer(5)]],
                                             device float *__vDelta [[buffer(6)]],
                                             constant uint2 &resolution [[buffer(7)]],
                                             constant uint2 &usize [[buffer(8)]],
                                             constant uint2 &vsize [[buffer(9)]],
                                             constant float &_picBlendingFactor [[buffer(10)]],
                                             uint id [[thread_position_in_grid]],
                                             uint size [[threads_per_grid]]) {
        ArrayAccessor1<float2> positions(size, _positions);
        ArrayAccessor1<float2> velocities(size, _velocities);
        class FaceCenteredGrid2 flow(_dataU, _dataV, resolution, flow_descriptor);
        ConstArrayAccessor2<float> _uDelta(usize, __uDelta);
        ConstArrayAccessor2<float> _vDelta(vsize, __vDelta);
        uint i = id;
        
        LinearArraySampler2<float, float> uSampler(
                                                   _uDelta,
                                                   flow.gridSpacing(),
                                                   flow.uOrigin());
        LinearArraySampler2<float, float> vSampler(
                                                   _vDelta,
                                                   flow.gridSpacing(),
                                                   flow.vOrigin());
        
        float2 xf = positions[i];
        float u = uSampler(xf);
        float v = vSampler(xf);
        
        float2 flipVel = velocities[i] + float2(u, v);
        if (_picBlendingFactor > 0.0) {
            float2 picVel = flow.sample(positions[i]);
            flipVel = lerp(flipVel, picVel, _picBlendingFactor);
        }
        velocities[i] = flipVel;
    }
}
