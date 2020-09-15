//
//  marching_cubes.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Computes marching cubes and extract triangle mesh from grid.
///
/// This function computes the marching cube algorithm to extract triangle mesh
/// from the scalar grid field. The triangle mesh will be the iso surface, and
/// the iso value can be specified. For the boundaries (the walls), it can be
/// specified whether to close or open with \p bndClose (default: close all).
/// Another boundary flag \p bndConnectivity can be used for specifying
/// topological connectivity of the boundary meshes (default: disconnect all).
/// - Parameters:
///   - grid: The grid.
///   - gridSize: The grid size.
///   - origin:  The origin.
///   - mesh: The output triangle mesh.
///   - isoValue: The iso-surface value.
///   - bndClose: The boundary open flag.
///   - bndConnectivity: The boundary connectivity flag.
func marchingCubes(grid:ConstArrayAccessor3<Float>,
                   gridSize:Vector3F, origin:Vector3F,
                   mesh:inout TriangleMesh3, isoValue:Float = 0,
                   bndClose:Int = kDirectionAll,
                   bndConnectivity:Int = kDirectionNone) {
    var vertexMap = MarchingCubeVertexMap()
    
    let dim = grid.size()
    let invGridSize = 1.0 / gridSize
    
    let pos = {(i:ssize_t, j:ssize_t, k:ssize_t)->Vector3F in
        return origin + gridSize * Vector3F(Float(i), Float(j), Float(k))
    }
    
    let dimx = dim.x
    let dimy = dim.y
    let dimz = dim.z
    
    for k in 0..<dimz - 1 {
        for j in 0..<dimy-1 {
            for i in 0..<dimx-1 {
                var data = Array<Float>(repeating: 0, count: 8)
                var edgeIds = Array<size_t>(repeating: 0, count: 12)
                var normals = Array<Vector3F>(repeating: Vector3F(), count: 8)
                var bound = BoundingBox3F()
                
                data[0] = grid[i, j, k]
                data[1] = grid[i + 1, j, k]
                data[4] = grid[i, j + 1, k]
                data[5] = grid[i + 1, j + 1, k]
                data[3] = grid[i, j, k + 1]
                data[2] = grid[i + 1, j, k + 1]
                data[7] = grid[i, j + 1, k + 1]
                data[6] = grid[i + 1, j + 1, k + 1]
                
                normals[0] = grad(grid: grid, i: i, j: j, k: k, invGridSize: invGridSize)
                normals[1] = grad(grid: grid, i: i + 1, j: j, k: k, invGridSize: invGridSize)
                normals[4] = grad(grid: grid, i: i, j: j + 1, k: k, invGridSize: invGridSize)
                normals[5] = grad(grid: grid, i: i + 1, j: j + 1, k: k, invGridSize: invGridSize)
                normals[3] = grad(grid: grid, i: i, j: j, k: k + 1, invGridSize: invGridSize)
                normals[2] = grad(grid: grid, i: i + 1, j: j, k: k + 1, invGridSize: invGridSize)
                normals[7] = grad(grid: grid, i: i, j: j + 1, k: k + 1, invGridSize: invGridSize)
                normals[6] = grad(grid: grid, i: i + 1, j: j + 1, k: k + 1, invGridSize: invGridSize)
                
                for e in 0..<12 {
                    edgeIds[e] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: e)
                }
                
                bound.lowerCorner = pos(i, j, k)
                bound.upperCorner = pos(i + 1, j + 1, k + 1)
                
                singleCube(data: data, edgeIds: edgeIds, normals: normals,
                           bound: bound, vertexMap: &vertexMap, mesh: &mesh,
                           isoValue: isoValue)
            }  // i
        }      // j
    }          // k
    
    // Construct boundaries parallel to x-y plane
    if (bndClose & (kDirectionBack | kDirectionFront) != 0) {
        var vertexMapBack = MarchingCubeVertexMap()
        var vertexMapFront = MarchingCubeVertexMap()
        
        for j in 0..<dimy-1 {
            for i in 0..<dimx-1 {
                var k:ssize_t = 0
                
                var data = Array<Float>(repeating: 0, count: 4)
                var vertexAndEdgeIds = Array<size_t>(repeating: 0, count: 8)
                var corners = Array<Vector3F>(repeating: Vector3F(), count: 4)
                var normal = Vector3F()
                
                data[0] = grid[i + 1, j, k]
                data[1] = grid[i, j, k]
                data[2] = grid[i, j + 1, k]
                data[3] = grid[i + 1, j + 1, k]
                
                if (bndClose & kDirectionBack != 0) {
                    normal = Vector3F(0, 0, -1)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 1)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 0)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 4)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 5)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 0)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 8)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 4)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 9)
                    
                    corners[0] = pos(i + 1, j, k)
                    corners[1] = pos(i, j, k)
                    corners[2] = pos(i, j + 1, k)
                    corners[3] = pos(i + 1, j + 1, k)
                    
                    if (bndConnectivity & kDirectionBack) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapBack,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
                
                k = dimz - 2
                data[0] = grid[i, j, k + 1]
                data[1] = grid[i + 1, j, k + 1]
                data[2] = grid[i + 1, j + 1, k + 1]
                data[3] = grid[i, j + 1, k + 1]
                
                if (bndClose & kDirectionFront != 0) {
                    normal = Vector3F(0, 0, 1)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 3)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 2)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 6)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 7)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 2)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 10)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 6)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 11)
                    
                    corners[0] = pos(i, j, k + 1)
                    corners[1] = pos(i + 1, j, k + 1)
                    corners[2] = pos(i + 1, j + 1, k + 1)
                    corners[3] = pos(i, j + 1, k + 1)
                    
                    if (bndConnectivity & kDirectionFront) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapFront,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
            }  // i
        }      // j
    }
    
    // Construct boundaries parallel to y-z plane
    if (bndClose & (kDirectionLeft | kDirectionRight) != 0) {
        var vertexMapLeft = MarchingCubeVertexMap()
        var vertexMapRight = MarchingCubeVertexMap()
        
        for k in 0..<dimz-1 {
            for j in 0..<dimy-1 {
                var i:ssize_t = 0
                
                var data = Array<Float>(repeating: 0, count: 4)
                var vertexAndEdgeIds = Array<size_t>(repeating: 0, count: 8)
                var corners = Array<Vector3F>(repeating: Vector3F(), count: 4)
                var normal = Vector3F()
                
                data[0] = grid[i, j, k]
                data[1] = grid[i, j, k + 1]
                data[2] = grid[i, j + 1, k + 1]
                data[3] = grid[i, j + 1, k]
                
                if (bndClose & kDirectionLeft != 0) {
                    normal = Vector3F(-1, 0, 0)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 0)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 3)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 7)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 4)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 3)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 11)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 7)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 8)
                    
                    corners[0] = pos(i, j, k)
                    corners[1] = pos(i, j, k + 1)
                    corners[2] = pos(i, j + 1, k + 1)
                    corners[3] = pos(i, j + 1, k)
                    
                    if (bndConnectivity & kDirectionLeft) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapLeft,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
                
                i = dimx - 2
                data[0] = grid[i + 1, j, k + 1]
                data[1] = grid[i + 1, j, k]
                data[2] = grid[i + 1, j + 1, k]
                data[3] = grid[i + 1, j + 1, k + 1]
                
                if (bndClose & kDirectionRight != 0) {
                    normal = Vector3F(1, 0, 0)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 2)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 1)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 5)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 6)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 1)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 9)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 5)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 10)
                    
                    corners[0] = pos(i + 1, j, k + 1)
                    corners[1] = pos(i + 1, j, k)
                    corners[2] = pos(i + 1, j + 1, k)
                    corners[3] = pos(i + 1, j + 1, k + 1)
                    
                    if (bndConnectivity & kDirectionRight) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapRight,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
            }  // j
        }      // k
    }
    
    // Construct boundaries parallel to x-z plane
    if (bndClose & (kDirectionDown | kDirectionUp) != 0) {
        var vertexMapDown = MarchingCubeVertexMap()
        var vertexMapUp = MarchingCubeVertexMap()
        
        for k in 0..<dimz-1 {
            for i in 0..<dimx-1 {
                var j:ssize_t = 0
                
                var data = Array<Float>(repeating: 0, count: 4)
                var vertexAndEdgeIds = Array<size_t>(repeating: 0, count: 8)
                var corners = Array<Vector3F>(repeating: Vector3F(), count: 4)
                var normal = Vector3F()
                
                data[0] = grid[i, j, k]
                data[1] = grid[i + 1, j, k]
                data[2] = grid[i + 1, j, k + 1]
                data[3] = grid[i, j, k + 1]
                
                if (bndClose & kDirectionDown != 0) {
                    normal = Vector3F(0, -1, 0)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 0)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 1)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 2)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 3)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 0)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 1)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 2)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 3)
                    
                    corners[0] = pos(i, j, k)
                    corners[1] = pos(i + 1, j, k)
                    corners[2] = pos(i + 1, j, k + 1)
                    corners[3] = pos(i, j, k + 1)
                    
                    if (bndConnectivity & kDirectionDown) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapDown,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
                
                j = dimy - 2
                data[0] = grid[i + 1, j + 1, k]
                data[1] = grid[i, j + 1, k]
                data[2] = grid[i, j + 1, k + 1]
                data[3] = grid[i + 1, j + 1, k + 1]
                
                if (bndClose & kDirectionUp != 0) {
                    normal = Vector3F(0, 1, 0)
                    
                    vertexAndEdgeIds[0] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 5)
                    vertexAndEdgeIds[1] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 4)
                    vertexAndEdgeIds[2] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 7)
                    vertexAndEdgeIds[3] = globalVertexId(i: i, j: j, k: k, dim: dim, localVertexId: 6)
                    vertexAndEdgeIds[4] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 4)
                    vertexAndEdgeIds[5] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 7)
                    vertexAndEdgeIds[6] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 6)
                    vertexAndEdgeIds[7] = globalEdgeId(i: i, j: j, k: k, dim: dim, localEdgeId: 5)
                    
                    corners[0] = pos(i + 1, j + 1, k)
                    corners[1] = pos(i, j + 1, k)
                    corners[2] = pos(i, j + 1, k + 1)
                    corners[3] = pos(i + 1, j + 1, k + 1)
                    
                    if (bndConnectivity & kDirectionUp) != 0 {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMap,
                                     mesh: &mesh, isoValue: isoValue)
                    } else {
                        singleSquare(data: data, vertAndEdgeIds: vertexAndEdgeIds,
                                     normal: normal, corners: corners,
                                     vertexMap: &vertexMapUp,
                                     mesh: &mesh, isoValue: isoValue)
                    }
                }
            }  // i
        }      // k
    }
}

