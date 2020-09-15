//
//  color_utils.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/2.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

enum ColorUtils {
    static func makeWhite()->Vector4F {
        return Vector4F(1, 1, 1, 1)
    }
    
    static func makeGray()->Vector4F {
        return Vector4F(0.5, 0.5, 0.5, 1)
    }
    
    static func makeBlack()->Vector4F {
        return Vector4F(0, 0, 0, 1)
    }
    
    static func makeRed()->Vector4F {
        return Vector4F(1, 0, 0, 1)
    }
    
    static func makeGreen()->Vector4F {
        return Vector4F(0, 1, 0, 1)
    }
    
    static func makeBlue()->Vector4F {
        return Vector4F(0, 0, 1, 1)
    }
    
    static func makeCyan()->Vector4F {
        return Vector4F(0, 1, 1, 1)
    }
    
    static func makeMagenta()->Vector4F {
        return Vector4F(1, 0, 1, 1)
    }
    
    static func makeYellow()->Vector4F {
        return Vector4F(1, 1, 0, 1)
    }
    
    /// Makes color with jet colormap.
    /// - Parameter value: Input scalar value in [-1, 1] range.
    /// - Returns: New color instance.
    static func makeJet(value:Float)->Vector4F {
        // Adopted from
        // https://stackoverflow.com/questions/7706339/grayscale-to-red-green-blue-matlab-jet-color-scale
        return Vector4F(jetRed(value: value), jetGreen(value: value), jetBlue(value: value), 1.0)
    }
    
    static func interpolate(val:Float, y0:Float, x0:Float,
                            y1:Float, x1:Float)->Float {
        return (val - x0) * (y1 - y0) / (x1 - x0) + y0
    }
    
    static func jetBase(val:Float)->Float {
        if (val <= -0.75) {
            return 0
        } else if (val <= -0.25) {
            return interpolate(val: val, y0: 0.0, x0: -0.75, y1: 1.0, x1: -0.25)
        } else if (val <= 0.25) {
            return 1.0
        } else if (val <= 0.75) {
            return interpolate(val: val, y0: 1.0, x0: 0.25, y1: 0.0, x1: 0.75)
        } else {
            return 0.0
        }
    }
    
    static func jetRed(value:Float)->Float {
        return jetBase(val: value - 0.5)
    }
    
    static func jetGreen(value:Float)->Float {
        return jetBase(val: value)
    }
    
    static func jetBlue(value:Float)->Float {
        return jetBase(val: value + 0.5)
    }
}
