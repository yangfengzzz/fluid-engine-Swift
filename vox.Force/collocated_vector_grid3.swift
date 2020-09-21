//
//  collocated_vector_grid3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/7/31.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import MetalKit

/// Abstract base class for 3-D collocated vector grid structure.
class CollocatedVectorGrid3: VectorGrid3 {
    var _data = Array3<Vector3F>()
    var _linearSampler:LinearArraySampler3<Vector3F, Float>
    var _sampler:((Vector3F)->Vector3F)?
    
    /// Constructs an empty grid.
    override init(){
        self._linearSampler = LinearArraySampler3<Vector3F, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: Vector3F())
    }
    
    /// Returns the actual data point size.
    func dataSize()->Size3 {
        fatalError()
    }
    
    /// Returns data position for the grid point at (0, 0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func dataOrigin()->Vector3F {
        fatalError()
    }
    
    /// Returns the grid data at given data point.
    subscript(i:size_t, j:size_t, k:size_t)->Vector3F{
        get{
            return _data[i, j, k]
        }
        set{
            _data[i, j, k] = newValue
        }
    }
    
    /// Returns divergence at data point location.
    func divergenceAtDataPoint(i:size_t, j:size_t, k:size_t)->Float {
        let ds:Size3 = _data.size()
        let gs:Vector3F = gridSpacing()
        
        VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
        
        let left:Float = _data[(i > 0) ? i - 1 : i, j, k].x
        let right:Float = _data[(i + 1 < ds.x) ? i + 1 : i, j, k].x
        let down:Float = _data[i, (j > 0) ? j - 1 : j, k].y
        let up:Float = _data[i, (j + 1 < ds.y) ? j + 1 : j, k].y
        let back:Float = _data[i, j, (k > 0) ? k - 1 : k].z
        let front:Float = _data[i, j, (k + 1 < ds.z) ? k + 1 : k].z
        
        return 0.5 * (right - left) / gs.x
            + 0.5 * (up - down) / gs.y
            + 0.5 * (front - back) / gs.z
    }
    
    /// Returns curl at data point location.
    func curlAtDataPoint(i:size_t, j:size_t, k:size_t)->Vector3F {
        let ds:Size3 = _data.size()
        let gs:Vector3F = gridSpacing()
        
        VOX_ASSERT(i < ds.x && j < ds.y && k < ds.z)
        
        let left:Vector3F = _data[(i > 0) ? i - 1 : i, j, k]
        let right:Vector3F = _data[(i + 1 < ds.x) ? i + 1 : i, j, k]
        let down:Vector3F = _data[i, (j > 0) ? j - 1 : j, k]
        let up:Vector3F = _data[i, (j + 1 < ds.y) ? j + 1 : j, k]
        let back:Vector3F = _data[i, j, (k > 0) ? k - 1 : k]
        let front:Vector3F = _data[i, j, (k + 1 < ds.z) ? k + 1 : k]
        
        let Fx_ym:Float = down.x
        let Fx_yp:Float = up.x
        let Fx_zm:Float = back.x
        let Fx_zp:Float = front.x
        
        let Fy_xm:Float = left.y
        let Fy_xp:Float = right.y
        let Fy_zm:Float = back.y
        let Fy_zp:Float = front.y
        
        let Fz_xm:Float = left.z
        let Fz_xp:Float = right.z
        let Fz_ym:Float = down.z
        let Fz_yp:Float = up.z
        
        return Vector3F(
            0.5 * (Fz_yp - Fz_ym) / gs.y - 0.5 * (Fy_zp - Fy_zm) / gs.z,
            0.5 * (Fx_zp - Fx_zm) / gs.z - 0.5 * (Fz_xp - Fz_xm) / gs.x,
            0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y)
    }
    
    /// Returns the read-write data array accessor.
    func dataAccessor()->ArrayAccessor3<Vector3F> {
        return _data.accessor()
    }
    
    /// Returns the read-only data array accessor.
    func constDataAccessor()->ConstArrayAccessor3<Vector3F> {
        return _data.constAccessor()
    }
    
    /// Returns the function that maps data point to its position.
    func dataPosition()->DataPositionFunc {
        let dataOrigin_:Vector3F = dataOrigin()
        return {(i:size_t, j:size_t, k:size_t) -> Vector3F in
            return dataOrigin_ + self.gridSpacing() * Vector3F(Float(i), Float(j), Float(k))
        }
    }
    
    /// Invokes the given function \p func for each data point.
    ///
    /// This function invokes the given function object \p func for each data
    /// point in serial manner. The input parameters are i and j indices of a
    /// data point. The order of execution is i-first, j-last.
    func forEachDataPointIndex(function:(size_t, size_t, size_t)->Void) {
        _data.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each data point parallelly.
    ///
    /// This function invokes the given function object \p func for each data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachDataPointIndex(function:(size_t, size_t, size_t)->Void) {
        _data.parallelForEachIndex(function)
    }
    
    /// Returns sampled value at given position \p x.
    override func sample(x:Vector3F)->Vector3F {
        return _sampler!(x)
    }
    
    /// Returns the sampler function.
    ///
    /// This function returns the data sampler function object. The sampling
    /// function is linear.
    func sampler()->(Vector3F)->Vector3F {
        return _sampler!
    }
    
    /// Returns divergence at given position \p x.
    func divergence(x:Vector3F)->Float {
        var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
        var weights = Array<Float>(repeating: 0, count: 8)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result:Float = 0.0
        
        for i in 0..<8 {
            result += weights[i] * divergenceAtDataPoint(
                i: indices[i].x, j: indices[i].y, k: indices[i].z)
        }
        
        return result
    }
    
    /// Returns curl at given position \p x.
    func curl(x:Vector3F)->Vector3F {
        var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
        var weights = Array<Float>(repeating: 0, count: 8)
        _linearSampler.getCoordinatesAndWeights(pt: x, indices: &indices, weights: &weights)
        
        var result:Vector3F = Vector3F()
        
        for i in 0..<8 {
            result += weights[i] * curlAtDataPoint(
                i: indices[i].x, j: indices[i].y, k: indices[i].z)
        }
        
        return result
    }
    
    /// Swaps the data storage and predefined samplers with given grid.
    func swapCollocatedVectorGrid(other: inout CollocatedVectorGrid3) {
        var father_grid = other as Grid3
        swapGrid(other: &father_grid)
        
        _data.swap(other: &other._data)
        Swift.swap(&_linearSampler, &other._linearSampler)
        Swift.swap(&_sampler, &other._sampler)
    }
    
    /// Sets the data storage and predefined samplers with given grid.
    func setCollocatedVectorGrid(other:CollocatedVectorGrid3) {
        setGrid(other: other)
        
        _data.set(other: other._data)
        resetSampler()
    }
    
    /// Fetches the data into a continuous linear array.
    override func getData(data: inout [Float]) {
        let size:size_t = 3 * dataSize().x * dataSize().y * dataSize().z
        data = Array<Float>(repeating: 0, count: size)
        var cnt:size_t = 0
        _data.forEach(){(value:Vector3F) in
            data[cnt] = value.x
            data[cnt] = value.y
            data[cnt] = value.z
            cnt += 1
        }
    }
    
    /// Sets the data from a continuous linear array.
    override func setData(data:[Float]) {
        VOX_ASSERT(3 * dataSize().x * dataSize().y * dataSize().z == data.count)
        
        var cnt:size_t = 0
        _data.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _data[i, j, k].x = data[cnt]
            _data[i, j, k].y = data[cnt]
            _data[i, j, k].z = data[cnt]
            cnt += 1
        }
    }
    
    override func onResize(resolution:Size3, gridSpacing:Vector3F,
                           origin:Vector3F, initialValue:Vector3F) {
        _data.resize(size: dataSize(), initVal: initialValue)
        resetSampler()
    }
    
    func resetSampler() {
        _linearSampler = LinearArraySampler3<Vector3F, Float>(
            accessor: _data.constAccessor(),
            gridSpacing: gridSpacing(),
            gridOrigin: dataOrigin())
        _sampler = _linearSampler.functor()
    }
}

//MARK:- GPU Method
extension CollocatedVectorGrid3 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_data._data!, offset: 0, index: index_begin)
        var buffer = Grid3Descriptor(_gridSpacing: _gridSpacing, _origin: _origin)
        encoder.setBytes(&buffer, length: MemoryLayout<Grid3Descriptor>.stride, index: index_begin+1)
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
        let threadsPerGrid = MTLSizeMake(dataSize().x, dataSize().y, dataSize().z)
        
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
