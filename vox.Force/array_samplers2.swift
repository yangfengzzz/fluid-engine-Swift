//
//  array_samplers2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D nearest array sampler class.
///
/// This class provides nearest sampling interface for a given 2-D array.
struct NearestArraySampler2<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector2<R>
    var _origin:Vector2<R>
    var _accessor:ConstArrayAccessor2<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor2<T>,
         gridSpacing:Vector2<R>,
         gridOrigin:Vector2<R>) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:NearestArraySampler2) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector2<R>)->T
}

extension NearestArraySampler2 where R == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            i = min(Int(Float(i) + fx + 0.5), iSize - 1)
            j = min(Int(Float(j) + fy + 0.5), jSize - 1)
            
            return _accessor[i, j]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(pt x:Vector2<R>, index: inout Point2UI) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                    _gridSpacing.y > R.leastNonzeroMagnitude)
        let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        index.x = min(Int(Float(i) + fx + 0.5), iSize - 1)
        index.y = min(Int(Float(j) + fy + 0.5), jSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = NearestArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

extension NearestArraySampler2 where R == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            i = min(Int(Double(i) + fx + 0.5), iSize - 1)
            j = min(Int(Double(j) + fy + 0.5), jSize - 1)
            
            return _accessor[i, j]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(pt x:Vector2<R>, index: inout Point2UI) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                    _gridSpacing.y > R.leastNonzeroMagnitude)
        let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        index.x = min(Int(Double(i) + fx + 0.5), iSize - 1)
        index.y = min(Int(Double(j) + fy + 0.5), jSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = NearestArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- LinearArraySampler2
/// 2-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 2-D array.
struct LinearArraySampler2<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector2<R>
    var _invGridSpacing:Vector2<R>
    var _origin:Vector2<R>
    var _accessor:ConstArrayAccessor2<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor2<T>,
         gridSpacing:Vector2<R>,
         gridOrigin:Vector2<R>) {
        self._gridSpacing = gridSpacing
        self._invGridSpacing = Vector2<R>(1, 1) / _gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:LinearArraySampler2) {
        self._gridSpacing = other._gridSpacing
        self._invGridSpacing = other._invGridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector2<R>)->T
}

