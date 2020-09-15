//
//  cell_centered_vector_grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D Cell-centered vector grid structure.
///
/// This class represents 2-D cell-centered vector grid which extends
/// CollocatedVectorGrid2. As its name suggests, the class defines the data
/// point at the center of a grid cell. Thus, the dimension of data points are
/// equal to the dimension of the cells.
final class CellCenteredVectorGrid2: CollocatedVectorGrid2 {
    /// Returns the type name of derived grid.
    override func typeName()->String {
        return "CellCenteredVectorGrid2"
    }
    
    /// Constructs zero-sized grid.
    override init() {}
    
    /// Constructs a grid with given resolution, grid spacing, origin and
    /// initial value.
    init(resolutionX:size_t,
         resolutionY:size_t,
         gridSpacingX:Float = 1.0,
         gridSpacingY:Float = 1.0,
         originX:Float = 0.0,
         originY:Float = 0.0,
         initialValueU:Float = 0.0,
         initialValueV:Float = 0.0) {
        super.init()
        resize(resolutionX: resolutionX,
               resolutionY: resolutionY,
               gridSpacingX: gridSpacingX,
               gridSpacingY: gridSpacingY,
               originX: originX,
               originY: originY,
               initialValueX: initialValueU,
               initialValueY: initialValueV)
    }
    
    /// Constructs a grid with given resolution, grid spacing, origin and
    /// initial value.
    init(resolution:Size2,
         gridSpacing:Vector2F = Vector2F(1.0, 1.0),
         origin:Vector2F = Vector2F(),
         initialValue:Vector2F = Vector2F()) {
        super.init()
        resize(resolution: resolution,
               gridSpacing: gridSpacing,
               origin: origin,
               initialValue: initialValue)
    }
    
    /// Copy constructor.
    init(other:CellCenteredVectorGrid2) {
        super.init()
        set(other: other)
    }
    
    /// Returns the actual data point size.
    override func dataSize()->Size2 {
        return resolution()
    }
    
    /// Returns data position for the grid point at (0, 0).
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    override func dataOrigin()->Vector2F {
        return origin() + 0.5 * gridSpacing()
    }
    
    /// Swaps the contents with the given \p other grid.
    ///
    /// This function swaps the contents of the grid instance with the given
    /// grid object \p other only if \p other has the same type with this grid.
    override func swap(other: inout Grid2) {
        let sameType = other as? CellCenteredVectorGrid2
        if (sameType != nil) {
            var father_grid = sameType! as CollocatedVectorGrid2
            swapCollocatedVectorGrid(other: &father_grid)
        }
    }
    
    /// Sets the contents with the given \p other grid.
    func set(other:CellCenteredVectorGrid2) {
        setCollocatedVectorGrid(other: other)
    }
    
    /// Fills the grid with given value.
    override func fill(value:Vector2F,
                       policy:ExecutionPolicy = .kParallel) {
        let size:Size2 = dataSize()
        var acc = dataAccessor()
        parallelFor(beginIndexX: 0, endIndexX: size.x,
                    beginIndexY: 0, endIndexY: size.y,
                    function: {(i:size_t, j:size_t) in
                        acc[i, j] = value
        },policy: policy)
    }
    
    /// Fills the grid with given position-to-value mapping function.
    override func fill(function:(Vector2F)->Vector2F,
                       policy:ExecutionPolicy = .kParallel) {
        let size:Size2 = dataSize()
        var acc = dataAccessor()
        let pos:DataPositionFunc = dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: size.x,
                    beginIndexY: 0, endIndexY: size.y,
                    function: {(i:size_t, j:size_t) in
                        acc[i, j] = function(pos(i, j))
        },policy: policy)
    }
    
    /// Returns the copy of the grid instance.
    override func clone()->VectorGrid2 {
        return CellCenteredVectorGrid2(other: self)
    }
    
    //MARK:- Builder
    /// Front-end to create CellCenteredVectorGrid2 objects step by step.
    class Builder: VectorGridBuilder2{
        var _resolution = Size2(1, 1)
        var _gridSpacing = Vector2F(1, 1)
        var _gridOrigin = Vector2F(0, 0)
        var _initialVal = Vector2F(0, 0)
        
        /// Returns builder with resolution.
        func withResolution(resolution:Size2)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with resolution.
        func withResolution(resolutionX:size_t, resolutionY:size_t)->Builder {
            _resolution.x = resolutionX
            _resolution.y = resolutionY
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacing:Vector2F)->Builder {
            _gridSpacing = gridSpacing
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacingX:Float, gridSpacingY:Float)->Builder {
            _gridSpacing.x = gridSpacingX
            _gridSpacing.y = gridSpacingY
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOrigin:Vector2F)->Builder {
            _gridOrigin = gridOrigin
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOriginX:Float, gridOriginY:Float)->Builder {
            _gridOrigin.x = gridOriginX
            _gridOrigin.y = gridOriginY
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialVal:Vector2F)->Builder {
            _initialVal = initialVal
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialValX:Float, initialValY:Float)->Builder {
            _initialVal.x = initialValX
            _initialVal.y = initialValY
            return self
        }
        
        /// Builds CellCenteredVectorGrid2 instance.
        func build()->CellCenteredVectorGrid2 {
            return CellCenteredVectorGrid2(
                resolution: _resolution,
                gridSpacing: _gridSpacing,
                origin: _gridOrigin,
                initialValue: _initialVal)
        }
        
        /// Builds shared pointer of CellCenteredVectorGrid2 instance.
        ///
        /// This is an overriding function that implements VectorGridBuilder2.
        func build(resolution: Size2,
                   gridSpacing: Vector2F,
                   gridOrigin: Vector2F,
                   initialVal: Vector2F)->VectorGrid2 {
            return CellCenteredVectorGrid2(
                resolution: resolution,
                gridSpacing: gridSpacing,
                origin: gridOrigin,
                initialValue: initialVal)
        }
    }
    
    /// Returns builder fox CellCenteredVectorGrid2.
    static func builder()->Builder{
        return Builder()
    }
}
