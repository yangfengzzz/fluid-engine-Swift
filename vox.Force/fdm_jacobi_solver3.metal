//
//  fdm_jacobi_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "fdm_matrix_row_type.h"

namespace FdmJacobiSolver3 {
    kernel void relax(device FdmMatrixRow3 *_A [[buffer(0)]],
                      device float *_b [[buffer(1)]],
                      device float *_x [[buffer(2)]],
                      device float *_xTemp [[buffer(3)]],
                      uint3 id [[thread_position_in_grid]],
                      uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> A(size, _A);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> xTemp(size, _xTemp);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        float r =
        ((i > 0) ? A(i - 1, j, k).right * x(i - 1, j, k) : 0.0) +
        ((i + 1 < size.x) ? A(i, j, k).right * x(i + 1, j, k) : 0.0) +
        ((j > 0) ? A(i, j - 1, k).up * x(i, j - 1, k) : 0.0) +
        ((j + 1 < size.y) ? A(i, j, k).up * x(i, j + 1, k) : 0.0) +
        ((k > 0) ? A(i, j, k - 1).front * x(i, j, k - 1) : 0.0) +
        ((k + 1 < size.z) ? A(i, j, k).front * x(i, j, k + 1) : 0.0);
        
        xTemp(i, j, k) = (b(i, j, k) - r) / A(i, j, k).center;
    }
}
