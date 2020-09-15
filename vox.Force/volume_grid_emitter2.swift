//
//  volume_grid_emitter2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D grid-based volumetric emitter.
final class VolumeGridEmitter2: GridEmitter2 {
    /// Maps to a scalar value for given signed-dist, location, and old value.
    typealias ScalarMapper = (Float, Vector2F, Float)->Float
    
    /// Maps to a vector value for given signed-dist, location, and old value.
    typealias VectorMapper = (Float, Vector2F, Vector2F)->Vector2F
    
    typealias ScalarTarget = (ScalarGrid2, ScalarMapper)
    typealias VectorTarget = (VectorGrid2, VectorMapper)
    var _sourceRegion:ImplicitSurface2?
    var _isOneShot:Bool = true
    var _hasEmitted:Bool = false
    var _customScalarTargets:[ScalarTarget] = []
    var _customVectorTargets:[VectorTarget] = []
    
    var _isEnabled: Bool = true
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    /// Constructs an emitter with a source and is-one-shot flag.
    /// - Parameters:
    ///   - sourceRegion: Emitting region given by the SDF.
    ///   - isOneShot: True if emitter gets disabled after one shot.
    init(sourceRegion:ImplicitSurface2,
         isOneShot:Bool = true) {
        self._sourceRegion = sourceRegion
        self._isOneShot = isOneShot
    }
    
    /// Adds signed-distance target to the scalar grid.
    func addSignedDistanceTarget(scalarGridTarget:ScalarGrid2) {
        let mapper = {(sdf:Float, _:Vector2F, oldVal:Float)->Float in
            return min(oldVal, sdf)
        }
        addTarget(scalarGridTarget: scalarGridTarget,
                  customMapper: mapper)
    }
    
    /// Adds step function target to the scalar grid.
    /// - Parameters:
    ///   - scalarGridTarget: The scalar grid target.
    ///   - minValue: The minimum value of the step function.
    ///   - maxValue: The maximum value of the step function.
    func addStepFunctionTarget(
        scalarGridTarget:ScalarGrid2,
        minValue:Float,
        maxValue:Float) {
        let smoothingWidth:Float = scalarGridTarget.gridSpacing().min()
        let mapper = {(sdf:Float, _:Vector2F, oldVal:Float)->Float in
            let step = 1.0 - smearedHeavisideSdf(phi: sdf / smoothingWidth)
            return max(oldVal, (maxValue - minValue) * step + minValue)
        }
        addTarget(scalarGridTarget: scalarGridTarget, customMapper: mapper)
    }
    
    /// Adds a scalar grid target.
    ///
    /// This function adds a custom target to the emitter. The first parameter
    /// defines which grid should it write to. The second parameter,
    /// \p customMapper, defines how to map signed-distance field from the
    /// volume geometry and location of the point to the final scalar value that
    /// is going to be written to the target grid. The third parameter defines
    /// how to blend the old value from the target grid and the new value from
    /// the mapper function.
    /// - Parameters:
    ///   - scalarGridTarget: The scalar grid target
    ///   - customMapper: The custom mapper.
    func addTarget(
        scalarGridTarget:ScalarGrid2,
        customMapper:@escaping ScalarMapper) {
        _customScalarTargets.append((scalarGridTarget, customMapper))
    }
    
    /// Adds a vector grid target.
    ///
    /// This function adds a custom target to the emitter. The first parameter
    /// defines which grid should it write to. The second parameter,
    /// \p customMapper, defines how to map sigend-distance field from the
    /// volume geometry and location of the point to the final vector value that
    /// is going to be written to the target grid. The third parameter defines
    /// how to blend the old value from the target grid and the new value from
    /// the mapper function.
    /// - Parameters:
    ///   - vectorGridTarget: The vector grid target
    ///   - customMapper: The custom mapper.
    func addTarget(
        vectorGridTarget:VectorGrid2,
        customMapper:@escaping VectorMapper) {
        _customVectorTargets.append((vectorGridTarget, customMapper))
    }
    
    /// Returns implicit surface which defines the source region.
    func sourceRegion()->ImplicitSurface2 {
        return _sourceRegion!
    }
    
    /// Returns true if this emits only once.
    func isOneShot()->Bool {
        return _isOneShot
    }
    
    func onUpdate(currentTimeInSeconds: Float,
                  timeIntervalInSeconds: Float) {
        if (!isEnabled()) {
            return
        }
        
        emit()
        
        if (_isOneShot) {
            setIsEnabled(enabled: false)
        }
        
        _hasEmitted = true
    }
    
    func emit() {
        if (_sourceRegion == nil) {
            return
        }
        
        _sourceRegion!.updateQueryEngine()
        
        for target in _customScalarTargets {
            let grid = target.0
            let mapper = target.1
            
            let pos = grid.dataPosition()
            grid.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                let gx = pos(i, j)
                let sdf = sourceRegion().signedDistance(otherPoint: gx)
                grid[i, j] = mapper(sdf, gx, grid[i, j])
            }
        }
        
        for target in _customVectorTargets {
            let grid = target.0
            let mapper = target.1
            
            let collocated = grid as? CollocatedVectorGrid2
            if (collocated != nil) {
                let pos = collocated!.dataPosition()
                collocated!.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                    let gx = pos(i, j)
                    let sdf = sourceRegion().signedDistance(otherPoint: gx)
                    if (isInsideSdf(phi: sdf)) {
                        collocated![i, j] = mapper(sdf, gx, collocated![i, j])
                    }
                }
                continue
            }
            
            let faceCentered = grid as? FaceCenteredGrid2
            if (faceCentered != nil) {
                let uPos = faceCentered!.uPosition()
                let vPos = faceCentered!.vPosition()
                
                faceCentered!.parallelForEachUIndex(){(i:size_t, j:size_t) in
                    let gx = uPos(i, j)
                    let sdf = sourceRegion().signedDistance(otherPoint: gx)
                    let oldVal = faceCentered!.sample(x: gx)
                    let newVal = mapper(sdf, gx, oldVal)
                    faceCentered!.u(i: i, j: j, val: newVal.x)
                }
                faceCentered!.parallelForEachVIndex(){(i:size_t, j:size_t) in
                    let gx = vPos(i, j)
                    let sdf = sourceRegion().signedDistance(otherPoint: gx)
                    let oldVal = faceCentered!.sample(x: gx)
                    let newVal = mapper(sdf, gx, oldVal)
                    faceCentered!.v(i: i, j: j, val: newVal.y)
                }
                continue
            }
        }
    }
    
    //MARK:- Builder
    /// Front-end to create VolumeGridEmitter2 objects step by step.
    class Builder {
        var _sourceRegion:ImplicitSurface2?
        var _isOneShot:Bool = true
        
        /// Returns builder with surface defining source region.
        func withSourceRegion(sourceRegion:Surface2)->Builder {
            let implicit = sourceRegion as? ImplicitSurface2
            if (implicit != nil) {
                _sourceRegion = implicit
            } else {
                _sourceRegion = SurfaceToImplicit2(surface: sourceRegion)
            }
            return self
        }
        
        /// Returns builder with one-shot flag.
        func withIsOneShot(isOneShot:Bool)->Builder {
            _isOneShot = isOneShot
            return self
        }
        
        /// Builds VolumeGridEmitter2.
        func build()->VolumeGridEmitter2 {
            return VolumeGridEmitter2(sourceRegion: _sourceRegion!, isOneShot: _isOneShot)
        }
    }
    
    /// Returns builder fox VolumeGridEmitter2.
    static func builder()->Builder{
        return Builder()
    }
}
