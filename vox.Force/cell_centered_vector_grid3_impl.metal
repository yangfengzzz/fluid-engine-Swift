//
//  cell_centered_vector_grid3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "cell_centered_vector_grid3.metal"
#include "macros.h"

CellCenteredVectorGrid3::CellCenteredVectorGrid3(device float3* data,
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

void CellCenteredVectorGrid3::resetSampler() {
    _linearSampler = LinearArraySampler3<float3, float>(_const_accessor, gridSpacing(), dataOrigin());
}

//MARK: Implementation-Accessor:-
uint3 CellCenteredVectorGrid3::dataSize() const {
    // The size of the data should be the same as the grid resolution.
    return resolution();
}

float3 CellCenteredVectorGrid3::dataOrigin() const {
    return origin() + 0.5 * gridSpacing();
}

float3 CellCenteredVectorGrid3::dataPosition(size_t i, size_t j, size_t k) const {
    float3 o = dataOrigin();
    return o + gridSpacing() * float3(i, j, k);
}

const uint3 CellCenteredVectorGrid3::resolution() const { return _resolution; }

const float3 CellCenteredVectorGrid3::origin() const { return _origin; }

const float3 CellCenteredVectorGrid3::gridSpacing() const { return _gridSpacing; }

float3 CellCenteredVectorGrid3::cellCenterPosition(size_t i, size_t j, size_t k) const {
    float3 h = _gridSpacing;
    float3 o = _origin;
    return o + h * float3(i + 0.5, j + 0.5, k + 0.5);
}

const float3 CellCenteredVectorGrid3::operator()(size_t i, size_t j, size_t k) const {
    return _const_accessor(i, j, k);
}

device float3& CellCenteredVectorGrid3::operator()(size_t i, size_t j, size_t k) {
    return _accessor(i, j, k);
}

float CellCenteredVectorGrid3::divergenceAtDataPoint(size_t i, size_t j, size_t k) const {
    const uint3 ds = _const_accessor.size();
    const float3 gs = gridSpacing();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float left = _const_accessor((i > 0) ? i - 1 : i, j, k).x;
    float right = _const_accessor((i + 1 < ds.x) ? i + 1 : i, j, k).x;
    float down = _const_accessor(i, (j > 0) ? j - 1 : j, k).y;
    float up = _const_accessor(i, (j + 1 < ds.y) ? j + 1 : j, k).y;
    float back = _const_accessor(i, j, (k > 0) ? k - 1 : k).z;
    float front = _const_accessor(i, j, (k + 1 < ds.z) ? k + 1 : k).z;
    
    return 0.5 * (right - left) / gs.x
    + 0.5 * (up - down) / gs.y
    + 0.5 * (front - back) / gs.z;
}

float3 CellCenteredVectorGrid3::curlAtDataPoint(size_t i, size_t j, size_t k) const {
    const uint3 ds = _const_accessor.size();
    const float3 gs = gridSpacing();
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z);
    
    float3 left = _const_accessor((i > 0) ? i - 1 : i, j, k);
    float3 right = _const_accessor((i + 1 < ds.x) ? i + 1 : i, j, k);
    float3 down = _const_accessor(i, (j > 0) ? j - 1 : j, k);
    float3 up = _const_accessor(i, (j + 1 < ds.y) ? j + 1 : j, k);
    float3 back = _const_accessor(i, j, (k > 0) ? k - 1 : k);
    float3 front = _const_accessor(i, j, (k + 1 < ds.z) ? k + 1 : k);
    
    float Fx_ym = down.x;
    float Fx_yp = up.x;
    float Fx_zm = back.x;
    float Fx_zp = front.x;
    
    float Fy_xm = left.y;
    float Fy_xp = right.y;
    float Fy_zm = back.y;
    float Fy_zp = front.y;
    
    float Fz_xm = left.z;
    float Fz_xp = right.z;
    float Fz_ym = down.z;
    float Fz_yp = up.z;
    
    return float3(
                  0.5 * (Fz_yp - Fz_ym) / gs.y - 0.5 * (Fy_zp - Fy_zm) / gs.z,
                  0.5 * (Fx_zp - Fx_zm) / gs.z - 0.5 * (Fz_xp - Fz_xm) / gs.x,
                  0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y);
}

float3 CellCenteredVectorGrid3::sample(const float3 x) const { return _linearSampler(x); }

float CellCenteredVectorGrid3::divergence(const float3 x) const {
    array<uint3, 8> indices;
    array<float, 8> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 8; ++i) {
        result += weights[i] * divergenceAtDataPoint(indices[i].x, indices[i].y, indices[i].z);
    }
    
    return result;
}

float3 CellCenteredVectorGrid3::curl(const float3 x) const {
    array<uint3, 8> indices;
    array<float, 8> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float3 result = float3();
    
    for (int i = 0; i < 8; ++i) {
        result += weights[i] * curlAtDataPoint(indices[i].x, indices[i].y, indices[i].z);
    }
    
    return result;
}

CellCenteredVectorGrid3::VectorDataAccessor CellCenteredVectorGrid3::dataAccessor() {
    return _accessor;
}

CellCenteredVectorGrid3::ConstVectorDataAccessor CellCenteredVectorGrid3::constDataAccessor() const {
    return _const_accessor;
}
