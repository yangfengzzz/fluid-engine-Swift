//
//  grid_point_generator2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D regular-grid point generator.
class GridPointGenerator2: PointGenerator2 {
    /// Invokes \p callback function for each regular grid points inside
    /// \p boundingBox.
    ///
    /// This function iterates every regular grid points inside \p boundingBox
    /// where \p spacing is the size of the unit cell of regular grid structure.
    func forEachPoint(boundingBox:BoundingBox2F,
                      spacing:Float,
                      callback:(Vector2F)->Bool) {
        var position = Vector2F()
        let boxWidth = boundingBox.width()
        let boxHeight = boundingBox.height()
        
        var shouldQuit = false
        var j:Int = 0
        while Float(j) * spacing <= boxHeight && !shouldQuit {
            position.y = Float(j) * spacing + boundingBox.lowerCorner.y
            var i:Int = 0
            while Float(i) * spacing <= boxWidth && !shouldQuit {
                position.x = Float(i) * spacing + boundingBox.lowerCorner.x
                if (!callback(position)) {
                    shouldQuit = true
                    break
                }
                
                i += 1
            }
            
            j += 1
        }
    }
}
