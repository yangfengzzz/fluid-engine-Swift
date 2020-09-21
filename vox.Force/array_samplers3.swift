//
//  array_samplers3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D nearest array sampler class.
///
/// This class provides nearest sampling interface for a given 3-D array.
struct NearestArraySampler3<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector3<R>
    var _origin:Vector3<R>
    var _accessor:ConstArrayAccessor3<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor3<T>,
         gridSpacing:Vector3<R>,
         gridOrigin:Vector3<R>) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:NearestArraySampler3) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector3<R>)->T
}

extension NearestArraySampler3 where R == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0,
                                iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0,
                                iHigh: kSize - 1, i: &k, f: &fz)
            
            i = min(Int(Float(i) + fx + 0.5), iSize - 1)
            j = min(Int(Float(j) + fy + 0.5), jSize - 1)
            k = min(Int(Float(k) + fz + 0.5), kSize - 1)
            
            return _accessor[i, j, k]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(pt x:Vector3<R>, index: inout Point3UI) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                    _gridSpacing.y > R.leastNonzeroMagnitude &&
                    _gridSpacing.z > R.leastNonzeroMagnitude)
        let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0,
                            iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0,
                            iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0,
                            iHigh: kSize - 1, i: &k, f: &fz)
        
        index.x = min(Int(Float(i) + fx + 0.5), iSize - 1)
        index.y = min(Int(Float(j) + fy + 0.5), jSize - 1)
        index.z = min(Int(Float(k) + fz + 0.5), kSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = NearestArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

extension NearestArraySampler3 where R == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0,
                                iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0,
                                iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0,
                                iHigh: kSize - 1, i: &k, f: &fz)
            
            i = min(Int(Double(i) + fx + 0.5), iSize - 1)
            j = min(Int(Double(j) + fy + 0.5), jSize - 1)
            k = min(Int(Double(k) + fz + 0.5), kSize - 1)
            
            return _accessor[i, j, k]
        }
    }
    
    /// Returns the nearest array index for point \p x.
    func getCoordinate(pt x:Vector3<R>, index: inout Point3UI) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                    _gridSpacing.y > R.leastNonzeroMagnitude &&
                    _gridSpacing.z > R.leastNonzeroMagnitude)
        let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0,
                            iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0,
                            iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0,
                            iHigh: kSize - 1, i: &k, f: &fz)
        
        index.x = min(Int(Double(i) + fx + 0.5), iSize - 1)
        index.y = min(Int(Double(j) + fy + 0.5), jSize - 1)
        index.z = min(Int(Double(k) + fz + 0.5), kSize - 1)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = NearestArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- LinearArraySampler3
/// 3-D linear array sampler class.
///
/// This class provides linear sampling interface for a given 3-D array.
struct LinearArraySampler3<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector3<R>
    var _invGridSpacing:Vector3<R>
    var _origin:Vector3<R>
    var _accessor:ConstArrayAccessor3<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor3<T>,
         gridSpacing:Vector3<R>,
         gridOrigin:Vector3<R>) {
        self._gridSpacing = gridSpacing
        self._invGridSpacing = Vector3<R>(1, 1, 1) / _gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:LinearArraySampler3) {
        self._gridSpacing = other._gridSpacing
        self._invGridSpacing = other._invGridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector3<R>)->T
}

