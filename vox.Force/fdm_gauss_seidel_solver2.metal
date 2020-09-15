//
//  fdm_gauss_seidel_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "fdm_matrix_row_type.h"

namespace FdmGaussSeidelSolver2 {
    kernel void red(constant uint &iBegin [[buffer(0)]],
                    constant uint &iEnd [[buffer(1)]],
                    device FdmMatrixRow2 *_A [[buffer(2)]],
                    device float *_b [[buffer(3)]],
                    device float *_x [[buffer(4)]],
                    constant float &sorFactor [[buffer(5)]],
                    uint id [[thread_position_in_grid]],
                    uint size [[threads_per_grid]]) {
        uint2 size_accessor(iEnd-iBegin, size);
        ArrayAccessor2<FdmMatrixRow2> A(size_accessor, _A);
        ArrayAccessor2<float> b(size_accessor, _b);
        ArrayAccessor2<float> x(size_accessor, _x);
        uint j = id;
        
        uint i = j % 2 + iBegin;  // i.e. (0, 0)
        for (; i < iEnd; i += 2) {
            float r =
            ((i > 0) ? A(i - 1, j).right * x(i - 1, j) : 0.0) +
            ((i + 1 < size_accessor.x) ? A(i, j).right * x(i + 1, j) : 0.0) +
            ((j > 0) ? A(i, j - 1).up * x(i, j - 1) : 0.0) +
            ((j + 1 < size_accessor.y) ? A(i, j).up * x(i, j + 1) : 0.0);
            
            x(i, j) = (1.0 - sorFactor) * x(i, j) +
            sorFactor * (b(i, j) - r) / A(i, j).center;
        }
    }
    
    kernel void black(constant uint &iBegin [[buffer(0)]],
                      constant uint &iEnd [[buffer(1)]],
                      device FdmMatrixRow2 *_A [[buffer(2)]],
                      device float *_b [[buffer(3)]],
                      device float *_x [[buffer(4)]],
                      constant float &sorFactor [[buffer(5)]],
                      uint id [[thread_position_in_grid]],
                      uint size [[threads_per_grid]]) {
        uint2 size_accessor(iEnd-iBegin, size);
        ArrayAccessor2<FdmMatrixRow2> A(size_accessor, _A);
        ArrayAccessor2<float> b(size_accessor, _b);
        ArrayAccessor2<float> x(size_accessor, _x);
        uint j = id;
        
        uint i = 1 - j % 2 + iBegin;  // i.e. (1, 0)
        for (; i < iEnd; i += 2) {
            float r =
            ((i > 0) ? A(i - 1, j).right * x(i - 1, j) : 0.0) +
            ((i + 1 < size_accessor.x) ? A(i, j).right * x(i + 1, j) : 0.0) +
            ((j > 0) ? A(i, j - 1).up * x(i, j - 1) : 0.0) +
            ((j + 1 < size_accessor.y) ? A(i, j).up * x(i, j + 1) : 0.0);
            
            x(i, j) = (1.0 - sorFactor) * x(i, j) +
            sorFactor * (b(i, j) - r) / A(i, j).center;
        }
    }
}
