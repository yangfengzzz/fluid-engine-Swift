//
//  points_to_implicit2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D points-to-implicit converters.
protocol PointsToImplicit2 {
    /// Converts the given points to implicit surface scalar field.
    func convert(points:ConstArrayAccessor1<Vector2F>,
                 output: inout ScalarGrid2)
}
