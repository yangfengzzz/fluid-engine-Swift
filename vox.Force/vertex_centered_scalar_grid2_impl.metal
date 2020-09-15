//
//  vertex_centered_scalar_grid2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "vertex_centered_scalar_grid2.metal"

VertexCenteredScalarGrid2::VertexCenteredScalarGrid2(device float* data,
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

void VertexCenteredScalarGrid2::resetSampler() {
    _linearSampler = LinearArraySampler2<float, float>(_const_accessor, gridSpacing(), dataOrigin());
}

//MARK: Implementation-Accessor:-
uint2 VertexCenteredScalarGrid2::dataSize() const {
    if (resolution().x != 0 || resolution().y != 0) {
        return resolution() + uint2(1, 1);
    } else {
        return uint2(0, 0);
    }
}

float2 VertexCenteredScalarGrid2::dataOrigin() const {
    return origin();
}

float2 VertexCenteredScalarGrid2::dataPosition(size_t i, size_t j) const {
    float2 o = dataOrigin();
    return o + gridSpacing() * float2(i, j);
}

const uint2 VertexCenteredScalarGrid2::resolution() const { return _resolution; }

const float2 VertexCenteredScalarGrid2::origin() const { return _origin; }

const float2 VertexCenteredScalarGrid2::gridSpacing() const { return _gridSpacing; }

float2 VertexCenteredScalarGrid2::cellCenterPosition(size_t i, size_t j) const {
    float2 h = _gridSpacing;
    float2 o = _origin;
    return o + h * float2(i + 0.5, j + 0.5);
}

const float VertexCenteredScalarGrid2::operator()(size_t i, size_t j) const {
    return _const_accessor(i, j);
}

device float& VertexCenteredScalarGrid2::operator()(size_t i, size_t j) {
    return _accessor(i, j);
}

float2 VertexCenteredScalarGrid2::gradientAtDataPoint(size_t i, size_t j) const {
    return gradient2(_const_accessor, gridSpacing(), i, j);
}

float VertexCenteredScalarGrid2::laplacianAtDataPoint(size_t i, size_t j) const {
    return laplacian2(_const_accessor, gridSpacing(), i, j);
}

float VertexCenteredScalarGrid2::sample(const float2 x) const { return _linearSampler(x); }

float2 VertexCenteredScalarGrid2::gradient(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float2 result = float2();
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * gradientAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

float VertexCenteredScalarGrid2::laplacian(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * laplacianAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

VertexCenteredScalarGrid2::ScalarDataAccessor VertexCenteredScalarGrid2::dataAccessor() {
    return _accessor;
}

VertexCenteredScalarGrid2::ConstScalarDataAccessor VertexCenteredScalarGrid2::constDataAccessor() const {
    return _const_accessor;
}
