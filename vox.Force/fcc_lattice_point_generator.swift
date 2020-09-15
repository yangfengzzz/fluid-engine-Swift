//
//  fcc_lattice_point_generator.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Face-centered lattice points generator.
///
/// http://en.wikipedia.org/wiki/Cubic_crystal_system
/// http://mathworld.wolfram.com/CubicClosePacking.html
class FccLatticePointGenerator: PointGenerator3 {
    /// Invokes \p callback function for each FCC-lattice points inside
    /// \p boundingBox.
    ///
    /// This function iterates every FCC-lattice points inside \p boundingBox
    /// where \p spacing is the size of the unit cell of FCC structure.
    func forEachPoint(boundingBox:BoundingBox3F,
                      spacing:Float,
                      callback:(Vector3F)->Bool) {
        let halfSpacing = spacing / 2.0
        let boxWidth = boundingBox.width()
        let boxHeight = boundingBox.height()
        let boxDepth = boundingBox.depth()
        
        var position = Vector3F()
        var shouldQuit = false
        var k:Int = 0
        while Float(k) * halfSpacing <= boxDepth && !shouldQuit {
            position.z = Float(k) * halfSpacing + boundingBox.lowerCorner.z
            
            var hasOffset = k % 2 == 1
            var j:Int = 0
            while Float(j) * halfSpacing <= boxHeight && !shouldQuit {
                position.y = Float(j) * halfSpacing + boundingBox.lowerCorner.y
                
                let offset = (hasOffset) ? halfSpacing : 0.0
                var i:Int = 0
                while Float(i) * spacing + offset <= boxWidth {
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
            
            k += 1
        }
    }
}
