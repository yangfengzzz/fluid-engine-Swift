//
//  face_centered_grid3_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "face_centered_grid3.metal"
#include "macros.h"

FaceCenteredGrid3::FaceCenteredGrid3(device float* dataU,
                                     device float* dataV,
                                     device float* dataW,
                                     const uint3 resolution,
                                     const Grid3Descriptor descriptor)
: _resolution(resolution),
_origin(descriptor._origin),
_gridSpacing(descriptor._gridSpacing),
_dataOriginU(_origin + 0.5 * float3(0.0, descriptor._gridSpacing.y, descriptor._gridSpacing.z)),
_dataOriginV(_origin + 0.5 * float3(descriptor._gridSpacing.x, 0.0, descriptor._gridSpacing.z)),
_dataOriginW(_origin + 0.5 * float3(descriptor._gridSpacing.x, descriptor._gridSpacing.y, 0.0)),
_dataU(dataU),
_dataV(dataV),
_dataW(dataW),
_accessorU(_resolution + uint3(1, 0, 0), _dataU),
_accessorV(_resolution + uint3(0, 1, 0), _dataV),
_accessorW(_resolution + uint3(0, 0, 1), _dataV),
_const_accessorU(_resolution + uint3(1, 0, 0), _dataU),
_const_accessorV(_resolution + uint3(0, 1, 0), _dataV),
_const_accessorW(_resolution + uint3(0, 0, 1), _dataV),
_uLinearSampler(_const_accessorU, float3(1, 1, 1), float3()),
_vLinearSampler(_const_accessorV, float3(1, 1, 1), float3()),
_wLinearSampler(_const_accessorW, float3(1, 1, 1), float3()){
    resetSampler();
}

void FaceCenteredGrid3::resetSampler() {
    _uLinearSampler = LinearArraySampler3<float, float>(_const_accessorU, gridSpacing(), _dataOriginU);
    _vLinearSampler = LinearArraySampler3<float, float>(_const_accessorV, gridSpacing(), _dataOriginV);
    _wLinearSampler = LinearArraySampler3<float, float>(_const_accessorW, gridSpacing(), _dataOriginW);
}

//MARK: Implementation-Accessor:-
const uint3 FaceCenteredGrid3::resolution() const { return _resolution; }

const float3 FaceCenteredGrid3::origin() const { return _origin; }

const float3 FaceCenteredGrid3::gridSpacing() const { return _gridSpacing; }

float3 FaceCenteredGrid3::cellCenterPosition(size_t i, size_t j, size_t k) const {
    float3 h = _gridSpacing;
    float3 o = _origin;
    return o + h * float3(i + 0.5, j + 0.5, k + 0.5);
}

device float& FaceCenteredGrid3::u(size_t i, size_t j, size_t k) { return _accessorU(i, j, k); }

const float FaceCenteredGrid3::u(size_t i, size_t j, size_t k) const {
    return _const_accessorU(i, j, k);
}

device float& FaceCenteredGrid3::v(size_t i, size_t j, size_t k) { return _accessorV(i, j, k); }

const float FaceCenteredGrid3::v(size_t i, size_t j, size_t k) const {
    return _const_accessorV(i, j, k);
}

device float& FaceCenteredGrid3::w(size_t i, size_t j, size_t k) { return _accessorW(i, j, k); }

const float FaceCenteredGrid3::w(size_t i, size_t j, size_t k) const {
    return _const_accessorW(i, j, k);
}

float3 FaceCenteredGrid3::valueAtCellCenter(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < resolution().x && j < resolution().y && k < resolution().z);
    
    return 0.5 * float3(_const_accessorU(i, j, k) + _const_accessorU(i + 1, j, k),
                        _const_accessorV(i, j, k) + _const_accessorV(i, j + 1, k),
                        _const_accessorW(i, j, k) + _const_accessorW(i, j, k + 1));
}

float FaceCenteredGrid3::divergenceAtCellCenter(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < resolution().x && j < resolution().y && k < resolution().z);
    
    const float3 gs = gridSpacing();
    
    float leftU = _const_accessorU(i, j, k);
    float rightU = _const_accessorU(i + 1, j, k);
    float bottomV = _const_accessorV(i, j, k);
    float topV = _const_accessorV(i, j + 1, k);
    float backW = _const_accessorW(i, j, k);
    float frontW = _const_accessorW(i, j, k + 1);
    
    return (rightU - leftU) / gs.x + (topV - bottomV) / gs.y +
    (frontW - backW) / gs.z;
}

