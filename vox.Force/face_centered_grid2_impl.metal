//
//  face_centered_grid2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "face_centered_grid2.metal"
#include "macros.h"

FaceCenteredGrid2::FaceCenteredGrid2(device float* dataU,
                                     device float* dataV,
                                     const uint2 resolution,
                                     const Grid2Descriptor descriptor)
: _resolution(resolution),
_origin(descriptor._origin),
_gridSpacing(descriptor._gridSpacing),
_dataOriginU(_origin + 0.5 * float2(0.0, descriptor._gridSpacing.y)),
_dataOriginV(_origin + 0.5 * float2(descriptor._gridSpacing.x, 0.0)),
_dataU(dataU),
_dataV(dataV),
_accessorU(_resolution + uint2(1, 0), _dataU),
_accessorV(_resolution + uint2(0, 1), _dataV),
_const_accessorU(_resolution + uint2(1, 0), _dataU),
_const_accessorV(_resolution + uint2(0, 1), _dataV),
_uLinearSampler(_const_accessorU, float2(1, 1), float2()),
_vLinearSampler(_const_accessorV, float2(1, 1), float2()){
    resetSampler();
}

void FaceCenteredGrid2::resetSampler() {
    _uLinearSampler = LinearArraySampler2<float, float>(_const_accessorU, gridSpacing(), _dataOriginU);
    _vLinearSampler = LinearArraySampler2<float, float>(_const_accessorV, gridSpacing(), _dataOriginV);
}

//MARK: Implementation-Accessor:-
const uint2 FaceCenteredGrid2::resolution() const { return _resolution; }

const float2 FaceCenteredGrid2::origin() const { return _origin; }

const float2 FaceCenteredGrid2::gridSpacing() const { return _gridSpacing; }

float2 FaceCenteredGrid2::cellCenterPosition(size_t i, size_t j) const {
    float2 h = _gridSpacing;
    float2 o = _origin;
    return o + h * float2(i + 0.5, j + 0.5);
}

device float& FaceCenteredGrid2::u(size_t i, size_t j) { return _accessorU(i, j); }

const float FaceCenteredGrid2::u(size_t i, size_t j) const {
    return _const_accessorU(i, j);
}

device float& FaceCenteredGrid2::v(size_t i, size_t j) { return _accessorV(i, j); }

const float FaceCenteredGrid2::v(size_t i, size_t j) const {
    return _const_accessorV(i, j);
}

float2 FaceCenteredGrid2::valueAtCellCenter(size_t i, size_t j) const {
    VOX_ASSERT(i < resolution().x && j < resolution().y);
    
    return 0.5 * float2(_const_accessorU(i, j) + _const_accessorU(i + 1, j),
                        _const_accessorV(i, j) + _const_accessorV(i, j + 1));
}

float FaceCenteredGrid2::divergenceAtCellCenter(size_t i, size_t j) const {
    VOX_ASSERT(i < resolution().x && j < resolution().y);
    
    const float2 gs = gridSpacing();
    
    float leftU = _const_accessorU(i, j);
    float rightU = _const_accessorU(i + 1, j);
    float bottomV = _const_accessorV(i, j);
    float topV = _const_accessorV(i, j + 1);
    
    return (rightU - leftU) / gs.x + (topV - bottomV) / gs.y;
}

float FaceCenteredGrid2::curlAtCellCenter(size_t i, size_t j) const {
    const uint2 res = resolution();
    
    VOX_ASSERT(i < res.x && j < res.y);
    
    const float2 gs = gridSpacing();
    
    float2 left = valueAtCellCenter((i > 0) ? i - 1 : i, j);
    float2 right = valueAtCellCenter((i + 1 < res.x) ? i + 1 : i, j);
    float2 bottom = valueAtCellCenter(i, (j > 0) ? j - 1 : j);
    float2 top = valueAtCellCenter(i, (j + 1 < res.y) ? j + 1 : j);
    
    float Fx_ym = bottom.x;
    float Fx_yp = top.x;
    
    float Fy_xm = left.y;
    float Fy_xp = right.y;
    
    return 0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y;
}