extension LinearArraySampler3 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            let kp1:ssize_t = min(k + 1, kSize - 1)
            
            return Math.trilerp(
                f000: _accessor[i, j, k],
                f100: _accessor[ip1, j, k],
                f010: _accessor[i, jp1, k],
                f110: _accessor[ip1, jp1, k],
                f001: _accessor[i, j, kp1],
                f101: _accessor[ip1, j, kp1],
                f011: _accessor[i, jp1, kp1],
                f111: _accessor[ip1, jp1, kp1],
                tx: fx,
                ty: fy,
                fz: fz)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector3<R>,
                                  indices: inout [Point3UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = (1 - fx) * (1 - fy) * (1 - fz)
        weights[1] = fx * (1 - fy) * (1 - fz)
        weights[2] = (1 - fx) * fy * (1 - fz)
        weights[3] = fx * fy * (1 - fz)
        weights[4] = (1 - fx) * (1 - fy) * fz
        weights[5] = fx * (1 - fy) * fz
        weights[6] = (1 - fx) * fy * fz
        weights[7] = fx * fy * fz
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector3<R>,
                                          indices: inout [Point3UI],
                                          weights: inout [Vector3<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = Vector3<R>(
            -_invGridSpacing.x * (1 - fy) * (1 - fz),
            -_invGridSpacing.y * (1 - fx) * (1 - fz),
            -_invGridSpacing.z * (1 - fx) * (1 - fy))
        weights[1] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * (1 - fz),
            fx * (-_invGridSpacing.y) * (1 - fz),
            fx * (1 - fy) * (-_invGridSpacing.z))
        weights[2] = Vector3<R>(
            (-_invGridSpacing.x) * fy * (1 - fz),
            (1 - fx) * _invGridSpacing.y * (1 - fz),
            (1 - fx) * fy * (-_invGridSpacing.z))
        weights[3] = Vector3<R>(
            _invGridSpacing.x * fy * (1 - fz),
            fx * _invGridSpacing.y * (1 - fz),
            fx * fy * (-_invGridSpacing.z))
        weights[4] = Vector3<R>(
            (-_invGridSpacing.x) * (1 - fy) * fz,
            (1 - fx) * (-_invGridSpacing.y) * fz,
            (1 - fx) * (1 - fy) * _invGridSpacing.z)
        weights[5] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * fz,
            fx * (-_invGridSpacing.y) * fz,
            fx * (1 - fy) * _invGridSpacing.z)
        weights[6] = Vector3<R>(
            (-_invGridSpacing.x) * fy * fz,
            (1 - fx) * _invGridSpacing.y * fz,
            (1 - fx) * fy * _invGridSpacing.z)
        weights[7] = Vector3<R>(
            _invGridSpacing.x * fy * fz,
            fx * _invGridSpacing.y * fz,
            fx * fy * _invGridSpacing.z)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = LinearArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

extension LinearArraySampler3 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            let kp1:ssize_t = min(k + 1, kSize - 1)
            
            return Math.trilerp(
                f000: _accessor[i, j, k],
                f100: _accessor[ip1, j, k],
                f010: _accessor[i, jp1, k],
                f110: _accessor[ip1, jp1, k],
                f001: _accessor[i, j, kp1],
                f101: _accessor[ip1, j, kp1],
                f011: _accessor[i, jp1, kp1],
                f111: _accessor[ip1, jp1, kp1],
                tx: fx,
                ty: fy,
                fz: fz)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector3<R>,
                                  indices: inout [Point3UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = (1 - fx) * (1 - fy) * (1 - fz)
        weights[1] = fx * (1 - fy) * (1 - fz)
        weights[2] = (1 - fx) * fy * (1 - fz)
        weights[3] = fx * fy * (1 - fz)
        weights[4] = (1 - fx) * (1 - fy) * fz
        weights[5] = fx * (1 - fy) * fz
        weights[6] = (1 - fx) * fy * fz
        weights[7] = fx * fy * fz
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector3<R>,
                                          indices: inout [Point3UI],
                                          weights: inout [Vector3<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = Vector3<R>(
            -_invGridSpacing.x * (1 - fy) * (1 - fz),
            -_invGridSpacing.y * (1 - fx) * (1 - fz),
            -_invGridSpacing.z * (1 - fx) * (1 - fy))
        weights[1] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * (1 - fz),
            fx * (-_invGridSpacing.y) * (1 - fz),
            fx * (1 - fy) * (-_invGridSpacing.z))
        weights[2] = Vector3<R>(
            (-_invGridSpacing.x) * fy * (1 - fz),
            (1 - fx) * _invGridSpacing.y * (1 - fz),
            (1 - fx) * fy * (-_invGridSpacing.z))
        weights[3] = Vector3<R>(
            _invGridSpacing.x * fy * (1 - fz),
            fx * _invGridSpacing.y * (1 - fz),
            fx * fy * (-_invGridSpacing.z))
        weights[4] = Vector3<R>(
            (-_invGridSpacing.x) * (1 - fy) * fz,
            (1 - fx) * (-_invGridSpacing.y) * fz,
            (1 - fx) * (1 - fy) * _invGridSpacing.z)
        weights[5] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * fz,
            fx * (-_invGridSpacing.y) * fz,
            fx * (1 - fy) * _invGridSpacing.z)
        weights[6] = Vector3<R>(
            (-_invGridSpacing.x) * fy * fz,
            (1 - fx) * _invGridSpacing.y * fz,
            (1 - fx) * fy * _invGridSpacing.z)
        weights[7] = Vector3<R>(
            _invGridSpacing.x * fy * fz,
            fx * _invGridSpacing.y * fz,
            fx * fy * _invGridSpacing.z)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = LinearArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

