//
//  particle_system_data2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

let kDefaultHashGridResolution:size_t = 64

/// 2-D particle system data.
///
/// This class is the key data structure for storing particle system data. A
/// single particle has position, velocity, and force attributes by default. But
/// it can also have additional custom scalar or vector attributes.
class ParticleSystemData2 {
    /// Scalar data chunk.
    typealias ScalarData = Array1<Float>
    /// Vector data chunk.
    typealias VectorData = Array1<Vector2F>
    
    var _radius:Float = 1e-3
    var _mass:Float = 1e-3
    var _numberOfParticles:size_t = 0
    var _positionIdx:size_t = 0
    var _velocityIdx:size_t = 0
    var _forceIdx:size_t = 0
    
    var _scalarDataList:[ScalarData] = []
    var _vectorDataList:[VectorData] = []
    
    var _neighborSearcher:PointNeighborSearcher2
    var _neighborLists:[[size_t]] = [[]]
    var _neighborLists_buffer = Array1<Int32>(size: 0)
    var _neighborLists_index = Array1<Int32>(size: 0)
    
    /// Default constructor.
    convenience init() {
        self.init(numberOfParticles: 0)
    }
    
    /// Constructs particle system data with given number of particles.
    init(numberOfParticles:size_t) {
        // Use PointParallelHashGridSearcher2 by default
        self._neighborSearcher
            = PointParallelHashGridSearcher2(resolutionX: kDefaultHashGridResolution,
                                             resolutionY: kDefaultHashGridResolution,
                                             gridSpacing: 2.0 * _radius)
        
        self._positionIdx = addVectorData()
        self._velocityIdx = addVectorData()
        self._forceIdx = addVectorData()
        
        resize(newNumberOfParticles: numberOfParticles)
    }
    
    /// Copy constructor.
    init(other:ParticleSystemData2) {
        _neighborSearcher = other._neighborSearcher.clone()
        set(other: other)
    }
    
    /// Resizes the number of particles of the container.
    ///
    /// This function will resize internal containers to store newly given
    /// number of particles including custom data layers. However, this will
    /// invalidate neighbor searcher and neighbor lists. It is users
    /// responsibility to call ParticleSystemData2::buildNeighborSearcher and
    /// ParticleSystemData2::buildNeighborLists to refresh those data.
    /// - Parameter newNumberOfParticles:  New number of particles.
    func resize(newNumberOfParticles:size_t) {
        _numberOfParticles = newNumberOfParticles
        
        for i in 0..<_scalarDataList.count {
            _scalarDataList[i].resize(size: newNumberOfParticles,
                                      initVal: 0.0)
        }
        
        for i in 0..<_vectorDataList.count {
            _vectorDataList[i].resize(size: newNumberOfParticles,
                                      initVal: Vector2F())
        }
    }
    
    /// Copies from other particle system data.
    func set(other:ParticleSystemData2) {
        _radius = other._radius
        _mass = other._mass
        _positionIdx = other._positionIdx
        _velocityIdx = other._velocityIdx
        _forceIdx = other._forceIdx
        _numberOfParticles = other._numberOfParticles
        
        for attr in other._scalarDataList {
            _scalarDataList.append(attr)
        }
        
        for attr in other._vectorDataList {
            _vectorDataList.append(attr)
        }
        
        _neighborLists = other._neighborLists
    }
    
    /// Returns the number of particles.
    func numberOfParticles()->size_t {
        return _numberOfParticles
    }
    
    /// Adds a scalar data layer and returns its index.
    ///
    /// This function adds a new scalar data layer to the system. It can be used
    /// for adding a scalar attribute, such as temperature, to the particles.
    /// - Parameter initialVal: initialVal  Initial value of the new scalar data.
    func addScalarData(initialVal:Float = 0.0)->size_t {
        let attrIdx = _scalarDataList.count
        _scalarDataList.append(ScalarData(size: numberOfParticles(),
                                          initVal: initialVal))
        return attrIdx
    }
    
    /// Adds a vector data layer and returns its index.
    ///
    /// This function adds a new vector data layer to the system. It can be used
    /// for adding a vector attribute, such as vortex, to the particles.
    /// - Parameter initialVal: initialVal  Initial value of the new vector data.
    func addVectorData(initialVal:Vector2F = Vector2F())->size_t {
        let attrIdx = _vectorDataList.count
        _vectorDataList.append(VectorData(size: numberOfParticles(),
                                          initVal: initialVal))
        return attrIdx
    }
    