float3 FaceCenteredGrid3::curlAtCellCenter(size_t i, size_t j, size_t k) const {
    const uint3 res = resolution();
    const float3 gs = gridSpacing();
    
    VOX_ASSERT(i < res.x && j < res.y && k < res.z);
    
    float3 left = valueAtCellCenter((i > 0) ? i - 1 : i, j, k);
    float3 right = valueAtCellCenter((i + 1 < res.x) ? i + 1 : i, j, k);
    float3 down = valueAtCellCenter(i, (j > 0) ? j - 1 : j, k);
    float3 up = valueAtCellCenter(i, (j + 1 < res.y) ? j + 1 : j, k);
    float3 back = valueAtCellCenter(i, j, (k > 0) ? k - 1 : k);
    float3 front = valueAtCellCenter(i, j, (k + 1 < res.z) ? k + 1 : k);
    
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

FaceCenteredGrid3::ScalarDataAccessor FaceCenteredGrid3::uAccessor() {
    return _accessorU;
}

FaceCenteredGrid3::ConstScalarDataAccessor FaceCenteredGrid3::uConstAccessor()
const {
    return _const_accessorU;
}

FaceCenteredGrid3::ScalarDataAccessor FaceCenteredGrid3::vAccessor() {
    return _accessorV;
}

FaceCenteredGrid3::ConstScalarDataAccessor FaceCenteredGrid3::vConstAccessor()
const {
    return _const_accessorV;
}

FaceCenteredGrid3::ScalarDataAccessor FaceCenteredGrid3::wAccessor() {
    return _accessorW;
}

FaceCenteredGrid3::ConstScalarDataAccessor FaceCenteredGrid3::wConstAccessor()
const {
    return _const_accessorW;
}

float3 FaceCenteredGrid3::uPosition(size_t i, size_t j, size_t k) const {
    float3 h = gridSpacing();
    return _dataOriginU + h * float3(i, j, k);
}

float3 FaceCenteredGrid3::vPosition(size_t i, size_t j, size_t k) const {
    float3 h = gridSpacing();
    return _dataOriginV + h * float3(i, j, k);
}

float3 FaceCenteredGrid3::wPosition(size_t i, size_t j, size_t k) const {
    float3 h = gridSpacing();
    return _dataOriginW + h * float3(i, j, k);
}

uint3 FaceCenteredGrid3::uSize() const { return _resolution + uint3(1, 0, 0); }

uint3 FaceCenteredGrid3::vSize() const { return _resolution + uint3(0, 1, 0); }

uint3 FaceCenteredGrid3::wSize() const { return _resolution + uint3(0, 0, 1); }

float3 FaceCenteredGrid3::uOrigin() const { return _dataOriginU; }

float3 FaceCenteredGrid3::vOrigin() const { return _dataOriginV; }

float3 FaceCenteredGrid3::wOrigin() const { return _dataOriginW; }

float3 FaceCenteredGrid3::sample(const float3 x) const {
    return float3(_uLinearSampler(x), _vLinearSampler(x), _wLinearSampler(x));
}

float FaceCenteredGrid3::divergence(const float3 x) const {
    uint3 res = resolution();
    int i, j, k;
    float fx, fy, fz;
    float3 cellCenterOrigin = origin() + 0.5 * gridSpacing();
    
    float3 normalizedX = (x - cellCenterOrigin) / gridSpacing();
    
    getBarycentric(normalizedX.x, 0, static_cast<int>(res.x) - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, static_cast<int>(res.y) - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, static_cast<int>(res.z) - 1, &k, &fz);
    
    array<uint3, 8> indices;
    array<float, 8> weights;
    
    indices[0] = uint3(i, j, k);
    indices[1] = uint3(i + 1, j, k);
    indices[2] = uint3(i, j + 1, k);
    indices[3] = uint3(i + 1, j + 1, k);
    indices[4] = uint3(i, j, k + 1);
    indices[5] = uint3(i + 1, j, k + 1);
    indices[6] = uint3(i, j + 1, k + 1);
    indices[7] = uint3(i + 1, j + 1, k + 1);
    
    weights[0] = (1.0 - fx) * (1.0 - fy) * (1.0 - fz);
    weights[1] = fx * (1.0 - fy) * (1.0 - fz);
    weights[2] = (1.0 - fx) * fy * (1.0 - fz);
    weights[3] = fx * fy * (1.0 - fz);
    weights[4] = (1.0 - fx) * (1.0 - fy) * fz;
    weights[5] = fx * (1.0 - fy) * fz;
    weights[6] = (1.0 - fx) * fy * fz;
    weights[7] = fx * fy * fz;
    
    float result = 0.0;
    
    for (int n = 0; n < 8; ++n) {
        result += weights[n] * divergenceAtCellCenter(
                                                      indices[n].x, indices[n].y, indices[n].z);
    }
    
    return result;
}

float3 FaceCenteredGrid3::curl(const float3 x) const {
    uint3 res = resolution();
    int i, j, k;
    float fx, fy, fz;
    float3 cellCenterOrigin = origin() + 0.5 * gridSpacing();
    
    float3 normalizedX = (x - cellCenterOrigin) / gridSpacing();
    
    getBarycentric(normalizedX.x, 0, static_cast<int>(res.x) - 1, &i, &fx);
    getBarycentric(normalizedX.y, 0, static_cast<int>(res.y) - 1, &j, &fy);
    getBarycentric(normalizedX.z, 0, static_cast<int>(res.z) - 1, &k, &fz);
    
    array<uint3, 8> indices;
    array<float, 8> weights;
    
    indices[0] = uint3(i, j, k);
    indices[1] = uint3(i + 1, j, k);
    indices[2] = uint3(i, j + 1, k);
    indices[3] = uint3(i + 1, j + 1, k);
    indices[4] = uint3(i, j, k + 1);
    indices[5] = uint3(i + 1, j, k + 1);
    indices[6] = uint3(i, j + 1, k + 1);
    indices[7] = uint3(i + 1, j + 1, k + 1);
    
    weights[0] = (1.0 - fx) * (1.0 - fy) * (1.0 - fz);
    weights[1] = fx * (1.0 - fy) * (1.0 - fz);
    weights[2] = (1.0 - fx) * fy * (1.0 - fz);
    weights[3] = fx * fy * (1.0 - fz);
    weights[4] = (1.0 - fx) * (1.0 - fy) * fz;
    weights[5] = fx * (1.0 - fy) * fz;
    weights[6] = (1.0 - fx) * fy * fz;
    weights[7] = fx * fy * fz;
    
    float3 result = float3();
    
    for (int n = 0; n < 8; ++n) {
        result += weights[n] *
        curlAtCellCenter(indices[n].x, indices[n].y, indices[n].z);
    }
    
    return result;
}
