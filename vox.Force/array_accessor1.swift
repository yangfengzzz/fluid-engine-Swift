//
//  array_accessor1.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

typealias ValueCallBack<T> = (T)->Void
typealias ValueCallBackInout<T> = (inout T)->Void

/// 1-D array accessor class.
///
/// This class represents 1-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
struct ArrayAccessor1<T:ZeroInit> {
    var _size:size_t = 0
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 1-D array accessor.
    init() {}
    
    /// Constructs an array accessor that wraps given array.
    init(size:size_t, data:UnsafeMutablePointer<T>?) {
        reset(size: size, data: data)
    }
    
    /// Copy constructor.
    init(other:ArrayAccessor1) {
        set(other: other)
    }
    
    /// Replaces the content with given \p other array accessor.
    mutating func set(other:ArrayAccessor1) {
        reset(size: other._size, data: other._data)
    }
    
    /// Resets the array.
    mutating func reset(size:size_t, data:UnsafeMutablePointer<T>?) {
        self._size = size
        self._data = data
    }
    
    /// Swaps the content of with \p other array accessor.
    mutating func swap(other: inout ArrayAccessor1) {
        Swift.swap(&other._data, &_data)
        Swift.swap(&other._size, &_size)
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns size of the array.
    func size()->size_t {
        return _size
    }
    
    /// Returns the raw pointer to the array data.
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the reference to i-th element.
    subscript(i:size_t)->T{
        get{
            return (_data?.advanced(by: i).pointee)!
        }
        set{
            _data?.advanced(by: i).pointee = newValue
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
        for i in 0..<_size {
            function(at(i: i)!)
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes one parameter which is the
    /// index of the array. The order of execution will be 0 to N-1 where N is
    /// the size of the array.
    func forEachIndex(_ function:IndexCallBack) {
        for i in 0..<_size {
            function(i)
        }
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
        parallelFor(beginIndex: 0, endIndex: _size, function: function)
    }
}

extension ArrayAccessor1: Sequence {
    typealias Iterator = ArrayAccessor1Iterator<T>
    func makeIterator()->Iterator {
        return ArrayAccessor1Iterator(b: _data, s: _size)
    }
}

struct ArrayAccessor1Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:size_t
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:size_t) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}

//MARK:- ConstArrayAccessor1
/// 1-D read-only array accessor class.
///
/// This class represents 1-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support.
struct ConstArrayAccessor1<T:ZeroInit> {
    var _size:size_t = 0
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 1-D array accessor.
    init() {}
    
    /// Constructs an read-only array accessor that wraps given array.
    init(size:size_t, data:UnsafeMutablePointer<T>?) {
        _size = size
        _data = data
    }
    
    /// Constructs a read-only array accessor from read/write accessor.
    init(other:ArrayAccessor1<T>) {
        _size = other.size()
        _data = other.data()
    }
    
    /// Copy constructor.
    init(other:ConstArrayAccessor1) {
        _size = other._size
        _data = other._data
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns size of the array.
    func size()->size_t {
        return _size
    }
    
    /// Returns the raw pointer to the array data.
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the reference to i-th element.
    subscript(i:size_t)->T{
        get{
            return (_data?.advanced(by: i).pointee)!
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
        var pointer = _data
        for _ in 0..<_size {
            function(pointer!.pointee)
            pointer = pointer!.advanced(by: 1)
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes one parameter which is the
    /// index of the array. The order of execution will be 0 to N-1 where N is
    /// the size of the array.
    func forEachIndex(_ function:IndexCallBack) {
        for i in 0..<_size {
            function(i)
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
        parallelFor(beginIndex: 0, endIndex: _size, function: function)
    }
}

extension ConstArrayAccessor1: Sequence {
    typealias Iterator = ConstArrayAccessor1Iterator<T>
    func makeIterator()->Iterator {
        return ConstArrayAccessor1Iterator(b: _data, s: _size)
    }
}

struct ConstArrayAccessor1Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:size_t
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:size_t) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}
