//
//  array_accessor3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D array accessor class.
///
/// This class represents 3-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
/// Similar to Array<T, 3>, this class interprets a linear array as a 3-D array
/// using i-major indexing.
struct ArrayAccessor3<T:ZeroInit> {
    var _size:Size3 = Size3()
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 3-D array accessor.
    init() {}
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - size: Size of the 3-D array.
    ///   - data: Raw array pointer.
    init(size:Size3, data:UnsafeMutablePointer<T>?) {
        reset(size: size, data: data)
    }
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - width: Width of the 3-D array.
    ///   - height: Height of the 3-D array.
    ///   - depth: Depth of the 3-D array.
    ///   - data: Raw array pointer.
    init(width:size_t, height:size_t, depth:size_t,
         data:UnsafeMutablePointer<T>?) {
        reset(width: width, height: height, depth: depth, data: data)
    }
    
    /// Copy constructor.
    init(other:ArrayAccessor3) {
        set(other: other)
    }
    
    /// Replaces the content with given \p other array accessor.
    mutating func set(other:ArrayAccessor3) {
        reset(size: other._size, data: other._data)
    }
    
    /// Resets the array.
    mutating func reset(size:Size3,
                        data:UnsafeMutablePointer<T>?) {
        self._size = size
        self._data = data
    }
    
    /// Resets the array.
    mutating func reset(width:size_t, height:size_t, depth:size_t,
                        data:UnsafeMutablePointer<T>?) {
        reset(size: Size3(width, height, depth), data: data)
    }
    
