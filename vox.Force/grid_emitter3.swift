//
//  grid_emitter3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D grid-based emitters.
protocol GridEmitter3 : class{
    /// Callback function type for update calls.
    ///
    /// This type of callback function will take the current time and time
    /// interval in seconds.
    typealias OnBeginUpdateCallback = (Float, Float)->Void
    
    var _isEnabled:Bool { get set }
    var _onBeginUpdateCallback:OnBeginUpdateCallback? { get set }
    
    /// Updates the emitter state from \p currentTimeInSeconds to the following
    /// time-step.
    func update(currentTimeInSeconds:Float, timeIntervalInSeconds:Float)
    
    /// Returns true if the emitter is enabled.
    func isEnabled()->Bool
    
    /// Sets true/false to enable/disable the emitter.
    func setIsEnabled(enabled:Bool)
    
    /// Sets the callback function to be called when
    ///             GridEmitter3::update function is invoked.
    ///
    /// The callback function takes current simulation time in seconds unit. Use
    /// this callback to track any motion or state changes related to this
    /// emitter.
    /// - Parameter callback: The callback function.
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback)
    
    func onUpdate(currentTimeInSeconds:Float,
                  timeIntervalInSeconds:Float)
}

extension GridEmitter3 {
    func update(currentTimeInSeconds:Float, timeIntervalInSeconds:Float) {
        if _onBeginUpdateCallback != nil {
            _onBeginUpdateCallback!(currentTimeInSeconds, timeIntervalInSeconds)
        }
        
        onUpdate(currentTimeInSeconds: currentTimeInSeconds,
                 timeIntervalInSeconds: timeIntervalInSeconds)
    }
    
    func isEnabled()->Bool {
        return _isEnabled
    }
    
    func setIsEnabled(enabled:Bool) {
        _isEnabled = enabled
    }
    
    func setOnBeginUpdateCallback(callback:@escaping OnBeginUpdateCallback) {
        _onBeginUpdateCallback = callback
    }
}
