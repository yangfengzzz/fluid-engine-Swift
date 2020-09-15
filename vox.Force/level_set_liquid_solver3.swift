//
//  level_set_liquid_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Level set based 3-D liquid solver.
///
/// This class implements level set-based 3-D liquid solver. It defines the
/// surface of the liquid using signed-distance field and use stable fluids
/// framework to compute the forces.
///
/// \see Enright, Douglas, Stephen Marschner, and Ronald Fedkiw.
///     "Animation and rendering of complex water surfaces." ACM Transactions on
///     Graphics (TOG). Vol. 21. No. 3. ACM, 2002.
class LevelSetLiquidSolver3: GridFluidSolver3 {
    var _signedDistanceFieldId:size_t = 0
    var _levelSetSolver:LevelSetSolver3?
    var _minReinitializeDistance:Float = 10.0
    var _isGlobalCompensationEnabled:Bool = false
    var _lastKnownVolume:Float = 0.0
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1, 1], gridSpacing: [1, 1, 1], gridOrigin: [0, 0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size3,
                  gridSpacing:Vector3F,
                  gridOrigin:Vector3F) {
        super.init(resolution: resolution, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let grids = gridSystemData()
        self._signedDistanceFieldId = grids.addAdvectableScalarData(builder: CellCenteredScalarGrid3.Builder(),
                                                                    initialVal: Float.greatestFiniteMagnitude)
        self._levelSetSolver = EnoLevelSetSolver3()
    }
    
    /// Returns signed-distance field.
    func signedDistanceField()->ScalarGrid3 {
        return gridSystemData().advectableScalarDataAt(idx: _signedDistanceFieldId)
    }
    
    /// Returns the level set solver.
    func levelSetSolver()->LevelSetSolver3 {
        return _levelSetSolver!
    }
    
    /// Sets the level set solver.
    func setLevelSetSolver(newSolver:LevelSetSolver3) {
        _levelSetSolver = newSolver
    }
    
    /// Sets minimum reinitialization distance.
    func setMinReinitializeDistance(distance:Float) {
        _minReinitializeDistance = distance
    }
    
    /// Enables (or disables) global compensation feature flag.
    ///
    /// When \p isEnabled is true, the global compensation feature is enabled.
    /// The global compensation measures the volume at the beginning and the end
    /// of the time-step and adds the volume change back to the level-set field
    /// by globally shifting the front.
    ///
    /// \see Song, Oh-Young, Hyuncheol Shin, and Hyeong-Seok Ko.
    /// "Stable but nondissipative water." ACM Transactions on Graphics (TOG)
    /// 34, no. 1 (3005): 81-97.
    func setIsGlobalCompensationEnabled(isEnabled:Bool) {
        _isGlobalCompensationEnabled = isEnabled
    }
    
    
    /// Returns liquid volume measured by smeared Heaviside function.
    ///
    /// This function measures the liquid volume (area in 3-D) using smeared
    /// Heaviside function. Thus, the estimated volume is an approximated
    /// quantity.
    func computeVolume()->Float {
        let sdf = signedDistanceField()
        let gridSpacing = sdf.gridSpacing()
        let cellVolume = gridSpacing.x * gridSpacing.y * gridSpacing.z
        let h = max(gridSpacing.x, gridSpacing.y, gridSpacing.z)
        
        var volume:Float = 0.0
        sdf.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            volume += 1.0 - smearedHeavisideSdf(phi: sdf[i, j, k] / h)
        }
        volume *= cellVolume
        
        return volume
    }
    
    /// Called at the beginning of the time-step.
    override func onBeginAdvanceTimeStep(timeIntervalInSeconds:Double) {
        // Measure current volume
        _lastKnownVolume = computeVolume()
        logger.info("Current volume: \(_lastKnownVolume)")
    }
    
    /// Called at the end of the time-step.
    override func onEndAdvanceTimeStep(timeIntervalInSeconds:Double) {
        let currentCfl = cfl(timeIntervalInSeconds: Float(timeIntervalInSeconds))
        
        let timer = Date()
        reinitialize(currentCfl: currentCfl)
        logger.info("reinitializing level set field took \(Date().timeIntervalSince(timer)) seconds")
        
        // Measure current volume
        var currentVol = computeVolume()
        let volDiff = currentVol - _lastKnownVolume
        logger.info("Current volume: \(currentVol) Volume diff: \(volDiff)")
        
        if (_isGlobalCompensationEnabled) {
            addVolume(volDiff: -volDiff)
            
            currentVol = computeVolume()
            logger.info("Volume after global compensation: \(currentVol)")
        }
    }
    
    /// Customizes advection step.
    override func computeAdvection(timeIntervalInSeconds:Double) {
        let currentCfl = cfl(timeIntervalInSeconds: Float(timeIntervalInSeconds))
        
        let timer = Date()
        if Renderer.arch == .CPU {
            extrapolateVelocityToAir(currentCfl: currentCfl)
        } else {
            extrapolateVelocityToAir_GPU(currentCfl: currentCfl)
        }
        logger.info("velocity extrapolation took \(Date().timeIntervalSince(timer)) seconds")
        
        super.computeAdvection(timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    /// Returns fluid region as a signed-distance field.
    ///
    /// This function returns fluid region as a signed-distance field. For this
    /// particular class, it returns the same field as the function
    /// LevelSetLiquidSolver3::signedDistanceField().
    override func fluidSdf()->ScalarField3 {
        return signedDistanceField()
    }
    
    func reinitialize(currentCfl:Float) {
        if (_levelSetSolver != nil) {
            var sdf = signedDistanceField()
            let sdf0 = sdf.clone()
            
            let gridSpacing = sdf.gridSpacing()
            let h = max(gridSpacing.x, gridSpacing.y)
            let maxReinitDist = max(3.0 * currentCfl, _minReinitializeDistance) * h
            logger.info("Max reinitialize distance: \(maxReinitDist)")
            
            _levelSetSolver!.reinitialize(
                inputSdf: sdf0, maxDistance: maxReinitDist, outputSdf: &sdf)
            extrapolateIntoCollider(grid: &sdf)
        }
    }
    
    func extrapolateVelocityToAir(currentCfl:Float) {
        let sdf = signedDistanceField()
        var vel = gridSystemData().velocity()
        
        var u = vel.uAccessor()
        var v = vel.vAccessor()
        var w = vel.wAccessor()
        let uPos = vel.uPosition()
        let vPos = vel.vPosition()
        let wPos = vel.wPosition()
        
        var uMarker = Array3<CChar>(size: u.size())
        var vMarker = Array3<CChar>(size: v.size())
        var wMarker = Array3<CChar>(size: w.size())
        
        uMarker.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: sdf.sample(x: uPos(i, j, k)))) {
                uMarker[i, j, k] = 1
            } else {
                uMarker[i, j, k] = 0
                u[i, j, k] = 0.0
            }
        }
        
        vMarker.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: sdf.sample(x: vPos(i, j, k)))) {
                vMarker[i, j, k] = 1
            } else {
                vMarker[i, j, k] = 0
                v[i, j, k] = 0.0
            }
        }
        
        wMarker.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (isInsideSdf(phi: sdf.sample(x: wPos(i, j, k)))) {
                wMarker[i, j, k] = 1
            } else {
                wMarker[i, j, k] = 0
                w[i, j, k] = 0.0
            }
        }
        
        let gridSpacing = sdf.gridSpacing()
        let h = max(gridSpacing.x, gridSpacing.y, gridSpacing.z)
        let maxDist = max(2.0 * currentCfl, _minReinitializeDistance) * h
        logger.info("Max velocity extrapolation distance: \(maxDist)")
        
        let fmmSolver = FmmLevelSetSolver3()
        fmmSolver.extrapolate(input: vel, sdf: sdf, maxDistance: maxDist, output: &vel)
        
        applyBoundaryCondition()
    }
    
    func addVolume(volDiff:Float) {
        let sdf = signedDistanceField()
        let gridSpacing = sdf.gridSpacing()
        let cellVolume = gridSpacing.x * gridSpacing.y * gridSpacing.z
        let h = max(gridSpacing.x, gridSpacing.y, gridSpacing.z)
        
        var volume0:Float = 0.0
        var volume1:Float = 0.0
        sdf.forEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            volume0 += 1.0 - smearedHeavisideSdf(phi: sdf[i, j, k] / h)
            volume1 += 1.0 - smearedHeavisideSdf(phi: sdf[i, j, k] / h + 1.0)
        }
        volume0 *= cellVolume
        volume1 *= cellVolume
        
        let dVdh = (volume1 - volume0) / h
        
        if (abs(dVdh) > 0.0) {
            let dist = volDiff / dVdh
            
            sdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
                sdf[i, j, k] += dist
            }
        }
    }
    
    //MARK:- Builder
    /// Front-end to create LevelSetLiquidSolver3 objects step by step.
    class Builder: GridFluidSolverBuilderBase3<Builder> {
        /// Builds LevelSetLiquidSolver3.
        func build()->LevelSetLiquidSolver3 {
            return LevelSetLiquidSolver3(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox LevelSetLiquidSolver3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension LevelSetLiquidSolver3 {
    func extrapolateVelocityToAir_GPU(currentCfl:Float) {
        let sdf = signedDistanceField()
        var vel = gridSystemData().velocity()
        let u = vel.uAccessor()
        let v = vel.vAccessor()
        let w = vel.wAccessor()
        var uMarker = Array3<CChar>(size: u.size())
        var vMarker = Array3<CChar>(size: v.size())
        var wMarker = Array3<CChar>(size: w.size())
        var resolution = Vector3<UInt32>(UInt32(vel.resolution().x),
                                         UInt32(vel.resolution().y),
                                         UInt32(vel.resolution().z))
        
        uMarker.parallelForEachIndex(name: "LevelSetLiquidSolver3::extrapolateVelocityToAirU") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = sdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index+1)
        }
        
        vMarker.parallelForEachIndex(name: "LevelSetLiquidSolver3::extrapolateVelocityToAirV") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = sdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index+1)
        }
        
        wMarker.parallelForEachIndex(name: "LevelSetLiquidSolver3::extrapolateVelocityToAirW") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = sdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index+1)
        }
        
        let gridSpacing = sdf.gridSpacing()
        let h = max(gridSpacing.x, gridSpacing.y, gridSpacing.z)
        let maxDist = max(2.0 * currentCfl, _minReinitializeDistance) * h
        logger.info("Max velocity extrapolation distance: \(maxDist)")
        
        let fmmSolver = FmmLevelSetSolver3()
        fmmSolver.extrapolate(input: vel, sdf: sdf, maxDistance: maxDist, output: &vel)
        
        applyBoundaryCondition()
    }
}
