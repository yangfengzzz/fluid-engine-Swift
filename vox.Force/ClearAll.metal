//
//  ClearAll.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/7/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void clearAll(texture2d<half, access::write> target [[texture(0)]],
                     uint2 gridPosition [[thread_position_in_grid]],
                     constant float &value [[buffer(0)]])
{
    target.write(half4(value), gridPosition);
}