//MARK:- Utility Functions
typealias MarchingCubeVertexHashKey = size_t
typealias MarchingCubeVertexId = size_t
typealias MarchingCubeVertexMap = [MarchingCubeVertexHashKey:MarchingCubeVertexId]

func queryVertexId(vertexMap:MarchingCubeVertexMap,
                   vKey:MarchingCubeVertexHashKey,
                   vId:inout MarchingCubeVertexId)->Bool {
    let vItr = vertexMap[vKey]
    if (vItr != nil) {
        vId = vItr!
        return true
    } else {
        return false
    }
}

func grad(grid:ConstArrayAccessor3<Float>, i:ssize_t,
          j:ssize_t, k:ssize_t, invGridSize:Vector3F)->Vector3F {
    var ret = Vector3F()
    var ip = i + 1
    var im = i - 1
    var jp = j + 1
    var jm = j - 1
    var kp = k + 1
    var km = k - 1
    let dim = grid.size()
    let dimx = dim.x
    let dimy = dim.y
    let dimz = dim.z
    if (i > dimx - 2) {
        ip = i
    } else if (i == 0) {
        im = 0
    }
    if (j > dimy - 2) {
        jp = j
    } else if (j == 0) {
        jm = 0
    }
    if (k > dimz - 2) {
        kp = k
    } else if (k == 0) {
        km = 0
    }
    ret.x = 0.5 * invGridSize.x * (grid[ip, j, k] - grid[im, j, k])
    ret.y = 0.5 * invGridSize.y * (grid[i, jp, k] - grid[i, jm, k])
    ret.z = 0.5 * invGridSize.z * (grid[i, j, kp] - grid[i, j, km])
    return ret
}

