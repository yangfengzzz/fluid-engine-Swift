//
//  fdm_mg_linear_system2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/27.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Multigrid-style 2-D FDM matrix.
typealias FdmMgMatrix2 = MgMatrix<FdmBlas2>

/// Multigrid-style 2-D FDM vector.
typealias FdmMgVector2 = MgVector<FdmBlas2>

struct FdmMgLinearSystem2 {
    /// The system matrix.
    var A = FdmMgMatrix2()
    
    /// The solution vector.
    var x = FdmMgVector2()
    
    /// The RHS vector.
    var b = FdmMgVector2()
    
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
    mutating func resizeWithCoarsest(coarsestResolution:Size2,
                                     numberOfLevels:size_t) {
        FdmMgUtils2.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &A.levels)
        FdmMgUtils2.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &x.levels)
        FdmMgUtils2.resizeArrayWithCoarsest(coarsestResolution: coarsestResolution,
                                            numberOfLevels: numberOfLevels,
                                            levels: &b.levels)
    }
    
    /// Resizes the system with the finest resolution and max number of levels.
    ///
    /// This function resizes the system with multiple levels until the
    /// resolution is divisible with 2^(level-1).
    /// - Parameters:
    ///   - finestResolution: The finest grid resolution.
    ///   - maxNumberOfLevels: Maximum number of multigrid levels.
    mutating func resizeWithFinest(finestResolution:Size2,
                                   maxNumberOfLevels:size_t) {
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &A.levels)
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &x.levels)
        FdmMgUtils2.resizeArrayWithFinest(finestResolution: finestResolution,
                                          maxNumberOfLevels: maxNumberOfLevels,
                                          levels: &b.levels)
    }
}

/// Multigrid utilities for 2-D FDM system.
class FdmMgUtils2 {
    /// Restricts given finer grid to the coarser grid.
    static func restrict(finer:FdmVector2, coarser:inout FdmVector2) {
        if Renderer.arch == .CPU {
            VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
            VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
            
            // --*--|--*--|--*--|--*--
            //  1/8   3/8   3/8   1/8
            //           to
            // -----|-----*-----|-----
            let kernel:[Float] = [0.125, 0.375, 0.375, 0.125]
            
            let n = coarser.size()
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y){(
                iBegin:size_t, iEnd:size_t,
                jBegin:size_t, jEnd:size_t) in
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
                        for y in 0..<4 {
                            for x in 0..<4 {
                                let w = kernel[x] * kernel[y]
                                sum += w * finer[iIndices[x], jIndices[y]]
                            }
                        }
                        coarser[i, j] = sum
                    }
                }
            }
        } else {
            restrict_GPU(finer: finer, coarser: &coarser)
        }
    }
    
    /// Corrects given coarser grid to the finer grid.
    static func correct(coarser:FdmVector2, finer:inout FdmVector2) {
        if Renderer.arch == .CPU {
            VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
            VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
            
            // -----|-----*-----|-----
            //           to
            //  1/4   3/4   3/4   1/4
            // --*--|--*--|--*--|--*--
            let n = finer.size()
            parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                             beginIndexY: 0, endIndexY: n.y){(
                iBegin:size_t, iEnd:size_t,
                jBegin:size_t, jEnd:size_t) in
                for j in jBegin..<jEnd {
                    for i in iBegin..<iEnd {
                        var iIndices = Array<size_t>(repeating: 0, count: 2)
                        var jIndices = Array<size_t>(repeating: 0, count: 2)
                        var iWeights = Array<Float>(repeating: 0, count: 2)
                        var jWeights = Array<Float>(repeating: 0, count: 2)
                        
                        let ci = i / 2
                        let cj = j / 2
                        
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
                        
                        for y in 0..<2 {
                            for x in 0..<2 {
                                let w = iWeights[x] * jWeights[y] *
                                    coarser[iIndices[x], jIndices[y]]
                                finer[i, j] += w
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
    static func resizeArrayWithCoarsest<T:ZeroInit>(coarsestResolution:Size2,
                                                    numberOfLevels:size_t,
                                                    levels:inout [Array2<T>]) {
        let numberOfLevels = max(numberOfLevels, 1)
        
        levels = [Array2<T>](repeating: Array2<T>(), count: numberOfLevels)
        
        // Level 0 is the finest level, thus takes coarsestResolution ^
        // numberOfLevels.
        // Level numberOfLevels - 1 is the coarsest, taking coarsestResolution.
        var res = coarsestResolution
        for level in 0..<numberOfLevels {
            levels[numberOfLevels - level - 1].resize(size: res)
            res.x = res.x << 1
            res.y = res.y << 1
        }
    }
    
    /// Resizes the array with the finest resolution and max number of levels.
    ///
    /// This function resizes the system with multiple levels until the
    /// resolution is divisible with 2^(level-1).
    /// - Parameters:
    ///   - finestResolution: The finest grid resolution.
    ///   - maxNumberOfLevels: Maximum number of multigrid levels.
    static func resizeArrayWithFinest<T:ZeroInit>(finestResolution:Size2,
                                                  maxNumberOfLevels:size_t,
                                                  levels:inout [Array2<T>]) {
        var res = finestResolution
        var index:size_t = 1
        for i in 1..<maxNumberOfLevels {
            if (res.x % 2 == 0 && res.y % 2 == 0) {
                res.x = res.x >> 1
                res.y = res.y >> 1
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

extension FdmMgUtils2 {
    static func restrict_GPU(finer:FdmVector2, coarser:inout FdmVector2) {
        VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
        VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
        let n = coarser.size()
        parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                         beginIndexY: 0, endIndexY: n.y, name: "FdmMgUtils2::restricted") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = finer.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = coarser.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
    
    static func correct_GPU(coarser:FdmVector2, finer:inout FdmVector2) {
        VOX_ASSERT(finer.size().x == 2 * coarser.size().x)
        VOX_ASSERT(finer.size().y == 2 * coarser.size().y)
        let n = finer.size()
        parallelRangeFor(beginIndexX: 0, endIndexX: n.x,
                         beginIndexY: 0, endIndexY: n.y, name: "FdmMgUtils2::corrected") {
            (encode:inout MTLComputeCommandEncoder, index:inout Int) in
            index = finer.loadGPUBuffer(encoder: &encode, index_begin: index)
            index = coarser.loadGPUBuffer(encoder: &encode, index_begin: index)
        }
    }
}
