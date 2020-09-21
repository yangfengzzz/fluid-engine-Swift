//
//  face_centered_grid3.swift
//  vox.Force
//
//  Created by Feng Yang on 3030/7/31.
//  Copyright © 3030 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D face-centered (a.k.a MAC or staggered) grid.
///
/// This class implements face-centered grid which is also known as
/// marker-and-cell (MAC) or staggered grid. This vector grid stores each vector
/// component at face center. Thus, u, v, and w components are not collocated.
final class FaceCenteredGrid3: VectorGrid3 {
    var _dataU = Array3<Float>()
    var _dataV = Array3<Float>()
    var _dataW = Array3<Float>()
    var _dataOriginU = Vector3F()
    var _dataOriginV = Vector3F()
    var _dataOriginW = Vector3F()
    var _uLinearSampler:LinearArraySampler3<Float, Float>
    var _vLinearSampler:LinearArraySampler3<Float, Float>
    var _wLinearSampler:LinearArraySampler3<Float, Float>
    var _sampler:((Vector3F)->Vector3F)?
    
    /// Returns the type name of derived grid.
    override func typeName()->String {
        return "FaceCenteredGrid3"
    }
    
    /// Constructs empty grid.
    override init() {
        self._dataOriginU = Vector3F(0.0, 0.5, 0.5)
        self._dataOriginV = Vector3F(0.5, 0.0, 0.5)
        self._dataOriginW = Vector3F(0.5, 0.5, 0.0)
        self._uLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginV)
        self._wLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataW.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginW)
    }
    
    /// Resizes the grid using given parameters.
    convenience init(resolutionX:size_t,
                     resolutionY:size_t,
                     resolutionZ:size_t,
                     gridSpacingX:Float = 1.0,
                     gridSpacingY:Float = 1.0,
                     gridSpacingZ:Float = 1.0,
                     originX:Float = 0.0,
                     originY:Float = 0.0,
                     originZ:Float = 0.0,
                     initialValueU:Float = 0.0,
                     initialValueV:Float = 0.0,
                     initialValueW:Float = 0.0) {
        self.init(resolution: Size3(resolutionX, resolutionY, resolutionZ),
                  gridSpacing: Vector3F(gridSpacingX, gridSpacingY, gridSpacingZ),
                  origin: Vector3F(originX, originY, originZ),
                  initialValue: Vector3F(initialValueU, initialValueV, initialValueW))
    }
    
    /// Resizes the grid using given parameters.
    init(resolution:Size3,
         gridSpacing:Vector3F = Vector3F(1.0, 1.0, 1.0),
         origin:Vector3F = Vector3F(),
         initialValue:Vector3F = Vector3F()) {
        self._uLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginV)
        self._wLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataW.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginW)
        super.init()
        resize(resolution: resolution,
               gridSpacing: gridSpacing,
               origin: origin,
               initialValue: initialValue)
    }
    
    /// Copy constructor.
    init(other:FaceCenteredGrid3) {
        self._uLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginU)
        self._vLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginV)
        self._wLinearSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataW.constAccessor(),
            gridSpacing: Vector3F(1, 1, 1),
            gridOrigin: _dataOriginW)
        super.init()
        set(other: other)
    }
    
    /// Swaps the contents with the given \p other grid.
    ///
    /// This function swaps the contents of the grid instance with the given
    /// grid object \p other only if \p other has the same type with this grid.
    override func swap(other: inout Grid3) {
        let sameType = other as? FaceCenteredGrid3
        
        if (sameType != nil) {
            var father_grid = sameType! as Grid3
            swapGrid(other: &father_grid)
            
            _dataU.swap(other: &sameType!._dataU)
            _dataV.swap(other: &sameType!._dataV)
            _dataW.swap(other: &sameType!._dataW)
            Swift.swap(&_dataOriginU, &sameType!._dataOriginU)
            Swift.swap(&_dataOriginV, &sameType!._dataOriginV)
            Swift.swap(&_dataOriginW, &sameType!._dataOriginW)
            Swift.swap(&_uLinearSampler, &sameType!._uLinearSampler)
            Swift.swap(&_vLinearSampler, &sameType!._vLinearSampler)
            Swift.swap(&_wLinearSampler, &sameType!._wLinearSampler)
            Swift.swap(&_sampler, &sameType!._sampler)
        }
    }
    
    /// Sets the contents with the given \p other grid.
    func set(other:FaceCenteredGrid3) {
        setGrid(other: other)
        
        _dataU.set(other: other._dataU)
        _dataV.set(other: other._dataV)
        _dataW.set(other: other._dataW)
        _dataOriginU = other._dataOriginU
        _dataOriginV = other._dataOriginV
        _dataOriginW = other._dataOriginW
        
        resetSampler()
    }
    
    /// Returns u-value at given data point.
    func u(i:size_t, j:size_t, k:size_t)->Float {
        return _dataU[i, j, k]
    }
    
    /// Returns u-value at given data point.
    func u(i:size_t, j:size_t, k:size_t, val:Float) {
        _dataU[i, j, k] = val
    }
    
    /// Returns v-value at given data point.
    func v(i:size_t, j:size_t, k:size_t)->Float {
        return _dataV[i, j, k]
    }
    
    /// Returns v-value at given data point.
    func v(i:size_t, j:size_t, k:size_t, val:Float) {
        _dataV[i, j, k] = val
    }
    
    /// Returns w-value at given data point.
    func w(i:size_t, j:size_t, k:size_t)->Float {
        return _dataW[i, j, k]
    }
    
    /// Returns w-value at given data point.
    func w(i:size_t, j:size_t, k:size_t, val:Float) {
        _dataW[i, j, k] = val
    }
    
    /// Returns interpolated value at cell center.
    func valueAtCellCenter(i:size_t, j:size_t, k:size_t)->Vector3F {
        VOX_ASSERT(i < resolution().x && j < resolution().y && k < resolution().z)
        
        return 0.5 * Vector3F(_dataU[i, j, k] + _dataU[i + 1, j, k],
                              _dataV[i, j, k] + _dataV[i, j + 1, k],
                              _dataW[i, j, k] + _dataW[i, j, k + 1])
    }
    
    /// Returns divergence at cell-center location.
    func divergenceAtCellCenter(i:size_t, j:size_t, k:size_t)->Float {
        VOX_ASSERT(i < resolution().x && j < resolution().y && k < resolution().z)
        
        let gs:Vector3F = gridSpacing()
        
        let leftU = _dataU[i, j, k]
        let rightU = _dataU[i + 1, j, k]
        let bottomV = _dataV[i, j, k]
        let topV = _dataV[i, j + 1, k]
        let backW = _dataW[i, j, k]
        let frontW = _dataW[i, j, k + 1]
        
        return (rightU - leftU) / gs.x + (topV - bottomV) / gs.y +
            (frontW - backW) / gs.z
    }
    
    ///  Returns curl at cell-center location.
    func curlAtCellCenter(i:size_t, j:size_t, k:size_t)->Vector3F {
        let res:Size3 = resolution()
        
        VOX_ASSERT(i < res.x && j < res.y && k < res.z)
        
        let gs:Vector3F = gridSpacing()
        
        let left = valueAtCellCenter(i: (i > 0) ? i - 1 : i, j: j, k: k)
        let right = valueAtCellCenter(i: (i + 1 < res.x) ? i + 1 : i, j: j, k: k)
        let down = valueAtCellCenter(i: i, j: (j > 0) ? j - 1 : j, k: k)
        let up = valueAtCellCenter(i: i, j: (j + 1 < res.y) ? j + 1 : j, k: k)
        let back = valueAtCellCenter(i: i, j: j, k: (k > 0) ? k - 1 : k)
        let front = valueAtCellCenter(i: i, j: j, k: (k + 1 < res.z) ? k + 1 : k)
        
        let Fx_ym = down.x
        let Fx_yp = up.x
        let Fx_zm = back.x
        let Fx_zp = front.x
        
        let Fy_xm = left.y
        let Fy_xp = right.y
        let Fy_zm = back.y
        let Fy_zp = front.y
        
        let Fz_xm = left.z
        let Fz_xp = right.z
        let Fz_ym = down.z
        let Fz_yp = up.z
        
        return Vector3F(
            0.5 * (Fz_yp - Fz_ym) / gs.y - 0.5 * (Fy_zp - Fy_zm) / gs.z,
            0.5 * (Fx_zp - Fx_zm) / gs.z - 0.5 * (Fz_xp - Fz_xm) / gs.x,
            0.5 * (Fy_xp - Fy_xm) / gs.x - 0.5 * (Fx_yp - Fx_ym) / gs.y)
    }
    
    /// Returns u data accessor.
    func uAccessor()->ArrayAccessor3<Float> {
        return _dataU.accessor()
    }
    
    /// Returns read-only u data accessor.
    func uConstAccessor()->ConstArrayAccessor3<Float> {
        return _dataU.constAccessor()
    }
    
    /// Returns v data accessor.
    func vAccessor()->ArrayAccessor3<Float> {
        return _dataV.accessor()
    }
    
    /// Returns read-only v data accessor.
    func vConstAccessor()->ConstArrayAccessor3<Float> {
        return _dataV.constAccessor()
    }
    
    /// Returns w data accessor.
    func wAccessor()->ArrayAccessor3<Float> {
        return _dataW.accessor()
    }
    
    /// Returns read-only w data accessor.
    func wConstAccessor()->ConstArrayAccessor3<Float> {
        return _dataW.constAccessor()
    }
    
    /// Returns function object that maps u data point to its actual position.
    func uPosition()->DataPositionFunc {
        let h = gridSpacing()
        
        return {(i:size_t, j:size_t, k:size_t) -> Vector3F in
            return self._dataOriginU + h * Vector3F(Float(i), Float(j), Float(k))
        }
    }
    
    /// Returns function object that maps v data point to its actual position.
    func vPosition()->DataPositionFunc {
        let h = gridSpacing()
        
        return {(i:size_t, j:size_t, k:size_t) -> Vector3F in
            return self._dataOriginV + h * Vector3F(Float(i), Float(j), Float(k))
        }
    }
    
    /// Returns function object that maps w data point to its actual position.
    func wPosition()->DataPositionFunc {
        let h = gridSpacing()
        
        return {(i:size_t, j:size_t, k:size_t) -> Vector3F in
            return self._dataOriginW + h * Vector3F(Float(i), Float(j), Float(k))
        }
    }
    
    /// Returns data size of the u component.
    func uSize()->Size3 {
        return _dataU.size()
    }
    
    /// Returns data size of the v component.
    func vSize()->Size3 {
        return _dataV.size()
    }
    
    /// Returns data size of the w component.
    func wSize()->Size3 {
        return _dataW.size()
    }
    
    /// Returns u-data position for the grid point at (0, 0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func uOrigin()->Vector3F {
        return _dataOriginU
    }
    
    /// Returns v-data position for the grid point at (0, 0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func vOrigin()->Vector3F {
        return _dataOriginV
    }
    
    /// Returns w-data position for the grid point at (0, 0, 0).
    ///
    /// Note that this is different from origin() since origin() returns
    /// the lower corner point of the bounding box.
    func wOrigin()->Vector3F {
        return _dataOriginW
    }
    
    /// Returns the copy of the grid instance.
    override func clone()->VectorGrid3 {
        return FaceCenteredGrid3(other: self)
    }
    
    /// Fills the grid with given value.
    override func fill(value:Vector3F,
                       policy:ExecutionPolicy = .kParallel) {
        parallelFor(beginIndexX: 0, endIndexX: _dataU.width(),
                    beginIndexY: 0, endIndexY: _dataU.height(),
                    beginIndexZ: 0, endIndexZ: _dataU.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataU[i, j, k] = value.x
                    }, policy: policy)
        
        parallelFor(beginIndexX: 0, endIndexX: _dataV.width(),
                    beginIndexY: 0, endIndexY: _dataV.height(),
                    beginIndexZ: 0, endIndexZ: _dataV.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataV[i, j, k] = value.y
                    }, policy: policy)
        
        parallelFor(beginIndexX: 0, endIndexX: _dataW.width(),
                    beginIndexY: 0, endIndexY: _dataW.height(),
                    beginIndexZ: 0, endIndexZ: _dataW.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataW[i, j, k] = value.z
                    }, policy: policy)
    }
    
    /// Fills the grid with given position-to-value mapping function.
    override func fill(function:(Vector3F)->Vector3F,
                       policy:ExecutionPolicy = .kParallel) {
        let uPos = uPosition()
        parallelFor(beginIndexX: 0, endIndexX: _dataU.width(),
                    beginIndexY: 0, endIndexY: _dataU.height(),
                    beginIndexZ: 0, endIndexZ: _dataU.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataU[i, j, k] = function(uPos(i, j, k)).x
                    }, policy: policy)
        
        let vPos = vPosition()
        parallelFor(beginIndexX: 0, endIndexX: _dataV.width(),
                    beginIndexY: 0, endIndexY: _dataV.height(),
                    beginIndexZ: 0, endIndexZ: _dataV.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataV[i, j, k] = function(vPos(i, j, k)).y
                    }, policy: policy)
        
        let wPos = wPosition()
        parallelFor(beginIndexX: 0, endIndexX: _dataW.width(),
                    beginIndexY: 0, endIndexY: _dataW.height(),
                    beginIndexZ: 0, endIndexZ: _dataW.depth(),
                    function: {(i:size_t, j:size_t, k:size_t) in
                        _dataW[i, j, k] = function(wPos(i, j, k)).z
                    }, policy: policy)
    }
    
    /// Invokes the given function \p func for each u-data point.
    ///
    /// This function invokes the given function object \p func for each u-data
    /// point in serial manner. The input parameters are i and j indices of a
    /// u-data point. The order of execution is i-first, j-last.
    func forEachUIndex(function:(size_t, size_t, size_t)->Void) {
        _dataU.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each u-data point
    /// parallelly.
    ///
    /// This function invokes the given function object \p func for each u-data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// u-data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachUIndex(function:(size_t, size_t, size_t)->Void) {
        _dataU.parallelForEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in serial manner. The input parameters are i and j indices of a
    /// v-data point. The order of execution is i-first, j-last.
    func forEachVIndex(function:(size_t, size_t, size_t)->Void) {
        _dataV.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point parallelly.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// v-data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachVIndex(function:(size_t, size_t, size_t)->Void) {
        _dataV.parallelForEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in serial manner. The input parameters are i and j indices of a
    /// w-data point. The order of execution is i-first, j-last.
    func forEachWIndex(function:(size_t, size_t, size_t)->Void) {
        _dataW.forEachIndex(function)
    }
    
    /// Invokes the given function \p func for each v-data point parallelly.
    ///
    /// This function invokes the given function object \p func for each v-data
    /// point in parallel manner. The input parameters are i and j indices of a
    /// w-data point. The order of execution can be arbitrary since it's
    /// multi-threaded.
    func parallelForEachWIndex(function:(size_t, size_t, size_t)->Void) {
        _dataW.parallelForEachIndex(function)
    }
    
    /// Returns sampled value at given position \p x.
    override func sample(x:Vector3F)->Vector3F {
        return _sampler!(x)
    }
    
    /// Returns the sampler function.
    ///
    /// This function returns the data sampler function object. The sampling
    /// function is linear.
    func sampler()->(Vector3F)->Vector3F {
        return _sampler!
    }
    
    /// Returns divergence at given position \p x.
    func divergence(x:Vector3F)->Float {
        let res:Size3 = resolution()
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:Float = 0, fy:Float = 0, fz:Float = 0
        let cellCenterOrigin = origin() + 0.5 * gridSpacing()
        
        let normalizedX = (x - cellCenterOrigin) / gridSpacing()
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: res.x - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: res.y - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: res.z - 1, i: &k, f: &fz)
        
        var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
        var weights = Array<Float>(repeating: 0, count: 8)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(i + 1, j, k)
        indices[2] = Point3UI(i, j + 1, k)
        indices[3] = Point3UI(i + 1, j + 1, k)
        indices[4] = Point3UI(i, j, k + 1)
        indices[5] = Point3UI(i + 1, j, k + 1)
        indices[6] = Point3UI(i, j + 1, k + 1)
        indices[7] = Point3UI(i + 1, j + 1, k + 1)
        
        weights[0] = (1.0 - fx) * (1.0 - fy) * (1.0 - fz)
        weights[1] = fx * (1.0 - fy) * (1.0 - fz)
        weights[2] = (1.0 - fx) * fy * (1.0 - fz)
        weights[3] = fx * fy * (1.0 - fz)
        weights[4] = (1.0 - fx) * (1.0 - fy) * fz
        weights[5] = fx * (1.0 - fy) * fz
        weights[6] = (1.0 - fx) * fy * fz
        weights[7] = fx * fy * fz
        
        var result:Float = 0.0
        for n in 0..<8 {
            result += weights[n] * divergenceAtCellCenter(
                i: indices[n].x, j: indices[n].y, k: indices[n].z)
        }
        
        return result
    }
    
    /// Returns curl at given position \p x.
    func curl(x:Vector3F)->Vector3F {
        let res:Size3 = resolution()
        var i:ssize_t = 0, j:ssize_t = 0, k:ssize_t = 0
        var fx:Float = 0, fy:Float = 0, fz:Float = 0
        let cellCenterOrigin = origin() + 0.5 * gridSpacing()
        
        let normalizedX = (x - cellCenterOrigin) / gridSpacing()
        
        Math.getBarycentric(x: normalizedX.x, iLow: 0, iHigh: res.x - 1, i: &i, f: &fx)
        Math.getBarycentric(x: normalizedX.y, iLow: 0, iHigh: res.y - 1, i: &j, f: &fy)
        Math.getBarycentric(x: normalizedX.z, iLow: 0, iHigh: res.z - 1, i: &k, f: &fz)
        
        var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
        var weights = Array<Float>(repeating: 0, count: 8)
        
        indices[0] = Point3UI(i, j, k)
        indices[1] = Point3UI(i + 1, j, k)
        indices[2] = Point3UI(i, j + 1, k)
        indices[3] = Point3UI(i + 1, j + 1, k)
        indices[4] = Point3UI(i, j, k + 1)
        indices[5] = Point3UI(i + 1, j, k + 1)
        indices[6] = Point3UI(i, j + 1, k + 1)
        indices[7] = Point3UI(i + 1, j + 1, k + 1)
        
        weights[0] = (1.0 - fx) * (1.0 - fy) * (1.0 - fz)
        weights[1] = fx * (1.0 - fy) * (1.0 - fz)
        weights[2] = (1.0 - fx) * fy * (1.0 - fz)
        weights[3] = fx * fy * (1.0 - fz)
        weights[4] = (1.0 - fx) * (1.0 - fy) * fz
        weights[5] = fx * (1.0 - fy) * fz
        weights[6] = (1.0 - fx) * fy * fz
        weights[7] = fx * fy * fz
        
        var result = Vector3F()
        for n in 0..<8 {
            result += weights[n] *
                curlAtCellCenter(i: indices[n].x, j: indices[n].y, k: indices[n].z)
        }
        
        return result
    }
    
    override func onResize(resolution:Size3, gridSpacing:Vector3F,
                           origin:Vector3F, initialValue:Vector3F) {
        if (resolution != Size3(0, 0, 0)) {
            _dataU.resize(size: resolution &+ Size3(1, 0, 0), initVal: initialValue.x)
            _dataV.resize(size: resolution &+ Size3(0, 1, 0), initVal: initialValue.y)
            _dataW.resize(size: resolution &+ Size3(0, 0, 1), initVal: initialValue.z)
        } else {
            _dataU.resize(size: Size3(0, 0, 0))
            _dataV.resize(size: Size3(0, 0, 0))
            _dataW.resize(size: Size3(0, 0, 0))
        }
        _dataOriginU = origin + 0.5 * Vector3F(0.0, gridSpacing.y, gridSpacing.z)
        _dataOriginV = origin + 0.5 * Vector3F(gridSpacing.x, 0.0, gridSpacing.z)
        _dataOriginW = origin + 0.5 * Vector3F(gridSpacing.x, gridSpacing.y, 0.0)
        
        resetSampler()
    }
    
    /// Fetches the data into a continuous linear array.
    override func getData(data: inout [Float]) {
        let size = uSize().x * uSize().y * uSize().z +
            vSize().x * vSize().y * vSize().z +
            wSize().x * wSize().y * wSize().z
        data = Array<Float>(repeating: 0, count: size)
        var cnt:size_t = 0
        _dataU.forEach(){(value:Float) in
            data[cnt] = value
            cnt += 1
        }
        _dataV.forEach(){(value:Float) in
            data[cnt] = value
            cnt += 1
        }
        _dataW.forEach(){(value:Float) in
            data[cnt] = value
            cnt += 1
        }
    }
    
    /// Sets the data from a continuous linear array.
    override func setData(data:[Float]) {
        VOX_ASSERT(uSize().x * uSize().y * uSize().z +
                    vSize().x * vSize().y * vSize().z +
                    wSize().x * wSize().y * wSize().z == data.count)
        
        var cnt:size_t = 0
        _dataU.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _dataU[i, j, k] = data[cnt]
            cnt += 1
        }
        _dataV.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _dataV[i, j, k] = data[cnt]
            cnt += 1
        }
        _dataW.forEachIndex(){(i:size_t, j:size_t, k:size_t) in
            _dataW[i, j, k] = data[cnt]
            cnt += 1
        }
    }
    
    func resetSampler() {
        let uSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataU.constAccessor(),
            gridSpacing: gridSpacing(), gridOrigin: _dataOriginU)
        let vSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataV.constAccessor(),
            gridSpacing: gridSpacing(), gridOrigin: _dataOriginV)
        let wSampler = LinearArraySampler3<Float, Float>(
            accessor: _dataW.constAccessor(),
            gridSpacing: gridSpacing(), gridOrigin: _dataOriginW)
        
        _uLinearSampler = uSampler
        _vLinearSampler = vSampler
        _wLinearSampler = wSampler
        
        _sampler = {(x:Vector3F) -> Vector3F in
            let u = uSampler[pt: x]
            let v = vSampler[pt: x]
            let w = wSampler[pt: x]
            return Vector3F(u, v, w)
        }
    }
    
    //MARK:- Builder
    class Builder: VectorGridBuilder3 {
        var _resolution = Size3(1, 1, 1)
        var _gridSpacing = Vector3F(1, 1, 1)
        var _gridOrigin = Vector3F(0, 0, 0)
        var _initialVal = Vector3F(0, 0, 0)
        
        /// Returns builder with resolution.
        func withResolution(resolution:Size3)->Builder {
            _resolution = resolution
            return self
        }
        
        /// Returns builder with resolution.
        func withResolution(resolutionX:size_t,
                            resolutionY:size_t,
                            resolutionZ:size_t)->Builder {
            _resolution.x = resolutionX
            _resolution.y = resolutionY
            _resolution.z = resolutionZ
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacing:Vector3F)->Builder {
            _gridSpacing = gridSpacing
            return self
        }
        
        /// Returns builder with grid spacing.
        func withGridSpacing(gridSpacingX:Float,
                             gridSpacingY:Float,
                             gridSpacingZ:Float)->Builder {
            _gridSpacing.x = gridSpacingX
            _gridSpacing.y = gridSpacingY
            _gridSpacing.z = gridSpacingZ
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOrigin:Vector3F)->Builder {
            _gridOrigin = gridOrigin
            return self
        }
        
        /// Returns builder with grid origin.
        func withOrigin(gridOriginX:Float,
                        gridOriginY:Float,
                        gridOriginZ:Float)->Builder {
            _gridOrigin.x = gridOriginX
            _gridOrigin.y = gridOriginY
            _gridOrigin.z = gridOriginZ
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialVal:Vector3F)->Builder {
            _initialVal = initialVal
            return self
        }
        
        /// Returns builder with initial value.
        func withInitialValue(initialValX:Float,
                              initialValY:Float,
                              initialValZ:Float)->Builder {
            _initialVal.x = initialValX
            _initialVal.y = initialValY
            _initialVal.z = initialValZ
            return self
        }
        
        /// Builds FaceCenteredGrid3 instance.
        func build()->FaceCenteredGrid3 {
            return FaceCenteredGrid3(resolution: _resolution,
                                     gridSpacing: _gridSpacing,
                                     origin: _gridOrigin,
                                     initialValue: _initialVal)
        }
        
        
        /// Builds shared pointer of FaceCenteredGrid3 instance.
        ///
        /// This is an overriding function that implements VectorGridBuilder3.
        func build(resolution: Size3,
                   gridSpacing: Vector3F,
                   gridOrigin: Vector3F,
                   initialVal: Vector3F) -> VectorGrid3 {
            return FaceCenteredGrid3(resolution: resolution,
                                     gridSpacing: gridSpacing,
                                     origin: gridOrigin,
                                     initialValue: initialVal)
        }
    }
    
    /// Returns builder fox FaceCenteredGrid3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Method