    /// Swaps the content of with \p other array accessor.
    mutating func swap(other: inout ArrayAccessor3) {
        Swift.swap(&other._data, &_data)
        Swift.swap(&other._size, &_size)
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    func at(pt:Point3UI)->T? {
        return at(i: pt.x, j: pt.y, k: pt.z)
    }
    
    /// Returns the const reference to the element at (i, j, k).
    func at(i:size_t, j:size_t, k:size_t)->T? {
        return _data?.advanced(by: i + _size.x * (j + _size.y * k)).pointee
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
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the linear index of the given 3-D coordinate (pt.x, pt.y, pt.z).
    func index(pt:Point3UI)->size_t {
        return pt.x + _size.x * (pt.y + _size.y * pt.z)
    }
    
    /// Returns the linear index of the given 3-D coordinate (i, j, k).
    func index(i:size_t, j:size_t, k:size_t)->size_t {
        return i + _size.x * (j + _size.y * k)
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
    
    /// Returns the const reference to the element at (i, j, k).
    subscript(i:size_t, j:size_t, k:size_t)->T{
        get{
            return (_data?.advanced(by: i + _size.x * (j + _size.y * k)).pointee)!
        }
        set{
            _data?.advanced(by: i + _size.x * (j + _size.y * k)).pointee = newValue
        }
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    subscript(pt:Point3UI)->T{
        get{
            return (_data?.advanced(by: pt.x + _size.x * (pt.y + _size.y * pt.z)).pointee)!
        }
        set{
            _data?.advanced(by: pt.x + _size.x * (pt.y + _size.y * pt.z)).pointee = newValue
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input.
    func forEach(_ function:ValueCallBack<T>) {
        for k in 0..<_size.z {
            for j in 0..<_size.y {
                for i in 0..<_size.x {
                    function(at(i: i, j: j, k: k)!)
                }
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes two parameters which are
    /// the (i, j) indices of the array.
    func forEachIndex(_ function:IndexCallBack3) {
        for k in 0..<_size.z {
            for j in 0..<_size.y {
                for i in 0..<_size.x {
                    function(i, j, k)
                }
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
    /// parallel.
    func parallelForEachIndex(_ function:IndexCallBack3) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y,
                    beginIndexZ: 0, endIndexZ: _size.z,
                    function: function)
    }
}

extension ArrayAccessor3: Sequence {
    typealias Iterator = ArrayAccessor3Iterator<T>
    func makeIterator()->Iterator {
        return ArrayAccessor3Iterator(b: _data, s: _size)
    }
}

struct ArrayAccessor3Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:Size3
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:Size3) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size.x * self.size.y * self.size.z {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}

//MARK:- ConstArrayAccessor3
/// 3-D read-only array accessor class.
///
/// This class represents 3-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support.Similar to Array<T, 3>, this class interprets a linear array as a
/// 3-D array using i-major indexing.
struct ConstArrayAccessor3<T:ZeroInit> {
    var _size:Size3 = Size3()
    var _data:UnsafeMutablePointer<T>?
    
    //MARK:- Basic Setter
    /// Constructs empty 3-D array accessor.
    init() {}
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - size: Size of the 3-D array.
    ///   - data: Raw array pointer.
    init(size:Size3, data:UnsafeMutablePointer<T>?) {
        _size = size
        _data = data
    }
    
    /// Constructs an array accessor that wraps given array.
    /// - Parameters:
    ///   - width: Width of the 3-D array.
    ///   - height: Height of the 3-D array.
    ///   - depth: Depth of the 3-D array.
    ///   - data: Raw array pointer.
    init(width:size_t, height:size_t, depth:size_t,
         data:UnsafeMutablePointer<T>?) {
        _size = Size3(width, height, depth)
        _data = data
    }
    
    /// Constructs a read-only array accessor from read/write accessor.
    init(other:ArrayAccessor3<T>) {
        _size = other.size()
        _data = other.data()
    }
    
    /// Copy constructor.
    init(other:ConstArrayAccessor3) {
        _size = other._size;
        _data = other._data
    }
    
    //MARK:- Basic Getter
    /// Returns the const reference to the i-th element.
    func at(i:size_t)->T? {
        return _data?.advanced(by: i).pointee
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    func at(pt:Point3UI)->T? {
        return at(i: pt.x, j: pt.y, k: pt.z)
    }
    
    /// Returns the const reference to the element at (i, j, k).
    func at(i:size_t, j:size_t, k:size_t)->T? {
        return _data?.advanced(by: i + _size.x * (j + _size.y * k)).pointee
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
    func data()->UnsafeMutablePointer<T>? {
        return _data
    }
    
    /// Returns the linear index of the given 3-D coordinate (pt.x, pt.y, pt.z).
    func index(pt:Point3UI)->size_t {
        return pt.x + _size.x * (pt.y + _size.y * pt.z)
    }
    
    /// Returns the linear index of the given 3-D coordinate (i, j, k).
    func index(i:size_t, j:size_t, k:size_t)->size_t {
        return i + _size.x * (j + _size.y * k)
    }
    
    /// Returns the reference to i-th element.
    subscript(i:size_t)->T{
        get{
            return (_data?.advanced(by: i).pointee)!
        }
    }
    
    /// Returns the const reference to the element at (i, j, k).
    subscript(i:size_t, j:size_t, k:size_t)->T{
        get{
            return (_data?.advanced(by: i + _size.x * (j + _size.y * k)).pointee)!
        }
    }
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    subscript(pt:Point3UI)->T{
        get{
            return (_data?.advanced(by: pt.x + _size.x * (pt.y + _size.y * pt.z)).pointee)!
        }
    }
    
    //MARK:- Array Loop
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes array's element as its
    /// input.
    func forEach(_ function:ValueCallBack<T>) {
        for k in 0..<_size.z {
            for j in 0..<_size.y {
                for i in 0..<_size.x {
                    function(at(i: i, j: j, k: k)!)
                }
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func. The callback function takes two parameters which are
    /// the (i, j) indices of the array.
    func forEachIndex(_ function:IndexCallBack3) {
        for k in 0..<_size.z {
            for j in 0..<_size.y {
                for i in 0..<_size.x {
                    function(i, j, k)
                }
            }
        }
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using multi-threading.
    ///
    /// This function iterates the array elements and invoke the callback
    /// function \p func in parallel using multi-threading. The callback
    /// function takes two parameters which are the (i, j, k) indices of the
    /// array. The order of execution will be non-deterministic since it runs in
    /// parallel.
    func parallelForEachIndex(_ function:IndexCallBack3) {
        parallelFor(beginIndexX: 0, endIndexX: _size.x,
                    beginIndexY: 0, endIndexY: _size.y,
                    beginIndexZ: 0, endIndexZ: _size.z,
                    function: function)
    }
}

extension ConstArrayAccessor3: Sequence {
    typealias Iterator = ConstArrayAccessor3Iterator<T>
    func makeIterator()->Iterator {
        return ConstArrayAccessor3Iterator(b: _data, s: _size)
    }
}

struct ConstArrayAccessor3Iterator<T:ZeroInit>: IteratorProtocol {
    var data:UnsafeMutablePointer<T>?
    var size:Size3
    var index = 0
    
    init(b:UnsafeMutablePointer<T>?, s:Size3) {
        self.data = b
        self.size = s
    }
    
    typealias Element = T
    public mutating func next()->T? {
        defer {
            index += 1
        }
        
        if index < self.size.x * self.size.y * self.size.z {
            return self.data?.advanced(by: index).pointee
        } else {
            return nil
        }
    }
}