func safeNormalize(n:Vector3F)->Vector3F {
    if (length_squared(n) > 0.0) {
        return normalize(n)
    } else {
        return n
    }
}

/// To compute unique edge ID, map vertices+edges into
/// doubled virtual vertex indices.
///
/// v edge  v
/// |----*----|    -->    |-----|-----|
/// i           i+1         2i   2i+1  2i+2
///

func globalEdgeId(i:size_t, j:size_t, k:size_t, dim:Size3,
                  localEdgeId:size_t)->size_t {
    // See edgeConnection in marching_cubes_table.h for the edge ordering.
    let edgeOffset3D:[[Int]] = [
        [1, 0, 0], [2, 0, 1], [1, 0, 2], [0, 0, 1], [1, 2, 0], [2, 2, 1],
        [1, 2, 2], [0, 2, 1], [0, 1, 0], [2, 1, 0], [2, 1, 2], [0, 1, 2]
    ]
    
    return ((2 * k + edgeOffset3D[localEdgeId][2]) * 2 * dim.y +
        (2 * j + edgeOffset3D[localEdgeId][1])) * 2 * dim.x +
        (2 * i + edgeOffset3D[localEdgeId][0])
}

/// To compute unique edge ID, map vertices+edges into
/// doubled virtual vertex indices.
///
/// v edge  v
/// |----*----|    -->    |-----|-----|
/// i           i+1         2i   2i+1  2i+2
///
func globalVertexId(i:size_t, j:size_t, k:size_t, dim:Size3,
                    localVertexId:size_t)->size_t {
    // See edgeConnection in marching_cubes_table.h for the edge ordering.
    let vertexOffset3D:[[Int]] = [
        [0, 0, 0], [2, 0, 0], [2, 0, 2],
        [0, 0, 2], [0, 2, 0], [2, 2, 0],
        [2, 2, 2], [0, 2, 2]
    ]
    
    return ((2 * k + vertexOffset3D[localVertexId][2]) * 2 * dim.y +
        (2 * j + vertexOffset3D[localVertexId][1])) * 2 * dim.x +
        (2 * i + vertexOffset3D[localVertexId][0])
}

