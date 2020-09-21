//
//  array_accessor2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_ACCESSOR2_METAL_
#define INCLUDE_VOX_ARRAY_ACCESSOR2_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_accessor.metal"
#include "macros.h"

//MARK: ArrayAccessor:-
///
/// \brief 2-D array accessor class.
///
/// This class represents 2-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
/// Similar to Array<T, 2>, this class interprets a linear array as a 2-D array
/// using i-major indexing.
///
/// \see Array<T, 2>
///
/// \tparam T - Array value type.
///
template <typename T>
class ArrayAccessor<T, 2> {
public:
    /// Constructs empty 2-D array accessor.
    ArrayAccessor();
    
    /// Constructs an array accessor that wraps given array.
    /// \param size Size of the 2-D array.
    /// \param data Raw array pointer.
    ArrayAccessor(const uint2 size, device T* const data);
    
    /// Constructs an array accessor that wraps given array.
    /// \param width Width of the 2-D array.
    /// \param height Height of the 2-D array.
    /// \param data Raw array pointer.
    ArrayAccessor(size_t width, size_t height, device T* const data);
    
    /// Copy constructor.
    ArrayAccessor(const thread ArrayAccessor& other);
    
    /// Replaces the content with given \p other array accessor.
    void set(const thread ArrayAccessor& other);
    
    /// Resets the array.
    void reset(const uint2 size, device T* const data);
    
    /// Resets the array.
    void reset(size_t width, size_t height, device T* const data);
    
    /// Returns the reference to the i-th element.
    device T& at(size_t i);
    
    /// Returns the const reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the reference to the element at (pt.x, pt.y).
    device T& at(const uint2 pt);
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    const device T& at(const uint2 pt) const;
    
    /// Returns the reference to the element at (i, j).
    device T& at(size_t i, size_t j);
    
    /// Returns the const reference to the element at (i, j).
    const device T& at(size_t i, size_t j) const;
    
    /// Returns the begin iterator of the array.
    device T* const begin() const;
    
    /// Returns the end iterator of the array.
    device T* const end() const;
    
    /// Returns the begin iterator of the array.
    device T* begin();
    
    /// Returns the end iterator of the array.
    device T* end();
    
    /// Returns the size of the array.
    uint2 size() const;
    
    /// Returns the width of the array.
    size_t width() const;
    
    /// Returns the height of the array.
    size_t height() const;
    
    /// Returns the raw pointer to the array data.
    device T* const data() const;
    
    /// Swaps the content of with \p other array accessor.
    void swap(thread ArrayAccessor& other);
    
    /// Returns the linear index of the given 2-D coordinate (pt.x, pt.y).
    size_t index(const uint2 pt) const;
    
    /// Returns the linear index of the given 2-D coordinate (i, j).
    size_t index(size_t i, size_t j) const;
    
    /// Returns the reference to the i-th element.
    device T& operator[](size_t i);
    
    /// Returns the const reference to the i-th element.
    const device T& operator[](size_t i) const;
    
    /// Returns the reference to the element at (pt.x, pt.y).
    device T& operator()(const uint2 pt);
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    const device T& operator()(const uint2 pt) const;
    
    /// Returns the reference to the element at (i, j).
    device T& operator()(size_t i, size_t j);
    
    /// Returns the const reference to the element at (i, j).
    const device T& operator()(size_t i, size_t j) const;
    
    /// Copies given array accessor \p other.
    thread ArrayAccessor& operator=(const thread ArrayAccessor& other);
    
    /// Casts type to ConstArrayAccessor.
    operator ConstArrayAccessor<T, 2>() const;
    
private:
    uint2 _size;
    device T* _data;
};

/// Type alias for 2-D array accessor.
template <typename T> using ArrayAccessor2 = ArrayAccessor<T, 2>;

//MARK: ConstArrayAccessor:-
///
/// \brief 2-D read-only array accessor class.
///
/// This class represents 2-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support. Similar to Array2<T, 2>, this class interprets a linear array as a
/// 2-D array using i-major indexing.
///
/// \see Array2<T, 2>
///
template <typename T>
class ConstArrayAccessor<T, 2> {
public:
    /// Constructs empty 2-D read-only array accessor.
    ConstArrayAccessor();
    
