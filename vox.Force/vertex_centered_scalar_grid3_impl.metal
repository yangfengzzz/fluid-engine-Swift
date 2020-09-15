//
//  vertex_centered_scalar_grid3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "vertex_centered_scalar_grid3.metal"

VertexCenteredScalarGrid3::VertexCenteredScalarGrid3(device float* data,
                                                     const uint3 resolution,
                                                     const Grid3Descriptor descriptor)
: _resolution(resolution),
_origin(descriptor._origin),
_gridSpacing(descriptor._gridSpacing),
_data(data),
_accessor(dataSize(), _data),
_const_accessor(dataSize(), _data),
_linearSampler(_const_accessor, float3(1, 1, 1), float3()) {
    resetSampler();
}

void VertexCenteredScalarGrid3::resetSampler() {
    _linearSampler = LinearArraySampler3<float, float>(_const_accessor, gridSpacing(), dataOrigin());
}

//MARK: Implementation-Accessor:-
uint3 VertexCenteredScalarGrid3::dataSize() const {
    if (resolution().x != 0 || resolution().y != 0 || resolution().z != 0) {
        return resolution() + uint3(1, 1, 1);
    } else {
        return uint3(0, 0, 0);
    }
}

float3 VertexCenteredScalarGrid3::dataOrigin() const {
    return origin();
}

float3 VertexCenteredScalarGrid3::dataPosition(size_t i, size_t j, size_t k) const {
    float3 o = dataOrigin();
    return o + gridSpacing() * float3(i, j, k);
}

const uint3 VertexCenteredScalarGrid3::resolution() const { return _resolution; }

const float3 VertexCenteredScalarGrid3::origin() const { return _origin; }

const float3 VertexCenteredScalarGrid3::gridSpacing() const { return _gridSpacing; }

float3 VertexCenteredScalarGrid3::cellCenterPosition(size_t i, size_t j, size_t k) const {
    float3 h = _gridSpacing;
    float3 o = _origin;
    return o + h * float3(i + 0.5, j + 0.5, k + 0.5);
}

const float VertexCenteredScalarGrid3::operator()(size_t i, size_t j, size_t k) const {
    return _const_accessor(i, j, k);
}

device float& VertexCenteredScalarGrid3::operator()(size_t i, size_t j, size_t k) {
    return _accessor(i, j, k);
}

float3 VertexCenteredScalarGrid3::gradientAtDataPoint(size_t i, size_t j, size_t k) const {
    return gradient3(_const_accessor, gridSpacing(), i, j, k);
}

float VertexCenteredScalarGrid3::laplacianAtDataPoint(size_t i, size_t j, size_t k) const {
    return laplacian3(_const_accessor, gridSpacing(), i, j, k);
}

float VertexCenteredScalarGrid3::sample(const float3 x) const { return _linearSampler(x); }

float3 VertexCenteredScalarGrid3::gradient(const float3 x) const {
    array<uint3, 8> indices;
    array<float, 8> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float3 result = float3();
    
    for (int i = 0; i < 8; ++i) {
        result += weights[i] * gradientAtDataPoint(indices[i].x, indices[i].y, indices[i].z);
    }
    
    return result;
}

float VertexCenteredScalarGrid3::laplacian(const float3 x) const {
    array<uint3, 8> indices;
    array<float, 8> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 8; ++i) {
        result += weights[i] * laplacianAtDataPoint(indices[i].x, indices[i].y, indices[i].z);
    }
    
    return result;
}

VertexCenteredScalarGrid3::ScalarDataAccessor VertexCenteredScalarGrid3::dataAccessor() {
    return _accessor;
}

VertexCenteredScalarGrid3::ConstScalarDataAccessor VertexCenteredScalarGrid3::constDataAccessor() const {
    return _const_accessor;
}
