//
//  fdm_utils.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

//MARK:- 2D Operators
/// Returns 2-D gradient vector from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
func gradient2(data:ConstArrayAccessor2<Float>,
               gridSpacing:Vector2F,
               i:size_t, j:size_t)->Vector2F {
    let ds:Size2 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    let left:Float = data[(i > 0) ? i - 1 : i, j]
    let right:Float = data[(i + 1 < ds.x) ? i + 1 : i, j]
    let down:Float = data[i, (j > 0) ? j - 1 : j]
    let up:Float = data[i, (j + 1 < ds.y) ? j + 1 : j]
    
    return 0.5 * Vector2F(right - left, up - down) / gridSpacing
}

/// Returns 2-D gradient vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
func gradient2(data:ConstArrayAccessor2<Vector2F>,
               gridSpacing:Vector2F,
               i:size_t, j:size_t)->[Vector2F] {
    let ds:Size2 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    let left:Vector2F = data[(i > 0) ? i - 1 : i, j]
    let right:Vector2F = data[(i + 1 < ds.x) ? i + 1 : i, j]
    let down:Vector2F = data[i, (j > 0) ? j - 1 : j]
    let up:Vector2F = data[i, (j + 1 < ds.y) ? j + 1 : j]
    
    var result = Array<Vector2F>(repeating: Vector2F(), count: 2)
    result[0] = 0.5 * Vector2F(right.x - left.x, up.x - down.x) / gridSpacing
    result[1] = 0.5 * Vector2F(right.y - left.y, up.y - down.y) / gridSpacing
    return result
}

