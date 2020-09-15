//
//  grid_smoke_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D grid-based smoke solver.
///
/// This class extends GridFluidSolver2 to implement smoke simulation solver.
/// It adds smoke density and temperature fields to define the smoke and uses
/// buoyancy force to simulate hot rising smoke.
///
/// \see Fedkiw, Ronald, Jos Stam, and Henrik Wann Jensen.
///     "Visual simulation of smoke." Proceedings of the 28th annual conference
///     on Computer graphics and interactive techniques. ACM, 2001.
class GridSmokeSolver2: GridFluidSolver2 {
    var _smokeDensityDataId:size_t = 0
    var _temperatureDataId:size_t = 0
    var _smokeDiffusionCoefficient:Float = 0.0
    var _temperatureDiffusionCoefficient:Float = 0.0
    var _buoyancySmokeDensityFactor:Float = -0.000625
    var _buoyancyTemperatureFactor:Float = 5.0
    var _smokeDecayFactor:Float = 0.001
    var _temperatureDecayFactor:Float = 0.001
    
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
        self._smokeDensityDataId = grids.addAdvectableScalarData(builder: CellCenteredScalarGrid2.Builder(), initialVal: 0.0)
        self._temperatureDataId = grids.addAdvectableScalarData(builder: CellCenteredScalarGrid2.Builder(), initialVal: 0.0)
    }
    
    /// Returns smoke diffusion coefficient.
    func smokeDiffusionCoefficient()->Float {
        return _smokeDiffusionCoefficient
    }
    
    /// Sets smoke diffusion coefficient.
    func setSmokeDiffusionCoefficient(newValue:Float) {
        _smokeDiffusionCoefficient = max(newValue, 0.0)
    }
    
    /// Returns temperature diffusion coefficient.
    func temperatureDiffusionCoefficient()->Float {
        return _temperatureDiffusionCoefficient
    }
    
    /// Sets temperature diffusion coefficient.
    func setTemperatureDiffusionCoefficient(newValue:Float) {
        _temperatureDiffusionCoefficient = max(newValue, 0.0)
    }
    
    /// Returns the buoyancy factor which will be multiplied to the
    ///     smoke density.
    ///
    /// This class computes buoyancy by looking up the value of smoke density
    /// and temperature, compare them to the average values, and apply
    /// multiplier factor to the diff between the value and the average. That
    /// multiplier is defined for each smoke density and temperature separately.
    /// For example, negative smoke density buoyancy factor means a heavier
    /// smoke should sink.
    /// - Returns: The buoyance factor for the smoke density.
    func buoyancySmokeDensityFactor()->Float {
        return _buoyancySmokeDensityFactor
    }
    
    /// Sets the buoyancy factor which will be multiplied to the
    ///     smoke density.
    ///
    /// This class computes buoyancy by looking up the value of smoke density
    /// and temperature, compare them to the average values, and apply
    /// multiplier factor to the diff between the value and the average. That
    /// multiplier is defined for each smoke density and temperature separately.
    /// For example, negative smoke density buoyancy factor means a heavier
    /// smoke should sink.
    /// - Parameter newValue: The new buoyancy factor for smoke density.
    func setBuoyancySmokeDensityFactor(newValue:Float) {
        _buoyancySmokeDensityFactor = newValue
    }
    
    /// Returns the buoyancy factor which will be multiplied to the
    ///     temperature.
    ///
    /// This class computes buoyancy by looking up the value of smoke density
    /// and temperature, compare them to the average values, and apply
    /// multiplier factor to the diff between the value and the average. That
    /// multiplier is defined for each smoke density and temperature separately.
    /// For example, negative smoke density buoyancy factor means a heavier
    /// smoke should sink.
    /// - Returns: The buoyance factor for the temperature.
    func buoyancyTemperatureFactor()->Float {
        return _buoyancyTemperatureFactor
    }
    
    
    /// Sets the buoyancy factor which will be multiplied to the
    ///     temperature.
    ///
    /// This class computes buoyancy by looking up the value of smoke density
    /// and temperature, compare them to the average values, and apply
    /// multiplier factor to the diff between the value and the average. That
    /// multiplier is defined for each smoke density and temperature separately.
    /// For example, negative smoke density buoyancy factor means a heavier
    /// smoke should sink.
    /// - Parameter newValue: The new buoyancy factor for temperature.
    func setBuoyancyTemperatureFactor(newValue:Float) {
        _buoyancyTemperatureFactor = newValue
    }
    
    /// Returns smoke decay factor.
    ///
    /// In addition to the diffusion, the smoke also can fade-out over time by
    /// setting the decay factor between 0 and 1.
    /// - Returns: The decay factor for smoke density.
    func smokeDecayFactor()->Float {
        return _smokeDecayFactor
    }
    
    
    /// Sets the smoke decay factor.
    ///
    /// In addition to the diffusion, the smoke also can fade-out over time by
    /// setting the decay factor between 0 and 1.
    /// - Parameter newValue: The new decay factor.
    func setSmokeDecayFactor(newValue:Float) {
        _smokeDecayFactor = Math.clamp(val: newValue, low: 0.0, high: 1.0)
    }
    
    /// Returns temperature decay factor.
    ///
    /// In addition to the diffusion, the smoke also can fade-out over time by
    /// setting the decay factor between 0 and 1.
    /// - Returns: The decay factor for smoke temperature.
    func smokeTemperatureDecayFactor()->Float {
        return _temperatureDecayFactor
    }
    
    /// Sets the temperature decay factor.
    ///
    /// In addition to the diffusion, the temperature also can fade-out over
    /// time by setting the decay factor between 0 and 1.
    /// - Parameter newValue: The new decay factor.
    func setTemperatureDecayFactor(newValue:Float) {
        _temperatureDecayFactor = Math.clamp(val: newValue, low: 0.0, high: 1.0)
    }
    
    /// Returns smoke density field.
    func smokeDensity()->ScalarGrid2 {
        return gridSystemData().advectableScalarDataAt(idx: _smokeDensityDataId)
    }
    
    /// Returns temperature field.
    func temperature()->ScalarGrid2 {
        return gridSystemData().advectableScalarDataAt(idx: _temperatureDataId)
    }
    
    override func onEndAdvanceTimeStep(timeIntervalInSeconds:Double) {
        computeDiffusion(timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    override func computeExternalForces(timeIntervalInSeconds:Double) {
        if Renderer.arch == .CPU {
            computeBuoyancyForce(timeIntervalInSeconds: timeIntervalInSeconds)
        } else {
            computeBuoyancyForce_GPU(timeIntervalInSeconds: timeIntervalInSeconds)
        }
    }
    
    func computeDiffusion(timeIntervalInSeconds:Double) {
        if (diffusionSolver() != nil) {
            if (_smokeDiffusionCoefficient > Float.leastNonzeroMagnitude) {
                var den = smokeDensity()
                let den0 = den.clone() as? CellCenteredScalarGrid2
                
                diffusionSolver()!.solve(source: den0!, diffusionCoefficient: _smokeDiffusionCoefficient,
                                         timeIntervalInSeconds: Float(timeIntervalInSeconds), dest: &den,
                                         boundarySdf: colliderSdf(),
                                         fluidSdf: ConstantScalarField2(value: -Float.greatestFiniteMagnitude))
                extrapolateIntoCollider(grid: &den)
            }
            
            if (_temperatureDiffusionCoefficient > Float.leastNonzeroMagnitude) {
                var temp = smokeDensity()
                let temp0 = temp.clone() as? CellCenteredScalarGrid2
                
                diffusionSolver()!.solve(source: temp0!, diffusionCoefficient: _temperatureDiffusionCoefficient,
                                         timeIntervalInSeconds: Float(timeIntervalInSeconds), dest: &temp,
                                         boundarySdf: colliderSdf(),
                                         fluidSdf: ConstantScalarField2(value: -Float.greatestFiniteMagnitude))
                extrapolateIntoCollider(grid: &temp)
            }
        }
        
        let den = smokeDensity()
        if Renderer.arch == .CPU {
            den.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                den[i, j] *= 1.0 - _smokeDecayFactor
            }
        } else {
            den.parallelForEachDataPointIndex(name: "GridSmokeSolver2::den_scalar") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                encoder.setBytes(&_smokeDecayFactor, length: MemoryLayout<Float>.stride, index: index)
            }
        }
        
        
        let temp = temperature()
        if Renderer.arch == .CPU {
            temp.parallelForEachDataPointIndex(){(i:size_t, j:size_t) in
                temp[i, j] *= 1.0 - _temperatureDecayFactor
            }
        } else {
            temp.parallelForEachDataPointIndex(name: "GridSmokeSolver2::temp_scalar") {
                (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                encoder.setBytes(&_temperatureDecayFactor, length: MemoryLayout<Float>.stride, index: index)
            }
        }
    }
    
    func computeBuoyancyForce(timeIntervalInSeconds:Double) {
        let grids = gridSystemData()
        let vel = grids.velocity()
        
        var up = Vector2F(0, 1)
        if (length_squared(gravity()) > Float.leastNonzeroMagnitude) {
            up = normalize(-gravity())
        }
        
        if (abs(_buoyancySmokeDensityFactor) > Float.leastNonzeroMagnitude ||
            abs(_buoyancyTemperatureFactor) > Float.leastNonzeroMagnitude) {
            let den = smokeDensity()
            let temp = temperature()
            
            var tAmb:Float = 0.0
            temp.forEachCellIndex(){(i:size_t, j:size_t) in
                tAmb += temp[i, j]
            }
            tAmb /= Float(temp.resolution().x * temp.resolution().y)
            
            var u = vel.uAccessor()
            var v = vel.vAccessor()
            let uPos = vel.uPosition()
            let vPos = vel.vPosition()
            
            if (abs(up.x) > Float.leastNonzeroMagnitude) {
                vel.parallelForEachUIndex(){(i:size_t, j:size_t) in
                    let pt = uPos(i, j)
                    let fBuoy =
                        _buoyancySmokeDensityFactor * den.sample(x: pt) +
                            _buoyancyTemperatureFactor * (temp.sample(x: pt) - tAmb)
                    u[i, j] += Float(timeIntervalInSeconds) * fBuoy * up.x
                }
            }
            
            if (abs(up.y) > Float.leastNonzeroMagnitude) {
                vel.parallelForEachVIndex(){(i:size_t, j:size_t) in
                    let pt = vPos(i, j)
                    let fBuoy =
                        _buoyancySmokeDensityFactor * den.sample(x: pt) +
                            _buoyancyTemperatureFactor * (temp.sample(x: pt) - tAmb)
                    v[i, j] += Float(timeIntervalInSeconds) * fBuoy * up.y
                }
            }
            
            applyBoundaryCondition()
        }
    }
    
    //MARK:- Builder
    /// Front-end to create GridSmokeSolver2 objects step by step.
    class Builder: GridFluidSolverBuilderBase2<Builder> {
        /// Builds GridSmokeSolver2.
        func build()->GridSmokeSolver2 {
            return GridSmokeSolver2(resolution: _resolution, gridSpacing: getGridSpacing(), gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox GridSmokeSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension GridSmokeSolver2 {
    func computeBuoyancyForce_GPU(timeIntervalInSeconds:Double) {
        let grids = gridSystemData()
        let vel = grids.velocity()
        var resolution = Vector2<UInt32>(UInt32(vel.resolution().x),
                                         UInt32(vel.resolution().y))
        
        var up = Vector2F(0, 1)
        if (length_squared(gravity()) > Float.leastNonzeroMagnitude) {
            up = normalize(-gravity())
        }
        
        if (abs(_buoyancySmokeDensityFactor) > Float.leastNonzeroMagnitude ||
            abs(_buoyancyTemperatureFactor) > Float.leastNonzeroMagnitude) {
            let den = smokeDensity()
            let temp = temperature()
            
            var tAmb:Float = 0.0
            temp.forEachCellIndex(){(i:size_t, j:size_t) in
                tAmb += temp[i, j]
            }
            tAmb /= Float(temp.resolution().x * temp.resolution().y)
            
            if (abs(up.x) > Float.leastNonzeroMagnitude) {
                vel.parallelForEachUIndex(name: "GridSmokeSolver2::computeBuoyancyForceU") {
                    (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                    index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    index = den.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    index = temp.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    encoder.setBytes(&tAmb, length: MemoryLayout<Float>.stride, index: index)
                    var timeIntervalInSeconds = Float(timeIntervalInSeconds)
                    encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
                    encoder.setBytes(&_buoyancySmokeDensityFactor, length: MemoryLayout<Float>.stride, index: index+2)
                    encoder.setBytes(&_buoyancyTemperatureFactor, length: MemoryLayout<Float>.stride, index: index+3)
                    var upx = up.x
                    encoder.setBytes(&upx, length: MemoryLayout<Float>.stride, index: index+4)
                    encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+5)
                }
            }
            
            if (abs(up.y) > Float.leastNonzeroMagnitude) {
                vel.parallelForEachVIndex(name: "GridSmokeSolver2::computeBuoyancyForceV") {
                    (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                    index = vel.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    index = den.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    index = temp.loadGPUBuffer(encoder: &encoder, index_begin: index)
                    encoder.setBytes(&tAmb, length: MemoryLayout<Float>.stride, index: index)
                    var timeIntervalInSeconds = Float(timeIntervalInSeconds)
                    encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
                    encoder.setBytes(&_buoyancySmokeDensityFactor, length: MemoryLayout<Float>.stride, index: index+2)
                    encoder.setBytes(&_buoyancyTemperatureFactor, length: MemoryLayout<Float>.stride, index: index+3)
                    var upy = up.y
                    encoder.setBytes(&upy, length: MemoryLayout<Float>.stride, index: index+4)
                    encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index+5)
                }
            }
            
            applyBoundaryCondition()
        }
    }
}
