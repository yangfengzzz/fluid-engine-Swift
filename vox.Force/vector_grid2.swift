//
//  vector_grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D vector grid structure.
class VectorGrid2: VectorField2&Grid2 {
    /// Constructs an empty grid.
    override init(){}
    
    /// Clears the contents of the grid.
    func clear() {
        resize(resolution: Size2(), gridSpacing: gridSpacing(),
               origin: origin(), initialValue: Vector2F())
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolutionX:size_t,
                resolutionY:size_t,
                gridSpacingX:Float = 1.0,
                gridSpacingY:Float = 1.0,
                originX:Float = 0.0,
                originY:Float = 0.0,
                initialValueX:Float = 0.0,
                initialValueY:Float = 0.0) {
        resize(resolution: Size2(resolutionX, resolutionY),
               gridSpacing: Vector2F(gridSpacingX, gridSpacingY),
               origin: Vector2F(originX, originY),
               initialValue: Vector2F(initialValueX, initialValueY))
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolution:Size2,
                gridSpacing:Vector2F = Vector2F(1, 1),
                origin:Vector2F = Vector2F(),
                initialValue:Vector2F = Vector2F()) {
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
                originX:Float,
                originY:Float){
        resize(gridSpacing: Vector2F(gridSpacingX, gridSpacingY),
               origin: Vector2F(originX, originY))
    }
    
    /// Resizes the grid using given parameters.
    func resize(gridSpacing:Vector2F,
                origin:Vector2F) {
        resize(resolution: resolution(),
               gridSpacing: gridSpacing, origin: origin)
    }
    
    /// Fills the grid with given value.
    func fill(value:Vector2F,
              policy:ExecutionPolicy = .kParallel) {
        fatalError()
    }
    
    /// Fills the grid with given position-to-value mapping function.
    func fill(function:(Vector2F)->Vector2F,
              policy:ExecutionPolicy = .kParallel) {
        fatalError()
    }
    
    /// Invoked when the resizing happens.
    ///
    /// This callback function is called when the grid gets resized. The
    /// overriding class should allocate the internal storage based on its
    /// data layout scheme.
    func onResize(resolution:Size2, gridSpacing:Vector2F,
                  origin:Vector2F, initialValue:Vector2F) {
        fatalError()
    }
    
    func sample(x: Vector2F) -> Vector2F {
        fatalError()
    }
    
    /// Returns the copy of the grid instance.
    func clone()->VectorGrid2 {
        fatalError()
    }
}

/// Abstract base class for 2-D vector grid builder.
protocol VectorGridBuilder2 {
    /// Returns 2-D vector grid with given parameters.
    func build(resolution:Size2, gridSpacing:Vector2F,
               gridOrigin:Vector2F, initialVal:Vector2F)->VectorGrid2
}
