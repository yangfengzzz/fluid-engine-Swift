//
//  array_accessor2_GPU_tests.metal
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../vox.Force/array_accessor2.metal"
#include "../vox.Force/cell_centered_scalar_grid2.metal"

kernel void testParallelForEachIndex2(device float *array [[buffer(0)]],
                                      uint2 id [[thread_position_in_grid]],
                                      uint2 size [[threads_per_grid]]) {
    ArrayAccessor2<float> accessor(size, array);
    accessor.at(id) = accessor.index(id);
}

kernel void testGridLoader(device float *array [[buffer(0)]],
                           device float *grid_array [[buffer(1)]],
                           device Grid2Descriptor& descriptor [[buffer(2)]],
                           uint2 id [[thread_position_in_grid]],
                           uint2 size [[threads_per_grid]]) {
    ArrayAccessor2<float> accessor(size, array);
    CellCenteredScalarGrid2 grid(grid_array, size, descriptor);
    ArrayAccessor2<float> grid_accessor = grid.dataAccessor();
    accessor.at(id) = grid_accessor.at(id);
}
