//
//  array_accessor3_GPU_tests.metal
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../vox.Force/array_accessor3.metal"

kernel void testParallelForEachIndex3(device float *array [[buffer(0)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
    ArrayAccessor3<float> accessor(size, array);
    accessor.at(id) = accessor.index(id);
}
