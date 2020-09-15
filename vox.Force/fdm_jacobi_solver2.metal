//
//  fdm_jacobi_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "fdm_matrix_row_type.h"

namespace FdmJacobiSolver2 {
    kernel void relax(device FdmMatrixRow2 *_A [[buffer(0)]],
                      device float *_b [[buffer(1)]],
                      device float *_x [[buffer(2)]],
                      device float *_xTemp [[buffer(3)]],
                      uint2 id [[thread_position_in_grid]],
                      uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> A(size, _A);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> xTemp(size, _xTemp);
        uint i = id.x;
        uint j = id.y;
        
        float r = ((i > 0) ? A(i - 1, j).right * x(i - 1, j) : 0.0) +
        ((i + 1 < size.x) ? A(i, j).right * x(i + 1, j) : 0.0) +
        ((j > 0) ? A(i, j - 1).up * x(i, j - 1) : 0.0) +
        ((j + 1 < size.y) ? A(i, j).up * x(i, j + 1) : 0.0);
        
        xTemp(i, j) = (b(i, j) - r) / A(i, j).center;
    }
}
