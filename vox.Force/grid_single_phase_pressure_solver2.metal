//
//  grid_single_phase_pressure_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "grid.metal"
#include "fdm_matrix_row_type.h"
#include "face_centered_grid2.metal"

constant char kFluid = 0;
constant char kAir = 1;
constant char kBoundary = 2;

namespace GridSinglePhasePressureSolver2 {
    kernel void buildSingleSystem(device FdmMatrixRow2 *_A [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device char *_markers [[buffer(2)]],
                                  device float *_dataU [[buffer(3)]],
                                  device float *_dataV [[buffer(4)]],
                                  constant Grid2Descriptor &descriptor [[buffer(5)]],
                                  constant float2 &invHSqr [[buffer(6)]],
                                  uint2 id [[thread_position_in_grid]],
                                  uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> A(size, _A);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<char> markers(size, _markers);
        FaceCenteredGrid2 input(_dataU, _dataV, size, descriptor);
        uint i = id.x;
        uint j = id.y;
        
        thread auto& row = A(i, j);
        
        // initialize
        row.center = row.right = row.up = 0.0;
        b(i, j) = 0.0;
        
        if (markers(i, j) == kFluid) {
            b(i, j) = input.divergenceAtCellCenter(i, j);
            
            if (i + 1 < size.x && markers(i + 1, j) != kBoundary) {
                row.center += invHSqr.x;
                if (markers(i + 1, j) == kFluid) {
                    row.right -= invHSqr.x;
                }
            }
            
            if (i > 0 && markers(i - 1, j) != kBoundary) {
                row.center += invHSqr.x;
            }
            
            if (j + 1 < size.y && markers(i, j + 1) != kBoundary) {
                row.center += invHSqr.y;
                if (markers(i, j + 1) == kFluid) {
                    row.up -= invHSqr.y;
                }
            }
            
            if (j > 0 && markers(i, j - 1) != kBoundary) {
                row.center += invHSqr.y;
            }
        } else {
            row.center = 1.0;
        }
    }
    
    kernel void applyPressureGradient(device float *_x [[buffer(0)]],
                                      device char *_markers [[buffer(1)]],
                                      device float *_inputU [[buffer(2)]],
                                      device float *_inputV [[buffer(3)]],
                                      constant Grid2Descriptor &input_descriptor [[buffer(4)]],
                                      device float *_outputU [[buffer(5)]],
                                      device float *_outputV [[buffer(6)]],
                                      constant Grid2Descriptor &output_descriptor [[buffer(7)]],
                                      constant float2 &invH [[buffer(8)]],
                                      uint2 id [[thread_position_in_grid]],
                                      uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<char> markers(size, _markers);
        FaceCenteredGrid2 input(_inputU, _inputV, size, input_descriptor);
        FaceCenteredGrid2 output(_outputU, _outputV, size, output_descriptor);
        auto u = input.uConstAccessor();
        auto v = input.vConstAccessor();
        auto u0 = output.uAccessor();
        auto v0 = output.vAccessor();
        uint i = id.x;
        uint j = id.y;
        
        if (markers(i, j) == kFluid) {
            if (i + 1 < size.x && markers(i + 1, j) != kBoundary) {
                u0(i + 1, j) = u(i + 1, j) + invH.x * (x(i + 1, j) - x(i, j));
            }
            if (j + 1 < size.y && markers(i, j + 1) != kBoundary) {
                v0(i, j + 1) = v(i, j + 1) + invH.y * (x(i, j + 1) - x(i, j));
            }
        }
    }
    
    kernel void buildMarkers(constant uint &iBegin [[buffer(0)]],
                             constant uint &iEnd [[buffer(1)]],
                             device char *_finer [[buffer(2)]],
                             device char *_coarser [[buffer(3)]],
                             uint id [[thread_position_in_grid]],
                             uint size [[threads_per_grid]]) {
        uint2 size_accessor(iEnd-iBegin, size);
        ArrayAccessor2<char> finer(size_accessor, _finer);
        ArrayAccessor2<char> coarser(size_accessor, _coarser);
        uint j = id;
        
        array<size_t, 4> jIndices;
        jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j;
        jIndices[1] = 2 * j;
        jIndices[2] = 2 * j + 1;
        jIndices[3] = (j + 1 < size_accessor.y) ? 2 * j + 2 : 2 * j + 1;
        
        array<size_t, 4> iIndices;
        for (size_t i = iBegin; i < iEnd; ++i) {
            iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i;
            iIndices[1] = 2 * i;
            iIndices[2] = 2 * i + 1;
            iIndices[3] = (i + 1 < size_accessor.x) ? 2 * i + 2 : 2 * i + 1;
            
            int cnt[3] = {0, 0, 0};
            for (size_t y = 0; y < 4; ++y) {
                for (size_t x = 0; x < 4; ++x) {
                    char f = finer(iIndices[x], jIndices[y]);
                    if (f == kBoundary) {
                        ++cnt[(int)kBoundary];
                    } else if (f == kFluid) {
                        ++cnt[(int)kFluid];
                    } else {
                        ++cnt[(int)kAir];
                    }
                }
            }
            
            coarser(i, j) =
            static_cast<char>(argmax3(cnt[0], cnt[1], cnt[2]));
        }
    }
}
