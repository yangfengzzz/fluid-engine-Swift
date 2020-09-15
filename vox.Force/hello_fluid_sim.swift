//
//  hello_fluid_sim.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

let kBufferSize:size_t = 80

func updateWave(timeInterval:Double, x:inout Float, speed:inout Float) {
    x += Float(timeInterval) * speed
    
    // Boundary reflection
    if (x > 1.0) {
        speed *= -1.0
        x = 1.0 + Float(timeInterval) * speed
    } else if (x < 0.0) {
        speed *= -1.0
        x = Float(timeInterval) * speed
    }
}

func accumulateWaveToHeightField(x:Float,
                                 waveLength:Float,
                                 maxHeight:Float,
                                 heightField:inout Array1<Float>) {
    let quarterWaveLength = 0.25 * waveLength
    let start:Int = Int((x - quarterWaveLength) * Float(kBufferSize))
    let end:Int = Int((x + quarterWaveLength) * Float(kBufferSize))
    
    for i in start..<end {
        var iNew:Int = i
        if (i < 0) {
            iNew = -i - 1
        } else if (i >= kBufferSize) {
            iNew = 2 * kBufferSize - i - 1
        }
        
        let distance = abs((Float(i) + 0.5) / Float(kBufferSize) - x)
        let height = maxHeight * 0.5 * (cos(min(distance * Float.pi / quarterWaveLength, Float.pi)) + 1.0)
        heightField[iNew] += height
    }
}

class HelloFluidSimRenderable: Renderable {
    let waveLengthX:Float = 0.8
    let waveLengthY:Float = 1.2
    
    let maxHeightX:Float = 0.5
    let maxHeightY:Float = 0.4
    
    let x:Float = 0.0
    let y:Float = 1.0
    let speedX:Float = 1.5
    let speedY:Float = -1.0
    
    let fps:Int = 100
    let timeInterval:Float = 1.0 / 100.0
    var heightField = Array1<Float>(size: kBufferSize)
    var gridPoints = Array1<Float>(size: kBufferSize)
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