func singleSquare(data:[Float],
                  vertAndEdgeIds:[size_t],
                  normal:Vector3F,
                  corners:[Vector3F],
                  vertexMap:inout MarchingCubeVertexMap,
                  mesh:inout TriangleMesh3,
                  isoValue:Float) {
    var idxFlags:Int = 0
    var idxEdgeFlags:Int = 0
    var idxVertexOfTheEdge = Array<Int>(repeating: 0, count: 2)
    
    var phi0:Float = 0
    var phi1:Float = 0
    var alpha:Float = 0
    var pos = Vector3F()
    var pos0 = Vector3F()
    var pos1 = Vector3F()
    var e = Array<Vector3F>(repeating: Vector3F(), count: 4)
    
    // Which vertices are inside? If i-th vertex is inside, mark '1' at i-th
    // bit. of 'idxFlags'.
    for itrVertex in 0..<4 {
        if (data[itrVertex] <= isoValue) {
            idxFlags |= 1 << itrVertex
        }
    }
    
    // If the rect is entirely outside of the surface,
    // there is no job to be done in this marching-cube cell.
    if (idxFlags == 0) {
        return
    }
    
    // If there are vertices which is inside the surface...
    // Which edges intersect the surface?
    // If i-th edge intersects the surface, mark '1' at i-th bit of
    // 'idxEdgeFlags'
    idxEdgeFlags = squareEdgeFlags[idxFlags]
    
    // Find the point of intersection of the surface with each edge
    for itrEdge in 0..<4 {
        // If there is an intersection on this edge
        if (idxEdgeFlags & (1 << itrEdge) != 0) {
            idxVertexOfTheEdge[0] = edgeConnection2D[itrEdge][0]
            idxVertexOfTheEdge[1] = edgeConnection2D[itrEdge][1]
            
            // Find the phi = 0 position by iteration
            pos0 = corners[idxVertexOfTheEdge[0]]
            pos1 = corners[idxVertexOfTheEdge[1]]
            
            phi0 = data[idxVertexOfTheEdge[0]] - isoValue
            phi1 = data[idxVertexOfTheEdge[1]] - isoValue
            
            // I think it needs perturbation a little bit.
            if (abs(phi0) + abs(phi1) > 1e-12) {
                alpha = abs(phi0) / (abs(phi0) + abs(phi1))
            } else {
                alpha = 0.5
            }
            
            if (alpha < 0.000001) {
                alpha = 0.000001
            }
            if (alpha > 0.999999) {
                alpha = 0.999999
            }
            
            pos = ((1.0 - alpha) * pos0 + alpha * pos1)
            
            // What is the position of this vertex of the edge?
            e[itrEdge] = pos
        }
    }
    
    // Make triangular patches.
    for itrTri in 0..<4 {
        // If there isn't any triangle to be built, escape this loop.
        if (triangleConnectionTable2D[idxFlags][3 * itrTri] < 0) {
            break
        }
        
        var face = Point3UI()
        
        for j in 0..<3 {
            let idxVertex = triangleConnectionTable2D[idxFlags][3 * itrTri + j]
            
            let vKey = vertAndEdgeIds[idxVertex]
            var vId = MarchingCubeVertexId()
            if (queryVertexId(vertexMap: vertexMap, vKey: vKey, vId: &vId)) {
                face[j] = vId
            } else {
                // if vertex does not exist...
                face[j] = mesh.numberOfPoints()
                mesh.addNormal(n: normal)
                if (idxVertex < 4) {
                    mesh.addPoint(pt: corners[idxVertex])
                } else {
                    mesh.addPoint(pt: e[idxVertex - 4])
                }
                mesh.addUv(t: Vector2F())  // empty texture coord...
                vertexMap.updateValue(face[j], forKey: vKey)
            }
        }
        
        mesh.addPointUvNormalTriangle(newPointIndices: face,
                                      newUvIndices: face,
                                      newNormalIndices: face)
    }
}

