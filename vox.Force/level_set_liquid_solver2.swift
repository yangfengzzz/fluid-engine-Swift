//
//  level_set_liquid_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Level set based 2-D liquid solver.
///
/// This class implements level set-based 2-D liquid solver. It defines the
/// surface of the liquid using signed-distance field and use stable fluids
/// framework to compute the forces.
///
/// \see Enright, Douglas, Stephen Marschner, and Ronald Fedkiw.
///     "Animation and rendering of complex water surfaces." ACM Transactions on
///     Graphics (TOG). Vol. 21. No. 3. ACM, 2002.
class LevelSetLiquidSolver2: GridFluidSolver2 {
    var _signedDistanceFieldId:size_t = 0
    var _levelSetSolver:LevelSetSolver2?
    var _minReinitializeDistance:Float = 10.0
    var _isGlobalCompensationEnabled:Bool = false
    var _lastKnownVolume:Float = 0.0
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1], gridSpacing: [1, 1], gridOrigin: [0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size2,
                  gridSpacing:Vector2F,
                  gridOrigin:Vector2F) {
        super.init(resolution: resolution, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let grids = gridSystemData()
        self._signedDistanceFieldId = grids.addAdvectableScalarData(builder: CellCenteredScalarGrid2.Builder(),
                                                                    initialVal: Float.greatestFiniteMagnitude)
        self._levelSetSolver = EnoLevelSetSolver2()
    }
    
    /// Returns signed-distance field.
    func signedDistanceField()->ScalarGrid2 {
        return gridSystemData().advectableScalarDataAt(idx: _signedDistanceFieldId)
    }
    
    /// Returns the level set solver.
    func levelSetSolver()->LevelSetSolver2 {
        return _levelSetSolver!
    }
    
    /// Sets the level set solver.
    func setLevelSetSolver(newSolver:LevelSetSolver2) {
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
    /// 24, no. 1 (2005): 81-97.
    func setIsGlobalCompensationEnabled(isEnabled:Bool) {
        _isGlobalCompensationEnabled = isEnabled
    }
    
    
    /// Returns liquid volume measured by smeared Heaviside function.
    ///
    /// This function measures the liquid volume (area in 2-D) using smeared
    /// Heaviside function. Thus, the estimated volume is an approximated
    /// quantity.
    func computeVolume()->Float {
        let sdf = signedDistanceField()
        let gridSpacing = sdf.gridSpacing()
        let cellVolume = gridSpacing.x * gridSpacing.y
        let h = max(gridSpacing.x, gridSpacing.y)
        
        var volume:Float = 0.0
        sdf.forEachDataPointIndex(){(i:size_t, j:size_t) in
            volume += 1.0 - smearedHeavisideSdf(phi: sdf[i, j] / h)
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
    /// LevelSetLiquidSolver2::signedDistanceField().
    override func fluidSdf()->ScalarField2 {
        return signedDistanceField()
    }
    
    func reinitialize(currentCfl:Float) {
        if (_levelSetSolver != nil) {
            var sdf = signedDistanceField()
            let sdf0 = sdf.clone()
            
            let gridSpacing = sdf.gridSpacing()
            let h = max(gridSpacing.x, gridSpacing.y)
            let maxReinitDist = max(2.0 * currentCfl, _minReinitializeDistance) * h
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
        let uPos = vel.uPosition()
        let vPos = vel.vPosition()
        
        var uMarker = Array2<CChar>(size: u.size())
        var vMarker = Array2<CChar>(size: v.size())
        
        uMarker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: sdf.sample(x: uPos(i, j)))) {
                uMarker[i, j] = 1
            } else {
                uMarker[i, j] = 0
                u[i, j] = 0.0
            }
        }
        
        vMarker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: sdf.sample(x: vPos(i, j)))) {
                vMarker[i, j] = 1
            } else {
                vMarker[i, j] = 0
                v[i, j] = 0.0
            }
        }
        
        let gridSpacing = sdf.gridSpacing()
        let h = max(gridSpacing.x, gridSpacing.y)
        let maxDist = max(2.0 * currentCfl, _minReinitializeDistance) * h
        logger.info("Max velocity extrapolation distance: \(maxDist)")
        
        let fmmSolver = FmmLevelSetSolver2()
        fmmSolver.extrapolate(input: vel, sdf: sdf, maxDistance: maxDist, output: &vel)
        
        applyBoundaryCondition()
    }
    
    func addVolume(volDiff:Float) {
        let sdf = signedDistanceField()
        let gridSpacing = sdf.gridSpacing()
        let cellVolume = gridSpacing.x * gridSpacing.y
        let h = max(gridSpacing.x, gridSpacing.y)
        
        var volume0:Float = 0.0
        var volume1:Float = 0.0
        sdf.forEachDataPointIndex(){(i:size_t, j:size_t) in
            volume0 += 1.0 - smearedHeavisideSdf(phi: sdf[i, j] / h)
            volume1 += 1.0 - smearedHeavisideSdf(phi: sdf[i, j] / h + 1.0)
        }
        volume0 *= cellVolume
        volume1 *= cellVolume
        
        let dVdh = (volume1 - volume0) / h
        
        if (abs(dVdh) > 0.0) {
            let dist = volDiff / dVdh
            
            sdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                sdf[i, j] += dist
            }
        }
    }
    
    //MARK:- Builder
    /// Front-end to create LevelSetLiquidSolver2 objects step by step.
    class Builder: GridFluidSolverBuilderBase2<Builder> {
        /// Builds LevelSetLiquidSolver2.
        func build()->LevelSetLiquidSolver2 {
            return LevelSetLiquidSolver2(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox LevelSetLiquidSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension LevelSetLiquidSolver2 {
    func extrapolateVelocityToAir_GPU(currentCfl:Float) {
        let sdf = signedDistanceField()
        var vel = gridSystemData().velocity()
        let u = vel.uAccessor()
        let v = vel.vAccessor()
        var uMarker = Array2<CChar>(size: u.size())
        var vMarker = Array2<CChar>(size: v.size())
        var resolution = Vector2<UInt32>(UInt32(vel.resolution().x),
                                         UInt32(vel.resolution().y))
        
        uMarker.parallelForEachIndex(name: "LevelSetLiquidSolver2::extrapolateVelocityToAirU") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = sdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+1)
        }
        
        vMarker.parallelForEachIndex(name: "LevelSetLiquidSolver2::extrapolateVelocityToAirV") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = sdf.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+1)
        }
        
        let gridSpacing = sdf.gridSpacing()
        let h = max(gridSpacing.x, gridSpacing.y)
        let maxDist = max(2.0 * currentCfl, _minReinitializeDistance) * h
        logger.info("Max velocity extrapolation distance: \(maxDist)")
        
        let fmmSolver = FmmLevelSetSolver2()
        fmmSolver.extrapolate(input: vel, sdf: sdf, maxDistance: maxDist, output: &vel)
        
        applyBoundaryCondition()
    }
}
