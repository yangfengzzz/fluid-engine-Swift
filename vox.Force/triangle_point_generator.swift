//
//  triangle_point_generator.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Right triangle point generator.
class TrianglePointGenerator: PointGenerator2 {
    /// Invokes \p callback function for each right triangle points
    /// inside \p boundingBox.
    ///
    /// This function iterates every right triangle points inside \p boundingBox
    /// where \p spacing is the size of the right triangle structure.
    func forEachPoint(boundingBox:BoundingBox2F,
                      spacing:Float,
                      callback:(Vector2F)->Bool) {
        let halfSpacing = spacing / 2.0
        let ySpacing = spacing * sqrt(3.0) / 2.0
        let boxWidth = boundingBox.width()
        let boxHeight = boundingBox.height()
        
        var position = Vector2F()
        var hasOffset = false
        var shouldQuit = false
        var j:Int = 0
        while Float(j) * ySpacing <= boxHeight && !shouldQuit {
            position.y = Float(j) * ySpacing + boundingBox.lowerCorner.y
            
            let offset = (hasOffset) ? halfSpacing : 0.0
            
            var i:Int = 0
            while Float(i) * spacing + offset <= boxWidth && !shouldQuit {
                position.x = Float(i) * spacing + offset + boundingBox.lowerCorner.x
                if (!callback(position)) {
                    shouldQuit = true
                    break
                }
                
                i += 1
            }
            
            hasOffset = !hasOffset
            
            j += 1
        }
    }
}
