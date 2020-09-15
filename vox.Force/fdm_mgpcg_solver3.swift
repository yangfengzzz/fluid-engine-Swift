//
//  fdm_mgpcg_solver3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D finite difference-type linear system solver using Multigrid
///        Preconditioned conjugate gradient (MGPCG).
/// McAdams, Aleka, Eftychios Sifakis, and Joseph Teran.
///      "A parallel multigrid Poisson solver for fluids simulation on large
///      grids." Proceedings of the 2010 ACM SIGGRAPH/Eurographics Symposium on
///      Computer Animation. Eurographics Association, 2010.
class FdmMgpcgSolver3: FdmMgSolver3 {
    struct Preconditioner : PrecondTypeProtocol {
        typealias BlasType = FdmBlas3
        
        var system:FdmMgLinearSystem3?
        var mgParams = MgParameters<FdmBlas3>()
        
        mutating func build(system system_:inout FdmMgLinearSystem3,
                            mgParams mgParams_:MgParameters<FdmBlas3>) {
            system = system_
            mgParams = mgParams_
        }
        
        func solve(b:FdmVector3, x:inout FdmVector3) {
            // Copy dimension
            var mgX = system!.x
            var mgB = system!.x
            var mgBuffer = system!.x
            
            // Copy input to the top
            mgX.levels[0].set(other: x)
            mgB.levels[0].set(other: b)
            
            _ = mgVCycle(A: system!.A, params: mgParams,
                         x: &mgX, b: &mgB, buffer: &mgBuffer)
            
            // Copy result to the output
            x.set(other: mgX.levels.first!)
        }
    }
    
    var _maxNumberOfIterations:UInt
    var _lastNumberOfIterations:UInt
    var _tolerance:Float
    var _lastResidualNorm:Float
    
    var _r = FdmVector3()
    var _d = FdmVector3()
    var _q = FdmVector3()
    var _s = FdmVector3()
    var _precond = Preconditioner()
    
    /// Constructs the solver with given parameters.
    /// - Parameters:
    ///   - numberOfCgIter: Number of CG iterations.
    ///   - maxNumberOfLevels: Number of maximum MG levels.
    ///   - numberOfRestrictionIter: Number of restriction iterations.
    ///   - numberOfCorrectionIter: Number of correction iterations.
    ///   - numberOfCoarsestIter: Number of iterations at the coarsest grid.
    ///   - numberOfFinalIter: Number of final iterations.
    ///   - maxTolerance: Number of max residual tolerance.
    init(numberOfCgIter:UInt, maxNumberOfLevels:size_t,
         numberOfRestrictionIter:UInt = 5,
         numberOfCorrectionIter:UInt = 5,
         numberOfCoarsestIter:UInt = 30,
         numberOfFinalIter:UInt = 30,
         maxTolerance:Float = 1e-9, sorFactor:Float = 1.5,
         useRedBlackOrdering:Bool = false) {
        self._maxNumberOfIterations = numberOfCgIter
        self._lastNumberOfIterations = 0
        self._tolerance = maxTolerance
        self._lastResidualNorm = Float.greatestFiniteMagnitude
        
        super.init(maxNumberOfLevels: maxNumberOfLevels,
                   numberOfRestrictionIter: numberOfRestrictionIter,
                   numberOfCorrectionIter: numberOfCorrectionIter,
                   numberOfCoarsestIter: numberOfCoarsestIter,
                   numberOfFinalIter: numberOfFinalIter,
                   maxTolerance: maxTolerance, sorFactor: sorFactor,
                   useRedBlackOrdering: useRedBlackOrdering)
    }
    
    /// Solves the given linear system.
    override func solve(system:inout FdmMgLinearSystem3)->Bool {
        let size = system.A.levels.first!.size()
        _r.resize(size: size)
        _d.resize(size: size)
        _q.resize(size: size)
        _s.resize(size: size)
        
        system.x.levels.first!.set(value: 0.0)
        _r.set(value: 0.0)
        _d.set(value: 0.0)
        _q.set(value: 0.0)
        _s.set(value: 0.0)
        
        _precond.build(system: &system, mgParams: params())
        
        pcg(A: system.A.levels.first!,
            b: system.b.levels.first!,
            maxNumberOfIterations: _maxNumberOfIterations,
            tolerance: _tolerance, M: &_precond,
            x: &system.x.levels[0], r: &_r, d: &_d, q: &_q, s: &_s,
            lastNumberOfIterations: &_lastNumberOfIterations,
            lastResidualNorm: &_lastResidualNorm)
        
        logger.info("Residual after solving MGPCG: \(_lastResidualNorm) Number of MGPCG iterations: \(_lastNumberOfIterations)")
        
        return _lastResidualNorm <= _tolerance ||
            _lastNumberOfIterations < _maxNumberOfIterations
    }
    
    /// Returns the max number of Jacobi iterations.
    func maxNumberOfIterations()->UInt {
        return _maxNumberOfIterations
    }
    
    /// Returns the last number of Jacobi iterations the solver made.
    func lastNumberOfIterations()->UInt {
        return _lastNumberOfIterations
    }
    
    /// Returns the max residual tolerance for the Jacobi method.
    func tolerance()->Float {
        return _tolerance
    }
    
    /// Returns the last residual after the Jacobi iterations.
    func lastResidual()->Float {
        return _lastResidualNorm
    }
}
