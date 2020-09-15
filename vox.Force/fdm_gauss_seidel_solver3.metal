//
//  fdm_gauss_seidel_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "fdm_matrix_row_type.h"

namespace FdmGaussSeidelSolver3 {
    kernel void red(constant uint &iBegin [[buffer(0)]],
                    constant uint &iEnd [[buffer(1)]],
                    constant uint &jBegin [[buffer(2)]],
                    constant uint &jEnd [[buffer(3)]],
                    device FdmMatrixRow3 *_A [[buffer(4)]],
                    device float *_b [[buffer(5)]],
                    device float *_x [[buffer(6)]],
                    constant float &sorFactor [[buffer(7)]],
                    uint id [[thread_position_in_grid]],
                    uint size [[threads_per_grid]]) {
        uint3 size_accessor(iEnd-iBegin, jEnd-jBegin, size);
        ArrayAccessor3<FdmMatrixRow3> A(size_accessor, _A);
        ArrayAccessor3<float> b(size_accessor, _b);
        ArrayAccessor3<float> x(size_accessor, _x);
        uint k = id;
        
        for (uint j = jBegin; j < jEnd; ++j) {
            uint i = (j + k) % 2 + iBegin;  // i.e. (0, 0, 0)
            for (; i < iEnd; i += 2) {
                float r =
                ((i > 0) ? A(i - 1, j, k).right * x(i - 1, j, k)
                 : 0.0) +
                ((i + 1 < size_accessor.x)
                 ? A(i, j, k).right * x(i + 1, j, k)
                 : 0.0) +
                ((j > 0) ? A(i, j - 1, k).up * x(i, j - 1, k)
                 : 0.0) +
                ((j + 1 < size_accessor.y) ? A(i, j, k).up * x(i, j + 1, k)
                 : 0.0) +
                ((k > 0) ? A(i, j, k - 1).front * x(i, j, k - 1)
                 : 0.0) +
                ((k + 1 < size_accessor.z)
                 ? A(i, j, k).front * x(i, j, k + 1)
                 : 0.0);
                
                x(i, j, k) =
                (1.0 - sorFactor) * x(i, j, k) +
                sorFactor * (b(i, j, k) - r) / A(i, j, k).center;
            }
        }
    }
    
    kernel void black(constant uint &iBegin [[buffer(0)]],
                      constant uint &iEnd [[buffer(1)]],
                      constant uint &jBegin [[buffer(2)]],
                      constant uint &jEnd [[buffer(3)]],
                      device FdmMatrixRow3 *_A [[buffer(4)]],
                      device float *_b [[buffer(5)]],
                      device float *_x [[buffer(6)]],
                      constant float &sorFactor [[buffer(7)]],
                      uint id [[thread_position_in_grid]],
                      uint size [[threads_per_grid]]) {
        uint3 size_accessor(iEnd-iBegin, jEnd-jBegin, size);
        ArrayAccessor3<FdmMatrixRow3> A(size_accessor, _A);
        ArrayAccessor3<float> b(size_accessor, _b);
        ArrayAccessor3<float> x(size_accessor, _x);
        uint k = id;
        
        for (uint j = jBegin; j < jEnd; ++j) {
            uint i = 1 - (j + k) % 2 + iBegin;  // i.e. (1, 1, 1)
            for (; i < iEnd; i += 2) {
                float r =
                ((i > 0) ? A(i - 1, j, k).right * x(i - 1, j, k)
                 : 0.0) +
                ((i + 1 < size_accessor.x)
                 ? A(i, j, k).right * x(i + 1, j, k)
                 : 0.0) +
                ((j > 0) ? A(i, j - 1, k).up * x(i, j - 1, k)
                 : 0.0) +
                ((j + 1 < size_accessor.y) ? A(i, j, k).up * x(i, j + 1, k)
                 : 0.0) +
                ((k > 0) ? A(i, j, k - 1).front * x(i, j, k - 1)
                 : 0.0) +
                ((k + 1 < size_accessor.z)
                 ? A(i, j, k).front * x(i, j, k + 1)
                 : 0.0);
                
                x(i, j, k) =
                (1.0 - sorFactor) * x(i, j, k) +
                sorFactor * (b(i, j, k) - r) / A(i, j, k).center;
            }
        }
    }
}