extension LinearArraySampler3 where R == Float, T == Vector3F {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
            let ip1:ssize_t = min(i + 1, iSize - 1)
            let jp1:ssize_t = min(j + 1, jSize - 1)
            let kp1:ssize_t = min(k + 1, kSize - 1)
            
            return Math.trilerp(
                f000: _accessor[i, j, k],
                f100: _accessor[ip1, j, k],
                f010: _accessor[i, jp1, k],
                f110: _accessor[ip1, jp1, k],
                f001: _accessor[i, j, kp1],
                f101: _accessor[ip1, j, kp1],
                f011: _accessor[i, jp1, kp1],
                f111: _accessor[ip1, jp1, kp1],
                tx: fx,
                ty: fy,
                fz: fz)
        }
    }
    
    /// Returns the indices of points and their sampling weight for given point.
    func getCoordinatesAndWeights(pt x:Vector3<R>,
                                  indices: inout [Point3UI],
                                  weights: inout [R]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) * _invGridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = (1 - fx) * (1 - fy) * (1 - fz)
        weights[1] = fx * (1 - fy) * (1 - fz)
        weights[2] = (1 - fx) * fy * (1 - fz)
        weights[3] = fx * fy * (1 - fz)
        weights[4] = (1 - fx) * (1 - fy) * fz
        weights[5] = fx * (1 - fy) * fz
        weights[6] = (1 - fx) * fy * fz
        weights[7] = fx * fy * fz
    }
    
    /// Returns the indices of points and their gradient of sampling weight for given point.
    func getCoordinatesAndGradientWeights(pt x:Vector3<R>,
                                          indices: inout [Point3UI],
                                          weights: inout [Vector3<R>]) {
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:R = 0, fy:R = 0, fz:R = 0
        
        VOX_ASSERT(_gridSpacing.x > 0.0 && _gridSpacing.y > 0.0 && _gridSpacing.z > 0.0)
        
        let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
        
        let iSize:ssize_t = _accessor.size().x
        let jSize:ssize_t = _accessor.size().y
        let kSize:ssize_t = _accessor.size().z
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
        
        let ip1:ssize_t = min(i + 1, iSize - 1)
        let jp1:ssize_t = min(j + 1, jSize - 1)
        let kp1:ssize_t = min(k + 1, kSize - 1)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(ip1, j, k)
        indices[2] = Point3UI(i, jp1, k)
        indices[3] = Point3UI(ip1, jp1, k)
        indices[4] = Point3UI(i, j, kp1)
        indices[5] = Point3UI(ip1, j, kp1)
        indices[6] = Point3UI(i, jp1, kp1)
        indices[7] = Point3UI(ip1, jp1, kp1)
        
        weights[0] = Vector3<R>(
            -_invGridSpacing.x * (1 - fy) * (1 - fz),
            -_invGridSpacing.y * (1 - fx) * (1 - fz),
            -_invGridSpacing.z * (1 - fx) * (1 - fy))
        weights[1] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * (1 - fz),
            fx * (-_invGridSpacing.y) * (1 - fz),
            fx * (1 - fy) * (-_invGridSpacing.z))
        weights[2] = Vector3<R>(
            (-_invGridSpacing.x) * fy * (1 - fz),
            (1 - fx) * _invGridSpacing.y * (1 - fz),
            (1 - fx) * fy * (-_invGridSpacing.z))
        weights[3] = Vector3<R>(
            _invGridSpacing.x * fy * (1 - fz),
            fx * _invGridSpacing.y * (1 - fz),
            fx * fy * (-_invGridSpacing.z))
        weights[4] = Vector3<R>(
            (-_invGridSpacing.x) * (1 - fy) * fz,
            (1 - fx) * (-_invGridSpacing.y) * fz,
            (1 - fx) * (1 - fy) * _invGridSpacing.z)
        weights[5] = Vector3<R>(
            _invGridSpacing.x * (1 - fy) * fz,
            fx * (-_invGridSpacing.y) * fz,
            fx * (1 - fy) * _invGridSpacing.z)
        weights[6] = Vector3<R>(
            (-_invGridSpacing.x) * fy * fz,
            (1 - fx) * _invGridSpacing.y * fz,
            (1 - fx) * fy * _invGridSpacing.z)
        weights[7] = Vector3<R>(
            _invGridSpacing.x * fy * fz,
            fx * _invGridSpacing.y * fz,
            fx * fy * _invGridSpacing.z)
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = LinearArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

