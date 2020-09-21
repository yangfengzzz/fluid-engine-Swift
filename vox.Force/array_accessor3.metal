//
//  array_accessor3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_ACCESSOR3_METAL_
#define INCLUDE_VOX_ARRAY_ACCESSOR3_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_accessor.metal"
#include "macros.h"

//MARK: ArrayAccessor:-
///
/// \brief 3-D array accessor class.
///
/// This class represents 3-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
/// Similar to Array<T, 3>, this class interprets a linear array as a 3-D array
/// using i-major indexing.
///
/// \see Array<T, 3>
///
/// \tparam T - Array value type.
///
template <typename T>
class ArrayAccessor<T, 3> {
public:
    /// Constructs empty 3-D array accessor.
    ArrayAccessor();
    
    /// Constructs an array accessor that wraps given array.
    /// \param size Size of the 3-D array.
    /// \param data Raw array pointer.
    ArrayAccessor(const uint3 size, device T* const data);
    
    /// Constructs an array accessor that wraps given array.
    /// \param width Width of the 3-D array.
    /// \param height Height of the 3-D array.
    /// \param depth Depth of the 3-D array.
    /// \param data Raw array pointer.
    ArrayAccessor(size_t width, size_t height, size_t depth,
                  device T* const data);
    
    /// Copy constructor.
    ArrayAccessor(const thread ArrayAccessor& other);
    
    /// Replaces the content with given \p other array accessor.
    void set(const thread ArrayAccessor& other);
    
    /// Resets the array.
    void reset(const uint3 size, device T* const data);
    
    /// Resets the array.
    void reset(size_t width, size_t height, size_t depth,
               device T* const data);
    
    /// Returns the reference to the i-th element.
    device T& at(size_t i);
    
    /// Returns the const reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the reference to the element at (pt.x, pt.y, pt.z).
    device T& at(const uint3 pt);
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    const device T& at(const uint3 pt) const;
    
    /// Returns the reference to the element at (i, j, k).
    device T& at(size_t i, size_t j, size_t k);
    
    /// Returns the const reference to the element at (i, j, k).
    const device T& at(size_t i, size_t j, size_t k) const;
    
    /// Returns the begin iterator of the array.
    device T* const begin() const;
    
    /// Returns the end iterator of the array.
    device T* const end() const;
    
    /// Returns the begin iterator of the array.
    device T* begin();
    
    /// Returns the end iterator of the array.
    device T* end();
    
    /// Returns the size of the array.
    uint3 size() const;
    
    /// Returns the width of the array.
    size_t width() const;
    
    /// Returns the height of the array.
    size_t height() const;
    
    /// Returns the depth of the array.
    size_t depth() const;
    
    /// Returns the raw pointer to the array data.
    device T* const data() const;
    
    /// Swaps the content of with \p other array accessor.
    void swap(thread ArrayAccessor& other);
    
    /// Returns the linear index of the given 3-D coordinate (pt.x, pt.y, pt.z).
    size_t index(const uint3 pt) const;
    
    /// Returns the linear index of the given =3-D coordinate (i, j, k).
    size_t index(size_t i, size_t j, size_t k) const;
    
    /// Returns the reference to the i-th element.
    device T& operator[](size_t i);
    
    /// Returns the const reference to the i-th element.
    const device T& operator[](size_t i) const;
    
    /// Returns the reference to the element at (pt.x, pt.y, pt.z).
    device T& operator()(const uint3 pt);
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    const device T& operator()(const uint3 pt) const;
    
    /// Returns the reference to the element at (i, j, k).
    device T& operator()(size_t i, size_t j, size_t k);
    
    /// Returns the const reference to the element at (i, j, k).
    const device T& operator()(size_t i, size_t j, size_t k) const;
    
    /// Copies given array \p other to this array.
    thread ArrayAccessor& operator=(const thread ArrayAccessor& other);
    
    /// Casts type to ConstArrayAccessor.
    operator ConstArrayAccessor<T, 3>() const;
    
private:
    uint3 _size;
    device T* _data;
};

/// Type alias for 3-D array accessor.
template <typename T> using ArrayAccessor3 = ArrayAccessor<T, 3>;

//MARK: ConstArrayAccessor:-
///
/// \brief 3-D read-only array accessor class.
///
/// This class represents 3-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support.Similar to Array<T, 3>, this class interprets a linear array as a
/// 3-D array using i-major indexing.
///
/// \see Array<T, 3>
///
template <typename T>
class ConstArrayAccessor<T, 3> {
public:
    /// Constructs empty 3-D read-only array accessor.
    ConstArrayAccessor();
    
