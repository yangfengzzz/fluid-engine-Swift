//
//  particle_emitter2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D particle emitter.
protocol ParticleEmitter2: class {
    var _isEnabled:Bool { get set }
    var _particles:ParticleSystemData2? { get set }
    var _onBeginUpdateCallback:OnBeginUpdateCallback? { get set }
    
    /// Callback function type for update calls.
    ///
    /// This type of callback function will take the emitter pointer, current
    /// time, and time interval in seconds.
    typealias OnBeginUpdateCallback = (ParticleEmitter2, Double, Double)->Void
    
    /// Updates the emitter state from \p currentTimeInSeconds to the following
    /// time-step.
    func update(currentTimeInSeconds:Double,
                timeIntervalInSeconds:Double)
    
    /// Returns the target particle system to emit.
    func target()->ParticleSystemData2?
    
    /// Sets the target particle system to emit.
    func setTarget(particles:ParticleSystemData2)
    
    /// Returns true if the emitter is enabled.
    func isEnabled()->Bool
    
    /// Sets true/false to enable/disable the emitter.
    func setIsEnabled(enabled:Bool)
    
    /// Sets the callback function to be called when
    ///             ParticleEmitter2::update function is invoked.
    ///
    /// The callback function takes current simulation time in seconds unit. Use
    /// this callback to track any motion or state changes related to this
    /// emitter.
    /// - Parameter callback: The callback function.
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback)
    
    /// Called when ParticleEmitter2::setTarget is executed.
    func onSetTarget(particles:ParticleSystemData2)
    
    /// Called when ParticleEmitter2::update is executed.
    func onUpdate(currentTimeInSeconds:Double,
                  timeIntervalInSeconds:Double)
}

extension ParticleEmitter2 {
    func target()->ParticleSystemData2? {
        return _particles
    }
    
    func setTarget(particles:ParticleSystemData2) {
        _particles = particles
        
        onSetTarget(particles: particles)
    }
    
    func isEnabled()->Bool {
         return _isEnabled
    }
    
    func setIsEnabled(enabled:Bool) {
        _isEnabled = enabled
    }
    
    func update(currentTimeInSeconds:Double,
                timeIntervalInSeconds:Double) {
        if (_onBeginUpdateCallback != nil) {
            _onBeginUpdateCallback!(self, currentTimeInSeconds,
                                   timeIntervalInSeconds)
        }
        
        onUpdate(currentTimeInSeconds: currentTimeInSeconds,
                 timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    func onSetTarget(particles:ParticleSystemData2) {
        
    }
    
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback) {
        _onBeginUpdateCallback = callback
    }
}
