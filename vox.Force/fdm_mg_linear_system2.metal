//
//  fdm_mg_linear_system2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"

namespace FdmMgUtils2 {
    kernel void restricted(constant uint &iBegin [[buffer(0)]],
                           constant uint &iEnd [[buffer(1)]],
                           device float *_finer [[buffer(2)]],
                           device float *_coarser [[buffer(3)]],
                           uint id [[thread_position_in_grid]],
                           uint size [[threads_per_grid]]) {
        uint2 size_accessor(iEnd-iBegin, size);
        ArrayAccessor2<float> finer(size_accessor, _finer);
        ArrayAccessor2<float> coarser(size_accessor, _coarser);
        uint j = id;
        
        const array<float, 4> restricted_kernel = {{0.125, 0.375, 0.375, 0.125}};
        
        array<uint, 4> jIndices;
        jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j;
        jIndices[1] = 2 * j;
        jIndices[2] = 2 * j + 1;
        jIndices[3] = (j + 1 < size_accessor.y) ? 2 * j + 2 : 2 * j + 1;
        
        array<uint, 4> iIndices;
        for (uint i = iBegin; i < iEnd; ++i) {
            iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i;
            iIndices[1] = 2 * i;
            iIndices[2] = 2 * i + 1;
            iIndices[3] = (i + 1 < size_accessor.x) ? 2 * i + 2 : 2 * i + 1;
            
            float sum = 0.0;
            for (uint y = 0; y < 4; ++y) {
                for (uint x = 0; x < 4; ++x) {
                    float w = restricted_kernel[x] * restricted_kernel[y];
                    sum += w * finer(iIndices[x], jIndices[y]);
                }
            }
            coarser(i, j) = sum;
        }
    }
    
    kernel void corrected(constant uint &iBegin [[buffer(0)]],
                          constant uint &iEnd [[buffer(1)]],
                          device float *_finer [[buffer(2)]],
                          device float *_coarser [[buffer(3)]],
                          uint id [[thread_position_in_grid]],
                          uint size [[threads_per_grid]]) {
        uint2 size_accessor(iEnd-iBegin, size);
        ArrayAccessor2<float> finer(size_accessor, _finer);
        ArrayAccessor2<float> coarser(size_accessor, _coarser);
        uint j = id;
        
        for (uint i = iBegin; i < iEnd; ++i) {
            array<uint, 2> iIndices;
            array<uint, 2> jIndices;
            array<float, 2> iWeights;
            array<float, 2> jWeights;
            
            const uint ci = i / 2;
            const uint cj = j / 2;
            
            if (i % 2 == 0) {
                iIndices[0] = (i > 1) ? ci - 1 : ci;
                iIndices[1] = ci;
                iWeights[0] = 0.25;
                iWeights[1] = 0.75;
            } else {
                iIndices[0] = ci;
                iIndices[1] = (i + 1 < size_accessor.x) ? ci + 1 : ci;
                iWeights[0] = 0.75;
                iWeights[1] = 0.25;
            }
            
            if (j % 2 == 0) {
                jIndices[0] = (j > 1) ? cj - 1 : cj;
                jIndices[1] = cj;
                jWeights[0] = 0.25;
                jWeights[1] = 0.75;
            } else {
                jIndices[0] = cj;
                jIndices[1] = (j + 1 < size_accessor.y) ? cj + 1 : cj;
                jWeights[0] = 0.75;
                jWeights[1] = 0.25;
            }
            
            for (uint y = 0; y < 2; ++y) {
                for (uint x = 0; x < 2; ++x) {
                    float w = iWeights[x] * jWeights[y] *
                    coarser(iIndices[x], jIndices[y]);
                    finer(i, j) += w;
                }
            }
        }
    }
}
