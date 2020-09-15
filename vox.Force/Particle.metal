//
//  Particle.metal
//  vox.Render
//
//  Created by Feng Yang on 2020/7/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position   [[position]];
    float  point_size [[point_size]];
    float4 color;
};


struct Particle {
    float2 startPosition;
    float2 position;
    float  direction;
    float  speed;
    float4 color;
    float  age;
    float  life;
    float  size;
    float  scale;
    float  startScale;
    float  endScale;
};

// 1
kernel void compute(device Particle *particles [[buffer(0)]],
                    uint id [[thread_position_in_grid]]) {
    float xVelocity = particles[id].speed * cos(particles[id].direction);
    float yVelocity = particles[id].speed * sin(particles[id].direction) ;
    particles[id].position.x += xVelocity;
    particles[id].position.y += yVelocity;
    particles[id].age += 1.0;
    float age = particles[id].age / particles[id].life;
    particles[id].scale =  mix(particles[id].startScale,
                               particles[id].endScale, age);
    if (particles[id].age > particles[id].life) {
        particles[id].position = particles[id].startPosition;
        particles[id].age = 0;
        particles[id].scale = particles[id].startScale;
    }
}

vertex VertexOut vertex_particle(
                                 constant float2 &size [[buffer(0)]],
                                 const device Particle *particles [[buffer(1)]],
                                 constant float2 &emitterPosition [[ buffer(2) ]],
                                 uint instance [[instance_id]]) {
    VertexOut out;
    float2 position = particles[instance].position + emitterPosition;
    out.position.xy = position.xy / size * 2.0 - 1.0;
    out.position.z = 0;
    out.position.w = 1;
    out.point_size = particles[instance].size * particles[instance].scale;
    out.color = particles[instance].color;
    return out;
}

fragment float4 fragment_particle(
                                  VertexOut in [[stage_in]],
                                  texture2d<float> particleTexture [[texture(0)]],
                                  float2 point [[point_coord]]) {
    constexpr sampler default_sampler;
    float4 color = particleTexture.sample(default_sampler, point);
    if (color.a < 0.5) {
        discard_fragment();
    }
    color = float4(color.xyz, 0.5);
    color *= in.color;
    return color;
}