    /// Returns the radius of the particles.
    func radius()->Float {
        return _radius
    }
    
    /// Sets the radius of the particles.
    func setRadius(newRadius:Float) {
        _radius = max(newRadius, 0.0)
    }
    
    /// Returns the mass of the particles.
    func mass()->Float {
        return _mass
    }
    
    /// Sets the mass of the particles.
    func setMass(newMass:Float) {
        _mass = max(newMass, 0.0)
    }
    
    /// Returns the position array (immutable).
    func positions()->ConstArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _positionIdx)
    }
    
    /// Returns the position array (mutable).
    func positions()->ArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _positionIdx)
    }
    
    /// Returns the velocity array (immutable).
    func velocities()->ConstArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _velocityIdx)
    }
    
    /// Returns the velocity array (mutable).
    func velocities()->ArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _velocityIdx)
    }
    
    /// Returns the force array (immutable).
    func forces()->ConstArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _forceIdx)
    }
    
    /// Returns the force array (mutable).
    func forces()->ArrayAccessor1<Vector2F> {
        return vectorDataAt(idx: _forceIdx)
    }
    
    /// Returns custom scalar data layer at given index (immutable).
    func scalarDataAt(idx:size_t)->ConstArrayAccessor1<Float> {
        return _scalarDataList[idx].constAccessor()
    }
    
    /// Returns custom scalar data layer at given index (mutable).
    func scalarDataAt(idx:size_t)->ArrayAccessor1<Float> {
        return _scalarDataList[idx].accessor()
    }
    
    /// Returns custom vector data layer at given index (immutable).
    func vectorDataAt(idx:size_t)->ConstArrayAccessor1<Vector2F> {
        return _vectorDataList[idx].constAccessor()
    }
    
    /// Returns custom vector data layer at given index (mutable).
    func vectorDataAt(idx:size_t)->ArrayAccessor1<Vector2F> {
        return _vectorDataList[idx].accessor()
    }
    
    /// Adds a particle to the data structure.
    ///
    /// This function will add a single particle to the data structure. For
    /// custom data layers, zeros will be assigned for new particles.
    /// However, this will invalidate neighbor searcher and neighbor lists. It
    /// is users responsibility to call
    /// ParticleSystemData2::buildNeighborSearcher and
    /// ParticleSystemData2::buildNeighborLists to refresh those data.
    /// - Parameters:
    ///   - newPosition: The new position.
    ///   - newVelocity: The new velocity.
    ///   - newForce: The new force.
    func addParticle(newPosition:Vector2F,
                     newVelocity:Vector2F = Vector2F(),
                     newForce:Vector2F = Vector2F()) {
        let newPositions = Array1<Vector2F>(lst: [newPosition])
        let newVelocities = Array1<Vector2F>(lst: [newVelocity])
        let newForces = Array1<Vector2F>(lst: [newForce])
        
        addParticles(
            newPositions: newPositions.constAccessor(),
            newVelocities: newVelocities.constAccessor(),
            newForces: newForces.constAccessor())
    }
    
    /// Adds particles to the data structure.
    ///
    /// This function will add particles to the data structure. For custom data
    /// layers, zeros will be assigned for new particles. However, this will
    /// invalidate neighbor searcher and neighbor lists. It is users
    /// responsibility to call ParticleSystemData2::buildNeighborSearcher and
    /// ParticleSystemData2::buildNeighborLists to refresh those data.
    /// - Parameters:
    ///   - newPositions:  The new positions.
    ///   - newVelocities: The new velocities.
    ///   - newForces: The new forces.
    func addParticles(
        newPositions:ConstArrayAccessor1<Vector2F>,
        newVelocities:ConstArrayAccessor1<Vector2F> = ConstArrayAccessor1<Vector2F>(),
        newForces:ConstArrayAccessor1<Vector2F> = ConstArrayAccessor1<Vector2F>()) {
        if newVelocities.size() > 0
            && newVelocities.size() != newPositions.size() {
            fatalError()
        }
        
        if newForces.size() > 0
            && newForces.size() != newPositions.size() {
            fatalError()
        }
        
        let oldNumberOfParticles = numberOfParticles()
        let newNumberOfParticles = oldNumberOfParticles + newPositions.size()
        
        resize(newNumberOfParticles: newNumberOfParticles)
        
        var pos:ArrayAccessor1<Vector2F> = positions()
        var vel:ArrayAccessor1<Vector2F> = velocities()
        var frc:ArrayAccessor1<Vector2F> = forces()
        
        parallelFor(beginIndex: 0, endIndex: newPositions.size()){(i:size_t) in
            pos[i + oldNumberOfParticles] = newPositions[i]
        }
        
        if (newVelocities.size() > 0) {
            parallelFor(beginIndex: 0, endIndex: newPositions.size()){(i:size_t) in
                vel[i + oldNumberOfParticles] = newVelocities[i]
            }
        }
        
        if (newForces.size() > 0) {
            parallelFor(beginIndex: 0, endIndex: newPositions.size()){(i:size_t) in
                frc[i + oldNumberOfParticles] = newForces[i]
            }
        }
    }
    
    /// Returns neighbor searcher.
    ///
    /// This function returns currently set neighbor searcher object. By
    /// default, PointParallelHashGridSearcher2 is used.
    /// - Returns: Current neighbor searcher.
    func neighborSearcher()->PointNeighborSearcher2 {
        return _neighborSearcher
    }
    
    /// Sets neighbor searcher.
    func setNeighborSearcher(newNeighborSearcher:PointNeighborSearcher2) {
        _neighborSearcher = newNeighborSearcher
    }
    
    /// Returns neighbor lists.
    ///
    /// This function returns neighbor lists which is available after calling
    /// PointParallelHashGridSearcher2::buildNeighborLists. Each list stores
    /// indices of the neighbors.
    /// - Returns: Neighbor lists.
    func neighborLists()->[[size_t]] {
        return _neighborLists
    }
    
    /// Builds neighbor searcher with given search radius.
    func buildNeighborSearcher(maxSearchRadius:Float) {
        // Use PointParallelHashGridSearcher2 by default
        _neighborSearcher = PointParallelHashGridSearcher2(
            resolutionX: kDefaultHashGridResolution,
            resolutionY: kDefaultHashGridResolution,
            gridSpacing: 2.0 * maxSearchRadius)
        
        _neighborSearcher.build(points: positions())
    }
    
    /// Builds neighbor lists with given search radius.
    func buildNeighborLists(maxSearchRadius:Float) {
        _neighborLists = Array<[size_t]>(repeating: [], count: numberOfParticles())
        _neighborLists_index = Array1<Int32>(size: numberOfParticles()+1, initVal: 0)
        
        let points:ArrayAccessor1<Vector2F> = positions()
        for i in 0..<numberOfParticles() {
            let origin = points[i]
            _neighborLists[i] = []
            
            _neighborSearcher.forEachNearbyPoint(
                origin: origin,
                radius: maxSearchRadius){(j:size_t, _:Vector2F) in
                    if (i != j) {
                        _neighborLists[i].append(j)
                    }
            }
            
            _neighborLists_index[i+1] = _neighborLists_index[i] + Int32(_neighborLists[i].count)
        }
    }
}

