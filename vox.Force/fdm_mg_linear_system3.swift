//
//  fdm_mg_linear_system3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Multigrid-style 3-D FDM matrix.
typealias FdmMgMatrix3 = MgMatrix<FdmBlas3>

/// Multigrid-style 3-D FDM vector.
typealias FdmMgVector3 = MgVector<FdmBlas3>

struct FdmMgLinearSystem3 {
    /// The system matrix.
    var A = FdmMgMatrix3()
    
    /// The solution vector.
    var x = FdmMgVector3()
    
    /// The RHS vector.
    var b = FdmMgVector3()
    
    /// Clears the linear system.
    mutating func clear() {
        A.levels = []
        x.levels = []
        b.levels = []
    }
    
    /// Returns the number of multigrid levels.
    func numberOfLevels()->size_t {
        return A.levels.count
    }
    
    /// Resizes the system with the coarsest resolution and number of levels.
    mutating func resizeWithCoarsest(coarsestResolution:Size3,
                                     numberOfLevels:size_t) {
        FdmMgUtils3.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &A.levels)
        FdmMgUtils3.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &x.levels)
        FdmMgUtils3.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &b.levels)
    }
    
    /// Resizes the system with the finest resolution and max number of levels.
    ///
    /// This function resizes the system with multiple levels until the
    /// resolution is divisible with 3^(level-1).
    /// - Parameters:
    ///   - finestResolution: The finest grid resolution.
    ///   - maxNumberOfLevels: Maximum number of multigrid levels.
    mutating func resizeWithFinest(finestResolution:Size3,
                                   maxNumberOfLevels:size_t) {
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &A.levels)
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &x.levels)
        FdmMgUtils3.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &b.levels)
    }
}

