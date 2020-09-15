//
//  grid_backward_euler_diffusion_solver2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "array_accessor2.metal"
#include "constants.metal"
#include "math_utils.metal"
#include "grid.metal"
#include "fdm_matrix_row_type.h"

constant char kFluid = 0;
constant char kAir = 1;
constant char kBoundary = 2;

namespace GridBackwardEulerDiffusionSolver2 {
    kernel void assign(device float *_source [[buffer(0)]],
                       device float *_dest [[buffer(1)]],
                       constant Grid2Descriptor &descriptor [[buffer(2)]],
                       device float *_x [[buffer(3)]],
                       uint2 id [[thread_position_in_grid]],
                       uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> dest(size, _dest);
        ArrayAccessor2<float> x(size, _x);
        dest(id) = x(id);
    }
    
    kernel void assignX(device float2 *_source [[buffer(0)]],
                        device float2 *_dest [[buffer(1)]],
                        constant Grid2Descriptor &descriptor [[buffer(2)]],
                        device float *_x [[buffer(3)]],
                        uint2 id [[thread_position_in_grid]],
                        uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float2> dest(size, _dest);
        ArrayAccessor2<float> x(size, _x);
        dest(id).x = x(id);
    }
    
    kernel void assignY(device float2 *_source [[buffer(0)]],
                        device float2 *_dest [[buffer(1)]],
                        constant Grid2Descriptor &descriptor [[buffer(2)]],
                        device float *_x [[buffer(3)]],
                        uint2 id [[thread_position_in_grid]],
                        uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float2> dest(size, _dest);
        ArrayAccessor2<float> x(size, _x);
        dest(id).y = x(id);
    }
    
    kernel void buildMatrix(device FdmMatrixRow2 *_A [[buffer(0)]],
                            device char *__markers [[buffer(1)]],
                            constant float2 &c [[buffer(2)]],
                            constant bool &isDirichlet [[buffer(3)]],
                            uint2 id [[thread_position_in_grid]],
                            uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<FdmMatrixRow2> A(size, _A);
        ArrayAccessor2<char> _markers(size, __markers);
        uint i = id.x;
        uint j = id.y;
        
        thread auto& row = A(i, j);
        
        // Initialize
        row.center = 1.0;
        row.right = row.up = 0.0;
        
        if (_markers(i, j) == kFluid) {
            if (i + 1 < size.x) {
                if ((isDirichlet && _markers(i + 1, j) != kAir)
                    || _markers(i + 1, j) == kFluid) {
                    row.center += c.x;
                }
                
                if (_markers(i + 1, j) == kFluid) {
                    row.right -=  c.x;
                }
            }
            
            if (i > 0
                && ((isDirichlet && _markers(i - 1, j) != kAir)
                    || _markers(i - 1, j) == kFluid)) {
                row.center += c.x;
            }
            
            if (j + 1 < size.y) {
                if ((isDirichlet && _markers(i, j + 1) != kAir)
                    || _markers(i, j + 1) == kFluid) {
                    row.center += c.y;
                }
                
                if (_markers(i, j + 1) == kFluid) {
                    row.up -=  c.y;
                }
            }
            
            if (j > 0
                && ((isDirichlet && _markers(i, j - 1) != kAir)
                    || _markers(i, j - 1) == kFluid)) {
                row.center += c.y;
            }
        }
    }
    
    kernel void buildVectors_scalar(device float *_x [[buffer(0)]],
                                    device float *_b [[buffer(1)]],
                                    device char *__markers [[buffer(2)]],
                                    device float *_f [[buffer(3)]],
                                    constant Grid2Descriptor &descriptor [[buffer(4)]],
                                    constant float2 &c [[buffer(5)]],
                                    constant bool &isDirichlet [[buffer(6)]],
                                    uint2 id [[thread_position_in_grid]],
                                    uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        
        b(i, j) = x(i, j) = f(i, j);
        
        if (isDirichlet && _markers(i, j) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j) == kBoundary) {
                b(i, j) += c.x * f(i + 1, j);
            }
            
            if (i > 0 && _markers(i - 1, j) == kBoundary) {
                b(i, j) += c.x * f(i - 1, j);
            }
            
            if (j + 1 < size.y && _markers(i, j + 1) == kBoundary) {
                b(i, j) += c.y * f(i, j + 1);
            }
            
            if (j > 0 && _markers(i, j - 1) == kBoundary) {
                b(i, j) += c.y * f(i, j - 1);
            }
        }
    }
    
    kernel void buildVectors_collocated(device float *_x [[buffer(0)]],
                                        device float *_b [[buffer(1)]],
                                        device char *__markers [[buffer(2)]],
                                        device float2 *_f [[buffer(3)]],
                                        constant Grid2Descriptor &descriptor [[buffer(4)]],
                                        constant float2 &c [[buffer(5)]],
                                        constant bool &isDirichlet [[buffer(6)]],
                                        constant uint &component [[buffer(7)]],
                                        uint2 id [[thread_position_in_grid]],
                                        uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float2> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        
        b(i, j) = x(i, j) = f(i, j)[component];
        
        if (isDirichlet && _markers(i, j) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j) == kBoundary) {
                b(i, j) += c.x * f(i + 1, j)[component];
            }
            
            if (i > 0 && _markers(i - 1, j) == kBoundary) {
                b(i, j) += c.x * f(i - 1, j)[component];
            }
            
            if (j + 1 < size.y && _markers(i, j + 1) == kBoundary) {
                b(i, j) += c.y * f(i, j + 1)[component];
            }
            
            if (j > 0 && _markers(i, j - 1) == kBoundary) {
                b(i, j) += c.y * f(i, j - 1)[component];
            }
        }
    }
    
    kernel void buildVectors_face(device float *_x [[buffer(0)]],
                                  device float *_b [[buffer(1)]],
                                  device char *__markers [[buffer(2)]],
                                  device float *_f [[buffer(3)]],
                                  constant float2 &c [[buffer(4)]],
                                  constant bool &isDirichlet [[buffer(5)]],
                                  uint2 id [[thread_position_in_grid]],
                                  uint2 size [[threads_per_grid]]) {
        ArrayAccessor2<float> x(size, _x);
        ArrayAccessor2<float> b(size, _b);
        ArrayAccessor2<char> _markers(size, __markers);
        ArrayAccessor2<float> f(size, _f);
        uint i = id.x;
        uint j = id.y;
        
        b(i, j) = x(i, j) = f(i, j);
        
        if (isDirichlet && _markers(i, j) == kFluid) {
            if (i + 1 < size.x && _markers(i + 1, j) == kBoundary) {
                b(i, j) += c.x * f(i + 1, j);
            }
            
            if (i > 0 && _markers(i - 1, j) == kBoundary) {
                b(i, j) += c.x * f(i - 1, j);
            }
            
            if (j + 1 < size.y && _markers(i, j + 1) == kBoundary) {
                b(i, j) += c.y * f(i, j + 1);
            }
            
            if (j > 0 && _markers(i, j - 1) == kBoundary) {
                b(i, j) += c.y * f(i, j - 1);
            }
        }
    }
}
