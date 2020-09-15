//
//  pic_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// 3-D Particle-in-Cell (PIC) implementation.
///
/// This class implements 3-D Particle-in-Cell (PIC) method by inheriting
/// GridFluidSolver3. Since it is a grid-particle hybrid method, the solver
/// also has a particle system to track fluid particles.
///
/// \see Zhu, Yongning, and Robert Bridson. "Animating sand as a fluid."
///     ACM Transactions on Graphics (TOG). Vol. 24. No. 3. ACM, 2005.
class PicSolver3: GridFluidSolver3 {
    var _uMarkers = Array3<CChar>()
    var _vMarkers = Array3<CChar>()
    var _wMarkers = Array3<CChar>()
    var _signedDistanceFieldId:size_t = 0
    var _particles:ParticleSystemData3
    var _particleEmitter:ParticleEmitter3?
    
    /// Default constructor.
    convenience init() {
        self.init(resolution: [1, 1, 1], gridSpacing: [1, 1, 1], gridOrigin: [0, 0, 0])
    }
    
    /// Constructs solver with initial grid size.
    override init(resolution:Size3,
                  gridSpacing:Vector3F,
                  gridOrigin:Vector3F) {
        self._particles = ParticleSystemData3()
        super.init(resolution: resolution, gridSpacing: gridSpacing, gridOrigin: gridOrigin)
        
        let grids = gridSystemData()
        self._signedDistanceFieldId = grids.addScalarData(builder: CellCenteredScalarGrid3.Builder(),
                                                          initialVal: Float.greatestFiniteMagnitude)
    }
    
    /// Returns the signed-distance field of particles.
    func signedDistanceField()->ScalarGrid3 {
        return gridSystemData().scalarDataAt(idx: _signedDistanceFieldId)
    }
    
    /// Returns the particle system data.
    func particleSystemData()->ParticleSystemData3 {
        return _particles
    }
    
    /// Returns the particle emitter.
    func particleEmitter()->ParticleEmitter3 {
        return _particleEmitter!
    }
    
    /// Sets the particle emitter.
    func setParticleEmitter(newEmitter:ParticleEmitter3) {
        _particleEmitter = newEmitter
        newEmitter.setTarget(particles: _particles)
    }
    
    /// Initializes the simulator.
    override func onInitialize() {
        super.onInitialize()
        
        let timer = Date()
        updateParticleEmitter(timeIntervalInSeconds: 0.0)
        logger.info("Update particle emitter took \(Date().timeIntervalSince(timer)) seconds")
    }
    
