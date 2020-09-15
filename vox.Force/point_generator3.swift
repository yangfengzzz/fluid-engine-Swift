//
//  point_generator3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

protocol PointGenerator3 {
    /// Generates points to output array \p points inside given \p boundingBox
    /// with target point \p spacing.
    func generate(boundingBox:BoundingBox3F,
                  spacing:Float,
                  points: inout Array1<Vector3F>)
    
    /// Iterates every point within the bounding box with specified
    /// point pattern and invokes the callback function.
    ///
    /// This function iterates every point within the bounding box and invokes
    /// the callback function. The position of the point is specified by the
    /// actual implementation. The suggested spacing between the points are
    /// given by \p spacing. The input parameter of the callback function is
    /// the position of the point and the return value tells whether the
    /// iteration should stop or not.
    func forEachPoint(boundingBox:BoundingBox3F,
                      spacing:Float,
                      callback:(Vector3F)->Bool)
}

extension PointGenerator3 {
    func generate(boundingBox:BoundingBox3F,
                  spacing:Float,
                  points: inout Array1<Vector3F>) {
        forEachPoint(boundingBox: boundingBox,
                     spacing: spacing){(point:Vector3F) in
                        let pointArray:[Vector3F] = [point]
                        points.append(other: pointArray)
                        return true;
        }
    }
}
