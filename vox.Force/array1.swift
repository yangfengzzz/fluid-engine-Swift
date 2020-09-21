//
//  array1.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/29.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 1-D array class.
///
/// This class represents 1-D array data structure. This class is a simple
/// wrapper around MTLBuffer with some additional features such as the array
/// accessor object and parallel for-loop.
struct Array1<T:ZeroInit> {
    var _data: MTLBuffer?
    var _size:size_t = 0
    
    //MARK:- Basic Setter
    /// Constructs zero-sized 1-D array.
    init(){}
    
    /// Constructs 1-D array with given \p size and fill it with \p initVal.
    /// - Parameters:
    ///   - size: Initial size of the array.
    ///   - initVal: Initial value of each array element.
    init(size:size_t, initVal:T = T()) {
        resize(size: size, initVal: initVal)
    }
    
    /// Constructs 1-D array with given initializer list \p lst.
    ///
    /// This constructor will build 1-D array with given initializer list \p lst
    /// - Parameter lst: lst Initializer list that should be copy to the new array.
    init(lst:[T]) {
        set(lst: lst)
    }
    
    /// Copy constructor.
    init(other:Array1) {
        set(other: other)
    }
    
    /// Sets entire array with given \p value.
    func set(value:T) {
        if _size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
            for _ in 0..<self._size {
                pointer.pointee = value
                pointer = pointer.advanced(by: 1)
            }
        }
    }
    
    /// Copies given initializer list \p lst to this array.
    mutating func set(lst:[T]) {
        resize(size: lst.count, initVal: T())
        
        if _size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
            for i in 0..<self._size {
                pointer.pointee = lst[i]
                pointer = pointer.advanced(by: 1)
            }
        }
    }
    
    /// Copies given array \p other to this array.
    mutating func set(other:Array1) {
        resize(size: other._size, initVal: T())
        
        if _size != 0 {
            var pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
            var pointerOther = other._data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
            for _ in 0..<self._size {
                pointer.pointee = pointerOther.pointee
                pointer = pointer.advanced(by: 1)
                pointerOther = pointerOther.advanced(by: 1)
            }
        }
    }
    
    /// Clears the array and resizes to zero.
    mutating func clear() {
        _size = 0
        _data = nil
    }
    
    /// Resizes the array with \p size and fill the new element with \p initVal.
    mutating func resize(size:size_t, initVal:T = T()){
        if size == 0 {
            self._size = 0
            self._data = nil
        } else if size < self._size {
            let bufferSize = MemoryLayout<T>.stride * size
            let new_data = Renderer.device.makeBuffer(length: bufferSize)!
            
            var pointer = new_data.contents()
                .bindMemory(to: T.self, capacity: size)
            for i in 0..<size {
                pointer.pointee = self[i]
                pointer = pointer.advanced(by: 1)
            }
            
            self._size = size
            self._data = new_data
        } else if size > self._size {
            let bufferSize = MemoryLayout<T>.stride * size
            let new_data = Renderer.device.makeBuffer(length: bufferSize)!
            
            var pointer = new_data.contents()
                .bindMemory(to: T.self, capacity: size)
            for i in 0..<size {
                if i < self._size {
                    pointer.pointee = self[i]
                } else {
                    pointer.pointee = initVal
                }
                pointer = pointer.advanced(by: 1)
            }
            
            self._size = size
            self._data = new_data
        }
    }
    
    /// Swaps the content of the array with \p other array.
    mutating func swap(other: inout Array1) {
        Swift.swap(&other._data, &_data)
        Swift.swap(&other._size, &_size)
    }
    
    /// Appends \p other array at the end of the array.
    mutating func append(other:[T]) {
        let new_size = _size + other.count
        let bufferSize = MemoryLayout<T>.stride * new_size
        let new_data = Renderer.device.makeBuffer(length: bufferSize)!
        
        var new_pointer = new_data.contents()
            .bindMemory(to: T.self, capacity: new_size)
        if _size != 0 {
            var old_pointer = _data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
            for _ in 0..<self._size {
                new_pointer.pointee = old_pointer.pointee
                new_pointer = new_pointer.advanced(by: 1)
                old_pointer = old_pointer.advanced(by: 1)
            }
        }
        
        for val in other {
            new_pointer.pointee = val
            new_pointer = new_pointer.advanced(by: 1)
        }
        
        self._size = new_size
        self._data = new_data
    }
    
    //MARK:- Basic Getter
    func at(i:size_t)->T {
        return _data!.contents()
            .bindMemory(to: T.self, capacity: self._size)
            .advanced(by: i)
            .pointee
    }
    
    /// Returns size of the array.
    func size()->size_t {
        return _size
    }
    
    /// Returns the raw pointer to the array data.
    func data()->MTLBuffer? {
        return _data
    }
    
    /// Returns the reference to i-th element.
    subscript(i:size_t)->T{
        get{
            return at(i: i)
        }
        set{
            _data!.contents()
                .bindMemory(to: T.self, capacity: self._size)
                .advanced(by: i)
                .pointee = newValue
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each element.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input. The order of execution will be 0 to N-1 where N is the size of
    /// the array.
    func forEach(_ function:ValueCallBack<T>) {
        constAccessor().forEach(function)
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes one parameter which is the
    /// index of the array. The order of execution will be 0 to N-1 where N is
    /// the size of the array.
    func forEachIndex(_ function:IndexCallBack) {
        constAccessor().forEachIndex(function)
    }
    
    /// Iterates the array and invoke given \p func for each element in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes array's element as its input. The order of execution will
    /// be non-deterministic since it runs in parallel.
    mutating func parallelForEach(_ function:ValueCallBackInout<T>) {
        parallelFor(beginIndex: 0, endIndex: _size) { (i:size_t) in
            function(&self[i])
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes one parameter which is the index of the array. The order
    /// of execution will be non-deterministic since it runs in parallel.
    func parallelForEachIndex(_ function:IndexCallBack) {
        constAccessor().parallelForEachIndex(function)
    }
    
    //MARK:- Array Accessor
    /// Returns the array accessor.
    func accessor()->ArrayAccessor1<T> {
        var pointer:UnsafeMutablePointer<T>? = nil
        if _data != nil {
            pointer = _data!.contents()
            .bindMemory(to: T.self, capacity: self._size)
        }
        return ArrayAccessor1<T>(size: size(), data: pointer)
    }
    
    /// Returns the const array accessor.
    func constAccessor()->ConstArrayAccessor1<T> {
        var pointer:UnsafeMutablePointer<T>? = nil
        if _data != nil {
            pointer = _data!.contents()
            .bindMemory(to: T.self, capacity: self._size)
        }
        return ConstArrayAccessor1<T>(size: size(), data: pointer)
    }
}

extension Array1: Sequence {
    typealias Iterator = Array1Iterator<T>
    func makeIterator()->Iterator {
        return Array1Iterator(b: self)
    }
}

struct Array1Iterator<T:ZeroInit>: IteratorProtocol {
    var data:Array1<T>
    var index = 0
    
    init(b:Array1<T>) {
        self.data = b
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < data._size {
            return data[index]
        } else {
            return nil
        }
    }
}

//MARK:- GPU Method
extension Array1 {
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
        let width = arrayPipelineState.threadExecutionWidth
        let threadsPerGroup = MTLSizeMake(width, 1, 1)
        let threadsPerGrid = MTLSizeMake(_size, 1, 1)
        
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
