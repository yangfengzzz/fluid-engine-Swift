//
//  cell_centered_scalar_grid2_impl.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "cell_centered_scalar_grid2.metal"

CellCenteredScalarGrid2::CellCenteredScalarGrid2(device float* data,
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

void CellCenteredScalarGrid2::resetSampler() {
    _linearSampler = LinearArraySampler2<float, float>(_const_accessor, gridSpacing(), dataOrigin());
}

//MARK: Implementation-Accessor:-
uint2 CellCenteredScalarGrid2::dataSize() const {
    // The size of the data should be the same as the grid resolution.
    return resolution();
}

float2 CellCenteredScalarGrid2::dataOrigin() const {
    return origin() + 0.5 * gridSpacing();
}

float2 CellCenteredScalarGrid2::dataPosition(size_t i, size_t j) const {
    float2 o = dataOrigin();
    return o + gridSpacing() * float2(i, j);
}

const uint2 CellCenteredScalarGrid2::resolution() const { return _resolution; }

const float2 CellCenteredScalarGrid2::origin() const { return _origin; }

const float2 CellCenteredScalarGrid2::gridSpacing() const { return _gridSpacing; }

float2 CellCenteredScalarGrid2::cellCenterPosition(size_t i, size_t j) const {
    float2 h = _gridSpacing;
    float2 o = _origin;
    return o + h * float2(i + 0.5, j + 0.5);
}

const float CellCenteredScalarGrid2::operator()(size_t i, size_t j) const {
    return _const_accessor(i, j);
}

device float& CellCenteredScalarGrid2::operator()(size_t i, size_t j) {
    return _accessor(i, j);
}

float2 CellCenteredScalarGrid2::gradientAtDataPoint(size_t i, size_t j) const {
    return gradient2(_const_accessor, gridSpacing(), i, j);
}

float CellCenteredScalarGrid2::laplacianAtDataPoint(size_t i, size_t j) const {
    return laplacian2(_const_accessor, gridSpacing(), i, j);
}

float CellCenteredScalarGrid2::sample(const float2 x) const { return _linearSampler(x); }

float2 CellCenteredScalarGrid2::gradient(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float2 result = float2();
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * gradientAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

float CellCenteredScalarGrid2::laplacian(const float2 x) const {
    array<uint2, 4> indices;
    array<float, 4> weights;
    _linearSampler.getCoordinatesAndWeights(x, &indices, &weights);
    
    float result = 0.0;
    
    for (int i = 0; i < 4; ++i) {
        result += weights[i] * laplacianAtDataPoint(indices[i].x, indices[i].y);
    }
    
    return result;
}

CellCenteredScalarGrid2::ScalarDataAccessor CellCenteredScalarGrid2::dataAccessor() {
    return _accessor;
}

CellCenteredScalarGrid2::ConstScalarDataAccessor CellCenteredScalarGrid2::constDataAccessor() const {
    return _const_accessor;
}
