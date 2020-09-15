//
//  cell_centered_vector_grid3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/7/31.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D Cell-centered vector grid structure.
///
/// This class represents 3-D cell-centered vector grid which extends
/// CollocatedVectorGrid3. As its name suggests, the class defines the data
/// point at the center of a grid cell. Thus, the dimension of data points are
/// equal to the dimension of the cells.
final class CellCenteredVectorGrid3: CollocatedVectorGrid3 {
    /// Returns the type name of derived grid.
    override func typeName()->String {
        return "CellCenteredVectorGrid3"
    }
    
    /// Constructs zero-sized grid.
    override init() {}
    
    /// Constructs a grid with given resolution, grid spacing, origin and
    /// initial value.
    init(resolutionX:size_t,
         resolutionY:size_t,
         resolutionZ:size_t,
         gridSpacingX:Float = 1.0,
         gridSpacingY:Float = 1.0,
         gridSpacingZ:Float = 1.0,
         originX:Float = 0.0,
         originY:Float = 0.0,
         originZ:Float = 0.0,
         initialValueU:Float = 0.0,
         initialValueV:Float = 0.0,
         initialValueW:Float = 0.0) {
        super.init()
        resize(resolutionX: resolutionX,
               resolutionY: resolutionY,
               resolutionZ: resolutionZ,
               gridSpacingX: gridSpacingX,
               gridSpacingY: gridSpacingY,
               gridSpacingZ: gridSpacingZ,
               originX: originX,
               originY: originY,
               originZ: originZ,
               initialValueX: initialValueU,
               initialValueY: initialValueV,
               initialValueZ: initialValueW)
    }
    
    /// Constructs a grid with given resolution, grid spacing, origin and
    /// initial value.
    init(resolution:Size3,
         gridSpacing:Vector3F = Vector3F(1.0, 1.0, 1.0),
         origin:Vector3F = Vector3F(),
         initialValue:Vector3F = Vector3F()) {
        super.init()
        resize(resolution: resolution,
               gridSpacing: gridSpacing,
               origin: origin,
               initialValue: initialValue)
    }
    
    /// Copy constructor.
    init(other:CellCenteredVectorGrid3) {
        super.init()
        set(other: other)
    }
    
    /// Returns the actual data point size.
    override func dataSize()->Size3 {
        return resolution()
    }
    
    /// Returns data position for the grid point at (0, 0, 0).
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    override func dataOrigin()->Vector3F {
        return origin() + 0.5 * gridSpacing()
    }
    
    /// Swaps the contents with the given \p other grid.
    ///
    /// This function swaps the contents of the grid instance with the given
    /// grid object \p other only if \p other has the same type with this grid.
    override func swap(other: inout Grid3) {
        let sameType = other as? CellCenteredVectorGrid3
        if (sameType != nil) {
            var father_grid = sameType! as CollocatedVectorGrid3
            swapCollocatedVectorGrid(other: &father_grid)
        }
    }
    
    /// Sets the contents with the given \p other grid.
    func set(other:CellCenteredVectorGrid3) {
        setCollocatedVectorGrid(other: other)
    }
    
    /// Fills the grid with given value.
    override func fill(value:Vector3F,
                       policy:ExecutionPolicy = .kParallel) {
        let size:Size3 = dataSize()
        var acc = dataAccessor()
        parallelFor(beginIndexX: 0, endIndexX: size.x,
                    beginIndexY: 0, endIndexY: size.y,
                    beginIndexZ: 0, endIndexZ: size.z,
                    function: {(i:size_t, j:size_t, k:size_t) in
                        acc[i, j, k] = value
        },policy: policy)
    }
    
    /// Fills the grid with given position-to-value mapping function.
    override func fill(function:(Vector3F)->Vector3F,
                       policy:ExecutionPolicy = .kParallel) {
        let size:Size3 = dataSize()
        var acc = dataAccessor()
        let pos:DataPositionFunc = dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: size.x,
                    beginIndexY: 0, endIndexY: size.y,
                    beginIndexZ: 0, endIndexZ: size.z,
                    function: {(i:size_t, j:size_t, k: size_t) in
                        acc[i, j, k] = function(pos(i, j, k))
        },policy: policy)
    }
    
    /// Returns the copy of the grid instance.
    override func clone()->VectorGrid3 {
        return CellCenteredVectorGrid3(other: self)
    }
    
    //MARK:- Builder
    /// Front-end to create CellCenteredVectorGrid3 objects step by step.
    class Builder: VectorGridBuilder3{
        var _resolution = Size3(1, 1, 1)
        var _gridSpacing = Vector3F(1, 1, 1)
        var _gridOrigin = Vector3F(0, 0, 0)
        var _initialVal = Vector3F(0, 0, 0)
        
        /// Returns builder with resolution.
        func withResolution(resolution:Size3)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with resolution.
        func withResolution(resolutionX:size_t,
                            resolutionY:size_t,
                            resolutionZ:size_t)->Builder {
            _resolution.x = resolutionX
            _resolution.y = resolutionY
            _resolution.z = resolutionZ
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacing:Vector3F)->Builder {
            _gridSpacing = gridSpacing
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacingX:Float,
                             gridSpacingY:Float,
                             gridSpacingZ:Float)->Builder {
            _gridSpacing.x = gridSpacingX
            _gridSpacing.y = gridSpacingY
            _gridSpacing.z = gridSpacingZ
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOrigin:Vector3F)->Builder {
            _gridOrigin = gridOrigin
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOriginX:Float,
                        gridOriginY:Float,
                        gridOriginZ:Float)->Builder {
            _gridOrigin.x = gridOriginX
            _gridOrigin.y = gridOriginY
            _gridOrigin.z = gridOriginZ
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialVal:Vector3F)->Builder {
            _initialVal = initialVal
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialValX:Float,
                              initialValY:Float,
                              initialValZ:Float)->Builder {
            _initialVal.x = initialValX
            _initialVal.y = initialValY
            _initialVal.z = initialValZ
            return self
        }
        
        /// Builds CellCenteredVectorGrid3 instance.
        func build()->CellCenteredVectorGrid3 {
            return CellCenteredVectorGrid3(
                resolution: _resolution,
                gridSpacing: _gridSpacing,
                origin: _gridOrigin,
                initialValue: _initialVal)
        }
        
        /// Builds shared pointer of CellCenteredVectorGrid3 instance.
        ///
        /// This is an overriding function that implements VectorGridBuilder3.
        func build(resolution: Size3,
                   gridSpacing: Vector3F,
                   gridOrigin: Vector3F,
                   initialVal: Vector3F)->VectorGrid3 {
            return CellCenteredVectorGrid3(
                resolution: resolution,
                gridSpacing: gridSpacing,
                origin: gridOrigin,
                initialValue: initialVal)
        }
    }
    
    /// Returns builder fox CellCenteredVectorGrid3.
    static func builder()->Builder{
        return Builder()
    }
}
