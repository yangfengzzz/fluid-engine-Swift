//
//  scalar_grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Abstract base class for 2-D scalar grid structure.
class ScalarGrid2: Grid2&ScalarField2 {
    var _data = Array2<Float>()
    var _linearSampler:LinearArraySampler2<Float, Float>
    var _sampler:((Vector2F)->Float)?
    
    /// Constructs an empty grid.
    override init(){
        self._linearSampler = LinearArraySampler2<Float, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: Vector2F())
    }
    
    /// Returns the size of the grid data.
    ///
    /// This function returns the size of the grid data which is not necessarily
    /// equal to the grid resolution if the data is not stored at cell-center.
    func dataSize()->Size2 {
        fatalError()
    }
    
    /// Returns the origin of the grid data.
    ///
    /// This function returns data position for the grid point at (0, 0).
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func dataOrigin()->Vector2F {
        fatalError()
    }
    
    /// Returns the copy of the grid instance.
    func clone()->ScalarGrid2 {
        fatalError()
    }
    
    /// Clears the contents of the grid.
    func clear() {
        resize(resolution: Size2(),
               gridSpacing: gridSpacing(),
               origin: origin(), initialValue: 0.0)
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolutionX:size_t,
                resolutionY:size_t,
                gridSpacingX:Float = 1.0,
                gridSpacingY:Float = 1.0,
                originX:Float = 0.0,
                originY:Float = 0.0,
                initialValue:Float = 0.0) {
        resize(resolution: Size2(resolutionX, resolutionY),
               gridSpacing: Vector2F(gridSpacingX, gridSpacingY),
               origin: Vector2F(originX, originY),
               initialValue: initialValue)
    }
    
    /// Resizes the grid using given parameters.
    func resize(resolution:Size2,
                gridSpacing:Vector2F = Vector2F(1, 1),
                origin:Vector2F = Vector2F(),
                initialValue:Float = 0.0) {
        setSizeParameters(resolution: resolution,
                          gridSpacing: gridSpacing,
                          origin: origin)
        _data.resize(size: dataSize(),
                     initVal: initialValue)
        resetSampler()
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
               gridSpacing: gridSpacing,
               origin: origin)
    }
    
    /// Returns the grid data at given data point.
    subscript(i:size_t, j:size_t)->Float{
        get{
            return _data[i, j]
        }
        set{
            _data[i, j] = newValue
        }
    }
    
    /// Returns the gradient vector at given data point.
    func gradientAtDataPoint(i:size_t, j:size_t)->Vector2F {
        return gradient2(data: _data.constAccessor(),
                         gridSpacing: gridSpacing(), i: i, j: j)
    }
    
    /// Returns the Laplacian at given data point.
    func laplacianAtDataPoint(i:size_t, j:size_t)->Float {
        return laplacian2(data: _data.constAccessor(),
                          gridSpacing: gridSpacing(), i: i, j: j)
    }
    
    /// Returns the read-write data array accessor.
    func dataAccessor()->ArrayAccessor2<Float> {
        return _data.accessor()
    }
    
    /// Returns the read-only data array accessor.
    func constDataAccessor()->ConstArrayAccessor2<Float> {
        return _data.constAccessor()
    }
    
    /// Returns the function that maps data point to its position.
    func dataPosition()->DataPositionFunc {
        let o:Vector2F = dataOrigin()
        return {(i:size_t, j:size_t) -> Vector2F in
            return o + self.gridSpacing() * Vector2F(Float(i), Float(j))
        }
    }
    
    /// Fills the grid with given value.
    func fill(value:Float,
              policy:ExecutionPolicy = .kParallel) {
        parallelFor(beginIndexX: 0, endIndexX: _data.width(),
                    beginIndexY: 0, endIndexY: _data.height(),
                    function: { (i:size_t, j:size_t) in
                        _data[i, j] = value
                    }, policy: policy)
    }
    
    /// Fills the grid with given position-to-value mapping function.
    func fill(function:(Vector2F)->Float,
              policy:ExecutionPolicy = .kParallel) {
        let pos:DataPositionFunc = dataPosition()
        parallelFor(beginIndexX: 0, endIndexX: _data.width(),
                    beginIndexY: 0, endIndexY: _data.height(),
                    function: { (i:size_t, j:size_t) in
                        _data[i, j] = function(pos(i, j))
                    }, policy: policy)
    }
    
    /// Invokes the given function \p func for each data point.
    ///
    /// This function invokes the given function object \p func for each data
    /// point in serial manner. The input parameters are i and j indices of a
    /// data point. The order of execution is i-first, j-last.
    func forEachDataPointIndex(function:(size_t, size_t)->Void) {
        _data.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each data point parallelly.
    ///
    /// This function invokes the given function object \p func for each data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachDataPointIndex(function:(size_t, size_t)->Void) {
        _data.parallelForEachIndex(function)
    }
    
    /// Returns the sampled value at given position \p x.
    ///
    /// This function returns the data sampled at arbitrary position \p x.
    /// The sampling function is linear.
    func sample(x: Vector2F) -> Float {
        _sampler!(x)
    }
    
    /// Returns the sampler function.
    ///
    /// This function returns the data sampler function object. The sampling
    /// function is linear.
    func sampler()->(Vector2F)->Float {
        return _sampler!
    }
    
    /// Returns the gradient vector at given position \p x.
    func gradient(x:Vector2F)->Vector2F {
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result = Vector2F()
        for i in 0..<4 {
            result += weights[i] * gradientAtDataPoint(i: indices[i].x, j: indices[i].y)
        }
        
        return result
    }
    
    /// Returns the Laplacian at given position \p x.
    func laplacian(x:Vector2F)->Float {
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result:Float = 0.0
        for i in 0..<4 {
            result += weights[i] * laplacianAtDataPoint(i: indices[i].x, j: indices[i].y)
        }
        
        return result
    }
    
    func resetSampler() {
        _linearSampler = LinearArraySampler2<Float, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: gridSpacing(),
            gridOrigin: dataOrigin())
        _sampler = _linearSampler.functor()
    }
    
    /// Swaps the data storage and predefined samplers with given grid.
    func swapScalarGrid(other: inout ScalarGrid2) {
        var father_grid = other as Grid2
        swapGrid(other: &father_grid)
        
        _data.swap(other: &other._data)
        Swift.swap(&_linearSampler, &other._linearSampler)
        Swift.swap(&_sampler, &other._sampler)
    }
    
    /// Sets the data storage and predefined samplers with given grid.
    func setScalarGrid(other:ScalarGrid2) {
        setGrid(other: other)
        
        _data.set(other: other._data)
        resetSampler()
    }
    
    /// Fetches the data into a continuous linear array.
    override func getData(data: inout [Float]) {
        let size:size_t = dataSize().x * dataSize().y
        data = Array<Float>(repeating: 0, count: size)
        
        for i in 0..<size {
            data[i] = _data[i]
        }
    }
    
    /// Sets the data from a continuous linear array.
    override func setData(data:[Float]) {
        VOX_ASSERT(dataSize().x * dataSize().y == data.count)
        for i in 0..<data.count {
            _data[i] = data[i]
        }
    }
}

/// Abstract base class for 2-D scalar grid builder.
protocol ScalarGridBuilder2 {
    /// Returns 2-D scalar grid with given parameters.
    func build(resolution:Size2, gridSpacing:Vector2F,
               gridOrigin:Vector2F, initialVal:Float)->ScalarGrid2
}

//MARK:- GPU Method
extension ScalarGrid2 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_data._data!, offset: 0, index: index_begin)
        var buffer = Grid2Descriptor(_gridSpacing: _gridSpacing, _origin: _origin)
        encoder.setBytes(&buffer, length: MemoryLayout<Grid2Descriptor>.stride, index: index_begin+1)
        return index_begin + 2
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachDataPointIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
        var arrayPipelineState: MTLComputePipelineState!
        var function: MTLFunction? = nil
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else {
                return 
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
        else { return }
        
        computeEncoder.setComputePipelineState(arrayPipelineState)
        let w = arrayPipelineState.threadExecutionWidth
        let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(dataSize().x, dataSize().y, 1)
        
        computeEncoder.setBuffer(_data._data!, offset: 0, index: 0)
        
        //Other Variables
        var index:Int = 1
        callBack(&computeEncoder, &index)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
