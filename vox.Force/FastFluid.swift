//
//  FastFluid.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit
import Accelerate

class FastFluid: NSObject {
    struct TouchEvent {
        let point: CGPoint
        let delta: CGPoint
    }
    
    static let maxInflightBuffers = 1
    
    private var hasInitVals = false
    private var inflightSemaphore = DispatchSemaphore(value: FastFluid.maxInflightBuffers)
    
    private var textureQueue = [MTLTexture]()
    var currentStateTexture: MTLTexture?
    
    private var visualizer: Visualizer?
    private var simulator: Simulator?
    
    private var gridSize: MTLSize = MTLSize()
    
    private let startDate: Date = Date()
    private var nextResizeTimestamp = Date()
    
    var touchEvents: [TouchEvent]?
    
    init?(with width: Int, height: Int, scale: CGFloat) {
        visualizer = Visualizer()
        simulator = Simulator(width: width,
                              height: height)
        
        super.init()
    }
    
    func reset() {
        simulator?.initializeFluid(with: gridSize.width,
                                   height: gridSize.height)
    }
    
    private func reshape(with drawableSize: CGSize, scale: CGFloat) {
        let propsedGridSize = MTLSize(width: Int(drawableSize.width / scale),
                                      height: Int(drawableSize.height / scale),
                                      depth: 1)
        if gridSize.width != propsedGridSize.width || gridSize.height != propsedGridSize.height {
            gridSize = propsedGridSize
            buildComputeResources()
        }
    }
    
    private func buildComputeResources() {
        if let fluid = simulator?.fluid, (fluid.width != gridSize.width || fluid.height != gridSize.height) {
            reset()
        }
    }
}

extension FastFluid: MTKViewDelegate {
    static let resizeHysteresis: TimeInterval = 0.2
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        nextResizeTimestamp = Date(timeIntervalSinceNow: type(of: self).resizeHysteresis)
        
        let dispatchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            if self.nextResizeTimestamp.timeIntervalSinceNow <= 0 {
                self.reshape(with: view.drawableSize, scale: view.layer.contentsScale)
            }
        }
    }
    
    func draw(in view: MTKView) {
        if hasInitVals == false {
            self.reshape(with: view.drawableSize, scale: view.layer.contentsScale)
            hasInitVals = true
        }
        
        _ = inflightSemaphore.wait(timeout: .distantFuture)
        
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.addCompletedHandler { _ in
            _ = self.inflightSemaphore.signal()
        }
        
        simulator?.encode(in: commandBuffer, touchEvents: touchEvents)
        if let texture = simulator?.currentTexture {
            visualizer?.encode(texture: texture, in: view)
        }
        
        commandBuffer.commit()
    }
}
