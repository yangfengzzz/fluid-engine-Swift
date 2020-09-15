//
//  triangle_mesh_to_sdf.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Generates signed-distance field out of given triangle mesh.
///
/// This function generates signed-distance field from a triangle mesh. The sign
/// is determined by TriangleMesh3::isInside (negative means inside).
/// - Parameters:
///   - mesh: The mesh.
///   - sdf: The output signed-distance field.
///   - exactBand: This parameter is no longer used.
/// - Warning: exactBand is no longer used and will be deprecated in next release (v2.x).
func triangleMeshToSdf(mesh:TriangleMesh3,
                       sdf: inout ScalarGrid3,
                       exactBand:UInt = 1) {
    let size = sdf.dataSize()
    if (size.x * size.y * size.z == 0) {
        return
    }
    
    let pos = sdf.dataPosition()
    mesh.updateQueryEngine()
    sdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
        let p = pos(i, j, k)
        let d = mesh.closestDistance(otherPoint: p)
        let sd = mesh.isInside(otherPoint: p) ? -d : d
        sdf[i, j, k] = sd
    }
}
