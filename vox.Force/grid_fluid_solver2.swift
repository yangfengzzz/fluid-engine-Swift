//
//  grid_fluid_solver2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Abstract base class for grid-based 2-D fluid solver.
///
/// This is an abstract base class for grid-based 2-D fluid solver based on
/// Jos Stam's famous 1999 paper - "Stable Fluids". This solver takes fractional
/// step method as its foundation which is consisted of independent advection,
/// diffusion, external forces, and pressure projection steps. Each step is
/// configurable so that a custom step can be implemented. For example, if a
/// user wants to change the advection solver to her/his own implementation,
/// simply call GridFluidSolver2::setAdvectionSolver(newSolver).
class GridFluidSolver2: PhysicsAnimation {
    var _gravity = Vector2F(0.0, -9.8)
    var _viscosityCoefficient:Float = 0.0
    var _maxCfl:Float = 5.0
    var _closedDomainBoundaryFlag = kDirectionAll
    
    var _grids:GridSystemData2
    var _collider:Collider2?
    var _emitter:GridEmitter2?
    
    var _advectionSolver:AdvectionSolver2?
    var _diffusionSolver:GridDiffusionSolver2?
    var _pressureSolver:GridPressureSolver2?
    var _boundaryConditionSolver:GridBoundaryConditionSolver2?
    
    /// Default constructor.
    override convenience init() {
        self.init(resolution: [1, 1], gridSpacing: [1, 1], gridOrigin: [0, 0])
    }
    
    /// Constructs solver with initial grid size.
    init(resolution:Size2,
         gridSpacing:Vector2F,
         gridOrigin:Vector2F) {
        self._grids = GridSystemData2()
        self._grids.resize(resolution: resolution,
                           gridSpacing: gridSpacing,
                           origin: gridOrigin)
        
        super.init()
        
        setAdvectionSolver(newSolver: CubicSemiLagrangian2())
        setDiffusionSolver(newSolver: GridBackwardEulerDiffusionSolver2())
        setPressureSolver(newSolver: GridFractionalSinglePhasePressureSolver2())
        setIsUsingFixedSubTimeSteps(isUsing: false)
    }
    
    /// Returns the gravity vector of the system.
    func gravity()->Vector2F {
        return _gravity
    }
    
    /// Sets the gravity of the system.
    func setGravity(newGravity:Vector2F) {
        _gravity = newGravity
    }
    
    /// Returns the viscosity coefficient.
    func viscosityCoefficient()->Float {
        return _viscosityCoefficient
    }
    
    /// Sets the viscosity coefficient.
    ///
    /// This function sets the viscosity coefficient. Non-positive input will be
    /// clamped to zero.
    /// - Parameter newValue: The new viscosity coefficient value.
    func setViscosityCoefficient(newValue:Float) {
        _viscosityCoefficient = max(newValue, 0.0)
    }
    
    /// Returns the CFL number from the current velocity field for given time interval.
    /// - Parameter timeIntervalInSeconds: The time interval in seconds.
    func cfl(timeIntervalInSeconds:Float)->Float {
        let vel = _grids.velocity()
        var maxVel:Float = 0.0
        vel.forEachCellIndex(){(i:size_t, j:size_t) in
            let v = vel.valueAtCellCenter(i: i, j: j) + timeIntervalInSeconds * _gravity
            maxVel = max(maxVel, v.x)
            maxVel = max(maxVel, v.y)
        }
        
        let gridSpacing = _grids.gridSpacing()
        let minGridSize = min(gridSpacing.x, gridSpacing.y)
        
        return maxVel * timeIntervalInSeconds / minGridSize
    }
    
    /// Returns the max allowed CFL number.
    func maxCfl()->Float {
        return _maxCfl
    }
    
    /// Sets the max allowed CFL number.
    func setMaxCfl(newCfl:Float) {
        _maxCfl = max(newCfl, Float.leastNonzeroMagnitude)
    }
    
    /// Returns the advection solver instance.
    func advectionSolver()->AdvectionSolver2? {
        return _advectionSolver
    }
    
    /// Sets the advection solver.
    func setAdvectionSolver(newSolver:AdvectionSolver2?) {
        _advectionSolver = newSolver
    }
    
    /// Returns the diffusion solver instance.
    func diffusionSolver()->GridDiffusionSolver2? {
        return _diffusionSolver
    }
    
