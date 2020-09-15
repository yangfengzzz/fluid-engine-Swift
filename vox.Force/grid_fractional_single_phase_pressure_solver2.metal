//
//  grid_fractional_single_phase_pressure_solver2.metal
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
#include "level_set_utils.metal"

namespace GridFractionalSinglePhasePressureSolver2 {
    kernel void applyPressureGradient(device float *_x [[buffer(0)]],
                                      device float *__fluidSdf [[buffer(1)]],
                                      device float *__uWeights [[buffer(2)]],
                                      device float *__vWeights [[buffer(3)]],
                                      device float *_inputU [[buffer(4)]],
                                      device float *_inputV [[buffer(5)]],
                                      constant Grid2Descriptor &input_descriptor [[buffer(6)]],
                                      device float *_outputU [[buffer(7)]],
                                      device float *_outputV [[buffer(8)]],
                                      constant Grid2Descriptor &output_descriptor [[buffer(9)]],
                                      constant float2 &invH [[buffer(10)]],
                                      uint2 id [[thread_position_in_grid]],
                                      uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> _fluidSdf(size, __fluidSdf);
        ArrayAccessor2<float> _uWeights(size+uint2(1, 0), __uWeights);
        ArrayAccessor2<float> _vWeights(size+uint2(0, 1), __vWeights);
        FaceCenteredGrid2 input(_inputU, _inputV, size, input_descriptor);
        FaceCenteredGrid2 output(_outputU, _outputV, size, output_descriptor);
        auto u = input.uConstAccessor();
        auto v = input.vConstAccessor();
        auto u0 = output.uAccessor();
        auto v0 = output.vAccessor();
        uint i = id.x;
        uint j = id.y;
        
        float centerPhi = _fluidSdf(i, j);
        
        if (i + 1 < size.x && _uWeights(i + 1, j) > 0.0 &&
            (isInsideSdf(centerPhi) || isInsideSdf(_fluidSdf(i + 1, j)))) {
            float rightPhi = _fluidSdf(i + 1, j);
            float theta = fractionInsideSdf(centerPhi, rightPhi);
            theta = max(theta, 0.01);
            
            u0(i + 1, j) =
            u(i + 1, j) + invH.x / theta * (x(i + 1, j) - x(i, j));
        }
        
        if (j + 1 < size.y && _vWeights(i, j + 1) > 0.0 &&
            (isInsideSdf(centerPhi) || isInsideSdf(_fluidSdf(i, j + 1)))) {
            float upPhi = _fluidSdf(i, j + 1);
            float theta = fractionInsideSdf(centerPhi, upPhi);
            theta = max(theta, 0.01);
            
            v0(i, j + 1) =
            v(i, j + 1) + invH.y / theta * (x(i, j + 1) - x(i, j));
        }
    }
    
    // --*--|--*--|--*--|--*--
    //  1/8   3/8   3/8   1/8
    //           to
    // -----|-----*-----|-----
    constant array<float, 4> centeredKernel = {
        {0.125f, 0.375f, 0.375f, 0.125f}};
    
    // -|----|----|----|----|-
    //      1/4  1/2  1/4
    //           to
    // -|---------|---------|-
    constant array<float, 4> staggeredKernel = {{0.f, 1.f, 0.f, 0.f}};
    
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
        
        array<int, 2> kernelSize;
        kernelSize[0] = finer.size().x != 2 * coarser.size().x ? 3 : 4;
        kernelSize[1] = finer.size().y != 2 * coarser.size().y ? 3 : 4;
        
        array<array<float, 4>, 2> kernels;
        kernels[0] = (kernelSize[0] == 3) ? staggeredKernel : centeredKernel;
        kernels[1] = (kernelSize[1] == 3) ? staggeredKernel : centeredKernel;
        
        array<size_t, 4> jIndices{{0, 0, 0, 0}};
        if (kernelSize[1] == 3) {
            jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j;
            jIndices[1] = 2 * j;
            jIndices[2] = (j + 1 < size_accessor.y) ? 2 * j + 1 : 2 * j;
        } else {
            jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j;
            jIndices[1] = 2 * j;
            jIndices[2] = 2 * j + 1;
            jIndices[3] = (j + 1 < size_accessor.y) ? 2 * j + 2 : 2 * j + 1;
        }
        
