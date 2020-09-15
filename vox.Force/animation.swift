//
//  animation.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import Logging

struct Frame {
    /// Frame index.
    var index:Int = 0
    /// Time interval in seconds between two adjacent frames.
    var timeIntervalInSeconds:Double = 1.0 / 60.0
    
    /// Constructs Frame instance with 1/60 seconds time interval.
    init() {}
    
    /// Constructs Frame instance with given time interval.
    init(newIndex:Int, newTimeIntervalInSeconds:Double) {
        self.index = newIndex
        self.timeIntervalInSeconds = newTimeIntervalInSeconds
    }
    
    /// Returns the elapsed time in seconds.
    func timeInSeconds()->Double {
        return Double(index) * timeIntervalInSeconds
    }
    
    /// Advances single frame.
    mutating func advance() {
        index += 1
    }
    
    /// Advances multiple frames.
    /// - Parameter delta: Number of frames to advance.
    mutating func advance(delta:Int) {
        index += delta
    }
}

/// Abstract base class for animation-related class.
///
/// This class represents the animation logic in very abstract level.
/// Generally animation is a function of time and/or its previous state.
/// This base class provides a virtual function update() which can be
/// overriden by its sub-classes to implement their own state update logic.
protocol Animation {
    /// The implementation of this function should update the animation
    ///     state for given Frame instance \p frame.
    ///
    /// This function is called from Animation::update when state of this class
    /// instance needs to be updated. Thus, the inherited class should overrride
    /// this function and implement its logic for updating the animation state.
    func update(frame:Frame)
    
    /// The implementation of this function should update the animation
    ///     state for given Frame instance \p frame.
    ///
    /// This function is called from Animation::update when state of this class
    /// instance needs to be updated. Thus, the inherited class should overrride
    /// this function and implement its logic for updating the animation state.
    func onUpdate(frame:Frame)
}

let logger = Logger(label: "com.vox.Force.main")
extension Animation {
    func update(frame:Frame) {
        let timer = Date()
        
        logger.info("Begin updating frame: \(frame.index) timeIntervalInSeconds: \(frame.timeIntervalInSeconds) (1/\(1.0 / frame.timeIntervalInSeconds)) seconds")
        onUpdate(frame: frame)
        logger.info("End updating frame (took \(Date().timeIntervalSince(timer)) seconds)")
    }
}