    /// Sets the diffusion solver.
    func setDiffusionSolver(newSolver:GridDiffusionSolver2?) {
        _diffusionSolver = newSolver
    }
    
    /// Returns the pressure solver instance.
    func pressureSolver()->GridPressureSolver2? {
        return _pressureSolver
    }
    
    /// Sets the pressure solver.
    func setPressureSolver(newSolver:GridPressureSolver2?) {
        _pressureSolver = newSolver
        if (_pressureSolver != nil) {
            _boundaryConditionSolver =
                _pressureSolver!.suggestedBoundaryConditionSolver()
            
            // Apply domain boundary flag
            _boundaryConditionSolver!.setClosedDomainBoundaryFlag(
                flag: _closedDomainBoundaryFlag)
        }
    }
    
    /// Returns the closed domain boundary flag.
    func closedDomainBoundaryFlag()->Int {
        return _closedDomainBoundaryFlag
    }
    
    /// Sets the closed domain boundary flag.
    func setClosedDomainBoundaryFlag(flag:Int) {
        _closedDomainBoundaryFlag = flag
        _boundaryConditionSolver!.setClosedDomainBoundaryFlag(
            flag: _closedDomainBoundaryFlag)
    }
    
    /// Returns the grid system data.
    ///
    /// This function returns the grid system data. The grid system data stores
    /// the core fluid flow fields such as velocity. By default, the data
    /// instance has velocity field only.
    func gridSystemData()->GridSystemData2 {
        return _grids
    }
    
    /// Resizes grid system data.
    ///
    /// This function resizes grid system data. You can also resize the grid by
    /// calling resize function directly from
    /// GridFluidSolver2::gridSystemData(), but this function provides a
    /// shortcut for the same operation.
    /// - Parameters:
    ///   - newSize: The new size.
    ///   - newGridSpacing: The new grid spacing.
    ///   - newGridOrigin: The new grid origin.
    func resizeGrid(newSize:Size2, newGridSpacing:Vector2F,
                    newGridOrigin:Vector2F) {
        _grids.resize(resolution: newSize,
                      gridSpacing: newGridSpacing,
                      origin: newGridOrigin)
    }
    
    /// Returns the resolution of the grid system data.
    ///
    /// This function returns the resolution of the grid system data. This is
    /// equivalent to calling gridSystemData()->resolution(), but provides a
    /// shortcut.
    func resolution()->Size2 {
        return _grids.resolution()
    }
    
    /// Returns the grid spacing of the grid system data.
    ///
    /// This function returns the resolution of the grid system data. This is
    /// equivalent to calling gridSystemData()->gridSpacing(), but provides a
    /// shortcut.
    func gridSpacing()->Vector2F {
        return _grids.gridSpacing()
    }
    
    /// Returns the origin of the grid system data.
    ///
    /// This function returns the resolution of the grid system data. This is
    /// equivalent to calling gridSystemData()->origin(), but provides a
    /// shortcut.
    func gridOrigin()->Vector2F {
        return _grids.origin()
    }
    
    /// Returns the velocity field.
    ///
    /// This function returns the velocity field from the grid system data.
    /// It is just a shortcut to the most commonly accessed data chunk.
    func velocity()->FaceCenteredGrid2 {
        return _grids.velocity()
    }
    
    /// Returns the collider.
    func collider()->Collider2? {
        return _collider
    }
    
    /// Sets the collider.
    func setCollider(newCollider:Collider2?) {
        _collider = newCollider
    }
    
    /// Returns the emitter.
    func emitter()->GridEmitter2? {
        return _emitter
    }
    
    /// Sets the emitter.
    func setEmitter(newEmitter:GridEmitter2?) {
        _emitter = newEmitter
    }
    
