//
//  sph_system_data2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 2-D SPH particle system data.
///
/// This class extends ParticleSystemData2 to specialize the data model for SPH.
/// It includes density and pressure array as a default particle attribute, and
/// it also contains SPH utilities such as interpolation operator.
class SphSystemData2: ParticleSystemData2 {
    /// Target density of this particle system in kg/m^2.
    var _targetDensity:Float = kWaterDensity
    /// Target spacing of this particle system in meters.
    var _targetSpacing:Float = 0.1
    /// Relative radius of SPH kernel.
    /// SPH kernel radius divided by target spacing.
    var _kernelRadiusOverTargetSpacing:Float = 1.8
    /// SPH kernel radius in meters.
    var _kernelRadius:Float = 0
    
    var _pressureIdx:size_t = 0
    var _densityIdx:size_t = 0
    
    /// Constructs empty SPH system.
    convenience init() {
        self.init(numberOfParticles: 0)
    }
    
    override init(numberOfParticles:size_t) {
        super.init(numberOfParticles: numberOfParticles)
        
        self._densityIdx = addScalarData()
        self._pressureIdx = addScalarData()
        setTargetSpacing(spacing: _targetSpacing)
    }
    
    /// Copy constructor.
    init(other:SphSystemData2) {
        super.init(other: other)
        set(other: other)
    }
    
    /// Sets the radius.
    ///
    /// Sets the radius of the particle system. The radius will be interpreted
    /// as target spacing.
    override func setRadius(newRadius:Float) {
        // Interpret it as setting target spacing
        setTargetSpacing(spacing: newRadius)
    }
    
    /// Sets the mass of a particle.
    ///
    /// Setting the mass of a particle will change the target density.
    /// - Parameter newMass: The new mass.
    override func setMass(newMass:Float) {
        let incRatio = newMass / mass()
        _targetDensity *= incRatio
        super.setMass(newMass: newMass)
    }
    
    /// Returns the density array accessor (immutable).
    func densities()->ConstArrayAccessor1<Float> {
        return scalarDataAt(idx: _densityIdx)
    }
    
    /// Returns the density array accessor (mutable).
    func densities()->ArrayAccessor1<Float> {
        return scalarDataAt(idx: _densityIdx)
    }
    
    /// Returns the pressure array accessor (immutable).
    func pressures()->ConstArrayAccessor1<Float> {
        return scalarDataAt(idx: _pressureIdx)
    }
    
    /// Returns the pressure array accessor (mutable).
    func pressures()->ArrayAccessor1<Float> {
        return scalarDataAt(idx: _pressureIdx)
    }
    