    /// Invoked before a simulation time-step begins.
    override func onBeginAdvanceTimeStep(timeIntervalInSeconds:Double) {
        var timer = Date()
        updateParticleEmitter(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Update particle emitter took \(Date().timeIntervalSince(timer)) seconds")
        
        logger.info("Number of PIC-type particles: \(_particles.numberOfParticles())")
        
        timer = Date()
        transferFromParticlesToGrids()
        logger.info("transferFromParticlesToGrids took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        buildSignedDistanceField()
        logger.info("buildSignedDistanceField took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        extrapolateVelocityToAir()
        logger.info("extrapolateVelocityToAir took \(Date().timeIntervalSince(timer)) seconds")
        
        applyBoundaryCondition()
    }
    
    /// Computes the advection term of the fluid solver.
    override func computeAdvection(timeIntervalInSeconds:Double) {
        var timer = Date()
        extrapolateVelocityToAir()
        logger.info("extrapolateVelocityToAir took \(Date().timeIntervalSince(timer)) seconds")
        
        applyBoundaryCondition()
        
        timer = Date()
        if Renderer.arch == .CPU {
            transferFromGridsToParticles()
        } else {
            transferFromGridsToParticles_GPU()
        }
        logger.info("transferFromGridsToParticles took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        if Renderer.arch == .CPU {
            moveParticles(timeIntervalInSeconds: timeIntervalInSeconds)
        } else {
            moveParticles_GPU(timeIntervalInSeconds: timeIntervalInSeconds)
        }
        logger.info("moveParticles took \(Date().timeIntervalSince(timer)) seconds")
    }
    
    /// Returns the signed-distance field of the fluid.
    override func fluidSdf()->ScalarField3 {
        return signedDistanceField()
    }
    
    /// Transfers velocity field from particles to grids.
    func transferFromParticlesToGrids() {
        let flow = gridSystemData().velocity()
        let positions:ConstArrayAccessor1<Vector3F> = _particles.positions()
        let velocities:ConstArrayAccessor1<Vector3F> = _particles.velocities()
        let numberOfParticles = _particles.numberOfParticles()
        
        // Clear velocity to zero
        flow.fill(value: Vector3F())
        
        // Weighted-average velocity
        var u = flow.uAccessor()
        var v = flow.vAccessor()
        var w = flow.wAccessor()
        var uWeight = Array3<Float>(size: u.size())
        var vWeight = Array3<Float>(size: v.size())
        var wWeight = Array3<Float>(size: w.size())
        _uMarkers.resize(size: u.size())
        _vMarkers.resize(size: v.size())
        _wMarkers.resize(size: w.size())
        _uMarkers.set(value: 0)
        _vMarkers.set(value: 0)
        _wMarkers.set(value: 0)
        let uSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.uConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.uOrigin())
        let vSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.vConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.vOrigin())
        let wSampler = LinearArraySampler3<Float, Float>(
            accessor: flow.wConstAccessor(),
            gridSpacing: flow.gridSpacing(),
            gridOrigin: flow.wOrigin())
        for i in 0..<numberOfParticles {
            var indices = Array<Point3UI>(repeating: Point3UI(), count: 8)
            var weights = Array<Float>(repeating: 0, count: 8)
            
            uSampler.getCoordinatesAndWeights(pt: positions[i], indices: &indices, weights: &weights)
            for j in 0..<8 {
                u[indices[j]] += velocities[i].x * weights[j]
                uWeight[indices[j]] += weights[j]
                _uMarkers[indices[j]] = 1
            }
            
            vSampler.getCoordinatesAndWeights(pt: positions[i], indices: &indices, weights: &weights)
            for j in 0..<8 {
                v[indices[j]] += velocities[i].y * weights[j]
                vWeight[indices[j]] += weights[j]
                _vMarkers[indices[j]] = 1
            }
            
            wSampler.getCoordinatesAndWeights(pt: positions[i], indices: &indices, weights: &weights)
            for j in 0..<8 {
                w[indices[j]] += velocities[i].z * weights[j]
                wWeight[indices[j]] += weights[j]
                _wMarkers[indices[j]] = 1
            }
        }
        
        uWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (uWeight[i, j, k] > 0.0) {
                u[i, j, k] /= uWeight[i, j, k]
            }
        }
        vWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (vWeight[i, j, k] > 0.0) {
                v[i, j, k] /= vWeight[i, j, k]
            }
        }
        wWeight.parallelForEachIndex(){(i:size_t, j:size_t, k:size_t) in
            if (wWeight[i, j, k] > 0.0) {
                w[i, j, k] /= wWeight[i, j, k]
            }
        }
    }
    
    /// Transfers velocity field from grids to particles.
    func transferFromGridsToParticles() {
        let flow = gridSystemData().velocity()
        let positions:ConstArrayAccessor1<Vector3F> = _particles.positions()
        var velocities:ArrayAccessor1<Vector3F> = _particles.velocities()
        let numberOfParticles = _particles.numberOfParticles()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            velocities[i] = flow.sample(x: positions[i])
        }
    }
    
    /// Moves particles.
    func moveParticles(timeIntervalInSeconds:Double) {
        let flow = gridSystemData().velocity()
        var positions:ArrayAccessor1<Vector3F> = _particles.positions()
        var velocities:ArrayAccessor1<Vector3F> = _particles.velocities()
        let numberOfParticles = _particles.numberOfParticles()
        let domainBoundaryFlag = closedDomainBoundaryFlag()
        let boundingBox = flow.boundingBox()
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
            var pt0 = positions[i]
            var pt1 = pt0
            var vel = velocities[i]
            
            // Adaptive time-stepping
            let numSubSteps:UInt = UInt(max(maxCfl(), 1.0))
            let dt:Float = Float(timeIntervalInSeconds) / Float(numSubSteps)
            for _ in 0..<numSubSteps {
                let vel0 = flow.sample(x: pt0)
                
                // Mid-point rule
                let midPt = pt0 + 0.5 * dt * vel0
                let midVel = flow.sample(x: midPt)
                pt1 = pt0 + dt * midVel
                
                pt0 = pt1
            }
            
            if ((domainBoundaryFlag & kDirectionLeft != 0)
                && pt1.x <= boundingBox.lowerCorner.x) {
                pt1.x = boundingBox.lowerCorner.x
                vel.x = 0.0
            }
            if ((domainBoundaryFlag & kDirectionRight != 0)
                && pt1.x >= boundingBox.upperCorner.x) {
                pt1.x = boundingBox.upperCorner.x
                vel.x = 0.0
            }
            if ((domainBoundaryFlag & kDirectionDown != 0)
                && pt1.y <= boundingBox.lowerCorner.y) {
                pt1.y = boundingBox.lowerCorner.y
                vel.y = 0.0
            }
            if ((domainBoundaryFlag & kDirectionUp != 0)
                && pt1.y >= boundingBox.upperCorner.y) {
                pt1.y = boundingBox.upperCorner.y
                vel.y = 0.0
            }
            if ((domainBoundaryFlag & kDirectionBack != 0)
                && pt1.z <= boundingBox.lowerCorner.z) {
                pt1.z = boundingBox.lowerCorner.z
                vel.z = 0.0
            }
            if ((domainBoundaryFlag & kDirectionFront != 0)
                && pt1.z >= boundingBox.upperCorner.z) {
                pt1.z = boundingBox.upperCorner.z
                vel.z = 0.0
            }
            
            positions[i] = pt1
            velocities[i] = vel
        }
        
        let col = collider()
        if (col != nil) {
            parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                col!.resolveCollision(
                    radius: 0.0,
                    restitutionCoefficient: 0.0,
                    position: &positions[i],
                    velocity: &velocities[i])
            }
        }
    }
    
    func extrapolateVelocityToAir() {
        let vel = gridSystemData().velocity()
        var u = vel.uAccessor()
        var v = vel.vAccessor()
        var w = vel.wAccessor()
        
        let depth:UInt = UInt(ceil(maxCfl()))
        extrapolateToRegion(input: vel.uConstAccessor(),
                            valid: _uMarkers.constAccessor(),
                            numberOfIterations: depth, output: &u)
        extrapolateToRegion(input: vel.vConstAccessor(),
                            valid: _vMarkers.constAccessor(),
                            numberOfIterations: depth, output: &v)
        extrapolateToRegion(input: vel.wConstAccessor(),
                            valid: _wMarkers.constAccessor(),
                            numberOfIterations: depth, output: &w)
    }
    
    func buildSignedDistanceField() {
        var sdf = signedDistanceField()
        let sdfPos = sdf.dataPosition()
        let maxH = max(sdf.gridSpacing().x, sdf.gridSpacing().y, sdf.gridSpacing().z)
        let radius = 1.2 * maxH / sqrt(2.0)
        let sdfBandRadius = 2.0 * radius
        
        _particles.buildNeighborSearcher(maxSearchRadius: 2 * radius)
        let searcher = _particles.neighborSearcher()
        sdf.parallelForEachDataPointIndex(){(i:size_t, j:size_t, k:size_t) in
            let pt = sdfPos(i, j, k)
            var minDist = sdfBandRadius
            searcher.forEachNearbyPoint(origin: pt, radius: 3.0 * radius){
                (_:size_t, x:Vector3F) in
                minDist = min(minDist, length(pt - x))
            }
            sdf[i, j, k] = minDist - radius
        }
        
        extrapolateIntoCollider(grid: &sdf)
    }
    
    func updateParticleEmitter(timeIntervalInSeconds:Double) {
        if (_particleEmitter != nil) {
            _particleEmitter!.update(currentTimeInSeconds: currentTimeInSeconds(),
                                     timeIntervalInSeconds: timeIntervalInSeconds)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create PicSolver3 objects step by step.
    class Builder: GridFluidSolverBuilderBase3<Builder> {
        /// Builds PicSolver3.
        func build()->PicSolver3 {
            return PicSolver3(
                resolution: _resolution,
                gridSpacing: getGridSpacing(),
                gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox PicSolver3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- GPU Methods
extension PicSolver3 {
    func moveParticles_GPU(timeIntervalInSeconds:Double) {
        let flow = gridSystemData().velocity()
        var positions:ArrayAccessor1<Vector3F> = _particles.positions()
        var velocities:ArrayAccessor1<Vector3F> = _particles.velocities()
        let numberOfParticles = _particles.numberOfParticles()
        var domainBoundaryFlag:Int32 = Int32(closedDomainBoundaryFlag())
        var timeIntervalInSeconds:Float = Float(timeIntervalInSeconds)
        var boundingBox = flow.boundingBox()
        var cfl = maxCfl()
        var resolution = Vector3<UInt32>(UInt32(gridSystemData().velocity().resolution().x),
                                         UInt32(gridSystemData().velocity().resolution().y),
                                         UInt32(gridSystemData().velocity().resolution().z))
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "PicSolver3::moveParticles") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = _particles.positions(encoder: &encoder, index_begin: index)
                        index = _particles.velocities(encoder: &encoder, index_begin: index)
                        index = flow.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&domainBoundaryFlag, length: MemoryLayout<Int32>.stride, index: index)
                        encoder.setBytes(&timeIntervalInSeconds, length: MemoryLayout<Float>.stride, index: index+1)
                        encoder.setBytes(&cfl, length: MemoryLayout<Float>.stride, index: index+2)
                        encoder.setBytes(&boundingBox.lowerCorner, length: MemoryLayout<Vector3F>.stride, index: index+3)
                        encoder.setBytes(&boundingBox.upperCorner, length: MemoryLayout<Vector3F>.stride, index: index+4)
                        encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index+5)
        }
        
        let col = collider()
        if (col != nil) {
            parallelFor(beginIndex: 0, endIndex: numberOfParticles){(i:size_t) in
                col!.resolveCollision(
                    radius: 0.0,
                    restitutionCoefficient: 0.0,
                    position: &positions[i],
                    velocity: &velocities[i])
            }
        }
    }
    
    @objc func transferFromGridsToParticles_GPU() {
        let flow = gridSystemData().velocity()
        let numberOfParticles = _particles.numberOfParticles()
        var resolution = Vector3<UInt32>(UInt32(gridSystemData().velocity().resolution().x),
                                         UInt32(gridSystemData().velocity().resolution().y),
                                         UInt32(gridSystemData().velocity().resolution().z))
        
        parallelFor(beginIndex: 0, endIndex: numberOfParticles,
                    name: "PicSolver3::transferFromGridsToParticles") {
                        (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
                        index = _particles.positions(encoder: &encoder, index_begin: index)
                        index = _particles.velocities(encoder: &encoder, index_begin: index)
                        index = flow.loadGPUBuffer(encoder: &encoder, index_begin: index)
                        encoder.setBytes(&resolution, length: MemoryLayout<Vector3<UInt32>>.stride, index: index)
        }
    }
}
