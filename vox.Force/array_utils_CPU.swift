//
//  array_utils_CPU.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Assigns \p value to 1-D array \p output with \p size.
///
/// This function assigns \p value to 1-D array \p output with \p size. The
/// output array must support random access operator [].
func setRange1<T:ZeroInit>(size:size_t, value:T,
                           output: inout ArrayAccessor1<T>) {
    setRange1(begin: 0, end: size,
              value: value, output: &output);
}

/// Assigns \p value to 1-D array \p output from \p begin to \p end.
///
/// This function assigns \p value to 1-D array \p output from \p begin to \p
/// end. The output array must support random access operator [].
func setRange1<T:ZeroInit>(begin:size_t, end:size_t,
                           value:T, output: inout ArrayAccessor1<T>) {
    parallelFor(beginIndex: begin, endIndex: end){(i:size_t) in
        output[i] = value;
    }
}


//MARK:- copyRange
/// Copies \p input array to \p output array with \p size.
///
/// This function copies \p input array to \p output array with \p size. The
/// input and output array must support random access operator [].
func copyRange1<T:ZeroInit>(input:ConstArrayAccessor1<T>, size:size_t,
                            output: inout ArrayAccessor1<T>) {
    copyRange1(input: input, begin: 0, end: size, output: &output);
}

/// Copies \p input array to \p output array from \p begin to \p end.
///
/// This function copies \p input array to \p output array from \p begin to
/// \p end. The input and output array must support random access operator [].
func copyRange1<T:ZeroInit>(input:ConstArrayAccessor1<T>, begin:size_t,
                            end:size_t, output: inout ArrayAccessor1<T>) {
    parallelFor(beginIndex: begin, endIndex: end){(i:size_t) in
        output[i] = input[i];
    }
}

/// Copies 2-D \p input array to \p output array with \p sizeX and  \p sizeY.
///
/// This function copies 2-D \p input array to \p output array with \p sizeX and
/// \p sizeY. The input and output array must support 2-D random access operator (i, j).
func copyRange2<T:ZeroInit>(input:ConstArrayAccessor2<T>,
                            sizeX:size_t,
                            sizeY:size_t,
                            output: inout ArrayAccessor2<T>) {
    copyRange2(input: input, beginX: 0, endX: sizeX,
               beginY: 0, endY: sizeY, output: &output);
}

/// Copies 2-D \p input array to \p output array from
/// (\p beginX, \p beginY) to (\p endX, \p endY).
///
/// This function copies 2-D \p input array to \p output array from
/// (\p beginX, \p beginY) to (\p endX, \p endY). The input and output array
/// must support 2-D random access operator (i, j).
func copyRange2<T:ZeroInit>(input:ConstArrayAccessor2<T>,
                            beginX:size_t,
                            endX:size_t,
                            beginY:size_t,
                            endY:size_t,
                            output: inout ArrayAccessor2<T>) {
    parallelFor(beginIndexX: beginX, endIndexX: endX,
                beginIndexY: beginY, endIndexY: endY){
        (i:size_t, j:size_t) in
        output[i, j] = input[i, j]
    }
}

/// Copies 3-D \p input array to \p output array with \p sizeX and \p sizeY.
///
/// This function copies 3-D \p input array to \p output array with \p sizeX and
/// \p sizeY. The input and output array must support 3-D random access operator  (i, j, k).
func copyRange3<T:ZeroInit>(input:ConstArrayAccessor3<T>,
                            sizeX:size_t,
                            sizeY:size_t,
                            sizeZ:size_t,
                            output: inout ArrayAccessor3<T>) {
    copyRange3(input: input, beginX: 0, endX: sizeX,
               beginY: 0, endY: sizeY,
               beginZ: 0, endZ: sizeZ, output: &output);
}

/// Copies 3-D \p input array to \p output array from
/// (\p beginX, \p beginY, \p beginZ) to (\p endX, \p endY, \p endZ).
///
/// This function copies 3-D \p input array to \p output array from
/// (\p beginX, \p beginY, \p beginZ) to (\p endX, \p endY, \p endZ). The input
/// and output array must support 3-D random access operator (i, j, k).
func copyRange3<T:ZeroInit>(input:ConstArrayAccessor3<T>,
                            beginX:size_t,
                            endX:size_t,
                            beginY:size_t,
                            endY:size_t,
                            beginZ:size_t,
                            endZ:size_t,
                            output: inout ArrayAccessor3<T>) {
    parallelFor(beginIndexX: beginX, endIndexX: endX,
                beginIndexY: beginY, endIndexY: endY,
                beginIndexZ: beginZ, endIndexZ: endZ){
        (i:size_t, j:size_t, k:size_t) in
        output[i, j, k] = input[i, j, k]
    }
}

