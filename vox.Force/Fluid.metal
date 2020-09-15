//
//  Fluid.metal
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    packed_float2 position;
    packed_float2 texCoords;
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 texCoords;
} FragmentVertex;

vertex FragmentVertex fluid_vertex_function(device VertexIn *vertexArray [[buffer(0)]],
                                            uint vertexIndex [[vertex_id]])
{
    FragmentVertex out;
    out.position = float4(vertexArray[vertexIndex].position, 0, 1);
    out.texCoords = vertexArray[vertexIndex].texCoords;
    return out;
}

fragment float4 fluid_fragment_function(FragmentVertex in [[stage_in]],
                                        texture2d<float, access::sample> gameGrid [[texture(0)]])
{
    constexpr sampler nearestSampler(coord::normalized, filter::nearest);
    float4 color = gameGrid.sample(nearestSampler, in.texCoords);
    return color;
}
