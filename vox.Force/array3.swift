//
//  array3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D array class.
///
/// This class represents 3-D array data structure. Internally, the 3-D data is
/// mapped to a linear array such that (i, j, k) element is actually stroed at
/// (i + width * (j + height * k))th element of the linear array. This mapping
/// means iterating i first, j and k next will give better performance such as:
struct Array3<T:ZeroInit> {
    var _data: MTLBuffer?
    var _size:Size3 = Size3()
    
    //MARK:- Basic Setter
    /// Constructs zero-sized 3-D array.
    init(){}
    
    /// Constructs 3-D array with given \p size and fill it with \p initVal.
    /// - Parameters:
    ///   - size: Initial size of the array.
    ///   - initVal: Initial value of each array element.
    init(size:Size3, initVal:T = T()) {
        resize(size: size, initVal: initVal)
    }
    
    /// Constructs 3-D array with size \p width x \p height x \p depth and fill it with \p initVal.
    /// - Parameters:
    ///   - width: Initial width of the array.
    ///   - height: Initial height of the array.
    ///   - depth: Initial depth of the array.
    ///   - initVal: Initial value of each array element.
    init(width:size_t, height:size_t,
         depth:size_t, initVal:T = T()) {
        resize(width: width, height: height,
               depth:depth, initVal: initVal)
    }
    
    /// Constructs 3-D array with given initializer list \p lst.
    ///
    /// This constructor will build 3-D array with given initializer list \p lst
    /// - Parameter lst: Initializer list that should be copy to the new array.
    init(lst:[[[T]]]) {
        set(lst: lst)
    }
    
    /// Copy constructor.
    init(other:Array3) {
        set(other: other)
    }
    
