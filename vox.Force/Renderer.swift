//
//  Renderer.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit
import SwiftUI

enum Arch {
    case CPU
    case GPU
}

struct MetalKitView: UIViewRepresentable {
    let view: Renderer
    func makeUIView(context: UIViewRepresentableContext<MetalKitView>) -> Renderer {
        return view
    }
    
    func updateUIView(_ nsView: Renderer, context: UIViewRepresentableContext<MetalKitView>) {}
}

final class Renderer: UIView {
    let metalView = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!
    static var fps: Int!
    static var commandBuffer: MTLCommandBuffer?
        
    var fragmentUniforms = FragmentUniforms()
    let depthStencilState: MTLDepthStencilState
    
    var partcles: Particles?
    var ray: RayMarching?
    var RenderableObj:Renderable?
    
    static var arch:Arch = .GPU
    
    init() {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        Renderer.fps = metalView.preferredFramesPerSecond
        
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.buildDepthStencilState()!
        
        super.init(frame: .zero)
        self.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        metalView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        metalView.framebufferOnly = false
        metalView.isMultipleTouchEnabled = true
        metalView.clearColor = MTLClearColor(red: 0.3, green: 0.3,
                                             blue: 0.3, alpha: 1)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        
        partcles = Particles()
        let fireEmitter = Particles.fire(size: metalView.drawableSize)
        fireEmitter.position = [0, -10]
        partcles?.emitters.append(fireEmitter)
        
        RenderableObj = FlipSolver2Renderable()
        
        ray = RayMarching()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// instantiate the depth stencil state
    /// - Returns: newly depth stencil state
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    /// Gets called every time the size of the window changes.
    /// This allows to update the render coordinate system.
    /// - Parameters:
    ///   - view: MTKView which called this method
    ///   - size: new drawable size in pixels
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        RenderableObj?.reset()
    }
    
    /// Called on the delegate when it is asked to render into the view
    /// - Parameter view: MTKView which called this method
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
                return
        }
        Renderer.commandBuffer = commandBuffer
        
        RenderableObj?.draw(in: view)
        //ray?.draw(in: view)
        //partcles?.draw(in: view)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
