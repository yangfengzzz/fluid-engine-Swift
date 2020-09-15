//
//  grid_fractional_single_phase_pressure_solver3.metal
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
#include "level_set_utils.metal"

namespace GridFractionalSinglePhasePressureSolver3 {
    kernel void applyPressureGradient(device float *_x [[buffer(0)]],
                                      device float *__fluidSdf [[buffer(1)]],
                                      device float *__uWeights [[buffer(2)]],
                                      device float *__vWeights [[buffer(3)]],
                                      device float *__wWeights [[buffer(4)]],
                                      device float *_inputU [[buffer(5)]],
                                      device float *_inputV [[buffer(6)]],
                                      device float *_inputW [[buffer(7)]],
                                      constant Grid3Descriptor &input_descriptor [[buffer(8)]],
                                      device float *_outputU [[buffer(9)]],
                                      device float *_outputV [[buffer(10)]],
                                      device float *_outputW [[buffer(11)]],
                                      constant Grid3Descriptor &output_descriptor [[buffer(12)]],
                                      constant float3 &invH [[buffer(13)]],
                                      uint3 id [[thread_position_in_grid]],
                                      uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> _fluidSdf(size, __fluidSdf);
        ArrayAccessor3<float> _uWeights(size+uint3(1, 0, 0), __uWeights);
        ArrayAccessor3<float> _vWeights(size+uint3(0, 1, 0), __vWeights);
        ArrayAccessor3<float> _wWeights(size+uint3(0, 0, 1), __wWeights);
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
        
        float centerPhi = _fluidSdf(i, j, k);
        
        if (i + 1 < size.x && _uWeights(i + 1, j, k) > 0.0 &&
            (isInsideSdf(centerPhi) ||
             isInsideSdf(_fluidSdf(i + 1, j, k)))) {
            float rightPhi = _fluidSdf(i + 1, j, k);
            float theta = fractionInsideSdf(centerPhi, rightPhi);
            theta = max(theta, 0.01);
            
            u0(i + 1, j, k) =
            u(i + 1, j, k) + invH.x / theta * (x(i + 1, j, k) - x(i, j, k));
        }
        
        if (j + 1 < size.y && _vWeights(i, j + 1, k) > 0.0 &&
            (isInsideSdf(centerPhi) ||
             isInsideSdf(_fluidSdf(i, j + 1, k)))) {
            float upPhi = _fluidSdf(i, j + 1, k);
            float theta = fractionInsideSdf(centerPhi, upPhi);
            theta = max(theta, 0.01);
            
            v0(i, j + 1, k) =
            v(i, j + 1, k) + invH.y / theta * (x(i, j + 1, k) - x(i, j, k));
        }
        
        if (k + 1 < size.z && _wWeights(i, j, k + 1) > 0.0 &&
            (isInsideSdf(centerPhi) ||
             isInsideSdf(_fluidSdf(i, j, k + 1)))) {
            float frontPhi = _fluidSdf(i, j, k + 1);
            float theta = fractionInsideSdf(centerPhi, frontPhi);
            theta = max(theta, 0.01);
            
            w0(i, j, k + 1) =
            w(i, j, k + 1) + invH.z / theta * (x(i, j, k + 1) - x(i, j, k));
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
                           constant uint &jBegin [[buffer(2)]],
                           constant uint &jEnd [[buffer(3)]],
                           device float *_finer [[buffer(4)]],
                           device float *_coarser [[buffer(5)]],
                           uint id [[thread_position_in_grid]],
                           uint size [[threads_per_grid]]) {
        uint3 size_accessor(iEnd-iBegin, jEnd-jBegin, size);
        ArrayAccessor3<float> finer(size_accessor, _finer);
        ArrayAccessor3<float> coarser(size_accessor, _coarser);
        uint k = id;
        
        array<int, 3> kernelSize;
        kernelSize[0] = finer.size().x != 2 * coarser.size().x ? 3 : 4;
        kernelSize[1] = finer.size().y != 2 * coarser.size().y ? 3 : 4;
        kernelSize[2] = finer.size().z != 2 * coarser.size().z ? 3 : 4;
        
        array<array<float, 4>, 3> kernels;
        kernels[0] = (kernelSize[0] == 3) ? staggeredKernel : centeredKernel;
        kernels[1] = (kernelSize[1] == 3) ? staggeredKernel : centeredKernel;
        kernels[2] = (kernelSize[2] == 3) ? staggeredKernel : centeredKernel;
        
        array<size_t, 4> kIndices;
        if (kernelSize[2] == 3) {
            kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k;
            kIndices[1] = 2 * k;
            kIndices[2] = (k + 1 < size_accessor.z) ? 2 * k + 1 : 2 * k;
        } else {
            kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k;
            kIndices[1] = 2 * k;
            kIndices[2] = 2 * k + 1;
            kIndices[3] = (k + 1 < size_accessor.z) ? 2 * k + 2 : 2 * k + 1;
        }
        
        array<size_t, 4> jIndices;
        for (size_t j = jBegin; j < jEnd; ++j) {
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
            
            array<size_t, 4> iIndices;
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
                for (int z = 0; z < kernelSize[2]; ++z) {
                    for (int y = 0; y < kernelSize[1]; ++y) {
                        for (int x = 0; x < kernelSize[0]; ++x) {
                            float w = kernels[0][x] * kernels[1][y] *
                            kernels[2][z];
                            sum += w * finer(iIndices[x], jIndices[y],
                                             kIndices[z]);
                        }
                    }
                }
                coarser(i, j, k) = sum;
            }
        }
    }
    