func singleCube(data:[Float],
                edgeIds:[size_t],
                normals:[Vector3F],
                bound:BoundingBox3F,
                vertexMap:inout MarchingCubeVertexMap,
                mesh:inout TriangleMesh3,
                isoValue:Float) {
    var idxFlagSize:Int = 0
    var idxEdgeFlags:Int = 0
    var idxVertexOfTheEdge = Array<Int>(repeating: 0, count: 2)
    
    var pos = Vector3F()
    var pos0 = Vector3F()
    var pos1 = Vector3F()
    var normal = Vector3F()
    var normal0 = Vector3F()
    var normal1 = Vector3F()
    var phi0:Float = 0
    var phi1:Float = 0
    var alpha:Float = 0
    var e = Array<Vector3F>(repeating: Vector3F(), count: 12)
    var n = Array<Vector3F>(repeating: Vector3F(), count: 12)
    
    // Which vertices are inside? If i-th vertex is inside, mark '1' at i-th
    // bit. of 'idxFlagSize'.
    for itrVertex in 0..<8 {
        if (data[itrVertex] <= isoValue) {
            idxFlagSize |= 1 << itrVertex
        }
    }
    
    // If the cube is entirely inside or outside of the surface, there is no job
    // to be done in t1his marching-cube cell.
    if (idxFlagSize == 0 || idxFlagSize == 255) {
        return
    }
    
    // If there are vertices which is inside the surface...
    // Which edges intersect the surface? If i-th edge intersects the surface,
    // mark '1' at i-th bit of 'itrEdgeFlags'
    idxEdgeFlags = cubeEdgeFlags[idxFlagSize]
    
    // Find the point of intersection of the surface with each edge
    for itrEdge in 0..<12 {
        // If there is an intersection on this edge
        if (idxEdgeFlags & (1 << itrEdge) != 0) {
            idxVertexOfTheEdge[0] = edgeConnection[itrEdge][0]
            idxVertexOfTheEdge[1] = edgeConnection[itrEdge][1]
            
            // cube vertex ordering to x-major ordering
            let indexMap:[Int] = [0, 1, 5, 4, 2, 3, 7, 6]
            
            // Find the phi = 0 position
            pos0 = bound.corner(idx: indexMap[idxVertexOfTheEdge[0]])
            pos1 = bound.corner(idx: indexMap[idxVertexOfTheEdge[1]])
            
            normal0 = normals[idxVertexOfTheEdge[0]]
            normal1 = normals[idxVertexOfTheEdge[1]]
            
            phi0 = data[idxVertexOfTheEdge[0]] - isoValue
            phi1 = data[idxVertexOfTheEdge[1]] - isoValue
            
            alpha = distanceToZeroLevelSet(phi0: phi0, phi1: phi1)
            
            if (alpha < 0.000001) {
                alpha = 0.000001
            }
            if (alpha > 0.999999) {
                alpha = 0.999999
            }
            
            pos = (1.0 - alpha) * pos0 + alpha * pos1
            normal = (1.0 - alpha) * normal0 + alpha * normal1
            
            e[itrEdge] = pos
            n[itrEdge] = normal
        }
    }
    
    // Make triangles
    for itrTri in 0..<5 {
        // If there isn't any triangle to be made, escape this loop.
        if (triangleConnectionTable3D[idxFlagSize][3 * itrTri] < 0) {
            break
        }
        
        var face = Point3UI()
        
        for j in 0..<3 {
            let k = 3 * itrTri + j
            let vKey = edgeIds[triangleConnectionTable3D[idxFlagSize][k]]
            var vId = MarchingCubeVertexId()
            if (queryVertexId(vertexMap: vertexMap, vKey: vKey, vId: &vId)) {
                face[j] = vId
            } else {
                // If vertex does not exist from the map
                face[j] = mesh.numberOfPoints()
                mesh.addNormal(n: safeNormalize(
                    n: n[triangleConnectionTable3D[idxFlagSize][k]]))
                mesh.addPoint(pt: e[triangleConnectionTable3D[idxFlagSize][k]])
                mesh.addUv(t: Vector2F())
                vertexMap.updateValue(face[j], forKey: vKey)
            }
        }
        mesh.addPointUvNormalTriangle(newPointIndices: face,
                                      newUvIndices: face,
                                      newNormalIndices: face)
    }
}
