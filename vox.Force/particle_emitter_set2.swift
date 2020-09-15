//
//  particle_emitter_set2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D particle-based emitter set.
class ParticleEmitterSet2: ParticleEmitter2 {
    var _isEnabled: Bool = true
    var _particles: ParticleSystemData2?
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _emitters:[ParticleEmitter2] = []
    
    ///  Constructs an emitter.
    init() {}
    
    /// Constructs an emitter with sub-emitters.
    init(emitters:[ParticleEmitter2]) {
        self._emitters = emitters
    }
    
    /// Adds sub-emitter.
    func addEmitter(emitter:ParticleEmitter2) {
        _emitters.append(emitter)
    }
    
    func onSetTarget(particles:ParticleSystemData2) {
        for emitter in _emitters {
            emitter.setTarget(particles: particles)
        }
    }
    
    func onUpdate(currentTimeInSeconds:Double,
                  timeIntervalInSeconds:Double) {
        if (!isEnabled()) {
            return
        }
        
        for emitter in _emitters {
            emitter.update(currentTimeInSeconds: currentTimeInSeconds,
                           timeIntervalInSeconds: timeIntervalInSeconds)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create ParticleEmitterSet2 objects step by step.
    class Builder {
        var _emitters:[ParticleEmitter2] = []
        /// Returns builder with list of sub-emitters.
        func withEmitters(emitters:[ParticleEmitter2])->Builder {
            _emitters = emitters
            return self
        }
        
        /// Builds ParticleEmitterSet2.
        func build()->ParticleEmitterSet2 {
            return ParticleEmitterSet2(emitters: _emitters)
        }
    }
    
    /// Returns builder fox ParticleEmitterSet2.
    static func builder()->Builder{
        return Builder()
    }
}
