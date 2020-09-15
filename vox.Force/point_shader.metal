//
//  point_shader.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float4 color;
    float  size;
};

struct VertexOut {
    float4 position [[position]];
    float  point_size [[point_size]];
    float4 color;
};

vertex VertexOut vertex_point(const device Particle *particles [[buffer(0)]],
                              uint instance [[instance_id]]) {
    VertexOut out;
    float2 position = particles[instance].position;
    out.position.xy = position.xy;
    out.position.z = 0;
    out.position.w = 1;
    
    out.point_size = particles[instance].size;
    out.color = particles[instance].color;
    return out;
}

fragment float4 fragment_point(VertexOut fragData [[stage_in]]) {
    return fragData.color;
}