//MARK:- GPU Method
extension ParticleSystemData2 {
    func positions(encoder:inout MTLComputeCommandEncoder,
                   index_begin:Int)->Int {
        return _vectorDataList[_positionIdx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func velocities(encoder:inout MTLComputeCommandEncoder,
                    index_begin:Int)->Int {
        return _vectorDataList[_velocityIdx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func forces(encoder:inout MTLComputeCommandEncoder,
                index_begin:Int)->Int {
        return _vectorDataList[_forceIdx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func scalarDataAt(idx:size_t, encoder:inout MTLComputeCommandEncoder,
                      index_begin:Int)->Int {
        return _scalarDataList[idx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func vectorDataAt(idx:size_t, encoder:inout MTLComputeCommandEncoder,
                      index_begin:Int)->Int {
        return _vectorDataList[idx]
            .loadGPUBuffer(encoder: &encoder,
                           index_begin: index_begin)
    }
    
    func buildNeighborListsBuffer() {
        _neighborLists_buffer = Array1<Int32>(size: size_t(_neighborLists_index[numberOfParticles()]), initVal: 0)
        var index:Int = 0
        for i in 0..<numberOfParticles() {
            let neigh = _neighborLists[i]
            for val in neigh {
                _neighborLists_buffer[index] = Int32(val)
                index += 1
            }
        }
    }
    
    func loadNeighborLists(encoder:inout MTLComputeCommandEncoder,
                           index_begin:Int)->Int {
        let index = _neighborLists_buffer.loadGPUBuffer(encoder: &encoder, index_begin: index_begin)
        return _neighborLists_index.loadGPUBuffer(encoder: &encoder, index_begin: index)
    }
}