//MARK:- extrapolateToRegion
/// Extrapolates 2-D input data from 'valid' (1) to 'invalid' (0) region.
///
/// This function extrapolates 2-D input data from 'valid' (1) to 'invalid' (0)
/// region. It iterates multiple times to propagate the 'valid' values to nearby
/// 'invalid' region. The maximum distance of the propagation is equal to
/// numberOfIterations. The input parameters 'valid' and 'data' should be
/// collocated.
/// - Parameters:
///   - input: data to extrapolate
///   - valid: set 1 if valid, else 0.
///   - numberOfIterations: number of iterations for propagation
///   - output: extrapolated output
func extrapolateToRegion(input: ConstArrayAccessor2<Float>,
                         valid: ConstArrayAccessor2<CChar>,
                         numberOfIterations:UInt,
                         output: inout ArrayAccessor2<Float>) {
    let size:Size2 = input.size()
    
    VOX_ASSERT(size == valid.size())
    VOX_ASSERT(size == output.size())
    
    var valid0 = Array2<CChar>(size: size)
    var valid1 = Array2<CChar>(size: size)
    
    valid0.parallelForEachIndex{(i:size_t, j:size_t) in
        valid0[i, j] = valid[i, j]
        output[i, j] = input[i, j]
    }
    
    for _ in 0..<numberOfIterations {
        valid0.forEachIndex{(i:size_t, j:size_t) in
            var sum:Float = 0
            var count:UInt = 0
            
            if (!(valid0[i, j] == 1)) {
                if (i + 1 < size.x && valid0[i + 1, j] == 1) {
                    sum += output[i + 1, j]
                    count += 1
                }
                
                if (i > 0 && valid0[i - 1, j] == 1) {
                    sum += output[i - 1, j]
                    count += 1
                }
                
                if (j + 1 < size.y && valid0[i, j + 1] == 1) {
                    sum += output[i, j + 1]
                    count += 1
                }
                
                if (j > 0 && valid0[i, j - 1] == 1) {
                    sum += output[i, j - 1]
                    count += 1
                }
                
                if (count > 0) {
                    output[i, j] = sum / Float(count)
                    valid1[i, j] = 1
                }
            } else {
                valid1[i, j] = 1
            }
        }
        
        valid0.swap(other: &valid1)
    }
}

/// Extrapolates 2-D input data from 'valid' (1) to 'invalid' (0) region.
///
/// This function extrapolates 2-D input data from 'valid' (1) to 'invalid' (0)
/// region. It iterates multiple times to propagate the 'valid' values to nearby
/// 'invalid' region. The maximum distance of the propagation is equal to
/// numberOfIterations. The input parameters 'valid' and 'data' should be
/// collocated.
/// - Parameters:
///   - input: data to extrapolate
///   - valid: set 1 if valid, else 0.
///   - numberOfIterations: number of iterations for propagation
///   - output: extrapolated output
func extrapolateToRegion(input: ConstArrayAccessor2<Vector2F>,
                         valid: ConstArrayAccessor2<CChar>,
                         numberOfIterations:UInt,
                         output: inout ArrayAccessor2<Vector2F>) {
    let size:Size2 = input.size()
    
    VOX_ASSERT(size == valid.size())
    VOX_ASSERT(size == output.size())
    
    var valid0 = Array2<CChar>(size: size)
    var valid1 = Array2<CChar>(size: size)
    
    valid0.parallelForEachIndex{(i:size_t, j:size_t) in
        valid0[i, j] = valid[i, j]
        output[i, j] = input[i, j]
    }
    
    for _ in 0..<numberOfIterations {
        valid0.forEachIndex{(i:size_t, j:size_t) in
            var sum:Vector2F = Vector2F()
            var count:UInt = 0
            
            if (!(valid0[i, j] == 1)) {
                if (i + 1 < size.x && valid0[i + 1, j] == 1) {
                    sum += output[i + 1, j]
                    count += 1
                }
                
                if (i > 0 && valid0[i - 1, j] == 1) {
                    sum += output[i - 1, j]
                    count += 1
                }
                
                if (j + 1 < size.y && valid0[i, j + 1] == 1) {
                    sum += output[i, j + 1]
                    count += 1
                }
                
                if (j > 0 && valid0[i, j - 1] == 1) {
                    sum += output[i, j - 1]
                    count += 1
                }
                
                if (count > 0) {
                    output[i, j] = sum / Float(count)
                    valid1[i, j] = 1
                }
            } else {
                valid1[i, j] = 1
            }
        }
        
        valid0.swap(other: &valid1)
    }
}

