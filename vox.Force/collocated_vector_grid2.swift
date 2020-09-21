//
//  collocated_vector_grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Abstract base class for 2-D collocated vector grid structure.
class CollocatedVectorGrid2: VectorGrid2 {
    var _data = Array2<Vector2F>()
    var _linearSampler:LinearArraySampler2<Vector2F, Float>
    var _sampler:((Vector2F)->Vector2F)?
    
    /// Constructs an empty grid.
    override init(){
        self._linearSampler = LinearArraySampler2<Vector2F, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: Vector2F())
    }
    
    /// Returns the actual data point size.
    func dataSize()->Size2 {
        fatalError()
    }
    
    /// Returns data position for the grid point at (0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func dataOrigin()->Vector2F {
        fatalError()
    }
    
    /// Returns the grid data at given data point.
    subscript(i:size_t, j:size_t)->Vector2F{
        get{
            return _data[i, j]
        }
        set{
            _data[i, j] = newValue
        }
    }
    
    /// Returns divergence at data point location.
    func divergenceAtDataPoint(i:size_t, j:size_t)->Float {
        let ds:Size2 = _data.size()
        let gs:Vector2F = gridSpacing()
        
        VOX_ASSERT(i < ds.x && j < ds.y)
        
        let left:Float = _data[(i > 0) ? i - 1 : i, j].x
        let right:Float = _data[(i + 1 < ds.x) ? i + 1 : i, j].x
        let down:Float = _data[i, (j > 0) ? j - 1 : j].y
        let up:Float = _data[i, (j + 1 < ds.y) ? j + 1 : j].y
        
        return 0.5 * (right - left) / gs.x
            + 0.5 * (up - down) / gs.y
    }
    
    /// Returns curl at data point location.
    func curlAtDataPoint(i:size_t, j:size_t)->Float {
        let ds:Size2 = _data.size()
        let gs:Vector2F = gridSpacing()
        
        VOX_ASSERT(i < ds.x && j < ds.y)
        
        let left:Vector2F = _data[(i > 0) ? i - 1 : i, j]
        let right:Vector2F = _data[(i + 1 < ds.x) ? i + 1 : i, j]
        let bottom:Vector2F = _data[i, (j > 0) ? j - 1 : j]
        let top:Vector2F = _data[i, (j + 1 < ds.y) ? j + 1 : j]
        
        let Fx_ym:Float = bottom.x
        let Fx_yp:Float = top.x
        
        let Fy_xm:Float = left.y
        let Fy_xp:Float = right.y
        
        return 0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y
    }
    
    /// Returns the read-write data array accessor.
    func dataAccessor()->ArrayAccessor2<Vector2F> {
        return _data.accessor()
    }
    
    /// Returns the read-only data array accessor.
    func constDataAccessor()->ConstArrayAccessor2<Vector2F> {
        return _data.constAccessor()
    }
    
    /// Returns the function that maps data point to its position.
    func dataPosition()->DataPositionFunc {
        let dataOrigin_:Vector2F = dataOrigin()
        return {(i:size_t, j:size_t) -> Vector2F in
            return dataOrigin_ + self.gridSpacing() * Vector2F(Float(i), Float(j))
        }
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
    
    /// Returns sampled value at given position \p x.
    override func sample(x:Vector2F)->Vector2F {
        return _sampler!(x)
    }
    
    /// Returns the sampler function.
    ///
    /// This function returns the data sampler function object. The sampling
    /// function is linear.
    func sampler()->(Vector2F)->Vector2F {
        return _sampler!
    }
    
    /// Returns divergence at given position \p x.
    func divergence(x:Vector2F)->Float {
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result:Float = 0.0
        
        for i in 0..<4 {
            result += weights[i] * divergenceAtDataPoint(
                i: indices[i].x, j: indices[i].y)
        }
        
        return result
    }
    
    /// Returns curl at given position \p x.
    func curl(x:Vector2F)->Float {
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result:Float = 0.0
        
        for i in 0..<4 {
            result += weights[i] * curlAtDataPoint(
                i: indices[i].x, j: indices[i].y)
        }
        
        return result
    }
    
    /// Swaps the data storage and predefined samplers with given grid.
    func swapCollocatedVectorGrid(other: inout CollocatedVectorGrid2) {
        var father_grid = other as Grid2
        swapGrid(other: &father_grid)
        
        _data.swap(other: &other._data)
        Swift.swap(&_linearSampler, &other._linearSampler)
        Swift.swap(&_sampler, &other._sampler)
    }
    
    /// Sets the data storage and predefined samplers with given grid.
    func setCollocatedVectorGrid(other:CollocatedVectorGrid2) {
        setGrid(other: other)
        
        _data.set(other: other._data)
        resetSampler()
    }
    
    /// Fetches the data into a continuous linear array.
    override func getData(data: inout [Float]) {
        let size:size_t = 2 * dataSize().x * dataSize().y
        data = Array<Float>(repeating: 0, count: size)
        var cnt:size_t = 0
        _data.forEach(){(value:Vector2F) in
            data[cnt] = value.x
            data[cnt] = value.y
            cnt += 1
        }
    }
    
    /// Sets the data from a continuous linear array.
    override func setData(data:[Float]) {
        VOX_ASSERT(2 * dataSize().x * dataSize().y == data.count)
        
        var cnt:size_t = 0
        _data.forEachIndex(){(i:size_t, j:size_t) in
            _data[i, j].x = data[cnt]
            _data[i, j].y = data[cnt]
            cnt += 1
        }
    }
    
    override func onResize(resolution:Size2, gridSpacing:Vector2F,
                           origin:Vector2F, initialValue:Vector2F) {
        _data.resize(size: dataSize(), initVal: initialValue)
        resetSampler()
    }
    
    func resetSampler() {
        _linearSampler = LinearArraySampler2<Vector2F, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: gridSpacing(),
            gridOrigin: dataOrigin())
        _sampler = _linearSampler.functor()
    }
}

//MARK:- GPU Method
extension CollocatedVectorGrid2 {
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