    /// Updates the density array with the latest particle positions.
    ///
    /// This function updates the density array by recalculating each particle's
    /// latest nearby particles' position.
    /// - Warning: You must update the neighbor searcher
    /// (SphSystemData2::buildNeighborSearcher) before calling this function.
    func updateDensities() {
        let p:ArrayAccessor1<Vector2F> = positions()
        var d:ArrayAccessor1<Float> = densities()
        let m = mass()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles()){(i:size_t) in
            let sum = sumOfKernelNearby(position: p[i])
            d[i] = m * sum
        }
    }
    
    /// Sets the target density of this particle system.
    func setTargetDensity(targetDensity:Float) {
        _targetDensity = targetDensity
        
        computeMass()
    }
    
    /// Returns the target density of this particle system.
    func targetDensity()->Float {
        return _targetDensity
    }
    
    /// Sets the target particle spacing in meters.
    ///
    /// Once this function is called, hash grid and density should be
    /// updated using updateHashGrid() and updateDensities).
    func setTargetSpacing(spacing:Float) {
        super.setRadius(newRadius: spacing)
        
        _targetSpacing = spacing
        _kernelRadius = _kernelRadiusOverTargetSpacing * _targetSpacing
        
        computeMass()
    }
    
    /// Returns the target particle spacing in meters.
    func targetSpacing()->Float {
        return _targetSpacing
    }
    
    /// Sets the relative kernel radius.
    ///
    /// Sets the relative kernel radius compared to the target particle
    /// spacing (i.e. kernel radius / target spacing).
    /// Once this function is called, hash grid and density should
    /// be updated using updateHashGrid() and updateDensities).
    func setRelativeKernelRadius(relativeRadius:Float) {
        _kernelRadiusOverTargetSpacing = relativeRadius
        _kernelRadius = _kernelRadiusOverTargetSpacing * _targetSpacing
        
        computeMass()
    }
    
    /// Returns the relative kernel radius.
    ///
    /// Returns the relative kernel radius compared to the target particle
    /// spacing (i.e. kernel radius / target spacing).
    func relativeKernelRadius()->Float {
        return _kernelRadiusOverTargetSpacing
    }
    
    /// Sets the absolute kernel radius.
    ///
    /// Sets the absolute kernel radius compared to the target particle
    /// spacing (i.e. relative kernel radius * target spacing).
    /// Once this function is called, hash grid and density should
    /// be updated using updateHashGrid() and updateDensities).
    func setKernelRadius(kernelRadius:Float) {
        _kernelRadius = kernelRadius
        _targetSpacing = kernelRadius / _kernelRadiusOverTargetSpacing
        
        computeMass()
    }
    
    /// Returns the kernel radius in meters unit.
    func kernelRadius()->Float {
        return _kernelRadius
    }
    
    /// Returns sum of kernel function evaluation for each nearby particle.
    func sumOfKernelNearby(position origin:Vector2F)->Float {
        var sum:Float = 0.0
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        neighborSearcher().forEachNearbyPoint(origin: origin, radius: _kernelRadius){
            (_:size_t, neighborPosition:Vector2F) in
            let dist = length(origin - neighborPosition)
            sum += kernel[dist]
        }
        return sum
    }
    
    /// Returns interpolated value at given origin point.
    ///
    /// Returns interpolated scalar data from the given position using
    /// standard SPH weighted average. The data array should match the
    /// particle layout. For example, density or pressure arrays can be
    /// used.
    /// - Warning: You must update the neighbor searcher
    /// (SphSystemData2::buildNeighborSearcher) before calling this function.
    func interpolate(origin:Vector2F,
                     values:ConstArrayAccessor1<Float>)->Float {
        var sum:Float = 0.0
        let d:ArrayAccessor1<Float> = densities()
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        let m = mass()
        
        neighborSearcher().forEachNearbyPoint(origin: origin, radius: _kernelRadius){
            (i:size_t, neighborPosition:Vector2F) in
            let dist = length(origin - neighborPosition)
            let weight = m / d[i] * kernel[dist]
            sum += weight * values[i]
        }
        
        return sum
    }
    
    /// Returns interpolated vector value at given origin point.
    ///
    /// Returns interpolated vector data from the given position using
    /// standard SPH weighted average. The data array should match the
    /// particle layout. For example, velocity or acceleration arrays can be
    /// used.
    /// - Warning: You must update the neighbor searcher
    /// (SphSystemData2::buildNeighborSearcher) before calling this function.
    func interpolate(origin:Vector2F,
                     values:ConstArrayAccessor1<Vector2F>)->Vector2F {
        var sum = Vector2F()
        let d:ArrayAccessor1<Float> = densities()
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        let m = mass()
        
        neighborSearcher().forEachNearbyPoint(origin: origin, radius: _kernelRadius){
            (i:size_t, neighborPosition:Vector2F) in
            let dist = length(origin - neighborPosition)
            let weight = m / d[i] * kernel[dist]
            sum += weight * values[i]
        }
        
        return sum
    }
    
    /// Returns the gradient of the given values at i-th particle.
    ///
    /// - Warning: You must update the neighbor lists
    /// (SphSystemData2::buildNeighborLists) before calling this function.
    func gradientAt(i:size_t,
                    values:ConstArrayAccessor1<Float>)->Vector2F {
        var sum = Vector2F()
        let p:ArrayAccessor1<Vector2F> = positions()
        let d:ArrayAccessor1<Float> = densities()
        let neighbors = neighborLists()[i]
        let origin = p[i]
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        let m = mass()
        
        for j in neighbors {
            let neighborPosition = p[j]
            let dist = length(origin - neighborPosition)
            if (dist > 0.0) {
                let dir = (neighborPosition - origin) / dist
                let para:Float = d[i] * m * (values[i] / Math.square(of: d[i]) + values[j] / Math.square(of: d[j]))
                sum += para * kernel.gradient(distance: dist, direction: dir)
            }
        }
        
        return sum
    }
    
    /// Returns the laplacian of the given values at i-th particle.
    ///
    /// - Warning: You must update the neighbor lists
    /// (SphSystemData2::buildNeighborLists) before calling this function.
    func laplacianAt(i:size_t,
                     values:ConstArrayAccessor1<Float>)->Float {
        var sum:Float = 0.0
        let p:ArrayAccessor1<Vector2F> = positions()
        let d:ArrayAccessor1<Float> = densities()
        let neighbors = neighborLists()[i]
        let origin = p[i]
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        let m = mass()
        
        for j in neighbors {
            let neighborPosition = p[j]
            let dist = length(origin - neighborPosition)
            sum += m * (values[j] - values[i]) / d[j] * kernel.secondDerivative(distance: dist)
        }
        
        return sum
    }
    
    /// Returns the laplacian of the given values at i-th particle.
    ///
    /// - Warning: You must update the neighbor lists
    /// (SphSystemData2::buildNeighborLists) before calling this function.
    func laplacianAt(i:size_t,
                     values:ConstArrayAccessor1<Vector2F>)->Vector2F {
        var sum = Vector2F()
        let p:ArrayAccessor1<Vector2F> = positions()
        let d:ArrayAccessor1<Float> = densities()
        let neighbors = neighborLists()[i]
        let origin = p[i]
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        let m = mass()
        
        for j in neighbors {
            let neighborPosition = p[j]
            let dist = length(origin - neighborPosition)
            sum += m * (values[j] - values[i]) / d[j] * kernel.secondDerivative(distance: dist)
        }
        
        return sum
    }
    
    /// Builds neighbor searcher with kernel radius.
    func buildNeighborSearcher() {
        super.buildNeighborSearcher(maxSearchRadius: _kernelRadius)
    }
    
    /// Builds neighbor lists with kernel radius.
    func buildNeighborLists() {
        super.buildNeighborLists(maxSearchRadius: _kernelRadius)
    }
    
    /// Copies from other SPH system data.
    func set(other:SphSystemData2) {
        super.set(other: other)
        _targetDensity = other._targetDensity
        _targetSpacing = other._targetSpacing
        _kernelRadiusOverTargetSpacing = other._kernelRadiusOverTargetSpacing
        _kernelRadius = other._kernelRadius
        _densityIdx = other._densityIdx
        _pressureIdx = other._pressureIdx
    }
    
    /// Computes the mass based on the target density and spacing.
    func computeMass() {
        var points = Array1<Vector2F>()
        let pointsGenerator = TrianglePointGenerator()
        let sampleBound = BoundingBox2F(
            point1: Vector2F(-1.5 * _kernelRadius, -1.5 * _kernelRadius),
            point2: Vector2F(1.5 * _kernelRadius, 1.5 * _kernelRadius))
        
        pointsGenerator.generate(boundingBox: sampleBound,
                                 spacing: _targetSpacing, points: &points)
        
        var maxNumberDensity:Float = 0.0
        let kernel = SphStdKernel2(kernelRadius: _kernelRadius)
        
        for i in 0..<points.size() {
            let point = points[i]
            var sum:Float = 0.0
            
            for j in 0..<points.size() {
                let neighborPoint = points[j]
                sum += kernel[length(neighborPoint - point)]
            }
            
            maxNumberDensity = max(maxNumberDensity, sum)
        }
        
        assert(maxNumberDensity > 0)
        
        let newMass = _targetDensity / maxNumberDensity
        
        super.setMass(newMass: newMass)
    }
}

//MARK:- GPU Method
extension SphSystemData2 {
    func densities(encoder:inout MTLComputeCommandEncoder,
                   index_begin:Int)->Int {
        return _scalarDataList[_densityIdx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func pressures(encoder:inout MTLComputeCommandEncoder,
                    index_begin:Int)->Int {
        return _scalarDataList[_pressureIdx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
}
