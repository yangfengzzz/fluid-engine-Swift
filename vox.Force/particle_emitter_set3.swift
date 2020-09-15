//
//  particle_emitter_set3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D particle-based emitter set.
class ParticleEmitterSet3: ParticleEmitter3 {
    var _isEnabled: Bool = true
    var _particles: ParticleSystemData3?
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _emitters:[ParticleEmitter3] = []
    
    ///  Constructs an emitter.
    init() {}
    
    /// Constructs an emitter with sub-emitters.
    init(emitters:[ParticleEmitter3]) {
        self._emitters = emitters
    }
    
    /// Adds sub-emitter.
    func addEmitter(emitter:ParticleEmitter3) {
        _emitters.append(emitter)
    }
    
    func onSetTarget(particles:ParticleSystemData3) {
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
    /// Front-end to create ParticleEmitterSet3 objects step by step.
    class Builder {
        var _emitters:[ParticleEmitter3] = []
        /// Returns builder with list of sub-emitters.
        func withEmitters(emitters:[ParticleEmitter3])->Builder {
            _emitters = emitters
            return self
        }
        
        /// Builds ParticleEmitterSet3.
        func build()->ParticleEmitterSet3 {
            return ParticleEmitterSet3(emitters: _emitters)
        }
    }
    
    /// Returns builder fox ParticleEmitterSet3.
    static func builder()->Builder{
        return Builder()
    }
}