/// Multigrid utilities for 3-D FDM system.
class FdmMgUtils3 {
    /// Restricts given finer grid to the coarser grid.
    static func restrict(finer:FdmVector3, coarser:inout FdmVector3) {
        if Renderer.arch == .CPU {
            VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
            VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
            VOX_ASSERT(finer.size().z == 2 * coarser.size().z)
            
            // --*--|--*--|--*--|--*--
            //  1/8   3/8   3/8   1/8
            //           to
            // -----|-----*-----|-----
            let kernel:[Float] = [0.125, 0.375, 0.375, 0.125]
            
            let n = coarser.size()
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y,
                             beginIndexZ: 0, endIndexZ: n.z){(
                iBegin:size_t, iEnd:size_t,
                jBegin:size_t, jEnd:size_t,
                kBegin:size_t, kEnd:size_t) in
                var kIndices = Array<size_t>(repeating: 0, count: 4)
                
                for k in kBegin..<kEnd {
                    kIndices[0] = (k > 0) ? 2 * k - 1 : 2 * k
                    kIndices[1] = 2 * k
                    kIndices[2] = 2 * k + 1
                    kIndices[3] = (k + 1 < n.z) ? 2 * k + 2 : 2 * k + 1
                    
                    var jIndices = Array<size_t>(repeating: 0, count: 4)
                    
                    for j in jBegin..<jEnd {
                        jIndices[0] = (j > 0) ? 2 * j - 1 : 2 * j
                        jIndices[1] = 2 * j
                        jIndices[2] = 2 * j + 1
                        jIndices[3] = (j + 1 < n.y) ? 2 * j + 2 : 2 * j + 1
                        
                        var iIndices = Array<size_t>(repeating: 0, count: 4)
                        for i in iBegin..<iEnd {
                            iIndices[0] = (i > 0) ? 2 * i - 1 : 2 * i
                            iIndices[1] = 2 * i
                            iIndices[2] = 2 * i + 1
                            iIndices[3] = (i + 1 < n.x) ? 2 * i + 2 : 2 * i + 1
                            
                            var sum:Float = 0.0
                            for z in 0..<4 {
                                for y in 0..<4 {
                                    for x in 0..<4 {
                                        let w = kernel[x] * kernel[y] * kernel[z]
                                        sum += w * finer[iIndices[x],
                                                         jIndices[y],
                                                         kIndices[z]]
                                    }
                                }
                            }
                            coarser[i, j, k] = sum
                        }
                    }
                }
            }
        } else {
            restrict_GPU(finer: finer, coarser: &coarser)
        }
    }
    
    /// Corrects given coarser grid to the finer grid.
    static func correct(coarser:FdmVector3, finer:inout FdmVector3) {
        if Renderer.arch == .CPU {
            VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
            VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
            VOX_ASSERT(finer.size().z == 2 * coarser.size().z)
            
            // -----|-----*-----|-----
            //           to
            //  1/4   3/4   3/4   1/4
            // --*--|--*--|--*--|--*--
            let n = finer.size()
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y,
                             beginIndexZ: 0, endIndexZ: n.z){(
                iBegin:size_t, iEnd:size_t,
                jBegin:size_t, jEnd:size_t,
                kBegin:size_t, kEnd:size_t) in
                for k in kBegin..<kEnd {
                    for j in jBegin..<jEnd {
                        for i in iBegin..<iEnd {
                            var iIndices = Array<size_t>(repeating: 0, count: 2)
                            var jIndices = Array<size_t>(repeating: 0, count: 2)
                            var kIndices = Array<size_t>(repeating: 0, count: 2)
                            var iWeights = Array<Float>(repeating: 0, count: 2)
                            var jWeights = Array<Float>(repeating: 0, count: 2)
                            var kWeights = Array<Float>(repeating: 0, count: 2)
                            
                            let ci = i / 2
                            let cj = j / 2
                            let ck = k / 2
                            
                            if (i % 2 == 0) {
                                iIndices[0] = (i > 1) ? ci - 1 : ci
                                iIndices[1] = ci
                                iWeights[0] = 0.25
                                iWeights[1] = 0.75
                            } else {
                                iIndices[0] = ci
                                iIndices[1] = (i + 1 < n.x) ? ci + 1 : ci
                                iWeights[0] = 0.75
                                iWeights[1] = 0.25
                            }
                            
                            if (j % 2 == 0) {
                                jIndices[0] = (j > 1) ? cj - 1 : cj
                                jIndices[1] = cj
                                jWeights[0] = 0.25
                                jWeights[1] = 0.75
                            } else {
                                jIndices[0] = cj
                                jIndices[1] = (j + 1 < n.y) ? cj + 1 : cj
                                jWeights[0] = 0.75
                                jWeights[1] = 0.25
                            }
                            
                            if (k % 2 == 0) {
                                kIndices[0] = (k > 1) ? ck - 1 : ck
                                kIndices[1] = ck
                                kWeights[0] = 0.25
                                kWeights[1] = 0.75
                            } else {
                                kIndices[0] = ck
                                kIndices[1] = (k + 1 < n.y) ? ck + 1 : ck
                                kWeights[0] = 0.75
                                kWeights[1] = 0.25
                            }
                            
                            for z in 0..<2 {
                                for y in 0..<2 {
                                    for x in 0..<2 {
                                        let w = iWeights[x] * jWeights[y] * kWeights[z] *
                                            coarser[iIndices[x], jIndices[y], kIndices[z]]
                                        finer[i, j, k] += w
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            correct_GPU(coarser: coarser, finer: &finer)
        }
    }
    
    /// Resizes the array with the coarsest resolution and number of levels.
    static func resizeArrayWithCoarsest<T:ZeroInit>(coarsestResolution:Size3,
                                                    numberOfLevels:size_t,
                                                    levels:inout [Array3<T>]) {
        let numberOfLevels = max(numberOfLevels, 1)
        
        levels = [Array3<T>](repeating: Array3<T>(), count: numberOfLevels)
        
        // Level 0 is the finest level, thus takes coarsestResolution ^
        // numberOfLevels.
        // Level numberOfLevels - 1 is the coarsest, taking coarsestResolution.
        var res = coarsestResolution
        for level in 0..<numberOfLevels {
            levels[numberOfLevels - level - 1].resize(size: res)
            res.x = res.x << 1
            res.y = res.y << 1
            res.z = res.z << 1
        }
    }
    
    /// Resizes the array with the finest resolution and max number of levels.
    ///
    /// This function resizes the system with multiple levels until the
    /// resolution is divisible with 3^(level-1).
    /// - Parameters:
    ///   - finestResolution: The finest grid resolution.
    ///   - maxNumberOfLevels: Maximum number of multigrid levels.
    static func resizeArrayWithFinest<T:ZeroInit>(finestResolution:Size3,
                                                  maxNumberOfLevels:size_t,
                                                  levels:inout [Array3<T>]) {
        var res = finestResolution
        var index:size_t = 1
        for i in 1..<maxNumberOfLevels {
            if (res.x % 3 == 0 && res.y % 3 == 0) {
                res.x = res.x >> 1
                res.y = res.y >> 1
                res.z = res.z >> 1
                index = i
            } else {
                index = i
                break
            }
        }
        resizeArrayWithCoarsest(coarsestResolution: res,
                                numberOfLevels: index,
                                levels: &levels)
    }
}

extension FdmMgUtils3 {
    static func restrict_GPU(finer:FdmVector3, coarser:inout FdmVector3) {
        VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
        VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
        VOX_ASSERT(finer.size().z == 2 * coarser.size().z)
        let n = coarser.size()
        parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                         beginIndexY: 0, endIndexY: n.y,
                         beginIndexZ: 0, endIndexZ: n.z, name: "FdmMgUtils3::restricted") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = finer.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = coarser.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
    
    static func correct_GPU(coarser:FdmVector3, finer:inout FdmVector3) {
        VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
        VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
        VOX_ASSERT(finer.size().z == 2 * coarser.size().z)
        let n = finer.size()
        parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                         beginIndexY: 0, endIndexY: n.y,
                         beginIndexZ: 0, endIndexZ: n.z, name: "FdmMgUtils3::corrected") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = finer.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = coarser.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
}
