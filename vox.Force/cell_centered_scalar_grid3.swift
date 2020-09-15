//
//  cell_centered_scalar_grid3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/7/31.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D Cell-centered scalar grid structure.
///
/// This class represents 3-D cell-centered scalar grid which extends
/// ScalarGrid3. As its name suggests, the class defines the data point at the
/// center of a grid cell. Thus, the dimension of data points are equal to the
/// dimension of the cells.
final class CellCenteredScalarGrid3: ScalarGrid3 {
    /// Returns the type name of derived grid.
    override func typeName()->String {
        return "CellCenteredScalarGrid3"
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
         initialValue:Float = 0.0) {
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
               initialValue: initialValue)
    }
    
    /// Constructs a grid with given resolution, grid spacing, origin and
    /// initial value.
    init(resolution:Size3,
         gridSpacing:Vector3F = Vector3F(1.0, 1.0, 1.0),
         origin:Vector3F = Vector3F(),
         initialValue:Float = 0.0) {
        super.init()
        resize(resolution: resolution,
               gridSpacing: gridSpacing,
               origin: origin,
               initialValue: initialValue)
    }
    
    /// Copy constructor.
    init(other:CellCenteredScalarGrid3) {
        super.init()
        set(other: other)
    }
    
    /// Returns the actual data point size.
    override func dataSize()->Size3 {
        return resolution()
    }
    
    /// Returns data position for the grid point at (0, 0).
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
        let sameType = other as? CellCenteredScalarGrid3
        if (sameType != nil) {
            var father_grid = sameType! as ScalarGrid3
            swapScalarGrid(other: &father_grid)
        }
    }
    
    /// Sets the contents with the given \p other grid.
    func set(other:CellCenteredScalarGrid3) {
        setScalarGrid(other: other)
    }
    
    /// Returns the copy of the grid instance.
    override func clone()->ScalarGrid3 {
        return CellCenteredScalarGrid3(other: self)
    }
    
    //MARK:- Builder
    /// Front-end to create CellCenteredScalarGrid3 objects step by step.
    class Builder: ScalarGridBuilder3{
        var _resolution = Size3(1, 1, 1)
        var _gridSpacing = Vector3F(1, 1, 1)
        var _gridOrigin = Vector3F(0, 0, 0)
        var _initialVal:Float = 0.0
        
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
        func withInitialValue(initialVal:Float)->Builder {
            _initialVal = initialVal
            return self
        }
        
        /// Builds CellCenteredScalarGrid3 instance.
        func build()->CellCenteredScalarGrid3 {
            return CellCenteredScalarGrid3(
                resolution: _resolution,
                gridSpacing: _gridSpacing,
                origin: _gridOrigin,
                initialValue: _initialVal)
        }
        
        /// Builds shared pointer of CellCenteredScalarGrid3 instance.
        ///
        /// This is an overriding function that implements ScalarGridBuilder3.
        func build(resolution: Size3,
                   gridSpacing: Vector3F,
                   gridOrigin: Vector3F,
                   initialVal: Float)->ScalarGrid3 {
            return CellCenteredScalarGrid3(
                resolution: resolution,
                gridSpacing: gridSpacing,
                origin: gridOrigin,
                initialValue: initialVal)
        }
    }
    
    /// Returns builder fox CellCenteredScalarGrid3.
    static func builder()->Builder{
        return Builder()
    }
}
