//
//  vector_grid3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D vector grid structure.
class VectorGrid3: VectorField3&Grid3 {
    /// Constructs an empty grid.
    override init(){}
    
    /// Clears the contents of the grid.
    func clear() {
        resize(resolution: Size3(), gridSpacing: gridSpacing(),
               origin: origin(), initialValue: Vector3F())
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolutionX:size_t,
                resolutionY:size_t,
                resolutionZ:size_t,
                gridSpacingX:Float = 1.0,
                gridSpacingY:Float = 1.0,
                gridSpacingZ:Float = 1.0,
                originX:Float = 0.0,
                originY:Float = 0.0,
                originZ:Float = 0.0,
                initialValueX:Float = 0.0,
                initialValueY:Float = 0.0,
                initialValueZ:Float = 0.0) {
        resize(resolution: Size3(resolutionX, resolutionY, resolutionZ),
               gridSpacing: Vector3F(gridSpacingX, gridSpacingY, gridSpacingZ),
               origin: Vector3F(originX, originY, originZ),
               initialValue: Vector3F(initialValueX, initialValueY, initialValueZ))
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolution:Size3,
                gridSpacing:Vector3F = Vector3F(1, 1, 1),
                origin:Vector3F = Vector3F(),
                initialValue:Vector3F = Vector3F()) {
        setSizeParameters(resolution: resolution,
                          gridSpacing: gridSpacing,
                          origin: origin)
        
        onResize(resolution: resolution,
                 gridSpacing: gridSpacing,
                 origin: origin,
                 initialValue: initialValue)
    }
    
    /// Resizes the grid using given parameters.
    func resize(gridSpacingX:Float,
                gridSpacingY:Float,
                gridSpacingZ:Float,
                originX:Float,
                originY:Float,
                originZ:Float){
        resize(gridSpacing: Vector3F(gridSpacingX, gridSpacingY, gridSpacingZ),
               origin: Vector3F(originX, originY, originZ))
    }
    
    /// Resizes the grid using given parameters.
    func resize(gridSpacing:Vector3F,
                origin:Vector3F) {
        resize(resolution: resolution(),
               gridSpacing: gridSpacing, origin: origin)
    }
    
    /// Fills the grid with given value.
    func fill(value:Vector3F,
              policy:ExecutionPolicy = .kParallel) {
        fatalError()
    }
    
    /// Fills the grid with given position-to-value mapping function.
    func fill(function:(Vector3F)->Vector3F,
              policy:ExecutionPolicy = .kParallel) {
        fatalError()
    }
    
    /// Invoked when the resizing happens.
    ///
    /// This callback function is called when the grid gets resized. The
    /// overriding class should allocate the internal storage based on its
    /// data layout scheme.
    func onResize(resolution:Size3, gridSpacing:Vector3F,
                  origin:Vector3F, initialValue:Vector3F) {
        fatalError()
    }
    
    func sample(x: Vector3F) -> Vector3F {
        fatalError()
    }
    
    /// Returns the copy of the grid instance.
    func clone()->VectorGrid3 {
        fatalError()
    }
}

/// Abstract base class for 3-D vector grid builder.
protocol VectorGridBuilder3 {
    /// Returns 3-D vector grid with given parameters.
    func build(resolution:Size3, gridSpacing:Vector3F,
               gridOrigin:Vector3F, initialVal:Vector3F)->VectorGrid3
}