FaceCenteredGrid2::ScalarDataAccessor FaceCenteredGrid2::uAccessor() {
    return _accessorU;
}

FaceCenteredGrid2::ConstScalarDataAccessor FaceCenteredGrid2::uConstAccessor()
const {
    return _const_accessorU;
}

FaceCenteredGrid2::ScalarDataAccessor FaceCenteredGrid2::vAccessor() {
    return _accessorV;
}

FaceCenteredGrid2::ConstScalarDataAccessor FaceCenteredGrid2::vConstAccessor()
const {
    return _const_accessorV;
}

float2 FaceCenteredGrid2::uPosition(size_t i, size_t j) const {
    float2 h = gridSpacing();
    return _dataOriginU + h * float2(i, j);
}

float2 FaceCenteredGrid2::vPosition(size_t i, size_t j) const {
    float2 h = gridSpacing();
    return _dataOriginV + h * float2(i, j);
}

uint2 FaceCenteredGrid2::uSize() const { return _resolution + uint2(1, 0); }

uint2 FaceCenteredGrid2::vSize() const { return _resolution + uint2(0, 1); }

float2 FaceCenteredGrid2::uOrigin() const { return _dataOriginU; }

float2 FaceCenteredGrid2::vOrigin() const { return _dataOriginV; }

float2 FaceCenteredGrid2::sample(const float2 x) const {
    return float2(_uLinearSampler(x), _vLinearSampler(x));
}

float FaceCenteredGrid2::divergence(const float2 x) const {
    int i, j;
    float fx, fy;
    float2 cellCenterOrigin = origin() + 0.5 * gridSpacing();
    
    float2 normalizedX = (x - cellCenterOrigin) / gridSpacing();
    
    getBarycentric(normalizedX.x, 0, static_cast<int>(resolution().x) - 1,
                   &i, &fx);
    getBarycentric(normalizedX.y, 0, static_cast<int>(resolution().y) - 1,
                   &j, &fy);
    
    array<uint2, 4> indices;
    array<float, 4> weights;
    
    indices[0] = uint2(i, j);
    indices[1] = uint2(i + 1, j);
    indices[2] = uint2(i, j + 1);
    indices[3] = uint2(i + 1, j + 1);
    
    weights[0] = (1.0 - fx) * (1.0 - fy);
    weights[1] = fx * (1.0 - fy);
    weights[2] = (1.0 - fx) * fy;
    weights[3] = fx * fy;
    
    float result = 0.0;
    
    for (int n = 0; n < 4; ++n) {
        result +=
        weights[n] * divergenceAtCellCenter(indices[n].x, indices[n].y);
    }
    
    return result;
}

float FaceCenteredGrid2::curl(const float2 x) const {
    int i, j;
    float fx, fy;
    float2 cellCenterOrigin = origin() + 0.5 * gridSpacing();
    
    float2 normalizedX = (x - cellCenterOrigin) / gridSpacing();
    
    getBarycentric(normalizedX.x, 0, static_cast<int>(resolution().x) - 1,
                   &i, &fx);
    getBarycentric(normalizedX.y, 0, static_cast<int>(resolution().y) - 1,
                   &j, &fy);
    
    array<uint2, 4> indices;
    array<float, 4> weights;
    
    indices[0] = uint2(i, j);
    indices[1] = uint2(i + 1, j);
    indices[2] = uint2(i, j + 1);
    indices[3] = uint2(i + 1, j + 1);
    
    weights[0] = (1.0 - fx) * (1.0 - fy);
    weights[1] = fx * (1.0 - fy);
    weights[2] = (1.0 - fx) * fy;
    weights[3] = fx * fy;
    
    float result = 0.0;
    
    for (int n = 0; n < 4; ++n) {
        result += weights[n] * curlAtCellCenter(indices[n].x, indices[n].y);
    }
    
    return result;
}