//MARK:- CubicArraySampler3
/// 3-D cubic array sampler class.
///
/// This class provides cubic sampling interface for a given 3-D array.
struct CubicArraySampler3<T:ZeroInit, R:FloatingPoint&SIMDScalar> {
    var _gridSpacing:Vector3<R>
    var _origin:Vector3<R>
    var _accessor:ConstArrayAccessor3<T>
    
    /// Constructs a sampler using array accessor, spacing between
    ///     the elements, and the position of the first array element.
    /// - Parameters:
    ///   - accessor:  The array accessor.
    ///   - gridSpacing: The grid spacing.
    ///   - gridOrigin:  The grid origin.
    init(accessor:ConstArrayAccessor3<T>,
         gridSpacing:Vector3<R>,
         gridOrigin:Vector3<R>) {
        self._gridSpacing = gridSpacing
        self._origin = gridOrigin
        self._accessor = accessor
    }
    
    /// Copy constructor.
    init(other:CubicArraySampler3) {
        self._gridSpacing = other._gridSpacing
        self._origin = other._origin
        self._accessor = other._accessor
    }
    
    typealias functionType = (Vector3<R>)->T
}

extension CubicArraySampler3 where R == Float, T == Float {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
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
            let Ks:[ssize_t] = [
                max(k - 1, 0),
                k,
                min(k + 1, kSize - 1),
                min(k + 2, kSize - 1)
            ]
            
            var kValues:[T] = Array<T>(repeating: 0, count: 4)
            
            for kk in 0..<4 {
                var jValues:[T] = Array<T>(repeating: 0, count: 4)
                
                for jj in 0..<4 {
                    jValues[jj] = Math.monotonicCatmullRom(
                        f0: _accessor[Is[0], Js[jj], Ks[kk]],
                        f1: _accessor[Is[1], Js[jj], Ks[kk]],
                        f2: _accessor[Is[2], Js[jj], Ks[kk]],
                        f3: _accessor[Is[3], Js[jj], Ks[kk]],
                        f: fx)
                }
                
                kValues[kk] =  Math.monotonicCatmullRom(
                    f0: jValues[0], f1: jValues[1], f2: jValues[2], f3: jValues[3], f: fy)
            }
            
