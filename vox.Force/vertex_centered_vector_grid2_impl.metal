//
//  vertex_centered_vector_grid2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "vertex_centered_vector_grid2.metal"
#include "macros.h"

VertexCenteredVectorGrid2::VertexCenteredVectorGrid2(device float2* data,
                                                     const uint2 resolution,
                                                     const Grid2Descriptor descriptor)
: _resolution(resolution),
_origin(descriptor._origin),
_gridSpacing(descriptor._gridSpacing),
_data(data),
_accessor(dataSize(), _data),
_const_accessor(dataSize(), _data),
_linearSampler(_const_accessor, float2(1, 1), float2()) {
    resetSampler();
}

void VertexCenteredVectorGrid2::resetSampler() {
    _linearSampler = LinearArraySampler2<float2, float>(_const_accessor, gridSpacing(), dataOrigin());
}

//MARK: Implementation-Accessor:-
uint2 VertexCenteredVectorGrid2::dataSize() const {
    if (resolution().x != 0 || resolution().y != 0) {
        return resolution() + uint2(1, 1);
    } else {
        return uint2(0, 0);
    }
}

float2 VertexCenteredVectorGrid2::dataOrigin() const {
    return origin();
}

float2 VertexCenteredVectorGrid2::dataPosition(size_t i, size_t j) const {
    float2 o = dataOrigin();
    return o + gridSpacing() * float2(i, j);
}

const uint2 VertexCenteredVectorGrid2::resolution() const { return _resolution; }

const float2 VertexCenteredVectorGrid2::origin() const { return _origin; }

const float2 VertexCenteredVectorGrid2::gridSpacing() const { return _gridSpacing; }

float2 VertexCenteredVectorGrid2::cellCenterPosition(size_t i, size_t j) const {
    float2 h = _gridSpacing;
    float2 o = _origin;
    return o + h * float2(i + 0.5, j + 0.5);
}

const float2 VertexCenteredVectorGrid2::operator()(size_t i, size_t j) const {
    return _const_accessor(i, j);
}

device float2& VertexCenteredVectorGrid2::operator()(size_t i, size_t j) {
    return _accessor(i, j);
}

float VertexCenteredVectorGrid2::divergenceAtDataPoint(size_t i, size_t j) const {
    const uint2 ds = _const_accessor.size();
    const float2 gs = gridSpacing();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float left = _const_accessor((i > 0) ? i - 1 : i, j).x;
    float right = _const_accessor((i + 1 < ds.x) ? i + 1 : i, j).x;
    float down = _const_accessor(i, (j > 0) ? j - 1 : j).y;
    float up = _const_accessor(i, (j + 1 < ds.y) ? j + 1 : j).y;
    
    return 0.5 * (right - left) / gs.x
    + 0.5 * (up - down) / gs.y;
}

float VertexCenteredVectorGrid2::curlAtDataPoint(size_t i, size_t j) const {
    const uint2 ds = _const_accessor.size();
    const float2 gs = gridSpacing();
    
    VOX_ASSERT(i < ds.x && j < ds.y);
    
    float2 left = _const_accessor((i > 0) ? i - 1 : i, j);
    float2 right = _const_accessor((i + 1 < ds.x) ? i + 1 : i, j);
    float2 bottom = _const_accessor(i, (j > 0) ? j - 1 : j);
    float2 top = _const_accessor(i, (j + 1 < ds.y) ? j + 1 : j);
    
    float Fx_ym = bottom.x;
    float Fx_yp = top.x;
    
    float Fy_xm = left.y;
    float Fy_xp = right.y;
    
    return 0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y;
}

float2 VertexCenteredVectorGrid2::sample(const float2 x) const { return _linearSampler(x); }

float VertexCenteredVectorGrid2::divergence(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * divergenceAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

float VertexCenteredVectorGrid2::curl(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * curlAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

VertexCenteredVectorGrid2::VectorDataAccessor VertexCenteredVectorGrid2::dataAccessor() {
    return _accessor;
}

VertexCenteredVectorGrid2::ConstVectorDataAccessor VertexCenteredVectorGrid2::constDataAccessor() const {
    return _const_accessor;
}