        array<size_t, 4> iIndices{{0, 0, 0, 0}};
        for (size_t i = iBegin; i < iEnd; ++i) {
            if (kernelSize[0] == 3) {
                iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i;
                iIndices[1] = 2 * i;
                iIndices[2] = (i + 1 < size_accessor.x) ? 2 * i + 1 : 2 * i;
            } else {
                iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i;
                iIndices[1] = 2 * i;
                iIndices[2] = 2 * i + 1;
                iIndices[3] = (i + 1 < size_accessor.x) ? 2 * i + 2 : 2 * i + 1;
            }
            
            float sum = 0.0f;
            for (int y = 0; y < kernelSize[1]; ++y) {
                for (int x = 0; x < kernelSize[0]; ++x) {
                    float w = kernels[0][x] * kernels[1][y];
                    sum += w * finer(iIndices[x], jIndices[y]);
                }
            }
            coarser(i, j) = sum;
        }
    }
    
    kernel void buildSingleSystem(device FdmMatrixRow2 *_A [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device float *_fluidSdf [[buffer(2)]],
                                  device float *_uWeights [[buffer(3)]],
                                  device float *_vWeights [[buffer(4)]],
                                  device float *_inputU [[buffer(5)]],
                                  device float *_inputV [[buffer(6)]],
                                  constant Grid2Descriptor &input_descriptor [[buffer(7)]],
                                  constant float2 &invH [[buffer(8)]],
                                  constant float2 &invHSqr [[buffer(9)]],
                                  uint2 id [[thread_position_in_grid]],
                                  uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> A(size, _A);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<float> fluidSdf(size, _fluidSdf);
        ArrayAccessor2<float> uWeights(size+uint2(1, 0), _uWeights);
        ArrayAccessor2<float> vWeights(size+uint2(0, 1), _vWeights);
        FaceCenteredGrid2 input(_inputU, _inputV, size, input_descriptor);
        uint i = id.x;
        uint j = id.y;
        
        thread auto& row = A(i, j);
        
        // initialize
        row.center = row.right = row.up = 0.0;
        b(i, j) = 0.0;
        
        float centerPhi = fluidSdf(i, j);
        
        if (isInsideSdf(centerPhi)) {
            float term = 0.0;
            
            if (i + 1 < size.x) {
                term = uWeights(i + 1, j) * invHSqr.x;
                float rightPhi = fluidSdf(i + 1, j);
                if (isInsideSdf(rightPhi)) {
                    row.center += term;
                    row.right -= term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, rightPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j) += uWeights(i + 1, j) * input.u(i + 1, j) * invH.x;
            } else {
                b(i, j) += input.u(i + 1, j) * invH.x;
            }
            
            if (i > 0) {
                term = uWeights(i, j) * invHSqr.x;
                float leftPhi = fluidSdf(i - 1, j);
                if (isInsideSdf(leftPhi)) {
                    row.center += term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, leftPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j) -= uWeights(i, j) * input.u(i, j) * invH.x;
            } else {
                b(i, j) -= input.u(i, j) * invH.x;
            }
            
            if (j + 1 < size.y) {
                term = vWeights(i, j + 1) * invHSqr.y;
                float upPhi = fluidSdf(i, j + 1);
                if (isInsideSdf(upPhi)) {
                    row.center += term;
                    row.up -= term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, upPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j) += vWeights(i, j + 1) * input.v(i, j + 1) * invH.y;
            } else {
                b(i, j) += input.v(i, j + 1) * invH.y;
            }
            
            if (j > 0) {
                term = vWeights(i, j) * invHSqr.y;
                float downPhi = fluidSdf(i, j - 1);
                if (isInsideSdf(downPhi)) {
                    row.center += term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, downPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j) -= vWeights(i, j) * input.v(i, j) * invH.y;
            } else {
                b(i, j) -= input.v(i, j) * invH.y;
            }
            
            // If row.center is near-zero, the cell is likely inside a solid
            // boundary.
            if (row.center < kEpsilonF) {
                row.center = 1.0;
                b(i, j) = 0.0;
            }
        } else {
            row.center = 1.0;
        }
    }
}