    /// Sets entire array with given \p value.
    func set(value:T) {
        let data_size = self._size.x * self._size.y * self._size.z
        
        if data_size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self,
                            capacity: data_size)
            for _ in 0..<data_size {
                pointer.pointee = value
                pointer = pointer.advanced(by: 1)
            }
        }
    }
    
    /// Copies given array \p other to this array.
    mutating func set(other:Array3) {
        resize(size: other._size, initVal: T())
        let data_size = self._size.x * self._size.y * self._size.z
        
        if data_size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self,
                            capacity: data_size)
            var pointerOther = other._data!.contents()
                .bindMemory(to: T.self,
                            capacity: data_size)
            for _ in 0..<data_size {
                pointer.pointee = pointerOther.pointee
                pointer = pointer.advanced(by: 1)
                pointerOther = pointerOther.advanced(by: 1)
            }
        }
    }
    
    /// Copies given initializer list \p lst to this array.
    ///
    /// This function copies given initializer list \p lst to the array
    /// - Parameter lst: Initializer list that should be copy to the new array.
    mutating func set(lst:[[[T]]]) {
        let depth = lst.count
        let height = (depth > 0) ? lst[0].count : 0
        let width = (height > 0) ? lst[0][0].count : 0
        resize(size: Size3(width, height, depth), initVal: T())
        let data_size = self._size.x * self._size.y * self._size.z
        
        if data_size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self,
                            capacity: data_size)
            for k in 0..<depth {
                for j in 0..<height {
                    for i in 0..<width {
                        pointer.pointee = lst[k][j][i]
                        pointer = pointer.advanced(by: 1)
                    }
                }
            }
        }
    }
    
    /// Clears the array and resizes to zero.
    mutating func clear() {
        _size = Size3()
        _data = nil
    }
    
    /// Resizes the array with \p size and fill the new element with \p initVal.
    mutating func resize(size:Size3, initVal:T = T()) {
        let data_size = size.x * size.y * size.z
        if data_size == 0 {
            self._size = Size3()
            self._data = nil
        } else if data_size != self._size.x * self._size.y * self._size.z {
            let bufferSize = MemoryLayout<T>.stride * data_size
            let new_data = Renderer.device.makeBuffer(length: bufferSize)!
            
            var pointer = new_data.contents()
                .bindMemory(to: T.self, capacity: data_size)
            for k in 0..<size.z {
                for j in 0..<size.y {
                    for i in 0..<size.x {
                        if i < self._size.x && j < self._size.y && k < self._size.z {
                            pointer.pointee = self[i, j, k]
                        } else {
                            pointer.pointee = initVal
                        }
                        pointer = pointer.advanced(by: 1)
                    }
                }
            }
            
            self._size = size
            self._data = new_data
        }
    }
    
    /// Resizes the array with size \p width x \p height and fill the new
    /// element with \p initVal.
    mutating func resize(width:size_t, height:size_t,
                         depth:size_t, initVal:T = T()) {
        resize(size: Size3(width, height, depth), initVal: initVal)
    }
    
    /// Swaps the content of the array with \p other array.
    mutating func swap(other: inout Array3) {
        Swift.swap(&other._data, &_data)
        Swift.swap(&other._size, &_size)
    }
    
    //MARK:- Basic Getter
    
    /// Returns the reference to the i-th element.
    ///
    /// This function returns the reference to the i-th element of the array
    /// where i is the index of linearly mapped elements such that
    /// i = x + width * (y + height * z) (x, y and z are the 3-D coordinates of
    /// the element).
    func at(i:size_t)->T {
        return _data!.contents()
            .bindMemory(to: T.self,
                        capacity: self._size.x * self._size.y * self._size.z)
            .advanced(by: i)
            .pointee
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    func at(pt:Point3UI)->T {
        return at(i: pt.x, j: pt.y, k: pt.z)
    }
    
    /// Returns the const reference to the element at (i, j, k).
    func at(i:size_t, j:size_t, k:size_t)->T {
        return _data!.contents()
            .bindMemory(to: T.self,
                        capacity: self._size.x * self._size.y * self._size.z)
            .advanced(by: i + _size.x * (j + _size.y * k))
            .pointee
    }
    
    /// Returns size of the array.
    func size()->Size3 {
        return _size
    }
    
    /// Returns the width of the array.
    func width()->size_t {
        return _size.x
    }
    
    /// Returns the height of the array.
    func height()->size_t {
        return _size.y
    }
    
    /// Returns the depth of the array.
    func depth()->size_t {
        return _size.z
    }
    
    /// Returns the raw pointer to the array data.
    func data()->MTLBuffer? {
        return _data
    }
    
    /// Returns the reference to the i-th element.
    ///
    /// This function returns the reference to the i-th element of the array
    /// where i is the index of linearly mapped elements such that
    /// i = x + width * (y + height * z) (x, y and z are the 3-D coordinates of
    /// the element).
    subscript(i:size_t)->T{
        get{
            return at(i: i)
        }
        set{
            _data!.contents()
                .bindMemory(to: T.self,
                            capacity: self._size.x * self._size.y * self._size.z)
                .advanced(by: i)
                .pointee = newValue
        }
    }
    
    /// Returns the reference to the element at (i, j, k).
    subscript(i:size_t, j:size_t, k:size_t)->T{
        get{
            return at(i: i, j: j, k: k)
        }
        set{
            _data!.contents()
                .bindMemory(to: T.self,
                            capacity: self._size.x * self._size.y * self._size.z)
                .advanced(by: i + _size.x * (j + _size.y * k))
                .pointee = newValue
        }
    }
    
    /// Returns the reference to the element at (pt.x, pt.y, pt.z).
    subscript(pt:Point3UI)->T{
        get{
            return at(pt: pt)
        }
        set{
            _data!.contents()
                .bindMemory(to: T.self,
                            capacity: self._size.x * self._size.y * self._size.z)
                .advanced(by: pt.x + _size.x * (pt.y + _size.y * pt.z))
                .pointee = newValue
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input.
    func forEach(_ function:ValueCallBack<T>) {
        constAccessor().forEach(function)
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes two parameters which are
    /// the (i, j) indices of the array.
    func forEachIndex(_ function:IndexCallBack3) {
        constAccessor().forEachIndex(function)
    }
    
    /// Iterates the array and invoke given \p func for each index in parallel.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input. The order of execution will be non-deterministic since it runs in
    /// parallel.
    mutating func parallelForEach(_ function:ValueCallBackInout<T>) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y,
                    beginIndexZ: 0, endIndexZ: _size.z) {
                        (i:size_t, j:size_t, k:size_t) in
                        function(&self[i, j, k])
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes two parameters which are the (i, j, k) indices of the
    /// array. The order of execution will be non-deterministic since it runs in
    /// parallel. Below is the sample usage:
    func parallelForEachIndex(_ function:IndexCallBack3) {
        constAccessor().parallelForEachIndex(function)
    }
    
    //MARK:- Array Accessor
    /// Returns the array accessor.
    func accessor()->ArrayAccessor3<T> {
        var pointer:UnsafeMutablePointer<T>? = nil
        if _data != nil {
            pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size.x * self._size.y * self._size.z)
        }
        return ArrayAccessor3<T>(size: size(), data: pointer)
    }
    
    /// Returns the const array accessor.
    func constAccessor()->ConstArrayAccessor3<T> {
        var pointer:UnsafeMutablePointer<T>? = nil
        if _data != nil {
            pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size.x * self._size.y * self._size.z)
        }
        return ConstArrayAccessor3<T>(size: size(), data: pointer)
    }
}

extension Array3: Sequence {
    typealias Iterator = Array3Iterator<T>
    func makeIterator()->Iterator {
        return Array3Iterator(b: self)
    }
}

struct Array3Iterator<T:ZeroInit>: IteratorProtocol {
    var data:Array3<T>
    var index = 0
    
    init(b:Array3<T>) {
        self.data = b
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < data._size.x * data._size.y * data._size.z {
            return data[index]
        } else {
            return nil
        }
    }
}

//MARK:- GPU Method
extension Array3 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        if _data != nil {
            encoder.setBuffer(_data!, offset: 0, index: index_begin)
            return index_begin + 1
        } else {
            return index_begin
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    mutating func parallelForEachIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
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
        let threadsPerGrid = MTLSizeMake(_size.x, _size.y, _size.z)
        
        computeEncoder.setBuffer(_data, offset: 0, index: 0)
        
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
