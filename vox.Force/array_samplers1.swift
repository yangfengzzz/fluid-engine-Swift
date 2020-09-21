//
//  array_samplers1.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 1-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 1-D array.
struct NearestArraySampler1<T:ZeroInit, R:FloatingPoint> {
    var _gridSpacing:R
    var _origin:R
    var _accessor:ConstArrayAccessor1<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor1<T>,
         gridSpacing:R,
         gridOrigin:R) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:NearestArraySampler1) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (R)->T
}

extension NearestArraySampler1 where R == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size()
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            i = min(Int(Float(i) + fx + 0.5), iSize - 1)
            
            return _accessor[i]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(x:R, i: inout size_t) {
        var fx:R = 0
        
        VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
        let normalizedX:R = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size()
        
        var _i:ssize_t = 0
        Math.getBarycentric(x: normalizedX, iLow: 0,
                            iHigh: iSize - 1, i: &_i, f: &fx)
        
        i = min(Int(Float(_i) + fx + 0.5), iSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = NearestArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}

extension NearestArraySampler1 where R == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size()
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            i = min(Int(Double(i) + fx + 0.5), iSize - 1)
            
            return _accessor[i]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(x:R, i: inout size_t) {
        var fx:R = 0
        
        VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
        let normalizedX:R = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size()
        
        var _i:ssize_t = 0
        Math.getBarycentric(x: normalizedX, iLow: 0,
                            iHigh: iSize - 1, i: &_i, f: &fx)
        
        i = min(Int(Double(_i) + fx + 0.5), iSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = NearestArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- LinearArraySampler1
/// 1-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 1-D array.
struct LinearArraySampler1<T:ZeroInit, R:FloatingPoint> {
    var _gridSpacing:R
    var _origin:R
    var _accessor:ConstArrayAccessor1<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor1<T>,
         gridSpacing:R,
         gridOrigin:R) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:LinearArraySampler1) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (R)->T
}

extension LinearArraySampler1 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size()
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            
            return
                Math.lerp(
                    value0: _accessor[i],
                    value1: _accessor[ip1],
                    f: fx)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(x:R, i0: inout size_t, i1: inout size_t,
                                  weight0: inout T, weight1: inout T) {
        var i:ssize_t = 0
        var fx:R = 0
        
        VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
        let normalizedX:R = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size()
        
        Math.getBarycentric(x: normalizedX, iLow: 0,
                            iHigh: iSize - 1, i: &i, f: &fx)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        
        i0 = i
        i1 = ip1
        weight0 = 1 - fx
        weight1 = fx
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = LinearArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}

extension LinearArraySampler1 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size()
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            
            return
                Math.lerp(
                    value0: _accessor[i],
                    value1: _accessor[ip1],
                    f: fx)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(x:R, i0: inout size_t, i1: inout size_t,
                                  weight0: inout T, weight1: inout T) {
        var i:ssize_t = 0
        var fx:R = 0
        
        VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
        let normalizedX:R = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size()
        
        Math.getBarycentric(x: normalizedX, iLow: 0,
                            iHigh: iSize - 1, i: &i, f: &fx)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        
        i0 = i
        i1 = ip1
        weight0 = 1 - fx
        weight1 = fx
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = LinearArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- CubicArraySampler1
/// 1-D cubic array sampler class.
///
/// This class provides cubic sampling interface for a given 1-D array.
struct CubicArraySampler1<T:ZeroInit, R:FloatingPoint> {
    var _gridSpacing:R
    var _origin:R
    var _accessor:ConstArrayAccessor1<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor1<T>,
         gridSpacing:R,
         gridOrigin:R) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:CubicArraySampler1) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (R)->T
}

extension CubicArraySampler1 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            let iSize:ssize_t = _accessor.size()
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            let im1:ssize_t = max(i - 1, 0)
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let ip2:ssize_t = min(i + 2, iSize - 1)
            
            return Math.monotonicCatmullRom(
                f0: _accessor[im1],
                f1: _accessor[i],
                f2: _accessor[ip1],
                f3: _accessor[ip2],
                f: fx)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = CubicArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}

extension CubicArraySampler1 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:R)->T{
        get{
            var i:ssize_t = 0
            let iSize:ssize_t = _accessor.size()
            var fx:R = 0
            
            VOX_ASSERT(_gridSpacing > R.leastNonzeroMagnitude)
            let normalizedX:R = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            
            let im1:ssize_t = max(i - 1, 0)
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let ip2:ssize_t = min(i + 2, iSize - 1)
            
            return Math.monotonicCatmullRom(
                f0: _accessor[im1],
                f1: _accessor[i],
                f2: _accessor[ip1],
                f3: _accessor[ip2],
                f: fx)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:R)->T in
            let sampler = CubicArraySampler1(other: self)
            return sampler[pt: pt]
        }
    }
}
