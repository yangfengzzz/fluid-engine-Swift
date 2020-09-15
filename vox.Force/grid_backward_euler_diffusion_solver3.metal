//
//  grid_backward_euler_diffusion_solver3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor3.metal"
#include "constants.metal"
#include "math_utils.metal"
#include "grid.metal"
#include "fdm_matrix_row_type.h"

constant char kFluid = 0;
constant char kAir = 1;
constant char kBoundary = 2;

namespace GridBackwardEulerDiffusionSolver3 {
    kernel void assign(device float *_source [[buffer(0)]],
                       device float *_dest [[buffer(1)]],
                       constant Grid3Descriptor &descriptor [[buffer(2)]],
                       device float *_x [[buffer(3)]],
                       uint3 id [[thread_position_in_grid]],
                       uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> dest(size, _dest);
        ArrayAccessor3<float> x(size, _x);
        dest(id) = x(id);
    }
    
    kernel void assignX(device float3 *_source [[buffer(0)]],
                        device float3 *_dest [[buffer(1)]],
                        constant Grid3Descriptor &descriptor [[buffer(2)]],
                        device float *_x [[buffer(3)]],
                        uint3 id [[thread_position_in_grid]],
                        uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float3> dest(size, _dest);
        ArrayAccessor3<float> x(size, _x);
        dest(id).x = x(id);
    }
    
    kernel void assignY(device float3 *_source [[buffer(0)]],
                        device float3 *_dest [[buffer(1)]],
                        constant Grid3Descriptor &descriptor [[buffer(2)]],
                        device float *_x [[buffer(3)]],
                        uint3 id [[thread_position_in_grid]],
                        uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float3> dest(size, _dest);
        ArrayAccessor3<float> x(size, _x);
        dest(id).y = x(id);
    }
    
    kernel void assignZ(device float3 *_source [[buffer(0)]],
                        device float3 *_dest [[buffer(1)]],
                        constant Grid3Descriptor &descriptor [[buffer(2)]],
                        device float *_x [[buffer(3)]],
                        uint3 id [[thread_position_in_grid]],
                        uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float3> dest(size, _dest);
        ArrayAccessor3<float> x(size, _x);
        dest(id).z = x(id);
    }
    
    kernel void buildMatrix(device FdmMatrixRow3 *_A [[buffer(0)]],
                            device char *__markers [[buffer(1)]],
                            constant float3 &c [[buffer(2)]],
                            constant bool &isDirichlet [[buffer(3)]],
                            uint3 id [[thread_position_in_grid]],
                            uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<FdmMatrixRow3> A(size, _A);
        ArrayAccessor3<char> _markers(size, __markers);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        thread auto& row = A(i, j, k);
        
        // Initialize
        row.center = 1.0;
        row.right = row.up = row.front = 0.0;
        
        if (_markers(i, j, k) == kFluid) {
            if (i + 1 < size.x) {
                if ((isDirichlet && _markers(i + 1, j, k) != kAir)
                    || _markers(i + 1, j, k) == kFluid) {
                    row.center += c.x;
                }
                
                if (_markers(i + 1, j, k) == kFluid) {
                    row.right -=  c.x;
                }
            }
            
            if (i > 0
                && ((isDirichlet && _markers(i - 1, j, k) != kAir)
                    || _markers(i - 1, j, k) == kFluid)) {
                row.center += c.x;
            }
            
            if (j + 1 < size.y) {
                if ((isDirichlet && _markers(i, j + 1, k) != kAir)
                    || _markers(i, j + 1, k) == kFluid) {
                    row.center += c.y;
                }
                
                if (_markers(i, j + 1, k) == kFluid) {
                    row.up -=  c.y;
                }
            }
            
            if (j > 0
                && ((isDirichlet && _markers(i, j - 1, k) != kAir)
                    || _markers(i, j - 1, k) == kFluid)) {
                row.center += c.y;
            }
            
            if (k + 1 < size.z) {
                if ((isDirichlet && _markers(i, j, k + 1) != kAir)
                    || _markers(i, j, k + 1) == kFluid) {
                    row.center += c.z;
                }
                
                if (_markers(i, j, k + 1) == kFluid) {
                    row.front -=  c.z;
                }
            }
            
            if (k > 0
                && ((isDirichlet && _markers(i, j, k - 1) != kAir)
                    || _markers(i, j, k - 1) == kFluid)) {
                row.center += c.z;
            }
        }
    }
    
