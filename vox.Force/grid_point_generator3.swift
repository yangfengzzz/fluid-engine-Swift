//
//  grid_point_generator3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D regular-grid point generator.
class GridPointGenerator3: PointGenerator3 {
    /// Invokes \p callback function for each regular grid points inside
    /// \p boundingBox.
    ///
    /// This function iterates every regular grid points inside \p boundingBox
    /// where \p spacing is the size of the unit cell of regular grid structure.
    func forEachPoint(boundingBox:BoundingBox3F,
                      spacing:Float,
                      callback:(Vector3F)->Bool) {
        var position = Vector3F()
        let boxWidth = boundingBox.width()
        let boxHeight = boundingBox.height()
        let boxDepth = boundingBox.depth()
        
        var shouldQuit = false
        var k:Int = 0
        while Float(k) * spacing <= boxDepth && !shouldQuit {
            position.z = Float(k) * spacing + boundingBox.lowerCorner.z
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
            
            k += 1
        }
    }
}