/// Extrapolates 3-D input data from 'valid' (1) to 'invalid' (0) region.
///
/// This function extrapolates 3-D input data from 'valid' (1) to 'invalid' (0)
/// region. It iterates multiple times to propagate the 'valid' values to nearby
/// 'invalid' region. The maximum distance of the propagation is equal to
/// numberOfIterations. The input parameters 'valid' and 'data' should be
/// collocated.
/// - Parameters:
///   - input: data to extrapolate
///   - valid: set 1 if valid, else 0.
///   - numberOfIterations: number of iterations for propagation
///   - output: extrapolated output
func extrapolateToRegion(input: ConstArrayAccessor3<Float>,
                         valid: ConstArrayAccessor3<CChar>,
                         numberOfIterations:UInt,
                         output: inout ArrayAccessor3<Float>) {
    let size:Size3 = input.size()
    
    VOX_ASSERT(size == valid.size())
    VOX_ASSERT(size == output.size())
    
    var valid0 = Array3<CChar>(size: size)
    var valid1 = Array3<CChar>(size: size)
    
    valid0.parallelForEachIndex{(i:size_t, j:size_t, k:size_t) in
        valid0[i, j, k] = valid[i, j, k]
        output[i, j, k] = input[i, j, k]
    }
    
    for _ in 0..<numberOfIterations {
        valid0.forEachIndex{(i:size_t, j:size_t, k:size_t) in
            var sum:Float = 0
            var count:UInt = 0
            
            if (!(valid0[i, j, k] == 1)) {
                if (i + 1 < size.x && valid0[i + 1, j, k] == 1) {
                    sum += output[i + 1, j, k]
                    count += 1
                }
                
                if (i > 0 && valid0[i - 1, j, k] == 1) {
                    sum += output[i - 1, j, k]
                    count += 1
                }
                
                if (j + 1 < size.y && valid0[i, j + 1, k] == 1) {
                    sum += output[i, j + 1, k]
                    count += 1
                }
                
                if (j > 0 && valid0[i, j - 1, k] == 1) {
                    sum += output[i, j - 1, k]
                    count += 1
                }
                
                if (k + 1 < size.z && valid0[i, j, k + 1] == 1) {
                    sum += output[i, j, k + 1]
                    count += 1
                }
                
                if (k > 0 && valid0[i, j, k - 1] == 1) {
                    sum += output[i, j, k - 1]
                    count += 1
                }
                
                if (count > 0) {
                    output[i, j, k] = sum / Float(count)
                    valid1[i, j, k] = 1
                }
            } else {
                valid1[i, j, k] = 1
            }
        }
        
        valid0.swap(other: &valid1)
    }
}

/// Extrapolates 3-D input data from 'valid' (1) to 'invalid' (0) region.
///
/// This function extrapolates 3-D input data from 'valid' (1) to 'invalid' (0)
/// region. It iterates multiple times to propagate the 'valid' values to nearby
/// 'invalid' region. The maximum distance of the propagation is equal to
/// numberOfIterations. The input parameters 'valid' and 'data' should be
/// collocated.
/// - Parameters:
///   - input: data to extrapolate
///   - valid: set 1 if valid, else 0.
///   - numberOfIterations: number of iterations for propagation
///   - output: extrapolated output
func extrapolateToRegion(input: ConstArrayAccessor3<Vector3F>,
                         valid: ConstArrayAccessor3<CChar>,
                         numberOfIterations:UInt,
                         output: inout ArrayAccessor3<Vector3F>) {
    let size:Size3 = input.size()
    
    VOX_ASSERT(size == valid.size())
    VOX_ASSERT(size == output.size())
    
    var valid0 = Array3<CChar>(size: size)
    var valid1 = Array3<CChar>(size: size)
    
    valid0.parallelForEachIndex{(i:size_t, j:size_t, k:size_t) in
        valid0[i, j, k] = valid[i, j, k]
        output[i, j, k] = input[i, j, k]
    }
    
    for _ in 0..<numberOfIterations {
        valid0.forEachIndex{(i:size_t, j:size_t, k:size_t) in
            var sum:Vector3F = Vector3F()
            var count:UInt = 0
            
            if (!(valid0[i, j, k] == 1)) {
                if (i + 1 < size.x && valid0[i + 1, j, k] == 1) {
                    sum += output[i + 1, j, k]
                    count += 1
                }
                
                if (i > 0 && valid0[i - 1, j, k] == 1) {
                    sum += output[i - 1, j, k]
                    count += 1
                }
                
                if (j + 1 < size.y && valid0[i, j + 1, k] == 1) {
                    sum += output[i, j + 1, k]
                    count += 1
                }
                
                if (j > 0 && valid0[i, j - 1, k] == 1) {
                    sum += output[i, j - 1, k]
                    count += 1
                }
                
                if (k + 1 < size.z && valid0[i, j, k + 1] == 1) {
                    sum += output[i, j, k + 1]
                    count += 1
                }
                
                if (k > 0 && valid0[i, j, k - 1] == 1) {
                    sum += output[i, j, k - 1]
                    count += 1
                }
                
                if (count > 0) {
                    output[i, j, k] = sum / Float(count)
                    valid1[i, j, k] = 1
                }
            } else {
                valid1[i, j, k] = 1
            }
        }
        
        valid0.swap(other: &valid1)
    }
}
