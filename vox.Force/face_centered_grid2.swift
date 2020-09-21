//
//  face_centered_grid2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D face-centered (a.k.a MAC or staggered) grid.
///
/// This class implements face-centered grid which is also known as
/// marker-and-cell (MAC) or staggered grid. This vector grid stores each vector
/// component at face center. Thus, u and v components are not collocated.
final class FaceCenteredGrid2: VectorGrid2 {
    var _dataU = Array2<Float>()
    var _dataV = Array2<Float>()
    var _dataOriginU = Vector2F()
    var _dataOriginV = Vector2F()
    var _uLinearSampler:LinearArraySampler2<Float, Float>
    var _vLinearSampler:LinearArraySampler2<Float, Float>
    var _sampler:((Vector2F)->Vector2F)?
    
    /// Returns the type name of derived grid.
    override func typeName()->String {
        return "FaceCenteredGrid2"
    }
    
    /// Constructs empty grid.
    override init() {
        self._dataOriginU = Vector2F(0.0, 0.5)
        self._dataOriginV = Vector2F(0.5, 0.0)
        self._uLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginV)
    }
    
    /// Resizes the grid using given parameters.
    convenience init(resolutionX:size_t, resolutionY:size_t,
                     gridSpacingX:Float = 1.0, gridSpacingY:Float = 1.0,
                     originX:Float = 0.0, originY:Float = 0.0,
                     initialValueU:Float = 0.0, initialValueV:Float = 0.0) {
        self.init(resolution: Size2(resolutionX, resolutionY),
                  gridSpacing: Vector2F(gridSpacingX, gridSpacingY),
                  origin: Vector2F(originX, originY),
                  initialValue: Vector2F(initialValueU, initialValueV))
    }
    
    /// Resizes the grid using given parameters.
    init(resolution:Size2,
         gridSpacing:Vector2F = Vector2F(1.0, 1.0),
         origin:Vector2F = Vector2F(),
         initialValue:Vector2F = Vector2F()) {
        self._uLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginV)
        super.init()
        resize(resolution: resolution,
               gridSpacing: gridSpacing,
               origin: origin,
               initialValue: initialValue)
    }
    
    /// Copy constructor.
    init(other:FaceCenteredGrid2) {
        self._uLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector2F(1, 1),
            gridOrigin: _dataOriginV)
        super.init()
        set(other: other)
    }
    
    /// Swaps the contents with the given \p other grid.
    ///
    /// This function swaps the contents of the grid instance with the given
    /// grid object \p other only if \p other has the same type with this grid.
    override func swap(other: inout Grid2) {
        let sameType = other as? FaceCenteredGrid2
        
        if (sameType != nil) {
            var father_grid = sameType! as Grid2
            swapGrid(other: &father_grid)
            
            _dataU.swap(other: &sameType!._dataU)
            _dataV.swap(other: &sameType!._dataV)
            Swift.swap(&_dataOriginU, &sameType!._dataOriginU)
            Swift.swap(&_dataOriginV, &sameType!._dataOriginV)
            Swift.swap(&_uLinearSampler, &sameType!._uLinearSampler)
            Swift.swap(&_vLinearSampler, &sameType!._vLinearSampler)
            Swift.swap(&_sampler, &sameType!._sampler)
        }
    }
    
    /// Sets the contents with the given \p other grid.
    func set(other:FaceCenteredGrid2) {
        setGrid(other: other)
        
        _dataU.set(other: other._dataU)
        _dataV.set(other: other._dataV)
        _dataOriginU = other._dataOriginU
        _dataOriginV = other._dataOriginV
        
        resetSampler()
    }
    
    /// Returns u-value at given data point.
    func u(i:size_t, j:size_t)->Float {
        return _dataU[i, j]
    }
    
    /// Returns u-value at given data point.
    func u(i:size_t, j:size_t, val:Float) {
        _dataU[i, j] = val
    }
    
    /// Returns v-value at given data point.
    func v(i:size_t, j:size_t)->Float {
        return _dataV[i, j]
    }
    
    /// Returns v-value at given data point.
    func v(i:size_t, j:size_t, val:Float) {
        _dataV[i, j] = val
    }
    
    /// Returns interpolated value at cell center.
    func valueAtCellCenter(i:size_t, j:size_t)->Vector2F {
        VOX_ASSERT(i < resolution().x && j < resolution().y)
        
        return 0.5 * Vector2F(_dataU[i, j] + _dataU[i + 1, j],
                              _dataV[i, j] + _dataV[i, j + 1])
    }
    
    /// Returns divergence at cell-center location.
    func divergenceAtCellCenter(i:size_t, j:size_t)->Float {
        VOX_ASSERT(i < resolution().x && j < resolution().y)
        
        let gs:Vector2F = gridSpacing()
        
        let leftU = _dataU[i, j]
        let rightU = _dataU[i + 1, j]
        let bottomV = _dataV[i, j]
        let topV = _dataV[i, j + 1]
        
        return (rightU - leftU) / gs.x + (topV - bottomV) / gs.y
    }
    
    ///  Returns curl at cell-center location.
    func curlAtCellCenter(i:size_t, j:size_t)->Float {
        let res:Size2 = resolution()
        
        VOX_ASSERT(i < res.x && j < res.y)
        
        let gs:Vector2F = gridSpacing()
        
        let left = valueAtCellCenter(i: (i > 0) ? i - 1 : i, j: j)
        let right = valueAtCellCenter(i: (i + 1 < res.x) ? i + 1 : i, j: j)
        let bottom = valueAtCellCenter(i: i, j: (j > 0) ? j - 1 : j)
        let top = valueAtCellCenter(i: i, j: (j + 1 < res.y) ? j + 1 : j)
        
        let Fx_ym = bottom.x
        let Fx_yp = top.x
        
        let Fy_xm = left.y
        let Fy_xp = right.y
        
        return 0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y
    }
    
    /// Returns u data accessor.
    func uAccessor()->ArrayAccessor2<Float> {
        return _dataU.accessor()
    }
    
    /// Returns read-only u data accessor.
    func uConstAccessor()->ConstArrayAccessor2<Float> {
        return _dataU.constAccessor()
    }
    
    /// Returns v data accessor.
    func vAccessor()->ArrayAccessor2<Float> {
        return _dataV.accessor()
    }
    
    /// Returns read-only v data accessor.
    func vConstAccessor()->ConstArrayAccessor2<Float> {
        return _dataV.constAccessor()
    }
    
    /// Returns function object that maps u data point to its actual position.
    func uPosition()->DataPositionFunc {
        let h = gridSpacing()
        
        return {(i:size_t, j:size_t) -> Vector2F in
            return self._dataOriginU + h * Vector2F(Float(i), Float(j))
        }
    }
    
    /// Returns function object that maps v data point to its actual position.
    func vPosition()->DataPositionFunc {
        let h = gridSpacing()
        
        return {(i:size_t, j:size_t) -> Vector2F in
            return self._dataOriginV + h * Vector2F(Float(i), Float(j))
        }
    }
    
    /// Returns data size of the u component.
    func uSize()->Size2 {
        return _dataU.size()
    }
    
    /// Returns data size of the v component.
    func vSize()->Size2 {
        return _dataV.size()
    }
    
    /// Returns u-data position for the grid point at (0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func uOrigin()->Vector2F {
        return _dataOriginU
    }
    
    /// Returns v-data position for the grid point at (0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func vOrigin()->Vector2F {
        return _dataOriginV
    }
    
    /// Returns the copy of the grid instance.
    override func clone()->VectorGrid2 {
        return FaceCenteredGrid2(other: self)
    }
    
    /// Fills the grid with given value.
    override func fill(value:Vector2F,
                       policy:ExecutionPolicy = .kParallel) {
        parallelFor(beginIndexX: 0, endIndexX: _dataU.width(),
                    beginIndexY: 0, endIndexY: _dataU.height(),
                    function: {(i:size_t, j:size_t) in
                        _dataU[i, j] = value.x
                    }, policy: policy)
        
        parallelFor(beginIndexX: 0, endIndexX: _dataV.width(),
                    beginIndexY: 0, endIndexY: _dataV.height(),
                    function: {(i:size_t, j:size_t) in
                        _dataV[i, j] = value.y
                    }, policy: policy)
    }
    
    /// Fills the grid with given position-to-value mapping function.
    override func fill(function:(Vector2F)->Vector2F,
                       policy:ExecutionPolicy = .kParallel) {
        let uPos = uPosition()
        parallelFor(beginIndexX: 0, endIndexX: _dataU.width(),
                    beginIndexY: 0, endIndexY: _dataU.height(),
                    function: {(i:size_t, j:size_t) in
                        _dataU[i, j] = function(uPos(i, j)).x
                    }, policy: policy)
        
        let vPos = vPosition()
        parallelFor(beginIndexX: 0, endIndexX: _dataV.width(),
                    beginIndexY: 0, endIndexY: _dataV.height(),
                    function: {(i:size_t, j:size_t) in
                        _dataV[i, j] = function(vPos(i, j)).y
                    }, policy: policy)
    }
    
    /// Invokes the given function \p func for each u-data point.
    ///
    /// This function invokes the given function object \p func for each u-data
    /// point in serial manner. The input parameters are i and j indices of a
    /// u-data point. The order of execution is i-first, j-last.
    func forEachUIndex(function:(size_t, size_t)->Void) {
        _dataU.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each u-data point
    /// parallelly.
    ///
    /// This function invokes the given function object \p func for each u-data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// u-data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachUIndex(function:(size_t, size_t)->Void) {
        _dataU.parallelForEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in serial manner. The input parameters are i and j indices of a
    /// v-data point. The order of execution is i-first, j-last.
    func forEachVIndex(function:(size_t, size_t)->Void) {
        _dataV.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point parallelly.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// v-data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachVIndex(function:(size_t, size_t)->Void) {
        _dataV.parallelForEachIndex(function)
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
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:Float = 0, fy:Float = 0
        let cellCenterOrigin = origin() + 0.5 * gridSpacing()
        
        let normalizedX = (x - cellCenterOrigin) / gridSpacing()
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: resolution().x - 1,
                            i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: resolution().y - 1,
                            i: &j, f: &fy)
        
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(i + 1, j)
        indices[2] = Point2UI(i, j + 1)
        indices[3] = Point2UI(i + 1, j + 1)
        
        weights[0] = (1.0 - fx) * (1.0 - fy)
        weights[1] = fx * (1.0 - fy)
        weights[2] = (1.0 - fx) * fy
        weights[3] = fx * fy
        
        var result:Float = 0.0
        
        for n in 0..<4 {
            result += weights[n] * divergenceAtCellCenter(i: indices[n].x, j: indices[n].y)
        }
        
        return result
    }
    
    /// Returns curl at given position \p x.
    func curl(x:Vector2F)->Float {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:Float = 0, fy:Float = 0
        let cellCenterOrigin = origin() + 0.5 * gridSpacing()
        
        let normalizedX = (x - cellCenterOrigin) / gridSpacing()
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: resolution().x - 1,
                            i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: resolution().y - 1,
                            i: &j, f: &fy)
        
        var indices = Array<Point2UI>(repeating: Point2UI(), count: 4)
        var weights = Array<Float>(repeating: 0, count: 4)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(i + 1, j)
        indices[2] = Point2UI(i, j + 1)
        indices[3] = Point2UI(i + 1, j + 1)
        
        weights[0] = (1.0 - fx) * (1.0 - fy)
        weights[1] = fx * (1.0 - fy)
        weights[2] = (1.0 - fx) * fy
        weights[3] = fx * fy
        
        var result:Float = 0.0
        
        for n in 0..<4 {
            result += weights[n] * curlAtCellCenter(i: indices[n].x, j: indices[n].y)
        }
        
        return result
    }
    
    override func onResize(resolution:Size2, gridSpacing:Vector2F,
                           origin:Vector2F, initialValue:Vector2F) {
        if (resolution != Size2(0, 0)) {
            _dataU.resize(size: resolution &+ Size2(1, 0), initVal: initialValue.x)
            _dataV.resize(size: resolution &+ Size2(0, 1), initVal: initialValue.y)
        } else {
            _dataU.resize(size: Size2(0, 0))
            _dataV.resize(size: Size2(0, 0))
        }
        _dataOriginU = origin + 0.5 * Vector2F(0.0, gridSpacing.y)
        _dataOriginV = origin + 0.5 * Vector2F(gridSpacing.x, 0.0)
        
        resetSampler()
    }
    
    /// Fetches the data into a continuous linear array.
    override func getData(data: inout [Float]) {
        let size = uSize().x * uSize().y + vSize().x * vSize().y
        data = Array<Float>(repeating: 0, count: size)
        var cnt:size_t = 0
        _dataU.forEach(){(value:Float) in
            data[cnt] = value
            cnt += 1
        }
        _dataV.forEach(){(value:Float) in
            data[cnt] = value
            cnt += 1
        }
    }
    
    /// Sets the data from a continuous linear array.
    override func setData(data:[Float]) {
        VOX_ASSERT(uSize().x * uSize().y + vSize().x * vSize().y == data.count)
        
        var cnt:size_t = 0
        _dataU.forEachIndex(){(i:size_t, j:size_t) in
            _dataU[i, j] = data[cnt]
            cnt += 1
        }
        _dataV.forEachIndex(){(i:size_t, j:size_t) in
            _dataV[i, j] = data[cnt]
            cnt += 1
        }
    }
    
    func resetSampler() {
        let uSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: gridSpacing(), gridOrigin: _dataOriginU)
        let vSampler = LinearArraySampler2<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: gridSpacing(), gridOrigin: _dataOriginV)
        
        _uLinearSampler = uSampler
        _vLinearSampler = vSampler
        
        _sampler = {(x:Vector2F) -> Vector2F in
            let u = uSampler[pt: x]
            let v = vSampler[pt: x]
            return Vector2F(u, v)
        }
    }
    
    //MARK:- Builder
    class Builder: VectorGridBuilder2 {
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
        func withResolution(resolutionX:size_t,
                            resolutionY:size_t)->Builder {
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
        func withGridSpacing(gridSpacingX:Float,
                             gridSpacingY:Float)->Builder {
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
        func withOrigin(gridOriginX:Float,
                        gridOriginY:Float)->Builder {
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
        func withInitialValue(initialValX:Float,
                              initialValY:Float)->Builder {
            _initialVal.x = initialValX
            _initialVal.y = initialValY
            return self
        }
        
        /// Builds FaceCenteredGrid2 instance.
        func build()->FaceCenteredGrid2 {
            return FaceCenteredGrid2(resolution: _resolution,
                                     gridSpacing: _gridSpacing,
                                     origin: _gridOrigin,
                                     initialValue: _initialVal)
        }
        
        
        /// Builds shared pointer of FaceCenteredGrid2 instance.
        ///
        /// This is an overriding function that implements VectorGridBuilder2.
        func build(resolution: Size2,
                   gridSpacing: Vector2F,
                   gridOrigin: Vector2F,
                   initialVal: Vector2F) -> VectorGrid2 {
            return FaceCenteredGrid2(resolution: resolution,
                                     gridSpacing: gridSpacing,
                                     origin: gridOrigin,
                                     initialValue: initialVal)
        }
    }
    
    /// Returns builder fox FaceCenteredGrid2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension FaceCenteredGrid2 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataU._data!, offset: 0, index: index_begin)
        encoder.setBuffer(_dataV._data!, offset: 0, index: index_begin+1)
        var buffer = Grid2Descriptor(_gridSpacing: _gridSpacing, _origin: _origin)
        encoder.setBytes(&buffer, length: MemoryLayout<Grid2Descriptor>.stride, index: index_begin+2)
        return index_begin + 3
    }
    
    func loadUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataU._data!, offset: 0, index: index_begin)
        return index_begin + 1
    }
    
    func loadVBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataV._data!, offset: 0, index: index_begin)
        return index_begin + 1
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachUIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
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
        let threadsPerGrid = MTLSizeMake(uSize().x, uSize().y, 1)
        
        computeEncoder.setBuffer(_dataU._data!, offset: 0, index: 0)
        
        //Other Variables
        var index:Int = 1
        callBack(&computeEncoder, &index)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachVIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
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
        let threadsPerGrid = MTLSizeMake(vSize().x, vSize().y, 1)
        
        computeEncoder.setBuffer(_dataV._data!, offset: 0, index: 0)
        
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