    /// Constructs a read-only array accessor that wraps given array.
    /// \param size Size of the 3-D array.
    /// \param data Raw array pointer.
    ConstArrayAccessor(const uint3 size, const device T* const data);
    
    /// Constructs a read-only array accessor that wraps given array.
    /// \param width Width of the 3-D array.
    /// \param height Height of the 3-D array.
    /// \param depth Depth of the 3-D array.
    /// \param data Raw array pointer.
    ConstArrayAccessor(size_t width, size_t height, size_t depth,
                       const device T* const data);
    
    /// Constructs a read-only array accessor from read/write accessor.
    explicit ConstArrayAccessor(const thread ArrayAccessor<T, 3>& other);
    
    /// Copy constructor.
    ConstArrayAccessor(const thread ConstArrayAccessor& other);
    
    /// Returns the const reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    const device T& at(const uint3 pt) const;
    
    /// Returns the const reference to the element at (i, j, k).
    const device T& at(size_t i, size_t j, size_t k) const;
    
    /// Returns the begin iterator of the array.
    const device T* const begin() const;
    
    /// Returns the end iterator of the array.
    const device T* const end() const;
    
    /// Returns the size of the array.
    uint3 size() const;
    
    /// Returns the width of the array.
    size_t width() const;
    
    /// Returns the height of the array.
    size_t height() const;
    
    /// Returns the depth of the array.
    size_t depth() const;
    
    /// Returns the raw pointer to the array data.
    const device T* const data() const;
    
    /// Returns the linear index of the given 3-D coordinate (pt.x, pt.y, pt.z).
    size_t index(const uint3 pt) const;
    
    /// Returns the linear index of the given =3-D coordinate (i, j, k).
    size_t index(size_t i, size_t j, size_t k) const;
    
    /// Returns the const reference to the i-th element.
    const device T& operator[](size_t i) const;
    
    /// Returns the const reference to the element at (pt.x, pt.y, pt.z).
    const device T& operator()(const uint3 pt) const;
    
    /// Returns the reference to the element at (i, j, k).
    const device T& operator()(size_t i, size_t j, size_t k) const;
    
private:
    uint3 _size;
    const device T* _data;
};

/// Type alias for 3-D const array accessor.
template <typename T> using ConstArrayAccessor3 = ConstArrayAccessor<T, 3>;

//MARK: Implementation-ArrayAccessor:-
template <typename T>
ArrayAccessor<T, 3>::ArrayAccessor() : _data(nullptr) {
}

template <typename T>
ArrayAccessor<T, 3>::ArrayAccessor(const uint3 size, device T* const data) {
    reset(size, data);
}

template <typename T>
ArrayAccessor<T, 3>::ArrayAccessor(
                                   size_t width, size_t height, size_t depth, device T* const data) {
    reset(width, height, depth, data);
}

template <typename T>
ArrayAccessor<T, 3>::ArrayAccessor(const thread ArrayAccessor& other) {
    set(other);
}

template <typename T>
void ArrayAccessor<T, 3>::set(const thread ArrayAccessor& other) {
    reset(other._size, other._data);
}

template <typename T>
void ArrayAccessor<T, 3>::reset(const uint3 size, device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
void ArrayAccessor<T, 3>::reset(
                                size_t width, size_t height, size_t depth, device T* const data) {
    reset(uint3(width, height, depth), data);
}

template <typename T>
device T& ArrayAccessor<T, 3>::at(size_t i) {
    VOX_ASSERT(i < _size.x*_size.y*_size.z);
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 3>::at(size_t i) const {
    VOX_ASSERT(i < _size.x*_size.y*_size.z);
    return _data[i];
}

template <typename T>
device T& ArrayAccessor<T, 3>::at(const uint3 pt) {
    return at(pt.x, pt.y, pt.z);
}

template <typename T>
const device T& ArrayAccessor<T, 3>::at(const uint3 pt) const {
    return at(pt.x, pt.y, pt.z);
}

template <typename T>
device T* const ArrayAccessor<T, 3>::begin() const {
    return _data;
}

template <typename T>
device T* const ArrayAccessor<T, 3>::end() const {
    return _data + _size.x * _size.y * _size.z;
}

template <typename T>
device T* ArrayAccessor<T, 3>::begin() {
    return _data;
}

template <typename T>
device T* ArrayAccessor<T, 3>::end() {
    return _data + _size.x * _size.y * _size.z;
}

template <typename T>
device T& ArrayAccessor<T, 3>::operator()(const uint3 pt) {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y && pt.z < _size.z);
    return _data[pt.x + _size.x * (pt.y + _size.y * pt.z)];
}

template <typename T>
const device T& ArrayAccessor<T, 3>::operator()(const uint3 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y && pt.z < _size.z);
    return _data[pt.x + _size.x * (pt.y + _size.y * pt.z)];
}

