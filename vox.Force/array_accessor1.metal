//
//  array_accessor1.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_ACCESSOR1_METAL_
#define INCLUDE_VOX_ARRAY_ACCESSOR1_METAL_

#include <metal_stdlib>
using namespace metal;
#include "array_accessor.metal"
#include "macros.h"

//MARK: ArrayAccessor:-
///
/// \brief 1-D array accessor class.
///
/// This class represents 1-D array accessor. Array accessor provides array-like
/// data read/write functions, but does not handle memory management. Thus, it
/// is more like a random access iterator, but with multi-dimension support.
///
/// \see Array1<T, 2>
///
/// \tparam T - Array value type.
///
template <typename T>
class ArrayAccessor<T, 1> final {
public:
    /// Constructs empty 1-D array accessor.
    ArrayAccessor();
    
    /// Constructs an array accessor that wraps given array.
    ArrayAccessor(size_t size, device T* const data);
    
    /// Copy constructor.
    ArrayAccessor(const thread ArrayAccessor& other);
    
    /// Replaces the content with given \p other array accessor.
    void set(const thread ArrayAccessor& other);
    
    /// Resets the array.
    void reset(size_t size, device T* const data);
    
    /// Returns the reference to the i-th element.
    device T& at(size_t i);
    
    /// Returns the const reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the begin iterator of the array.
    device T* const begin() const;
    
    /// Returns the end iterator of the array.
    device T* const end() const;
    
    /// Returns the begin iterator of the array.
    device T* begin();
    
    /// Returns the end iterator of the array.
    device T* end();
    
    /// Returns size of the array.
    size_t size() const;
    
    /// Returns the raw pointer to the array data.
    device T* const data() const;
    
    /// Swaps the content of with \p other array accessor.
    void swap(thread ArrayAccessor& other);
    
    /// Returns the reference to i-th element.
    device T& operator[](size_t i);
    
    /// Returns the const reference to i-th element.
    const device T& operator[](size_t i) const;
    
    /// Copies given array accessor \p other.
    thread ArrayAccessor& operator=(const thread ArrayAccessor& other);
    
    /// Casts type to ConstArrayAccessor.
    operator ConstArrayAccessor<T, 1>() const;
    
private:
    size_t _size;
    device T* _data;
};

/// Type alias for 1-D array accessor.
template <typename T> using ArrayAccessor1 = ArrayAccessor<T, 1>;

//MARK: ConstArrayAccessor:-
///
/// \brief 1-D read-only array accessor class.
///
/// This class represents 1-D read-only array accessor. Array accessor provides
/// array-like data read/write functions, but does not handle memory management.
/// Thus, it is more like a random access iterator, but with multi-dimension
/// support.
///
template <typename T>
class ConstArrayAccessor<T, 1> {
public:
    /// Constructs empty 1-D array accessor.
    ConstArrayAccessor();
    
    /// Constructs an read-only array accessor that wraps given array.
    ConstArrayAccessor(size_t size, const device T* const data);
    
    /// Constructs a read-only array accessor from read/write accessor.
    explicit ConstArrayAccessor(const thread ArrayAccessor<T, 1>& other);
    
    /// Copy constructor.
    ConstArrayAccessor(const thread ConstArrayAccessor& other);
    
    /// Returns the const reference to the i-th element.
    const device T& at(size_t i) const;
    
    /// Returns the begin iterator of the array.
    const device T* const begin() const;
    
    /// Returns the end iterator of the array.
    const device T* const end() const;
    
    /// Returns size of the array.
    size_t size() const;
    
    /// Returns the raw pointer to the array data.
    const device T* const data() const;
    
    /// Returns the const reference to i-th element.
    const device T& operator[](size_t i) const;
    
private:
    size_t _size;
    const device T* _data;
};

/// Type alias for 1-D const array accessor.
template <typename T> using ConstArrayAccessor1 = ConstArrayAccessor<T, 1>;

