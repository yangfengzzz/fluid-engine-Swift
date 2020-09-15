//
//  grid.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_GRID_METAL_
#define INCLUDE_VOX_GRID_METAL_

#include <metal_stdlib>
using namespace metal;

struct Grid2Descriptor {
    float2 _gridSpacing = float2(1.0, 1.0);
    float2 _origin = float2();
};

struct Grid3Descriptor {
    float3 _gridSpacing = float3(1.0, 1.0, 1.0);
    float3 _origin = float3();
};

#endif  // INCLUDE_VOX_GRID_METAL_