    kernel void buildSingleSystem(device FdmMatrixRow3 *_A [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device float *_fluidSdf [[buffer(2)]],
                                  device float *_uWeights [[buffer(3)]],
                                  device float *_vWeights [[buffer(4)]],
                                  device float *_wWeights [[buffer(5)]],
                                  device float *_inputU [[buffer(6)]],
                                  device float *_inputV [[buffer(7)]],
                                  device float *_inputW [[buffer(8)]],
                                  constant Grid3Descriptor &input_descriptor [[buffer(9)]],
                                  constant float3 &invH [[buffer(10)]],
                                  constant float3 &invHSqr [[buffer(11)]],
                                  uint3 id [[thread_position_in_grid]],
                                  uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> A(size, _A);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<float> fluidSdf(size, _fluidSdf);
        ArrayAccessor3<float> uWeights(size+uint3(1, 0, 0), _uWeights);
        ArrayAccessor3<float> vWeights(size+uint3(0, 1, 0), _vWeights);
        ArrayAccessor3<float> wWeights(size+uint3(0, 0, 1), _wWeights);
        FaceCenteredGrid3 input(_inputU, _inputV, _inputW, size, input_descriptor);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        thread auto& row = A(i, j, k);
        
        // initialize
        row.center = row.right = row.up = row.front = 0.0;
        b(i, j, k) = 0.0;
        
        float centerPhi = fluidSdf(i, j, k);
        
        if (isInsideSdf(centerPhi)) {
            float term = 0.0;
            
            if (i + 1 < size.x) {
                term = uWeights(i + 1, j, k) * invHSqr.x;
                float rightPhi = fluidSdf(i + 1, j, k);
                if (isInsideSdf(rightPhi)) {
                    row.center += term;
                    row.right -= term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, rightPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) +=
                uWeights(i + 1, j, k) * input.u(i + 1, j, k) * invH.x;
            } else {
                b(i, j, k) += input.u(i + 1, j, k) * invH.x;
            }
            
            if (i > 0) {
                term = uWeights(i, j, k) * invHSqr.x;
                float leftPhi = fluidSdf(i - 1, j, k);
                if (isInsideSdf(leftPhi)) {
                    row.center += term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, leftPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) -= uWeights(i, j, k) * input.u(i, j, k) * invH.x;
            } else {
                b(i, j, k) -= input.u(i, j, k) * invH.x;
            }
            
            if (j + 1 < size.y) {
                term = vWeights(i, j + 1, k) * invHSqr.y;
                float upPhi = fluidSdf(i, j + 1, k);
                if (isInsideSdf(upPhi)) {
                    row.center += term;
                    row.up -= term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, upPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) +=
                vWeights(i, j + 1, k) * input.v(i, j + 1, k) * invH.y;
            } else {
                b(i, j, k) += input.v(i, j + 1, k) * invH.y;
            }
            
            if (j > 0) {
                term = vWeights(i, j, k) * invHSqr.y;
                float downPhi = fluidSdf(i, j - 1, k);
                if (isInsideSdf(downPhi)) {
                    row.center += term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, downPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) -= vWeights(i, j, k) * input.v(i, j, k) * invH.y;
            } else {
                b(i, j, k) -= input.v(i, j, k) * invH.y;
            }
            
            if (k + 1 < size.z) {
                term = wWeights(i, j, k + 1) * invHSqr.z;
                float frontPhi = fluidSdf(i, j, k + 1);
                if (isInsideSdf(frontPhi)) {
                    row.center += term;
                    row.front -= term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, frontPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) +=
                wWeights(i, j, k + 1) * input.w(i, j, k + 1) * invH.z;
            } else {
                b(i, j, k) += input.w(i, j, k + 1) * invH.z;
            }
            
            if (k > 0) {
                term = wWeights(i, j, k) * invHSqr.z;
                float backPhi = fluidSdf(i, j, k - 1);
                if (isInsideSdf(backPhi)) {
                    row.center += term;
                } else {
                    float theta = fractionInsideSdf(centerPhi, backPhi);
                    theta = max(theta, 0.01);
                    row.center += term / theta;
                }
                b(i, j, k) -= wWeights(i, j, k) * input.w(i, j, k) * invH.z;
            } else {
                b(i, j, k) -= input.w(i, j, k) * invH.z;
            }
            
            // If row.center is near-zero, the cell is likely inside a solid
            // boundary.
            if (row.center < kEpsilonF) {
                row.center = 1.0;
                b(i, j, k) = 0.0;
            }
        } else {
            row.center = 1.0;
        }
    }
}