//MARK: Implementation:-ArrayAccessor:-
template <typename T>
ArrayAccessor<T, 1>::ArrayAccessor() : _size(0), _data(nullptr) {
}

template <typename T>
ArrayAccessor<T, 1>::ArrayAccessor(size_t size, device T* const data) {
    reset(size, data);
}

template <typename T>
ArrayAccessor<T, 1>::ArrayAccessor(const thread ArrayAccessor& other) {
    set(other);
}

template <typename T>
void ArrayAccessor<T, 1>::set(const thread ArrayAccessor& other) {
    reset(other._size, other._data);
}

template <typename T>
void ArrayAccessor<T, 1>::reset(size_t size, device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
device T& ArrayAccessor<T, 1>::at(size_t i) {
    VOX_ASSERT(i < _size);
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 1>::at(size_t i) const {
    VOX_ASSERT(i < _size);
    return _data[i];
}

template <typename T>
device T* const ArrayAccessor<T, 1>::begin() const {
    return _data;
}

template <typename T>
device T* const ArrayAccessor<T, 1>::end() const {
    return _data + _size;
}

template <typename T>
device T* ArrayAccessor<T, 1>::begin() {
    return _data;
}

template <typename T>
device T* ArrayAccessor<T, 1>::end() {
    return _data + _size;
}

template <typename T>
size_t ArrayAccessor<T, 1>::size() const {
    return _size;
}

template <typename T>
device T* const ArrayAccessor<T, 1>::data() const {
    return _data;
}

template <typename T>
void ArrayAccessor<T, 1>::swap(thread ArrayAccessor& other) {
    size_t tmp_size = other._size;
    device T* tmp_data = other._data;
    
    other._data = _data;
    other._size = _size;
    _data = tmp_data;
    _size = tmp_size;
}

template <typename T>
device T& ArrayAccessor<T, 1>::operator[](size_t i) {
    return _data[i];
}

template <typename T>
const device T& ArrayAccessor<T, 1>::operator[](size_t i) const {
    return _data[i];
}

template <typename T>
thread ArrayAccessor<T, 1>&
ArrayAccessor<T, 1>::operator=(const thread ArrayAccessor& other) {
    set(other);
    return *this;
}

template <typename T>
ArrayAccessor<T, 1>::operator ConstArrayAccessor<T, 1>() const {
    return ConstArrayAccessor<T, 1>(*this);
}

//MARK: Implementation:-ConstArrayAccessor:-
template <typename T>
ConstArrayAccessor<T, 1>::ConstArrayAccessor() : _size(0), _data(nullptr) {
}

template <typename T>
ConstArrayAccessor<T, 1>::ConstArrayAccessor(
                                             size_t size, const device T* const data) {
    _size = size;
    _data = data;
}

template <typename T>
ConstArrayAccessor<T, 1>::ConstArrayAccessor(const thread ArrayAccessor<T, 1>& other) {
    _size = other.size();
    _data = other.data();
}

template <typename T>
ConstArrayAccessor<T, 1>::ConstArrayAccessor(const thread ConstArrayAccessor& other) {
    _size = other._size;
    _data = other._data;
}

template <typename T>
const device T& ConstArrayAccessor<T, 1>::at(size_t i) const {
    VOX_ASSERT(i < _size);
    return _data[i];
}

template <typename T>
const device T* const ConstArrayAccessor<T, 1>::begin() const {
    return _data;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 1>::end() const {
    return _data + _size;
}

template <typename T>
size_t ConstArrayAccessor<T, 1>::size() const {
    return _size;
}

template <typename T>
const device T* const ConstArrayAccessor<T, 1>::data() const {
    return _data;
}

template <typename T>
const device T& ConstArrayAccessor<T, 1>::operator[](size_t i) const {
    return _data[i];
}

#endif  // INCLUDE_VOX_ARRAY_ACCESSOR1_METAL_
