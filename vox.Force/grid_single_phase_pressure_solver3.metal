//
//  grid_single_phase_pressure_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "grid.metal"
#include "fdm_matrix_row_type.h"
#include "face_centered_grid3.metal"

constant char kFluid = 0;
constant char kAir = 1;
constant char kBoundary = 2;

namespace GridSinglePhasePressureSolver3 {
    kernel void buildSingleSystem(device FdmMatrixRow3 *_A [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device char *_markers [[buffer(2)]],
                                  device float *_dataU [[buffer(3)]],
                                  device float *_dataV [[buffer(4)]],
                                  device float *_dataW [[buffer(5)]],
                                  constant Grid3Descriptor &descriptor [[buffer(6)]],
                                  constant float3 &invHSqr [[buffer(7)]],
                                  uint3 id [[thread_position_in_grid]],
                                  uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> A(size, _A);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<char> markers(size, _markers);
        FaceCenteredGrid3 input(_dataU, _dataV, _dataW, size, descriptor);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        thread auto& row = A(i, j, k);
        
        // initialize
        row.center = row.right = row.up = row.front = 0.0;
        b(i, j, k) = 0.0;
        
        if (markers(i, j, k) == kFluid) {
            b(i, j, k) = input.divergenceAtCellCenter(i, j, k);
            
            if (i + 1 < size.x && markers(i + 1, j, k) != kBoundary) {
                row.center += invHSqr.x;
                if (markers(i + 1, j, k) == kFluid) {
                    row.right -= invHSqr.x;
                }
            }
            
            if (i > 0 && markers(i - 1, j, k) != kBoundary) {
                row.center += invHSqr.x;
            }
            
            if (j + 1 < size.y && markers(i, j + 1, k) != kBoundary) {
                row.center += invHSqr.y;
                if (markers(i, j + 1, k) == kFluid) {
                    row.up -= invHSqr.y;
                }
            }
            
            if (j > 0 && markers(i, j - 1, k) != kBoundary) {
                row.center += invHSqr.y;
            }
            
            if (k + 1 < size.z && markers(i, j, k + 1) != kBoundary) {
                row.center += invHSqr.z;
                if (markers(i, j, k + 1) == kFluid) {
                    row.front -= invHSqr.z;
                }
            }
            
            if (k > 0 && markers(i, j, k - 1) != kBoundary) {
                row.center += invHSqr.z;
            }
        } else {
            row.center = 1.0;
        }
    }
    
    kernel void applyPressureGradient(device float *_x [[buffer(0)]],
                                      device char *_markers [[buffer(1)]],
                                      device float *_inputU [[buffer(2)]],
                                      device float *_inputV [[buffer(3)]],
                                      device float *_inputW [[buffer(4)]],
                                      constant Grid3Descriptor &input_descriptor [[buffer(5)]],
                                      device float *_outputU [[buffer(6)]],
                                      device float *_outputV [[buffer(7)]],
                                      device float *_outputW [[buffer(8)]],
                                      constant Grid3Descriptor &output_descriptor [[buffer(9)]],
                                      constant float3 &invH [[buffer(10)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<char> markers(size, _markers);
        FaceCenteredGrid3 input(_inputU, _inputV, _inputW, size, input_descriptor);
        FaceCenteredGrid3 output(_outputU, _outputV, _outputW, size, output_descriptor);
        auto u = input.uConstAccessor();
        auto v = input.vConstAccessor();
        auto w = input.wConstAccessor();
        auto u0 = output.uAccessor();
        auto v0 = output.vAccessor();
        auto w0 = output.wAccessor();
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        if (markers(i, j, k) == kFluid) {
            if (i + 1 < size.x && markers(i + 1, j, k) != kBoundary) {
                u0(i + 1, j, k) =
                u(i + 1, j, k) + invH.x * (x(i + 1, j, k) - x(i, j, k));
            }
            if (j + 1 < size.y && markers(i, j + 1, k) != kBoundary) {
                v0(i, j + 1, k) =
                v(i, j + 1, k) + invH.y * (x(i, j + 1, k) - x(i, j, k));
            }
            if (k + 1 < size.z && markers(i, j, k + 1) != kBoundary) {
                w0(i, j, k + 1) =
                w(i, j, k + 1) + invH.z * (x(i, j, k + 1) - x(i, j, k));
            }
        }
    }
    
    kernel void buildMarkers(constant uint &iBegin [[buffer(0)]],
                             constant uint &iEnd [[buffer(1)]],
                             constant uint &jBegin [[buffer(2)]],
                             constant uint &jEnd [[buffer(3)]],
                             device char *_finer [[buffer(4)]],
                             device char *_coarser [[buffer(5)]],
                             uint id [[thread_position_in_grid]],
                             uint size [[threads_per_grid]]) {
        uint3 size_accessor(iEnd-iBegin, jEnd-jBegin, size);
        ArrayAccessor3<char> finer(size_accessor, _finer);
        ArrayAccessor3<char> coarser(size_accessor, _coarser);
        uint k = id;
        
        array<size_t, 4> kIndices;
        kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k;
        kIndices[1] = 2 * k;
        kIndices[2] = 2 * k + 1;
        kIndices[3] = (k + 1 < size_accessor.z) ? 2 * k + 2 : 2 * k + 1;
        
        array<size_t, 4> jIndices;
        
        for (size_t j = jBegin; j < jEnd; ++j) {
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
                for (size_t z = 0; z < 4; ++z) {
                    for (size_t y = 0; y < 4; ++y) {
                        for (size_t x = 0; x < 4; ++x) {
                            char f = finer(iIndices[x], jIndices[y],
                                           kIndices[z]);
                            if (f == kBoundary) {
                                ++cnt[(int)kBoundary];
                            } else if (f == kFluid) {
                                ++cnt[(int)kFluid];
                            } else {
                                ++cnt[(int)kAir];
                            }
                        }
                    }
                }
                
                coarser(i, j, k) = static_cast<char>(
                                                     argmax3(cnt[0], cnt[1], cnt[2]));
            }
        }
    }
}
