//
//  physics_animation.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/8.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for physics-based animation.
///
/// This class represents physics-based animation by adding time-integration
/// specific functions to Animation class.
class PhysicsAnimation: Animation {
    var _currentFrame:Frame = Frame()
    var _isUsingFixedSubTimeSteps:Bool = true
    var _numberOfFixedSubTimeSteps:UInt = 1
    var _currentTime:Double = 0.0
    
    /// Default constructor.
    init() {
        self._currentFrame.index = -1
    }
    
    /// Returns true if fixed sub-timestepping is used.
    ///
    /// When performing a time-integration, it is often required to take
    /// sub-timestepping for better results. The sub-stepping can be either
    /// fixed rate or adaptive, and this function returns which feature is
    /// currently selected.
    /// - Returns: True if using fixed sub time steps, false otherwise.
    func isUsingFixedSubTimeSteps()->Bool {
        return _isUsingFixedSubTimeSteps
    }
    
    /// Sets true if fixed sub-timestepping is used.
    ///
    /// When performing a time-integration, it is often required to take
    /// sub-timestepping for better results. The sub-stepping can be either
    /// fixed rate or adaptive, and this function sets which feature should be
    /// selected.
    /// - Parameter isUsing: True to enable fixed sub-stepping.
    func setIsUsingFixedSubTimeSteps(isUsing:Bool) {
        _isUsingFixedSubTimeSteps = isUsing
    }
    
    /// Returns the number of fixed sub-timesteps.
    ///
    /// When performing a time-integration, it is often required to take
    /// sub-timestepping for better results. The sub-stepping can be either
    /// fixed rate or adaptive, and this function returns the number of fixed
    /// sub-steps.
    /// - Returns: The number of fixed sub-timesteps.
    func numberOfFixedSubTimeSteps()->UInt {
        return _numberOfFixedSubTimeSteps
    }
    
    /// Sets the number of fixed sub-timesteps.
    ///
    /// When performing a time-integration, it is often required to take
    /// sub-timestepping for better results. The sub-stepping can be either
    /// fixed rate or adaptive, and this function sets the number of fixed
    /// sub-steps.
    /// - Parameter numberOfSteps: The number of fixed sub-timesteps.
    func setNumberOfFixedSubTimeSteps(numberOfSteps:UInt) {
        _numberOfFixedSubTimeSteps = numberOfSteps
    }
    
    /// Advances a single frame.
    func advanceSingleFrame() {
        var f = _currentFrame
        f.advance()
        update(frame: f)
    }
    
    /// Returns current frame.
    func currentFrame()->Frame {
        return _currentFrame
    }
    
    /// Sets current frame cursor (but do not invoke update()).
    func setCurrentFrame(frame:Frame) {
        _currentFrame = frame
    }
    
    /// Returns current time in seconds.
    ///
    /// This function returns the current time which is calculated by adding
    /// current frame + sub-timesteps it passed.
    func currentTimeInSeconds()->Double {
        return _currentTime
    }
    
    /// Called when a single time-step should be advanced.
    ///
    /// When Animation::update function is called, this class will internally
    /// subdivide a frame into sub-steps if needed. Each sub-step, or time-step,
    /// is then taken to move forward in time. This function is called for each
    /// time-step, and a subclass that inherits PhysicsAnimation class should
    /// implement this function for its own physics model.
    /// - Parameter timeIntervalInSeconds: The time interval in seconds
    func onAdvanceTimeStep(timeIntervalInSeconds:Double) {
        fatalError()
    }
    
    /// Returns the required number of sub-timesteps for given time
    ///             interval.
    ///
    /// The required number of sub-timestep can be different depending on the
    /// physics model behind the implementation. Override this function to
    /// implement own logic for model specific sub-timestepping for given
    /// time interval.
    /// - Parameter timeIntervalInSeconds: The time interval in seconds.
    /// - Returns: The required number of sub-timesteps.
    func numberOfSubTimeSteps(timeIntervalInSeconds:Double)->UInt {
        // Returns number of fixed sub-timesteps by default
        return _numberOfFixedSubTimeSteps
    }
    
    /// Called at frame 0 to initialize the physics state.
    ///
    /// Inheriting classes can override this function to setup initial condition
    /// for the simulation.
    func onInitialize() {
        // Do nothing
    }
    
    func onUpdate(frame: Frame) {
        if (frame.index > _currentFrame.index) {
            if (_currentFrame.index < 0) {
                initialize()
            }
            
            let numberOfFrames = frame.index - _currentFrame.index
            
            for _ in 0..<numberOfFrames {
                advanceTimeStep(timeIntervalInSeconds: frame.timeIntervalInSeconds)
            }
            
            _currentFrame = frame
        }
    }
    
    func advanceTimeStep(timeIntervalInSeconds:Double) {
        _currentTime = _currentFrame.timeInSeconds()
        
        if (_isUsingFixedSubTimeSteps) {
            logger.info("Using fixed sub-timesteps: \(_numberOfFixedSubTimeSteps)")
            
            // Perform fixed time-stepping
            let actualTimeInterval = timeIntervalInSeconds / Double(_numberOfFixedSubTimeSteps)
            
            for _ in 0..<_numberOfFixedSubTimeSteps {
                logger.info("Begin onAdvanceTimeStep: \(actualTimeInterval) (1/\(1.0 / actualTimeInterval)) seconds")
                
                let timer = Date()
                onAdvanceTimeStep(timeIntervalInSeconds: actualTimeInterval)

                logger.info("End onAdvanceTimeStep (took \(Date().timeIntervalSince(timer)) seconds)")
                
                _currentTime += actualTimeInterval
            }
        } else {
            logger.info("Using adaptive sub-timesteps")
            
            // Perform adaptive time-stepping
            var remainingTime = timeIntervalInSeconds
            while (remainingTime > Double.leastNonzeroMagnitude) {
                let numSteps = numberOfSubTimeSteps(timeIntervalInSeconds: remainingTime)
                let actualTimeInterval = remainingTime / Double(numSteps)
                
                logger.info("Number of remaining sub-timesteps: \(numSteps)")
                
                logger.info("Begin onAdvanceTimeStep: \(actualTimeInterval) (1/\(1.0 / actualTimeInterval)) seconds")
                
                let timer = Date()
                onAdvanceTimeStep(timeIntervalInSeconds: actualTimeInterval)
                
                logger.info("End onAdvanceTimeStep (took \(Date().timeIntervalSince(timer)) seconds)")
                
                remainingTime -= actualTimeInterval
                _currentTime += actualTimeInterval
            }
        }
    }
    
    func initialize() {
        onInitialize()
    }
}
