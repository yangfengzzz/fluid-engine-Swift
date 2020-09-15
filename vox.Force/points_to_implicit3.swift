//
//  points_to_implicit3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D points-to-implicit converters.
protocol PointsToImplicit3 {
    /// Converts the given points to implicit surface scalar field.
    func convert(points:ConstArrayAccessor1<Vector3F>,
                 output: inout ScalarGrid3)
}