extension FaceCenteredGrid3 {
    /// Load Grid Buffer into GPU which can be assemble as Grid
    /// - Parameters:
    ///   - encoder: encoder of data
    ///   - index_begin: the begin index of buffer attribute in kernel
    /// - Returns: the end index of buffer attribute in kernel
    func loadGPUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataU._data!, offset: 0, index: index_begin)
        encoder.setBuffer(_dataV._data!, offset: 0, index: index_begin+1)
        encoder.setBuffer(_dataW._data!, offset: 0, index: index_begin+2)
        var buffer = Grid3Descriptor(_gridSpacing: _gridSpacing, _origin: _origin)
        encoder.setBytes(&buffer, length: MemoryLayout<Grid3Descriptor>.stride, index: index_begin+3)
        return index_begin + 4
    }
    
    func loadUBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataU._data!, offset: 0, index: index_begin)
        return index_begin + 1
    }
    
    func loadVBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataV._data!, offset: 0, index: index_begin)
        return index_begin + 1
    }
    
    func loadWBuffer(encoder:inout MTLComputeCommandEncoder, index_begin:Int)->Int {
        encoder.setBuffer(_dataW._data!, offset: 0, index: index_begin)
        return index_begin + 1
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachUIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
        var arrayPipelineState: MTLComputePipelineState!
        var function: MTLFunction? = nil
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else {
                return
            }
            
            function = library.makeFunction(name: name)
            
            // array update pipeline state
            arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        // command encoder
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              var computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        
        computeEncoder.setComputePipelineState(arrayPipelineState)
        let w = arrayPipelineState.threadExecutionWidth
        let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(uSize().x, uSize().y,  uSize().z)
        
        computeEncoder.setBuffer(_dataU._data!, offset: 0, index: 0)
        
        //Other Variables
        var index:Int = 1
        callBack(&computeEncoder, &index)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachVIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
        var arrayPipelineState: MTLComputePipelineState!
        var function: MTLFunction? = nil
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else {
                return
            }
            
            function = library.makeFunction(name: name)
            
            // array update pipeline state
            arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        // command encoder
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              var computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        
        computeEncoder.setComputePipelineState(arrayPipelineState)
        let w = arrayPipelineState.threadExecutionWidth
        let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(vSize().x, vSize().y, vSize().z)
        
        computeEncoder.setBuffer(_dataV._data!, offset: 0, index: 0)
        
        //Other Variables
        var index:Int = 1
        callBack(&computeEncoder, &index)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    /// Iterates the array and invoke given \p func for each index in
    ///     parallel using Metal Compute Shader.
    ///
    /// - Parameters:
    ///   - name: name of shader
    ///   - callBack:GPU variable other than data, which is already set as index 0
    func parallelForEachWIndex(name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
        var arrayPipelineState: MTLComputePipelineState!
        var function: MTLFunction? = nil
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else {
                return
            }
            
            function = library.makeFunction(name: name)
            
            // array update pipeline state
            arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        // command encoder
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              var computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        
        computeEncoder.setComputePipelineState(arrayPipelineState)
        let w = arrayPipelineState.threadExecutionWidth
        let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(wSize().x, wSize().y, wSize().z)
        
        computeEncoder.setBuffer(_dataW._data!, offset: 0, index: 0)
        
        //Other Variables
        var index:Int = 1
        callBack(&computeEncoder, &index)
        
        computeEncoder.dispatchThreads(threadsPerGrid,
                                       threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