    /// Constructs a read-only array accessor that wraps given array.
    /// \param size Size of the 2-D array.
    /// \param data Raw array pointer.
    ConstArrayAccessor(const uint2 size, const device T* const data);
    
    /// Constructs an array accessor that wraps given array.
    /// \param width Width of the 2-D array.
    /// \param height Height of the 2-D array.
    /// \param data Raw array pointer.
    ConstArrayAccessor(size_t width, size_t height, const device T* const data);
    
    /// Constructs a read-only array accessor from read/write accessor.
    explicit ConstArrayAccessor(const thread ArrayAccessor<T, 2>& other);
    
    /// Copy constructor.
    ConstArrayAccessor(const thread ConstArrayAccessor& other);
    
    /// Returns the reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    const device T& at(const uint2 pt) const;
    
    /// Returns the const reference to the element at (i, j).
    const device T& at(size_t i, size_t j) const;
    
    /// Returns the begin iterator of the array.
    const device T* const begin() const;
    
    /// Returns the end iterator of the array.
    const device T* const end() const;
    
    /// Returns the size of the array.
    uint2 size() const;
    
    /// Returns the width of the array.
    size_t width() const;
    
    /// Returns the height of the array.
    size_t height() const;
    
    /// Returns the raw pointer to the array data.
    const device T* const data() const;
    
    /// Returns the linear index of the given 2-D coordinate (pt.x, pt.y).
    size_t index(const uint2 pt) const;
    
    /// Returns the linear index of the given 2-D coordinate (i, j).
    size_t index(size_t i, size_t j) const;
    
    /// Returns the const reference to the i-th element.
    const device T& operator[](size_t i) const;
    
    /// Returns the const reference to the element at (pt.x, pt.y).
    const device T& operator()(const uint2 pt) const;
    
    /// Returns the const reference to the element at (i, j).
    const device T& operator()(size_t i, size_t j) const;
    
private:
    uint2 _size;
    const device T* _data;
};

/// Type alias for 2-D const array accessor.
template <typename T> using ConstArrayAccessor2 = ConstArrayAccessor<T, 2>;

//MARK: Implementation-ArrayAccessor:-
template <typename T>
ArrayAccessor<T, 2>::ArrayAccessor() : _data(nullptr) {
}

template <typename T>
ArrayAccessor<T, 2>::ArrayAccessor(const uint2 size, device T* const data) {
    reset(size, data);
}

template <typename T>
ArrayAccessor<T, 2>::ArrayAccessor(size_t width, size_t height, device T* const data) {
    reset(width, height, data);
}

template <typename T>
ArrayAccessor<T, 2>::ArrayAccessor(const thread ArrayAccessor& other) {
    set(other);
}

template <typename T>
void ArrayAccessor<T, 2>::set(const thread ArrayAccessor& other) {
    reset(other._size, other._data);
}

