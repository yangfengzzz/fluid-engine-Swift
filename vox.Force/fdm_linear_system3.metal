//
//  fdm_linear_system3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "fdm_matrix_row_type.h"

namespace FdmBlas3 {
    kernel void axpy(device float *_x [[buffer(0)]],
                     device float *_y [[buffer(1)]],
                     device float *_result [[buffer(2)]],
                     constant float &a [[buffer(3)]],
                     uint3 id [[thread_position_in_grid]],
                     uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> y(size, _y);
        ArrayAccessor3<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        result(i, j, k) = a * x(i, j, k) + y(i, j, k);
    }
    
    kernel void mvm(device FdmMatrixRow3 *_m [[buffer(0)]],
                    device float *_v [[buffer(1)]],
                    device float *_result [[buffer(2)]],
                    uint3 id [[thread_position_in_grid]],
                    uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> m(size, _m);
        ArrayAccessor3<float> v(size, _v);
        ArrayAccessor3<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        result(i, j, k) =
        m(i, j, k).center * v(i, j, k) +
        ((i > 0) ? m(i - 1, j, k).right * v(i - 1, j, k) : 0.0) +
        ((i + 1 < size.x) ? m(i, j, k).right * v(i + 1, j, k) : 0.0) +
        ((j > 0) ? m(i, j - 1, k).up * v(i, j - 1, k) : 0.0) +
        ((j + 1 < size.y) ? m(i, j, k).up * v(i, j + 1, k) : 0.0) +
        ((k > 0) ? m(i, j, k - 1).front * v(i, j, k - 1) : 0.0) +
        ((k + 1 < size.z) ? m(i, j, k).front * v(i, j, k + 1) : 0.0);
    }
    
    kernel void residual(device FdmMatrixRow3 *_a [[buffer(0)]],
                         device float *_x [[buffer(1)]],
                         device float *_b [[buffer(2)]],
                         device float *_result [[buffer(3)]],
                         uint3 id [[thread_position_in_grid]],
                         uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> a(size, _a);
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        result(i, j, k) =
        b(i, j, k) - a(i, j, k).center * x(i, j, k) -
        ((i > 0) ? a(i - 1, j, k).right * x(i - 1, j, k) : 0.0) -
        ((i + 1 < size.x) ? a(i, j, k).right * x(i + 1, j, k) : 0.0) -
        ((j > 0) ? a(i, j - 1, k).up * x(i, j - 1, k) : 0.0) -
        ((j + 1 < size.y) ? a(i, j, k).up * x(i, j + 1, k) : 0.0) -
        ((k > 0) ? a(i, j, k - 1).front * x(i, j, k - 1) : 0.0) -
        ((k + 1 < size.z) ? a(i, j, k).front * x(i, j, k + 1) : 0.0);
    }
}
