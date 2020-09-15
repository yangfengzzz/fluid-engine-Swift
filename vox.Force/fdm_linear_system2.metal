//
//  fdm_linear_system2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/12.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "fdm_matrix_row_type.h"

namespace FdmBlas2 {
    kernel void axpy(device float *_x [[buffer(0)]],
                     device float *_y [[buffer(1)]],
                     device float *_result [[buffer(2)]],
                     constant float &a [[buffer(3)]],
                     uint2 id [[thread_position_in_grid]],
                     uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> y(size, _y);
        ArrayAccessor2<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        
        result(i, j) = a * x(i, j) + y(i, j);
    }
    
    kernel void mvm(device FdmMatrixRow2 *_m [[buffer(0)]],
                    device float *_v [[buffer(1)]],
                    device float *_result [[buffer(2)]],
                    uint2 id [[thread_position_in_grid]],
                    uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> m(size, _m);
        ArrayAccessor2<float> v(size, _v);
        ArrayAccessor2<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        
        result(i, j) =
        m(i, j).center * v(i, j) +
        ((i > 0) ? m(i - 1, j).right * v(i - 1, j) : 0.0) +
        ((i + 1 < size.x) ? m(i, j).right * v(i + 1, j) : 0.0) +
        ((j > 0) ? m(i, j - 1).up * v(i, j - 1) : 0.0) +
        ((j + 1 < size.y) ? m(i, j).up * v(i, j + 1) : 0.0);
    }
    
    kernel void residual(device FdmMatrixRow2 *_a [[buffer(0)]],
                         device float *_x [[buffer(1)]],
                         device float *_b [[buffer(2)]],
                         device float *_result [[buffer(3)]],
                         uint2 id [[thread_position_in_grid]],
                         uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> a(size, _a);
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<float> result(size, _result);
        uint i = id.x;
        uint j = id.y;
        
        result(i, j) =
        b(i, j) - a(i, j).center * x(i, j) -
        ((i > 0) ? a(i - 1, j).right * x(i - 1, j) : 0.0) -
        ((i + 1 < size.x) ? a(i, j).right * x(i + 1, j) : 0.0) -
        ((j > 0) ? a(i, j - 1).up * x(i, j - 1) : 0.0) -
        ((j + 1 < size.y) ? a(i, j).up * x(i, j + 1) : 0.0);
    }
}
