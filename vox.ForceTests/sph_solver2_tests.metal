//
//  sph_solver2_tests.metal
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void testNeighborListsBuffer(device int *result [[buffer(0)]],
                                    device int *_neighborLists_buffer [[buffer(1)]],
                                    device int *_neighborLists_index [[buffer(2)]],
                                    uint id [[thread_position_in_grid]],
                                    uint size [[threads_per_grid]]) {
    result[id] = _neighborLists_index[id];
}
