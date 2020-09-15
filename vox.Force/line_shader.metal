//
//  animation_render.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/8/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_line(const VertexIn vertex_in [[stage_in]],
                             const device float4 *color [[buffer(1)]],
                             uint instance [[instance_id]]) {
    VertexOut out;
    float2 position = vertex_in.position;
    out.position.xy = position.xy;
    out.position.z = 0;
    out.position.w = 1;
    
    out.color = color[instance];
    return out;
}

fragment float4 fragment_line(VertexOut fragData [[stage_in]]) {
    return fragData.color;
}
