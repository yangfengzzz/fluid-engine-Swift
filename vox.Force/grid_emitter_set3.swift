//
//  grid_emitter_set3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D grid-based emitter set.
class GridEmitterSet3: GridEmitter3 {
    var _isEnabled: Bool = true
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _emitters:[GridEmitter3] = []
    
    /// Constructs an emitter.
    init() {}
    
    /// Constructs an emitter with sub-emitters.
    init(emitters:[GridEmitter3]) {
        for e in emitters {
            addEmitter(emitter: e)
        }
    }
    
    /// Adds sub-emitter.
    func addEmitter(emitter:GridEmitter3) {
        _emitters.append(emitter)
    }
    
    func onUpdate(currentTimeInSeconds: Float,
                  timeIntervalInSeconds: Float) {
        if (!isEnabled()) {
            return
        }
        
        for emitter in _emitters {
            emitter.update(currentTimeInSeconds: currentTimeInSeconds,
                           timeIntervalInSeconds: timeIntervalInSeconds)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create GridEmitterSet3 objects step by step.
    class Builder {
        var _emitters:[GridEmitter3] = []
        
        /// Returns builder with list of sub-emitters.
        func withEmitters(emitters:[GridEmitter3])->Builder {
            _emitters = emitters
            return self
        }
        
        /// Builds GridEmitterSet3.
        func build()->GridEmitterSet3 {
            return GridEmitterSet3(emitters: _emitters)
        }
    }
    
    /// Returns builder fox GridEmitterSet3.
    static func builder()->Builder{
        return Builder()
    }
}
