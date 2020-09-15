//
//  array_samplers_GPU_tests.metal
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../vox.Force/array_samplers1.metal"
#include "../vox.Force/array_samplers2.metal"
#include "../vox.Force/array_samplers3.metal"

kernel void testNearestArraySampler1(device float *array [[buffer(0)]],
                                     device float *output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]],
                                     uint size [[threads_per_grid]]) {
    ConstArrayAccessor1<float> accessor(size, array);
    NearestArraySampler1<float, float> samplers(accessor, 1.0, 0.0);
    
    if (id == 0) {
        output[id] = samplers(0.45);
    } else if (id == 1) {
        output[id] = samplers(1.57);
    }  else if (id == 2) {
        output[id] = samplers(3.51);
    }
}

kernel void testNearestArraySampler2(device float *array [[buffer(0)]],
                                     device float *output [[buffer(1)]],
                                     uint2 id [[thread_position_in_grid]],
                                     uint2 size [[threads_per_grid]]) {
    ConstArrayAccessor2<float> accessor(size, array);
    ArrayAccessor2<float> output_accessor(size, output);
    
    NearestArraySampler2<float, float> samplers(accessor, 1.0, 0.0);
    
    if (id.x == 0) {
        output_accessor(id) = samplers(0.45);
    } else if (id.x == 1) {
        output_accessor(id) = samplers(1.57);
    }  else if (id.x == 2) {
        output_accessor(id) = samplers(3.51);
    }
}