template <typename T>
device T& ArrayAccessor<T, 3>::at(size_t i, size_t j, size_t k) {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
const device T& ArrayAccessor<T, 3>::at(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
uint3 ArrayAccessor<T, 3>::size() const {
    return _size;
}

template <typename T>
size_t ArrayAccessor<T, 3>::width() const {
    return _size.x;
}

template <typename T>
size_t ArrayAccessor<T, 3>::height() const {
    return _size.y;
}

template <typename T>
size_t ArrayAccessor<T, 3>::depth() const {
    return _size.z;
}

template <typename T>
device T* const ArrayAccessor<T, 3>::data() const {
    return _data;
}

template <typename T>
void ArrayAccessor<T, 3>::swap(thread ArrayAccessor& other) {
    uint3 tmp_size = other._size;
    device T* tmp_data = other._data;
    
    other._data = _data;
    other._size = _size;
    _data = tmp_data;
    _size = tmp_size;
}

template <typename T>
size_t ArrayAccessor<T, 3>::index(const uint3 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y && pt.z < _size.z);
    return pt.x + _size.x * (pt.y + _size.y * pt.z);
}

template <typename T>
size_t ArrayAccessor<T, 3>::index(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return i + _size.x * (j + _size.y * k);
}

template <typename T>
device T& ArrayAccessor<T, 3>::operator[](size_t i) {
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 3>::operator[](size_t i) const {
    return _data[i];
}

template <typename T>
device T& ArrayAccessor<T, 3>::operator()(size_t i, size_t j, size_t k) {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
const device T& ArrayAccessor<T, 3>::operator()(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
thread ArrayAccessor<T, 3>& ArrayAccessor<T, 3>::operator=(
                                                           const thread ArrayAccessor& other) {
    set(other);
    return *this;
}

template <typename T>
ArrayAccessor<T, 3>::operator ConstArrayAccessor<T, 3>() const {
    return ConstArrayAccessor<T, 3>(*this);
}

//MARK: Implementation-ConstArrayAccessor:-
template <typename T>
ConstArrayAccessor<T, 3>::ConstArrayAccessor() : _data(nullptr) {
}

template <typename T>
ConstArrayAccessor<T, 3>::ConstArrayAccessor(
                                             const uint3 size, const device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
ConstArrayAccessor<T, 3>::ConstArrayAccessor(
                                             size_t width, size_t height, size_t depth, const device T* const data) {
    _size = uint3(width, height, depth);
    _data = data;
}

template <typename T>
ConstArrayAccessor<T, 3>::ConstArrayAccessor(const thread ArrayAccessor<T, 3>& other) {
    _size = other.size();
    _data = other.data();
}

template <typename T>
ConstArrayAccessor<T, 3>::ConstArrayAccessor(const thread ConstArrayAccessor& other) {
    _size = other._size;
    _data = other._data;
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::at(size_t i) const {
    VOX_ASSERT(i < _size.x*_size.y*_size.z);
    return _data[i];
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::at(const uint3 pt) const {
    return at(pt.x, pt.y, pt.z);
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::at(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
const device T* const ConstArrayAccessor<T, 3>::begin() const {
    return _data;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 3>::end() const {
    return _data + _size.x * _size.y * _size.z;
}

template <typename T>
uint3 ConstArrayAccessor<T, 3>::size() const {
    return _size;
}

template <typename T>
size_t ConstArrayAccessor<T, 3>::width() const {
    return _size.x;
}

template <typename T>
size_t ConstArrayAccessor<T, 3>::height() const {
    return _size.y;
}

template <typename T>
size_t ConstArrayAccessor<T, 3>::depth() const {
    return _size.z;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 3>::data() const {
    return _data;
}

template <typename T>
size_t ConstArrayAccessor<T, 3>::index(const uint3 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y && pt.z < _size.z);
    return pt.x + _size.x * (pt.y + _size.y * pt.z);
}

template <typename T>
size_t ConstArrayAccessor<T, 3>::index(size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return i + _size.x * (j + _size.y * k);
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::operator[](size_t i) const {
    return _data[i];
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::operator()(
                                                     size_t i, size_t j, size_t k) const {
    VOX_ASSERT(i < _size.x && j < _size.y && k < _size.z);
    return _data[i + _size.x * (j + _size.y * k)];
}

template <typename T>
const device T& ConstArrayAccessor<T, 3>::operator()(const uint3 pt) const {
    VOX_ASSERT(pt.x < _size.x && pt.y < _size.y && pt.z < _size.z);
    return _data[pt.x + _size.x * (pt.y + _size.y * pt.z)];
}

#endif  // INCLUDE_VOX_ARRAY_ACCESSOR3_METAL_
