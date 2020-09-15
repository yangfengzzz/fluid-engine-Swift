//
//  array_accessor2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D array accessor class.
///
/// This class represents 2-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
/// Similar to Array<T, 2>, this class interprets a linear array as a 2-D array
/// using i-major indexing.
struct ArrayAccessor2<T:ZeroInit> {
    var _size:Size2 = Size2()
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 2-D array accessor.
    init() {}
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - size: Size of the 2-D array.
    ///   - data: Raw array pointer.
    init(size:Size2, data:UnsafeMutablePointer<T>?) {
        reset(size: size, data: data)
    }
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - width: Width of the 2-D array.
    ///   - height: Height of the 2-D array.
    ///   - data: Raw array pointer.
    init(width:size_t, height:size_t,
         data:UnsafeMutablePointer<T>?) {
        reset(width: width, height: height, data: data)
    }
    
    /// Copy constructor.
    init(other:ArrayAccessor2) {
        set(other: other)
    }
    
    /// Replaces the content with given \p other array accessor.
    mutating func set(other:ArrayAccessor2) {
        reset(size: other._size, data: other._data)
    }
    
    /// Resets the array.
    mutating func reset(size:Size2,
                        data:UnsafeMutablePointer<T>?) {
        self._size = size
        self._data = data
    }
    
    /// Resets the array.
    mutating func reset(width:size_t, height:size_t,
                        data:UnsafeMutablePointer<T>?) {
        reset(size: Size2(width, height), data: data)
    }
    
    /// Swaps the content of with \p other array accessor.
    mutating func swap(other: inout ArrayAccessor2) {
        Swift.swap(&other._data, &_data)
        Swift.swap(&other._size, &_size)
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    func at(pt:Point2UI)->T? {
        return at(i: pt.x, j: pt.y)
    }
    
    /// Returns the const reference to the element at (i, j).
    func at(i:size_t, j:size_t)->T? {
        return _data?.advanced(by: i + _size.x * j).pointee
    }
    
    /// Returns size of the array.
    func size()->Size2 {
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
    
    /// Returns the raw pointer to the array data.
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the linear index of the given 2-D coordinate (pt.x, pt.y).
    func index(pt:Point2UI)->size_t {
        return pt.x + _size.x * pt.y
    }
    
    /// Returns the linear index of the given 2-D coordinate (i, j).
    func index(i:size_t, j:size_t)->size_t {
        return i + _size.x * j
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
    
    /// Returns the reference to the element at (i, j).
    subscript(i:size_t, j:size_t)->T{
        get{
            return (_data?.advanced(by: i + _size.x * j).pointee)!
        }
        set{
            _data?.advanced(by: i + _size.x * j).pointee = newValue
        }
    }
    
    /// Returns the reference to the element at (pt.x, pt.y).
    subscript(pt:Point2UI)->T{
        get{
            return (_data?.advanced(by: pt.x + _size.x * pt.y).pointee)!
        }
        set{
            _data?.advanced(by: pt.x + _size.x * pt.y).pointee = newValue
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input.
    func forEach(_ function:ValueCallBack<T>) {
        for j in 0..<_size.y {
            for i in 0..<_size.x {
                function(at(i: i, j: j)!)
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes two parameters which are
    /// the (i, j) indices of the array.
    func forEachIndex(_ function:IndexCallBack2) {
        for j in 0..<_size.y {
            for i in 0..<_size.x {
                function(i, j)
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in parallel.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input. The order of execution will be non-deterministic since it runs in
    /// parallel.
    mutating func parallelForEach(_ function:ValueCallBackInout<T>) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y) {
                        (i:size_t, j:size_t) in
                        function(&self[i, j])
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes two parameters which are the (i, j) indices of the array.
    /// The order of execution will be non-deterministic since it runs in
    /// parallel.
    func parallelForEachIndex(_ function:IndexCallBack2) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y,
                    function: function)
    }
}

extension ArrayAccessor2: Sequence {
    typealias Iterator = ArrayAccessor2Iterator<T>
    func makeIterator()->Iterator {
        return ArrayAccessor2Iterator(b: _data, s: _size)
    }
}

struct ArrayAccessor2Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:Size2
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:Size2) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size.x * self.size.y {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}

//MARK:- ConstArrayAccessor2
/// 2-D read-only array accessor class.
///
/// This class represents 2-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support. Similar to Array2<T, 2>, this class interprets a linear array as a
/// 2-D array using i-major indexing.
struct ConstArrayAccessor2<T:ZeroInit> {
    var _size:Size2 = Size2()
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 2-D array accessor.
    init() {}
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - size: Size of the 2-D array.
    ///   - data: Raw array pointer.
    init(size:Size2, data:UnsafeMutablePointer<T>?) {
        _size = size
        _data = data
    }
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - width: Width of the 2-D array.
    ///   - height: Height of the 2-D array.
    ///   - data: Raw array pointer.
    init(width:size_t, height:size_t,
         data:UnsafeMutablePointer<T>?) {
        _size = Size2(width, height)
        _data = data
    }
    
    /// Copy constructor.
    init(other:ArrayAccessor2<T>) {
        _size = other.size()
        _data = other.data()
    }
    
    init(other:ConstArrayAccessor2) {
        _size = other._size
        _data = other._data
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    func at(pt:Point2UI)->T? {
        return at(i: pt.x, j: pt.y)
    }
    
    /// Returns the const reference to the element at (i, j).
    func at(i:size_t, j:size_t)->T? {
        return _data?.advanced(by: i + _size.x * j).pointee
    }
    
    /// Returns size of the array.
    func size()->Size2 {
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
    
    /// Returns the raw pointer to the array data.
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the linear index of the given 2-D coordinate (pt.x, pt.y).
    func index(pt:Point2UI)->size_t {
        return pt.x + _size.x * pt.y
    }
    
    /// Returns the linear index of the given 2-D coordinate (i, j).
    func index(i:size_t, j:size_t)->size_t {
        return i + _size.x * j
    }
    
    /// Returns the reference to i-th element.
    subscript(i:size_t)->T{
        get{
            return (_data?.advanced(by: i).pointee)!
        }
    }
    
    /// Returns the reference to the element at (i, j).
    subscript(i:size_t, j:size_t)->T{
        get{
            return (_data?.advanced(by: i + _size.x * j).pointee)!
        }
    }
    
    /// Returns the reference to the element at (pt.x, pt.y).
    subscript(pt:Point2UI)->T{
        get{
            return (_data?.advanced(by: pt.x + _size.x * pt.y).pointee)!
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input.
    func forEach(_ function:ValueCallBack<T>) {
        for j in 0..<_size.y {
            for i in 0..<_size.x {
                function(at(i: i, j: j)!)
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes two parameters which are
    /// the (i, j) indices of the array.
    func forEachIndex(_ function:IndexCallBack2) {
        for j in 0..<_size.y {
            for i in 0..<_size.x {
                function(i, j)
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes two parameters which are the (i, j) indices of the array.
    /// The order of execution will be non-deterministic since it runs in
    /// parallel.
    func parallelForEachIndex(_ function:IndexCallBack2) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y,
                    function: function)
    }
}

extension ConstArrayAccessor2: Sequence {
    typealias Iterator = ConstArrayAccessor2Iterator<T>
    func makeIterator()->Iterator {
        return ConstArrayAccessor2Iterator(b: _data, s: _size)
    }
}

struct ConstArrayAccessor2Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:Size2
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:Size2) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size.x * self.size.y {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}
