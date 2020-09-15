//
//  array_accessor.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_ARRAY_ACCESSOR_METAL_
#define INCLUDE_VOX_ARRAY_ACCESSOR_METAL_

#include <metal_stdlib>
using namespace metal;

//!
/// \brief Generic N-dimensional array accessor class interface.
//!
/// This class provides generic template class for N-dimensional array accessor
/// where N must be either 1, 2 or 3. This particular class exists to provide
/// generic interface for 1, 2 or 3 dimensional arrays using template
/// specialization only, but it cannot create any instance by itself.
/// Array accessor provides array-like data read/write functions, but does not
/// handle memory management. Thus, it is more like a random access iterator,
/// but with multi-dimension support.
//!
/// \tparam T - Real number type.
/// \tparam N - Dimension.
//!
template <typename T, size_t N>
class ArrayAccessor {
public:
    static_assert(
                  N < 1 || N > 3, "Not implemented - N should be either 1, 2 or 3.");
};

//!
/// \brief Generic N-dimensional read-only array accessor class interface.
//!
/// This class provides generic template class for N-dimensional read-only array
/// accessor where N must be either 1, 2 or 3. This particular class exists to
/// provide generic interface for 1, 2 or 3 dimensional arrays using template
/// specialization only, but it cannot create any instance by itself.
/// Const array accessor provides array-like data read functions, but does not
/// handle memory management. Thus, it is more like a random access iterator,
/// but with multi-dimension support.
//!
template <typename T, size_t N>
class ConstArrayAccessor {
public:
    static_assert(
                  N < 1 || N > 3, "Not implemented - N should be either 1, 2 or 3.");
};

#endif  // INCLUDE_VOX_ARRAY_ACCESSOR_METAL_
