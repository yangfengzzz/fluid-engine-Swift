//
//  array_accessor1_GPU_tests.metal
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../vox.Force/array_accessor1.metal"

kernel void testParallelForEachIndex(device float *array [[buffer(0)]],
                                     uint id [[thread_position_in_grid]],
                                     uint size [[threads_per_grid]]) {
    ArrayAccessor1<float> accessor(size, array);
    accessor[id] = float(200 - id);
}
