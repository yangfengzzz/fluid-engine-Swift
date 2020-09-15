//
//  array_utils.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_UTILS_METAL_
#define INCLUDE_VOX_ARRAY_UTILS_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_accessor1.metal"
#include "array_accessor2.metal"
#include "array_accessor3.metal"

//MARK: setRange1
kernel void setRange1_float(device float *array [[buffer(0)]],
                            constant uint &begin [[buffer(1)]],
                            constant uint &end [[buffer(2)]],
                            constant float &value [[buffer(3)]],
                            uint id [[thread_position_in_grid]]) {
    if (id >= begin && id < end) {
        array[id] = value;
    }
}

kernel void setRange1_float2(device float2 *array [[buffer(0)]],
                             constant uint &begin [[buffer(1)]],
                             constant uint &end [[buffer(2)]],
                             constant float2 &value [[buffer(3)]],
                             uint id [[thread_position_in_grid]]) {
    if (id >= begin && id < end) {
        array[id] = value;
    }
}

kernel void setRange1_float3(device float3 *array [[buffer(0)]],
                             constant uint &begin [[buffer(1)]],
                             constant uint &end [[buffer(2)]],
                             constant float3 &value [[buffer(3)]],
                             uint id [[thread_position_in_grid]]) {
    if (id >= begin && id < end) {
        array[id] = value;
    }
}

kernel void setRange1_float4(device float4 *array [[buffer(0)]],
                             constant uint &begin [[buffer(1)]],
                             constant uint &end [[buffer(2)]],
                             constant float4 &value [[buffer(3)]],
                             uint id [[thread_position_in_grid]]) {
    if (id >= begin && id < end) {
        array[id] = value;
    }
}

//MARK: copyRange
constant int variant [[function_constant(0)]];
kernel void copyRange1(device void *array1 [[buffer(0)]],
                       device void *array2 [[buffer(1)]],
                       constant uint &begin [[buffer(2)]],
                       constant uint &end [[buffer(3)]],
                       uint id [[thread_position_in_grid]]) {
    if (variant == 0) {
        device float *data1 = static_cast<device float*>(array1);
        device float *data2 = static_cast<device float*>(array2);
        if (id >= begin && id < end) {
            data2[id] = data1[id];
        }
    } else if (variant == 1) {
        device float2 *data1 = static_cast<device float2*>(array1);
        device float2 *data2 = static_cast<device float2*>(array2);
        if (id >= begin && id < end) {
            data2[id] = data1[id];
        }
    } else if (variant == 2) {
        device float3 *data1 = static_cast<device float3*>(array1);
        device float3 *data2 = static_cast<device float3*>(array2);
        if (id >= begin && id < end) {
            data2[id] = data1[id];
        }
    } else if (variant == 3) {
        device float4 *data1 = static_cast<device float4*>(array1);
        device float4 *data2 = static_cast<device float4*>(array2);
        if (id >= begin && id < end) {
            data2[id] = data1[id];
        }
    }
}

kernel void copyRange2(device void *array1 [[buffer(0)]],
                       device void *array2 [[buffer(1)]],
                       constant uint &beginX [[buffer(2)]],
                       constant uint &endX [[buffer(3)]],
                       constant uint &beginY [[buffer(4)]],
                       constant uint &endY [[buffer(5)]],
                       uint2 id [[thread_position_in_grid]],
                       uint2 size [[threads_per_grid]]) {
    if (variant == 0) {
        device float *data1 = static_cast<device float*>(array1);
        device float *data2 = static_cast<device float*>(array2);
        ArrayAccessor2<float> accessor1(size, data1);
        ArrayAccessor2<float> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 1) {
        device float2 *data1 = static_cast<device float2*>(array1);
        device float2 *data2 = static_cast<device float2*>(array2);
        ArrayAccessor2<float2> accessor1(size, data1);
        ArrayAccessor2<float2> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 2) {
        device float3 *data1 = static_cast<device float3*>(array1);
        device float3 *data2 = static_cast<device float3*>(array2);
        ArrayAccessor2<float3> accessor1(size, data1);
        ArrayAccessor2<float3> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 3) {
        device float4 *data1 = static_cast<device float4*>(array1);
        device float4 *data2 = static_cast<device float4*>(array2);
        ArrayAccessor2<float4> accessor1(size, data1);
        ArrayAccessor2<float4> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY) {
            accessor2(id) = accessor1(id);
        }
    }
}

kernel void copyRange3(device void *array1 [[buffer(0)]],
                       device void *array2 [[buffer(1)]],
                       constant uint &beginX [[buffer(2)]],
                       constant uint &endX [[buffer(3)]],
                       constant uint &beginY [[buffer(4)]],
                       constant uint &endY [[buffer(5)]],
                       constant uint &beginZ [[buffer(6)]],
                       constant uint &endZ [[buffer(7)]],
                       uint3 id [[thread_position_in_grid]],
                       uint3 size [[threads_per_grid]]) {
    if (variant == 0) {
        device float *data1 = static_cast<device float*>(array1);
        device float *data2 = static_cast<device float*>(array2);
        ArrayAccessor3<float> accessor1(size, data1);
        ArrayAccessor3<float> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY
            && id.z >= beginZ && id.z < endZ) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 1) {
        device float2 *data1 = static_cast<device float2*>(array1);
        device float2 *data2 = static_cast<device float2*>(array2);
        ArrayAccessor3<float2> accessor1(size, data1);
        ArrayAccessor3<float2> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY
            && id.z >= beginZ && id.z < endZ) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 2) {
        device float3 *data1 = static_cast<device float3*>(array1);
        device float3 *data2 = static_cast<device float3*>(array2);
        ArrayAccessor3<float3> accessor1(size, data1);
        ArrayAccessor3<float3> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY
            && id.z >= beginZ && id.z < endZ) {
            accessor2(id) = accessor1(id);
        }
    } else if (variant == 3) {
        device float4 *data1 = static_cast<device float4*>(array1);
        device float4 *data2 = static_cast<device float4*>(array2);
        ArrayAccessor3<float4> accessor1(size, data1);
        ArrayAccessor3<float4> accessor2(size, data2);
        if (id.x >= beginX && id.x < endX
            && id.y >= beginY && id.y < endY
            && id.z >= beginZ && id.z < endZ) {
            accessor2(id) = accessor1(id);
        }
    }
}

#endif  // INCLUDE_VOX_ARRAY_UTILS_METAL_