extension LinearArraySampler2 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            
            return Math.bilerp(
                f00: _accessor[i, j],
                f10: _accessor[ip1, j],
                f01: _accessor[i, jp1],
                f11: _accessor[ip1, jp1],
                tx: fx,
                ty: fy)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector2<R>,
                                  indices: inout [Point2UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = (1 - fx) * (1 - fy)
        weights[1] = fx * (1 - fy)
        weights[2] = (1 - fx) * fy
        weights[3] = fx * fy
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector2<R>,
                                          indices: inout [Point2UI],
                                          weights: inout [Vector2<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = Vector2<R>(
            fy * _invGridSpacing.x - _invGridSpacing.x,
            fx * _invGridSpacing.y - _invGridSpacing.y)
        weights[1] = Vector2<R>(
            -fy * _invGridSpacing.x + _invGridSpacing.x,
            -fx * _invGridSpacing.y)
        weights[2] = Vector2<R>(
            -fy * _invGridSpacing.x,
            -fx * _invGridSpacing.y + _invGridSpacing.y)
        weights[3] = Vector2<R>(
            fy * _invGridSpacing.x,
            fx * _invGridSpacing.y)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = LinearArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

extension LinearArraySampler2 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            
            return Math.bilerp(
                f00: _accessor[i, j],
                f10: _accessor[ip1, j],
                f01: _accessor[i, jp1],
                f11: _accessor[ip1, jp1],
                tx: fx,
                ty: fy)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector2<R>,
                                  indices: inout [Point2UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = (1 - fx) * (1 - fy)
        weights[1] = fx * (1 - fy)
        weights[2] = (1 - fx) * fy
        weights[3] = fx * fy
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector2<R>,
                                          indices: inout [Point2UI],
                                          weights: inout [Vector2<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = Vector2<R>(
            fy * _invGridSpacing.x - _invGridSpacing.x,
            fx * _invGridSpacing.y - _invGridSpacing.y)
        weights[1] = Vector2<R>(
            -fy * _invGridSpacing.x + _invGridSpacing.x,
            -fx * _invGridSpacing.y)
        weights[2] = Vector2<R>(
            -fy * _invGridSpacing.x,
            -fx * _invGridSpacing.y + _invGridSpacing.y)
        weights[3] = Vector2<R>(
            fy * _invGridSpacing.x,
            fx * _invGridSpacing.y)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = LinearArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

extension LinearArraySampler2 where R == Float, T == Vector2F {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            
            return Math.bilerp(
                f00: _accessor[i, j],
                f10: _accessor[ip1, j],
                f01: _accessor[i, jp1],
                f11: _accessor[ip1, jp1],
                tx: fx,
                ty: fy)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector2<R>,
                                  indices: inout [Point2UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = (1 - fx) * (1 - fy)
        weights[1] = fx * (1 - fy)
        weights[2] = (1 - fx) * fy
        weights[3] = fx * fy
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector2<R>,
                                          indices: inout [Point2UI],
                                          weights: inout [Vector2<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0
        var fx:R = 0, fy:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0)
        
        let normalizedX:Vector2<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        
        indices[0] = Point2UI(i, j)
        indices[1] = Point2UI(ip1, j)
        indices[2] = Point2UI(i, jp1)
        indices[3] = Point2UI(ip1, jp1)
        
        weights[0] = Vector2<R>(
            fy * _invGridSpacing.x - _invGridSpacing.x,
            fx * _invGridSpacing.y - _invGridSpacing.y)
        weights[1] = Vector2<R>(
            -fy * _invGridSpacing.x + _invGridSpacing.x,
            -fx * _invGridSpacing.y)
        weights[2] = Vector2<R>(
            -fy * _invGridSpacing.x,
            -fx * _invGridSpacing.y + _invGridSpacing.y)
        weights[3] = Vector2<R>(
            fy * _invGridSpacing.x,
            fx * _invGridSpacing.y)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = LinearArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- CubicArraySampler2
/// 2-D cubic array sampler class.
///
/// This class provides cubic sampling interface for a given 2-D array.
struct CubicArraySampler2<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector2<R>
    var _origin:Vector2<R>
    var _accessor:ConstArrayAccessor2<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor2<T>,
         gridSpacing:Vector2<R>,
         gridOrigin:Vector2<R>) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:CubicArraySampler2) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector2<R>)->T
}

extension CubicArraySampler2 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let Is:[ssize_t] = [
                max(i - 1, 0),
                i,
                min(i + 1, iSize - 1),
                min(i + 2, iSize - 1)
            ]
            let Js:[ssize_t] = [
                max(j - 1, 0),
                j,
                min(j + 1, jSize - 1),
                min(j + 2, jSize - 1)
            ]
            
            // Calculate in i direction first
            var values:[T] = Array<T>(repeating: 0, count: 4)
            for n in 0..<4 {
                values[n] = Math.monotonicCatmullRom(
                    f0: _accessor[Is[0], Js[n]],
                    f1: _accessor[Is[1], Js[n]],
                    f2: _accessor[Is[2], Js[n]],
                    f3: _accessor[Is[3], Js[n]],
                    f: fx)
            }
            
            return Math.monotonicCatmullRom(f0: values[0], f1: values[1],
                                            f2: values[2], f3: values[3], f: fy)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = CubicArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

extension CubicArraySampler2 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let Is:[ssize_t] = [
                max(i - 1, 0),
                i,
                min(i + 1, iSize - 1),
                min(i + 2, iSize - 1)
            ]
            let Js:[ssize_t] = [
                max(j - 1, 0),
                j,
                min(j + 1, jSize - 1),
                min(j + 2, jSize - 1)
            ]
            
            // Calculate in i direction first
            var values:[T] = Array<T>(repeating: 0, count: 4)
            for n in 0..<4 {
                values[n] = Math.monotonicCatmullRom(
                    f0: _accessor[Is[0], Js[n]],
                    f1: _accessor[Is[1], Js[n]],
                    f2: _accessor[Is[2], Js[n]],
                    f3: _accessor[Is[3], Js[n]],
                    f: fx)
            }
            
            return Math.monotonicCatmullRom(f0: values[0], f1: values[1],
                                            f2: values[2], f3: values[3], f: fy)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = CubicArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}

extension CubicArraySampler2 where R == Float, T == Vector2F {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector2<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            var fx:R = 0, fy:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude)
            let normalizedX:Vector2<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            
            let Is:[ssize_t] = [
                max(i - 1, 0),
                i,
                min(i + 1, iSize - 1),
                min(i + 2, iSize - 1)
            ]
            let Js:[ssize_t] = [
                max(j - 1, 0),
                j,
                min(j + 1, jSize - 1),
                min(j + 2, jSize - 1)
            ]
            
            // Calculate in i direction first
            var values:[T] = Array<T>(repeating: Vector2F(), count: 4)
            for n in 0..<4 {
                values[n] = monotonicCatmullRom(
                    v0: _accessor[Is[0], Js[n]],
                    v1: _accessor[Is[1], Js[n]],
                    v2: _accessor[Is[2], Js[n]],
                    v3: _accessor[Is[3], Js[n]],
                    f: fx)
            }
            
            return monotonicCatmullRom(v0: values[0], v1: values[1],
                                       v2: values[2], v3: values[3], f: fy)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector2<R>)->T in
            let sampler = CubicArraySampler2(other: self)
            return sampler[pt: pt]
        }
    }
}
