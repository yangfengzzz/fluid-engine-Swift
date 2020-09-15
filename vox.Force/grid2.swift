//
//  grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Abstract base class for 2-D cartesian grid structure.
///
/// This class represents 2-D cartesian grid structure. This class is an
/// abstract base class and does not store any data. The class only stores the
/// shape of the grid. The grid structure is axis-aligned and can have different
/// grid spacing per axis.
class Grid2 {
    /// Function type for mapping data index to actual position.
    typealias DataPositionFunc = (size_t, size_t)->Vector2F
    
    struct Grid2Descriptor {
        var _gridSpacing = Vector2F(1, 1)
        var _origin = Vector2F()
    }
    
    var _resolution = Size2()
    var _gridSpacing = Vector2F(1, 1)
    var _origin = Vector2F()
    var _boundingBox = BoundingBox2F(point1: Vector2F(),
                                     point2: Vector2F())
    
    /// Constructs an empty grid.
    init() {}
    
    /// Returns the type name of derived grid.
    func typeName()->String {
        fatalError()
    }
    
    /// Returns the grid resolution.
    func resolution()->Size2 {
        return _resolution
    }
    
    /// Returns the grid origin.
    func origin()->Vector2F {
        return _origin
    }
    
    ///  Returns the grid spacing.
    func gridSpacing()->Vector2F {
        return _gridSpacing
    }
    
    /// Returns the bounding box of the grid.
    func boundingBox()->BoundingBox2F {
        return _boundingBox
    }
    
    /// Returns the function that maps grid index to the cell-center position.
    func cellCenterPosition()->DataPositionFunc {
        let h = _gridSpacing
        let o = _origin
        return {(i:size_t, j:size_t)->Vector2F in
            return o + h * Vector2F(Float(i) + 0.5,
                                    Float(j) + 0.5)
        }
    }
    
    /// Invokes the given function \p func for each grid cell.
    ///
    /// This function invokes the given function object \p func for each grid
    /// cell in serial manner. The input parameters are i and j indices of a
    /// grid cell. The order of execution is i-first, j-last.
    func forEachCellIndex(function:(size_t, size_t)->Void) {
        parallelFor(beginIndexX: 0, endIndexX: _resolution.x,
                    beginIndexY: 0, endIndexY: _resolution.y,
                    function: { (i:size_t, j:size_t) in
                        function(i, j)
        }, policy: .kSerial)
    }
    
    /// Invokes the given function \p func for each grid cell parallelly.
    ///
    /// This function invokes the given function object \p func for each grid
    /// cell in parallel manner. The input parameters are i and j indices of a
    /// grid cell. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachCellIndex(function:(size_t, size_t)->Void) {
        parallelFor(beginIndexX: 0, endIndexX: _resolution.x,
                    beginIndexY: 0, endIndexY: _resolution.y,
                    function: { (i:size_t, j:size_t) in
                        function(i, j)
        }, policy: .kParallel)
    }
    
    /// Returns true if resolution, grid-spacing and origin are same.
    func hasSameShape(other:Grid2)->Bool {
        return _resolution.x == other._resolution.x &&
            _resolution.y == other._resolution.y &&
            Math.similar(x: _gridSpacing.x, y: other._gridSpacing.x) &&
            Math.similar(x: _gridSpacing.y, y: other._gridSpacing.y) &&
            Math.similar(x: _origin.x, y: other._origin.x) &&
            Math.similar(x: _origin.y, y: other._origin.y)
    }
    
    /// Swaps the data with other grid.
    func swap(other: inout Grid2) {
        fatalError()
    }
    
    /// Sets the size parameters including the resolution, grid spacing, and origin.
    func setSizeParameters(resolution:Size2,
                           gridSpacing:Vector2F,
                           origin:Vector2F) {
        _resolution = resolution
        _origin = origin
        _gridSpacing = gridSpacing
        
        let resolutionD = Vector2F(Float(resolution.x),
                                   Float(resolution.y))
        
        _boundingBox = BoundingBox2F(point1: origin,
                                     point2: origin + gridSpacing * resolutionD)
    }
    
    /// Swaps the size parameters with given grid \p other.
    func swapGrid(other: inout Grid2) {
        Swift.swap(&_resolution, &other._resolution)
        Swift.swap(&_gridSpacing, &other._gridSpacing)
        Swift.swap(&_origin, &other._origin)
        Swift.swap(&_boundingBox, &other._boundingBox)
    }
    
    /// Sets the size parameters with given grid \p other.
    func setGrid(other:Grid2) {
        _resolution = other._resolution
        _gridSpacing = other._gridSpacing
        _origin = other._origin
        _boundingBox = other._boundingBox
    }
    
    /// Fetches the data into a continuous linear array.
    func getData(data: inout [Float]) {
        fatalError()
    }
    
    /// Sets the data from a continuous linear array.
    func setData(data:[Float]) {
        fatalError()
    }
}

//MARK:- GPU Method
extension Grid2 {
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    /// - Returns: Begin Index which is 0 if kernrl launch well
    func parallelForEachCellIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder)->Void)->Int {
        var arrayPipelineState: MTLComputePipelineState!
        var function: MTLFunction? = nil
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else {
                return 0
            }
            
            function = library.makeFunction(name: name)
            
            // array update pipeline state
            arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        // command encoder
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            var computeEncoder = commandBuffer.makeComputeCommandEncoder()
            else { return 0 }
        
        computeEncoder.setComputePipelineState(arrayPipelineState)
        let w = arrayPipelineState.threadExecutionWidth
        let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(_resolution.x, _resolution.y, 1)
        
        //Other Variables
        callBack(&computeEncoder)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return 0
    }
}