            return  Math.monotonicCatmullRom(
                f0: kValues[0], f1: kValues[1], f2: kValues[2], f3: kValues[3], f: fz)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = CubicArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

extension CubicArraySampler3 where R == Double, T == Double {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
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
            let Ks:[ssize_t] = [
                max(k - 1, 0),
                k,
                min(k + 1, kSize - 1),
                min(k + 2, kSize - 1)
            ]
            
            var kValues:[T] = Array<T>(repeating: 0, count: 4)
            
            for kk in 0..<4 {
                var jValues:[T] = Array<T>(repeating: 0, count: 4)
                
                for jj in 0..<4 {
                    jValues[jj] = Math.monotonicCatmullRom(
                        f0: _accessor[Is[0], Js[jj], Ks[kk]],
                        f1: _accessor[Is[1], Js[jj], Ks[kk]],
                        f2: _accessor[Is[2], Js[jj], Ks[kk]],
                        f3: _accessor[Is[3], Js[jj], Ks[kk]],
                        f: fx)
                }
                
                kValues[kk] =  Math.monotonicCatmullRom(
                    f0: jValues[0], f1: jValues[1], f2: jValues[2], f3: jValues[3], f: fy)
            }
            
            return  Math.monotonicCatmullRom(
                f0: kValues[0], f1: kValues[1], f2: kValues[2], f3: kValues[3], f: fz)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = CubicArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}

extension CubicArraySampler3 where R == Float, T == Vector3F {
    /// Returns sampled value at point \p pt.
    subscript(pt x:Vector3<R>)->T{
        get{
            var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
            let iSize:ssize_t = _accessor.size().x
            let jSize:ssize_t = _accessor.size().y
            let kSize:ssize_t = _accessor.size().z
            var fx:R = 0, fy:R = 0, fz:R = 0
            
            VOX_ASSERT(_gridSpacing.x > R.leastNonzeroMagnitude &&
                        _gridSpacing.y > R.leastNonzeroMagnitude &&
                        _gridSpacing.z > R.leastNonzeroMagnitude)
            let normalizedX:Vector3<R> = (x - _origin) / _gridSpacing
            
            Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: iSize - 1, i: &i, f: &fx)
            Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: jSize - 1, i: &j, f: &fy)
            Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: kSize - 1, i: &k, f: &fz)
            
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
            let Ks:[ssize_t] = [
                max(k - 1, 0),
                k,
                min(k + 1, kSize - 1),
                min(k + 2, kSize - 1)
            ]
            
            var kValues:[T] = Array<T>(repeating: Vector3F(), count: 4)
            
            for kk in 0..<4 {
                var jValues:[T] = Array<T>(repeating: Vector3F(), count: 4)
                
                for jj in 0..<4 {
                    jValues[jj] = monotonicCatmullRom(
                        v0: _accessor[Is[0], Js[jj], Ks[kk]],
                        v1: _accessor[Is[1], Js[jj], Ks[kk]],
                        v2: _accessor[Is[2], Js[jj], Ks[kk]],
                        v3: _accessor[Is[3], Js[jj], Ks[kk]],
                        f: fx)
                }
                
                kValues[kk] =  monotonicCatmullRom(
                    v0: jValues[0], v1: jValues[1], v2: jValues[2], v3: jValues[3], f: fy)
            }
            
            return  monotonicCatmullRom(
                v0: kValues[0], v1: kValues[1], v2: kValues[2], v3: kValues[3], f: fz)
        }
    }
    
    /// Returns a funtion object that wraps this instance.
    func functor()->functionType {
        return {(pt:Vector3<R>)->T in
            let sampler = CubicArraySampler3(other: self)
            return sampler[pt: pt]
        }
    }
}
