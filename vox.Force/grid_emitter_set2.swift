//
//  grid_emitter_set2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D grid-based emitter set.
class GridEmitterSet2: GridEmitter2 {
    var _isEnabled: Bool = true
    var _onBeginUpdateCallback: OnBeginUpdateCallback?
    
    var _emitters:[GridEmitter2] = []
    
    /// Constructs an emitter.
    init() {}
    
    /// Constructs an emitter with sub-emitters.
    init(emitters:[GridEmitter2]) {
        for e in emitters {
            addEmitter(emitter: e)
        }
    }
    
    /// Adds sub-emitter.
    func addEmitter(emitter:GridEmitter2) {
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
    /// Front-end to create GridEmitterSet2 objects step by step.
    class Builder {
        var _emitters:[GridEmitter2] = []
        
        /// Returns builder with list of sub-emitters.
        func withEmitters(emitters:[GridEmitter2])->Builder {
            _emitters = emitters
            return self
        }
        
        /// Builds GridEmitterSet2.
        func build()->GridEmitterSet2 {
            return GridEmitterSet2(emitters: _emitters)
        }
    }
    
    /// Returns builder fox GridEmitterSet2.
    static func builder()->Builder{
        return Builder()
    }
}