    /// Called when it needs to setup initial condition.
    override func onInitialize() {
        // When initializing the solver, update the collider and emitter state as
        // well since they also affects the initial condition of the simulation.
        var timer = Date()
        updateCollider(timeIntervalInSeconds: 0.0)
        logger.info("Update collider took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        updateEmitter(timeIntervalInSeconds: 0.0)
        logger.info("Update emitter took \(Date().timeIntervalSince(timer)) seconds")
    }
    
    /// Called when advancing a single time-step.
    override func onAdvanceTimeStep(timeIntervalInSeconds:Double) {
        // The minimum grid resolution is 1x1.
        if (_grids.resolution().x == 0 || _grids.resolution().y == 0) {
            logger.warning("Empty grid. Skipping the simulation.")
            return
        }
        
        beginAdvanceTimeStep(timeIntervalInSeconds: timeIntervalInSeconds)
        
        var timer = Date()
        computeExternalForces(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Computing external force took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        computeViscosity(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Computing viscosity force took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        computePressure(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Computing pressure force took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        computeAdvection(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Computing advection force took \(Date().timeIntervalSince(timer)) seconds")
    }
    
    /// Returns the required sub-time-steps for given time interval.
    ///
    /// This function returns the required sub-time-steps for given time
    /// interval based on the max allowed CFL number. If the time interval is
    /// too large so that it makes the CFL number greater than the max value,
    /// This function will return a numebr that is greater than 1.
    override func numberOfSubTimeSteps(timeIntervalInSeconds:Double)->UInt {
        let currentCfl = cfl(timeIntervalInSeconds: Float(timeIntervalInSeconds))
        return UInt(max(ceil(currentCfl / _maxCfl), 1.0))
    }
    
    /// Called at the beginning of a time-step.
    func onBeginAdvanceTimeStep(timeIntervalInSeconds:Double) {
        
    }
    
    /// Called at the end of a time-step.
    func onEndAdvanceTimeStep(timeIntervalInSeconds:Double) {
        
    }
    
    /// Computes the external force terms.
    ///
    /// This function computes the external force applied for given time
    /// interval. By default, it only computes the gravity.
    func computeExternalForces(timeIntervalInSeconds:Double) {
        computeGravity(timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    /// Computes the viscosity term using the diffusion solver.
    func computeViscosity(timeIntervalInSeconds:Double) {
        if (_diffusionSolver != nil && _viscosityCoefficient > Float.leastNonzeroMagnitude) {
            var vel = velocity()
            let vel0 = vel.clone() as? FaceCenteredGrid2
            
            _diffusionSolver!.solve(source: vel0!, diffusionCoefficient: _viscosityCoefficient,
                                    timeIntervalInSeconds: Float(timeIntervalInSeconds), dest: &vel,
                                    boundarySdf: colliderSdf(), fluidSdf: fluidSdf())
            applyBoundaryCondition()
        }
    }
    
    /// Computes the pressure term using the pressure solver.
    func computePressure(timeIntervalInSeconds:Double) {
        if (_pressureSolver != nil) {
            var vel = velocity()
            let vel0 = vel.clone() as? FaceCenteredGrid2
            
            _pressureSolver!.solve(input: vel0!, timeIntervalInSeconds: timeIntervalInSeconds, output: &vel,
                                   boundarySdf: colliderSdf(), boundaryVelocity: colliderVelocityField(),
                                   fluidSdf: fluidSdf())
            applyBoundaryCondition()
        }
    }
    
    /// Computes the advection term using the advection solver.
    func computeAdvection(timeIntervalInSeconds:Double) {
        var vel = velocity()
        if (_advectionSolver != nil) {
            // Solve advections for custom scalar fields
            var n = _grids.numberOfAdvectableScalarData()
            for i in 0..<n {
                var grid = _grids.advectableScalarDataAt(idx: i)
                let grid0 = grid.clone()
                _advectionSolver!.advect(input: grid0, flow: vel, dt: Float(timeIntervalInSeconds),
                                         output: &grid, boundarySdf: colliderSdf())
                if Renderer.arch == .CPU {
                    extrapolateIntoCollider(grid: &grid)
                } else {
                    extrapolateIntoCollider_GPU(grid: &grid)
                }
            }
            
            // Solve advections for custom vector fields
            n = _grids.numberOfAdvectableVectorData()
            let velIdx = _grids.velocityIndex()
            for i in 0..<n {
                // Handle velocity layer separately.
                if (i == velIdx) {
                    continue
                }
                
                let grid = _grids.advectableVectorDataAt(idx: i)
                let grid0 = grid.clone()
                
                var collocated = grid as? CollocatedVectorGrid2
                let collocated0 = grid0 as? CollocatedVectorGrid2
                if (collocated != nil) {
                    _advectionSolver!.advect(input: collocated0!, flow: vel,
                                             dt: Float(timeIntervalInSeconds),
                                             output: &collocated!, boundarySdf: colliderSdf())
                    if Renderer.arch == .CPU {
                        extrapolateIntoCollider(grid: &collocated!)
                    } else {
                        extrapolateIntoCollider_GPU(grid: &collocated!)
                    }
                    continue
                }
                
                var faceCentered = grid as? FaceCenteredGrid2
                let faceCentered0 = grid0 as? FaceCenteredGrid2
                if (faceCentered != nil && faceCentered0 != nil) {
                    _advectionSolver!.advect(input: faceCentered0!, flow: vel,
                                             dt: Float(timeIntervalInSeconds),
                                             output: &faceCentered!, boundarySdf: colliderSdf())
                    if Renderer.arch == .CPU {
                        extrapolateIntoCollider(grid: &faceCentered!)
                    } else {
                        extrapolateIntoCollider_GPU(grid: &faceCentered!)
                    }
                    continue
                }
            }
            
            // Solve velocity advection
            let vel0 = vel.clone() as? FaceCenteredGrid2
            _advectionSolver!.advect(input: vel0!, flow: vel0!,
                                     dt: Float(timeIntervalInSeconds), output: &vel,
                                     boundarySdf: colliderSdf())
            applyBoundaryCondition()
        }
    }
    
    /// Returns the signed-distance representation of the fluid.
    ///
    /// This function returns the signed-distance representation of the fluid.
    /// Positive sign area is considered to be atmosphere and won't be included
    /// for computing the dynamics. By default, this will return constant scalar
    /// field of -kMaxD, meaning that the entire volume is occupied with fluid.
    func fluidSdf()->ScalarField2 {
        return ConstantScalarField2(value: -Float.greatestFiniteMagnitude)
    }
    
    /// Computes the gravity term.
    func computeGravity(timeIntervalInSeconds:Double) {
        if (length_squared(_gravity) > Float.leastNonzeroMagnitude) {
            let vel = _grids.velocity()
            var u = vel.uAccessor()
            var v = vel.vAccessor()
            
            if (abs(_gravity.x) > Float.leastNonzeroMagnitude) {
                vel.forEachUIndex(){(i:size_t, j:size_t) in
                    u[i, j] += Float(timeIntervalInSeconds) * _gravity.x
                }
            }
            
            if (abs(_gravity.y) > Float.leastNonzeroMagnitude) {
                vel.forEachVIndex(){(i:size_t, j:size_t) in
                    v[i, j] += Float(timeIntervalInSeconds) * _gravity.y
                }
            }
            
            applyBoundaryCondition()
        }
    }
    
    /// Applies the boundary condition to the velocity field.
    ///
    /// This function applies the boundary condition to the velocity field by
    /// constraining the flow based on the boundary condition solver.
    func applyBoundaryCondition() {
        var vel = _grids.velocity()
        
        if (_boundaryConditionSolver != nil) {
            let depth:UInt = UInt(ceil(_maxCfl))
            _boundaryConditionSolver!.constrainVelocity(velocity: &vel,
                                                        extrapolationDepth: depth)
        }
    }
    
    /// Extrapolates given field into the collider-occupied region.
    func extrapolateIntoCollider(grid:inout ScalarGrid2) {
        var marker = Array2<CChar>(size: grid.dataSize())
        let pos = grid.dataPosition()
        marker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: colliderSdf().sample(x: pos(i, j)))) {
                marker[i, j] = 0
            } else {
                marker[i, j] = 1
            }
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        var accessor = grid.dataAccessor()
        extrapolateToRegion(input: grid.constDataAccessor(),
                            valid: marker.constAccessor(),
                            numberOfIterations: depth,
                            output: &accessor)
    }
    
    /// Extrapolates given field into the collider-occupied region.
    func extrapolateIntoCollider(grid:inout CollocatedVectorGrid2) {
        var marker = Array2<CChar>(size: grid.dataSize())
        let pos = grid.dataPosition()
        marker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: colliderSdf().sample(x: pos(i, j)))) {
                marker[i, j] = 0
            } else {
                marker[i, j] = 1
            }
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        var accessor = grid.dataAccessor()
        extrapolateToRegion(input: grid.constDataAccessor(),
                            valid: marker.constAccessor(),
                            numberOfIterations: depth,
                            output: &accessor)
    }
    
    /// Extrapolates given field into the collider-occupied region.
    func extrapolateIntoCollider(grid:inout FaceCenteredGrid2) {
        var u = grid.uAccessor()
        var v = grid.vAccessor()
        let uPos = grid.uPosition()
        let vPos = grid.vPosition()
        
        var uMarker = Array2<CChar>(size: u.size())
        var vMarker = Array2<CChar>(size: v.size())
        
        uMarker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: colliderSdf().sample(x: uPos(i, j)))) {
                uMarker[i, j] = 0
            } else {
                uMarker[i, j] = 1
            }
        }
        
        vMarker.parallelForEachIndex(){(i:size_t, j:size_t) in
            if (isInsideSdf(phi: colliderSdf().sample(x: vPos(i, j)))) {
                vMarker[i, j] = 0
            } else {
                vMarker[i, j] = 1
            }
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        extrapolateToRegion(input: grid.uConstAccessor(),
                            valid: uMarker.constAccessor(),
                            numberOfIterations: depth, output: &u)
        extrapolateToRegion(input: grid.vConstAccessor(),
                            valid: vMarker.constAccessor(),
                            numberOfIterations: depth, output: &v)
    }
    
    /// Returns the signed-distance field representation of the collider.
    func colliderSdf()->ScalarField2 {
        return _boundaryConditionSolver!.colliderSdf()
    }
    
    /// Returns the velocity field of the collider.
    func colliderVelocityField()->VectorField2 {
        return _boundaryConditionSolver!.colliderVelocityField()
    }
    
    func beginAdvanceTimeStep(timeIntervalInSeconds:Double) {
        // Update collider and emitter
        var timer = Date()
        updateCollider(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Update collider took \(Date().timeIntervalSince(timer)) seconds")
        
        timer = Date()
        updateEmitter(timeIntervalInSeconds: timeIntervalInSeconds)
        logger.info("Update emitter took \(Date().timeIntervalSince(timer)) seconds")
        
        // Update boundary condition solver
        if (_boundaryConditionSolver != nil) {
            _boundaryConditionSolver!.updateCollider(
                newCollider: _collider, gridSize: _grids.resolution(),
                gridSpacing: _grids.gridSpacing(),
                gridOrigin: _grids.origin())
        }
        
        // Apply boundary condition to the velocity field in case the field got
        // updated externally.
        applyBoundaryCondition()
        
        // Invoke callback
        onBeginAdvanceTimeStep(timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    func endAdvanceTimeStep(timeIntervalInSeconds:Double) {
        onEndAdvanceTimeStep(timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    func updateCollider(timeIntervalInSeconds:Double) {
        if (_collider != nil) {
            _collider!.update(currentTimeInSeconds: currentTimeInSeconds(),
                              timeIntervalInSeconds: timeIntervalInSeconds)
        }
    }
    
    func updateEmitter(timeIntervalInSeconds:Double) {
        if (_emitter != nil) {
            _emitter!.update(currentTimeInSeconds: Float(currentTimeInSeconds()),
                             timeIntervalInSeconds: Float(timeIntervalInSeconds))
        }
    }
    
    //MARK:- Builder
    /// Front-end to create GridFluidSolver2 objects step by step.
    class Builder: GridFluidSolverBuilderBase2<Builder> {
        /// Builds GridFluidSolver2.
        func build()->GridFluidSolver2 {
            return GridFluidSolver2(resolution: _resolution,
                                    gridSpacing: getGridSpacing(),
                                    gridOrigin: _gridOrigin)
        }
    }
    
    /// Returns builder fox GridFluidSolver2.
    static func builder()->Builder{
        return Builder()
    }
}

class GridFluidSolverBuilderBase2<DerivedBuilder> {
    var _resolution = Size2(1, 1)
    var _gridSpacing = Vector2F(1, 1)
    var _gridOrigin = Vector2F(0, 0)
    var _domainSizeX:Float = 1.0
    var _useDomainSize = false
    
    /// Returns builder with grid resolution.
    func withResolution(resolution:Size2)->DerivedBuilder {
        _resolution = resolution
        return self as! DerivedBuilder
    }
    
    /// Returns builder with grid spacing.
    func withGridSpacing(gridSpacing:Vector2F)->DerivedBuilder {
        _gridSpacing = gridSpacing
        _useDomainSize = false
        return self as! DerivedBuilder
    }
    
    /// Returns builder with grid spacing.
    func withGridSpacing(gridSpacing:Float)->DerivedBuilder {
        _gridSpacing.x = gridSpacing
        _gridSpacing.y = gridSpacing
        _useDomainSize = false
        return self as! DerivedBuilder
    }
    
    /// Returns builder with domain size in x-direction.
    ///
    /// To build a solver, one can use either grid spacing directly or domain
    /// size in x-direction to set the final grid spacing.
    func withDomainSizeX(domainSizeX:Float)->DerivedBuilder {
        _domainSizeX = domainSizeX
        _useDomainSize = true
        return self as! DerivedBuilder
    }
    
    /// Returns builder with grid origin
    func withOrigin(gridOrigin:Vector2F)->DerivedBuilder {
        _gridOrigin = gridOrigin
        return self as! DerivedBuilder
    }
    
    func getGridSpacing()->Vector2F {
        var gridSpacing = _gridSpacing
        if (_useDomainSize) {
            gridSpacing = Vector2F(repeating: _domainSizeX / Float(_resolution.x))
        }
        return gridSpacing
    }
}

//MARK:- GPU Methods
extension GridFluidSolver2 {
    func extrapolateIntoCollider_GPU(grid:inout ScalarGrid2) {
        var marker = Array2<CChar>(size: grid.dataSize())
        let sdf = colliderSdf() as? CellCenteredScalarGrid2
        var function:String = ""
        if grid.typeName() == "CellCenteredScalarGrid2" {
            function = "GridFluidSolver2::CellCenteredScalarGrid2::extrapolateIntoCollider"
        } else {
            function = "GridFluidSolver2::VertexCenteredScalarGrid2::extrapolateIntoCollider"
        }
        
        marker.parallelForEachIndex(name: function) {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = sdf!.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = grid.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        var accessor = grid.dataAccessor()
        extrapolateToRegion(input: grid.constDataAccessor(),
                            valid: marker.constAccessor(),
                            numberOfIterations: depth,
                            output: &accessor)
    }
    
    func extrapolateIntoCollider_GPU(grid:inout CollocatedVectorGrid2) {
        var marker = Array2<CChar>(size: grid.dataSize())
        let sdf = colliderSdf() as? CellCenteredScalarGrid2
        var function:String = ""
        if grid.typeName() == "CellCenteredVectorGrid2" {
            function = "GridFluidSolver2::CellCenteredVectorGrid2::extrapolateIntoCollider"
        } else {
            function = "GridFluidSolver2::VertexCenteredVectorGrid2::extrapolateIntoCollider"
        }
        
        marker.parallelForEachIndex(name: function) {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = sdf!.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = grid.loadGPUBuffer(encoder: &encoder, index_begin: index)
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        var accessor = grid.dataAccessor()
        extrapolateToRegion(input: grid.constDataAccessor(),
                            valid: marker.constAccessor(),
                            numberOfIterations: depth,
                            output: &accessor)
    }
    
    func extrapolateIntoCollider_GPU(grid:inout FaceCenteredGrid2) {
        var u = grid.uAccessor()
        var v = grid.vAccessor()
        let sdf = colliderSdf() as? CellCenteredScalarGrid2
        var uMarker = Array2<CChar>(size: u.size())
        var vMarker = Array2<CChar>(size: v.size())
        var resolution = Vector2<UInt32>(UInt32(grid.resolution().x),
                                         UInt32(grid.resolution().y))
        
        uMarker.parallelForEachIndex(name: "GridFluidSolver2::FaceCenteredGrid2::extrapolateIntoColliderU") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = sdf!.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = grid.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index)
        }
        
        vMarker.parallelForEachIndex(name: "GridFluidSolver2::FaceCenteredGrid2::extrapolateIntoColliderV") {
            (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
            index = sdf!.loadGPUBuffer(encoder: &encoder, index_begin: index)
            index = grid.loadGPUBuffer(encoder: &encoder, index_begin: index)
            encoder.setBytes(&resolution, length: MemoryLayout<Vector2<UInt32>>.stride, index: index)
        }
        
        let depth:UInt = UInt(ceil(_maxCfl))
        extrapolateToRegion(input: grid.uConstAccessor(),
                            valid: uMarker.constAccessor(),
                            numberOfIterations: depth, output: &u)
        extrapolateToRegion(input: grid.vConstAccessor(),
                            valid: vMarker.constAccessor(),
                            numberOfIterations: depth, output: &v)
    }
}