template <typename T>
void ArrayAccessor<T, 2>::reset(const uint2 size, device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
void ArrayAccessor<T, 2>::reset(size_t width, size_t height, device T* const data) {
    reset(uint2(width, height), data);
}

template <typename T>
device T& ArrayAccessor<T, 2>::at(size_t i) {
    VOX_ASSERT(i < _size.x*_size.y);
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 2>::at(size_t i) const {
    VOX_ASSERT(i < _size.x*_size.y);
    return _data[i];
}

template <typename T>
device T& ArrayAccessor<T, 2>::at(const uint2 pt) {
    return at(pt.x, pt.y);
}

template <typename T>
const device T& ArrayAccessor<T, 2>::at(const uint2 pt) const {
    return at(pt.x, pt.y);
}

template <typename T>
device T& ArrayAccessor<T, 2>::at(size_t i, size_t j) {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

template <typename T>
const device T& ArrayAccessor<T, 2>::at(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

template <typename T>
device T* const ArrayAccessor<T, 2>::begin() const {
    return _data;
}

template <typename T>
device T* const ArrayAccessor<T, 2>::end() const {
    return _data + _size.x * _size.y;
}

template <typename T>
device T* ArrayAccessor<T, 2>::begin() {
    return _data;
}

template <typename T>
device T* ArrayAccessor<T, 2>::end() {
    return _data + _size.x * _size.y;
}

template <typename T>
uint2 ArrayAccessor<T, 2>::size() const {
    return _size;
}

template <typename T>
size_t ArrayAccessor<T, 2>::width() const {
    return _size.x;
}

template <typename T>
size_t ArrayAccessor<T, 2>::height() const {
    return _size.y;
}

template <typename T>
device T* const ArrayAccessor<T, 2>::data() const {
    return _data;
}

template <typename T>
void ArrayAccessor<T, 2>::swap(thread ArrayAccessor& other) {
    uint2 tmp_size = other._size;
    device T* tmp_data = other._data;
    
    other._data = _data;
    other._size = _size;
    _data = tmp_data;
    _size = tmp_size;
}

template <typename T>
size_t ArrayAccessor<T, 2>::index(const uint2 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y);
    return pt.x + _size.x * pt.y;
}

template <typename T>
size_t ArrayAccessor<T, 2>::index(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return i + _size.x * j;
}

template <typename T>
device T& ArrayAccessor<T, 2>::operator[](size_t i) {
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 2>::operator[](size_t i) const {
    return _data[i];
}

template <typename T>
device T& ArrayAccessor<T, 2>::operator()(const uint2 pt) {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y);
    return _data[pt.x + _size.x * pt.y];
}

template <typename T>
const device T& ArrayAccessor<T, 2>::operator()(const uint2 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y);
    return _data[pt.x + _size.x * pt.y];
}

template <typename T>
device T& ArrayAccessor<T, 2>::operator()(size_t i, size_t j) {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

template <typename T>
const device T& ArrayAccessor<T, 2>::operator()(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

template <typename T>
thread ArrayAccessor<T, 2>& ArrayAccessor<T, 2>::operator=(
                                                           const thread ArrayAccessor& other) {
    set(other);
    return *this;
}

template <typename T>
ArrayAccessor<T, 2>::operator ConstArrayAccessor<T, 2>() const {
    return ConstArrayAccessor<T, 2>(*this);
}

//MARK: Implementation-ConstArrayAccessor:-
template <typename T>
ConstArrayAccessor<T, 2>::ConstArrayAccessor() : _data(nullptr) {
}

template <typename T>
ConstArrayAccessor<T, 2>::ConstArrayAccessor(
                                             const uint2 size, const device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
ConstArrayAccessor<T, 2>::ConstArrayAccessor(
                                             size_t width, size_t height, const device T* const data) {
    _size = uint2(width, height);
    _data = data;
}

template <typename T>
ConstArrayAccessor<T, 2>::ConstArrayAccessor(const thread ArrayAccessor<T, 2>& other) {
    _size = other.size();
    _data = other.data();
}

template <typename T>
ConstArrayAccessor<T, 2>::ConstArrayAccessor(const thread ConstArrayAccessor& other) {
    _size = other._size;
    _data = other._data;
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::at(size_t i) const {
    VOX_ASSERT(i < _size.x*_size.y);
    return _data[i];
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::at(const uint2 pt) const {
    return at(pt.x, pt.y);
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::at(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

template <typename T>
const device T* const ConstArrayAccessor<T, 2>::begin() const {
    return _data;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 2>::end() const {
    return _data + _size.x * _size.y;
}

template <typename T>
uint2 ConstArrayAccessor<T, 2>::size() const {
    return _size;
}

template <typename T>
size_t ConstArrayAccessor<T, 2>::width() const {
    return _size.x;
}

template <typename T>
size_t ConstArrayAccessor<T, 2>::height() const {
    return _size.y;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 2>::data() const {
    return _data;
}

template <typename T>
size_t ConstArrayAccessor<T, 2>::index(const uint2 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y);
    return pt.x + _size.x * pt.y;
}

template <typename T>
size_t ConstArrayAccessor<T, 2>::index(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return i + _size.x * j;
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::operator[](size_t i) const {
    return _data[i];
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::operator()(const uint2 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y);
    return _data[pt.x + _size.x * pt.y];
}

template <typename T>
const device T& ConstArrayAccessor<T, 2>::operator()(size_t i, size_t j) const {
    VOX_ASSERT(i < _size.x && j < _size.y);
    return _data[i + _size.x * j];
}

#endif  // INCLUDE_VOX_ARRAY_ACCESSOR2_METAL_