/// Returns Laplacian value from given 2-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
func laplacian2(data:ConstArrayAccessor2<Float>,
                gridSpacing:Vector2F,
                i:size_t, j:size_t)->Float {
    let center:Float = data[i, j]
    let ds:Size2 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    var dleft:Float = 0.0
    var dright:Float = 0.0
    var ddown:Float = 0.0
    var dup:Float = 0.0
    
    if (i > 0) {
        dleft = center - data[i - 1, j]
    }
    if (i + 1 < ds.x) {
        dright = data[i + 1, j] - center
    }
    
    if (j > 0) {
        ddown = center - data[i, j - 1]
    }
    if (j + 1 < ds.y) {
        dup = data[i, j + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
}

/// Returns 2-D Laplacian vectors from given 2-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j).
func laplacian2(data:ConstArrayAccessor2<Vector2F>,
                gridSpacing:Vector2F,
                i:size_t, j:size_t)->Vector2F {
    let center:Vector2F = data[i, j]
    let ds:Size2 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y)
    
    var dleft = Vector2F()
    var dright = Vector2F()
    var ddown = Vector2F()
    var dup = Vector2F()
    
    if (i > 0) {
        dleft = center - data[i - 1, j]
    }
    if (i + 1 < ds.x) {
        dright = data[i + 1, j] - center
    }
    
    if (j > 0) {
        ddown = center - data[i, j - 1]
    }
    if (j + 1 < ds.y) {
        dup = data[i, j + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
}

//MARK:- 3D Operators
/// Returns 3-D gradient vector from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
func gradient3(data:ConstArrayAccessor3<Float>,
               gridSpacing:Vector3F,
               i:size_t, j:size_t, k:size_t)->Vector3F {
    let ds:Size3 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    let left:Float = data[(i > 0) ? i - 1 : i, j, k]
    let right:Float = data[(i + 1 < ds.x) ? i + 1 : i, j, k]
    let down:Float = data[i, (j > 0) ? j - 1 : j, k]
    let up:Float = data[i, (j + 1 < ds.y) ? j + 1 : j, k]
    let back:Float = data[i, j, (k > 0) ? k - 1 : k]
    let front:Float = data[i, j, (k + 1 < ds.z) ? k + 1 : k]
    
    return 0.5 * Vector3F(right - left, up - down, front - back) / gridSpacing
}

/// Returns 3-D gradient vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
func gradient3(data:ConstArrayAccessor3<Vector3F>,
               gridSpacing:Vector3F,
               i:size_t, j:size_t, k:size_t)->[Vector3F] {
    let ds:Size3 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    let left:Vector3F = data[(i > 0) ? i - 1 : i, j, k]
    let right:Vector3F = data[(i + 1 < ds.x) ? i + 1 : i, j, k]
    let down:Vector3F = data[i, (j > 0) ? j - 1 : j, k]
    let up:Vector3F = data[i, (j + 1 < ds.y) ? j + 1 : j, k]
    let back:Vector3F = data[i, j, (k > 0) ? k - 1 : k]
    let front:Vector3F = data[i, j, (k + 1 < ds.z) ? k + 1 : k]
    
    var result = Array<Vector3F>(repeating: Vector3F(), count: 3)
    result[0] = 0.5 * Vector3F(
        right.x - left.x, up.x - down.x, front.x - back.x) / gridSpacing
    result[1] = 0.5 * Vector3F(
        right.y - left.y, up.y - down.y, front.y - back.y) / gridSpacing
    result[2] = 0.5 * Vector3F(
        right.z - left.z, up.z - down.z, front.z - back.z) / gridSpacing
    return result
}

/// Returns Laplacian value from given 3-D scalar grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
func laplacian3(data:ConstArrayAccessor3<Float>,
                gridSpacing:Vector3F,
                i:size_t, j:size_t, k:size_t)->Float {
    let center:Float = data[i, j, k]
    let ds:Size3 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    var dleft:Float = 0.0
    var dright:Float = 0.0
    var ddown:Float = 0.0
    var dup:Float = 0.0
    var dback:Float = 0.0
    var dfront:Float = 0.0
    
    if (i > 0) {
        dleft = center - data[i - 1, j, k]
    }
    if (i + 1 < ds.x) {
        dright = data[i + 1, j, k] - center
    }
    
    if (j > 0) {
        ddown = center - data[i, j - 1, k]
    }
    if (j + 1 < ds.y) {
        dup = data[i, j + 1, k] - center
    }
    
    if (k > 0) {
        dback = center - data[i, j, k - 1]
    }
    if (k + 1 < ds.z) {
        dfront = data[i, j, k + 1] - center
    }
    
    return (dright - dleft) / Math.square(of: gridSpacing.x)
        + (dup - ddown) / Math.square(of: gridSpacing.y)
        + (dfront - dback) / Math.square(of: gridSpacing.z)
}

/// Returns 3-D Laplacian vectors from given 3-D vector grid-like array
///        \p data, \p gridSpacing, and array index (\p i, \p j, \p k).
func laplacian3(data:ConstArrayAccessor3<Vector3F>,
                gridSpacing:Vector3F,
                i:size_t, j:size_t, k:size_t)->Vector3F {
    let center:Vector3F = data[i, j, k]
    let ds:Size3 = data.size()
    
    VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
    
    var dleft:Vector3F = Vector3F()
    var dright:Vector3F = Vector3F()
    var ddown:Vector3F = Vector3F()
    var dup:Vector3F = Vector3F()
    var dback:Vector3F = Vector3F()
    var dfront:Vector3F = Vector3F()
    
    if (i > 0) {
        dleft = center - data[i - 1, j, k]
    }
    if (i + 1 < ds.x) {
        dright = data[i + 1, j, k] - center
    }
    
    if (j > 0) {
        ddown = center - data[i, j - 1, k]
    }
    if (j + 1 < ds.y) {
        dup = data[i, j + 1, k] - center
    }
    
    if (k > 0) {
        dback = center - data[i, j, k - 1]
    }
    if (k + 1 < ds.z) {
        dfront = data[i, j, k + 1] - center
    }
    
    var result = (dright - dleft) / Math.square(of: gridSpacing.x)
    result += (dup - ddown) / Math.square(of: gridSpacing.y)
    return result + (dfront - dback) / Math.square(of: gridSpacing.z)
}