    kernel void buildVectors_scalar(device float *_x [[buffer(0)]],
                                    device float *_b [[buffer(1)]],
                                    device char *__markers [[buffer(2)]],
                                    device float *_f [[buffer(3)]],
                                    constant Grid3Descriptor &descriptor [[buffer(4)]],
                                    constant float3 &c [[buffer(5)]],
                                    constant bool &isDirichlet [[buffer(6)]],
                                    uint3 id [[thread_position_in_grid]],
                                    uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        b(i, j, k) = x(i, j, k) = f(i, j, k);
        
        if (isDirichlet && _markers(i, j, k) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i + 1, j, k);
            }
            
            if (i > 0 && _markers(i - 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i - 1, j, k);
            }
            
            if (j + 1 < size.y && _markers(i, j + 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j + 1, k);
            }
            
            if (j > 0 && _markers(i, j - 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j - 1, k);
            }
            
            if (k + 1 < size.z && _markers(i, j, k + 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k + 1);
            }
            
            if (k > 0 && _markers(i, j, k - 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k - 1);
            }
        }
    }
    
    kernel void buildVectors_collocated(device float *_x [[buffer(0)]],
                                        device float *_b [[buffer(1)]],
                                        device char *__markers [[buffer(2)]],
                                        device float3 *_f [[buffer(3)]],
                                        constant Grid3Descriptor &descriptor [[buffer(4)]],
                                        constant float3 &c [[buffer(5)]],
                                        constant bool &isDirichlet [[buffer(6)]],
                                        constant uint &component [[buffer(7)]],
                                        uint3 id [[thread_position_in_grid]],
                                        uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float3> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        b(i, j, k) = x(i, j, k) = f(i, j, k)[component];
        
        if (isDirichlet && _markers(i, j, k) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i + 1, j, k)[component];
            }
            
            if (i > 0 && _markers(i - 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i - 1, j, k)[component];
            }
            
            if (j + 1 < size.y && _markers(i, j + 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j + 1, k)[component];
            }
            
            if (j > 0 && _markers(i, j - 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j - 1, k)[component];
            }
            
            if (k + 1 < size.z && _markers(i, j, k + 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k + 1)[component];
            }
            
            if (k > 0 && _markers(i, j, k - 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k - 1)[component];
            }
        }
    }
    
    kernel void buildVectors_face(device float *_x [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device char *__markers [[buffer(2)]],
                                  device float *_f [[buffer(3)]],
                                  constant float3 &c [[buffer(4)]],
                                  constant bool &isDirichlet [[buffer(5)]],
                                  uint3 id [[thread_position_in_grid]],
                                  uint3 size [[threads_per_grid]]) {
        ArrayAccessor3<float> x(size, _x);
        ArrayAccessor3<float> b(size, _b);
        ArrayAccessor3<char> _markers(size, __markers);
        ArrayAccessor3<float> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        uint k = id.z;
        
        b(i, j, k) = x(i, j, k) = f(i, j, k);
        
        if (isDirichlet && _markers(i, j, k) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i + 1, j, k);
            }
            
            if (i > 0 && _markers(i - 1, j, k) == kBoundary) {
                b(i, j, k) += c.x * f(i - 1, j, k);
            }
            
            if (j + 1 < size.y && _markers(i, j + 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j + 1, k);
            }
            
            if (j > 0 && _markers(i, j - 1, k) == kBoundary) {
                b(i, j, k) += c.y * f(i, j - 1, k);
            }
            
            if (k + 1 < size.z && _markers(i, j, k + 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k + 1);
            }
            
            if (k > 0 && _markers(i, j, k - 1) == kBoundary) {
                b(i, j, k) += c.z * f(i, j, k - 1);
            }
        }
    }
}
