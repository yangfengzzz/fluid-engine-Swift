//
//  pci_sph_solver2_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class PciSphSolver2Renderable: Renderable {
    var solver = PciSphSolver2()
    var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
    
    struct Particle : ZeroInit {
        init() {
            position = float2()
            color = float4(1, 0, 0, 1)
            size = 0
        }
        
        func getKernelType() -> KernelType {
            .unsupported
        }
        
        var position: float2
        var color: float4
        var size: Float
    }
    
    var renderPipelineState: MTLRenderPipelineState!
    var GPUBuffer = Array1<Particle>()
    var numberOfpoints:Int = 0
    
    init() {
        WaterDrop()
        buildPipelineStates()
    }
    
    func SteadyState() {
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.1)
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 10.0)
        
        let particles = solver.sphSystemData()
        particles.setTargetDensity(targetDensity: 1000.0)
        let targetSpacing = particles.targetSpacing()
        
        var initialBound = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 0.5))
        initialBound.expand(delta: -targetSpacing)
        
        let emitter = VolumeParticleEmitter2(implicitSurface: SurfaceToImplicit2(surface: Sphere2(center: Vector2F(),
                                                                                                  radiustransform: 10.0)),
                                             maxRegion: initialBound,
                                             spacing: targetSpacing,
                                             initialVel: Vector2F())
        emitter.setJitter(newJitter: 0.0)
        solver.setEmitter(newEmitter: emitter)
        
        let box = Box2(lowerCorner: Vector2F(), upperCorner: Vector2F(1, 1))
        box.isNormalFlipped = true
        let collider = RigidBodyCollider2(surface: box)
        solver.setCollider(newCollider: collider)
    }
    
    func WaterDrop() {
        let targetSpacing:Float = 0.02
        
        let domain = BoundingBox2F(point1: Vector2F(), point2: Vector2F(1, 2))
        
        // Initialize solvers
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 0.0)
        
        let particles = solver.sphSystemData()
        particles.setTargetDensity(targetDensity: 1000.0)
        particles.setTargetSpacing(spacing: targetSpacing)
        
        // Initialize source
        let surfaceSet = ImplicitSurfaceSet2()
        surfaceSet.addExplicitSurface(surface: Plane2(
            normal: Vector2F(0, 1), point: Vector2F(0, 0.25 * domain.height())))
        surfaceSet.addExplicitSurface(surface: Sphere2(
            center: domain.midPoint(), radiustransform: 0.15 * domain.width()))
        
        var sourceBound = BoundingBox2F(other: domain)
        sourceBound.expand(delta: -targetSpacing)
        
        let emitter = VolumeParticleEmitter2(
            implicitSurface: surfaceSet,
            maxRegion: sourceBound,
            spacing: targetSpacing,
            initialVel: Vector2F())
        solver.setEmitter(newEmitter: emitter)
        
        // Initialize boundary
        let box = Box2(boundingBox: domain)
        box.isNormalFlipped = true
        let collider = RigidBodyCollider2(surface: box)
        solver.setCollider(newCollider: collider)
    }
    
    func RotatingTank() {
        let targetSpacing:Float = 0.02
        
        // Build solver
        solver = PciSphSolver2.builder()
            .withTargetSpacing(targetSpacing: targetSpacing)
            .build()
        
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.01)
        
        // Build emitter
        let box = Box2.builder()
            .withLowerCorner(pt: [0.25 + targetSpacing, 0.25 + targetSpacing])
            .withUpperCorner(pt: [0.75 - targetSpacing, 0.50])
            .build()
        
        let emitter = VolumeParticleEmitter2.builder()
            .withSurface(surface: box)
            .withSpacing(spacing: targetSpacing)
            .withIsOneShot(isOneShot: true)
            .build()
        
        solver.setEmitter(newEmitter: emitter)
        
        // Build collider
        let tank = Box2.builder()
            .withLowerCorner(pt: [-0.25, -0.25])
            .withUpperCorner(pt: [ 0.25,  0.25])
            .withTranslation(translation: [0.5, 0.5])
            .withOrientation(orientation: 0.0)
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        
        let collider = RigidBodyCollider2.builder()
            .withSurface(surface: tank)
            .withAngularVelocity(angularVelocity: 2.0)
            .build()
        
        collider.setOnBeginUpdateCallback(){(col:Collider2, t:Double, _:Double) in
            if (t < 1.0) {
                var trans = col.surface().transform
                trans.setOrientation(orientation: Float(2.0 * t))
                var surf = col.surface()
                surf.transform = trans
                col.setSurface(newSurface: surf)
                (col as! RigidBodyCollider2).angularVelocity = 2.0
            } else {
                (col as! RigidBodyCollider2).angularVelocity = 0.0
            }
        }
        
        solver.setCollider(newCollider: collider)
    }
    
    func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else { return }
            
            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_point")
            let fragmentFunction = library.makeFunction(name: "fragment_point")
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            descriptor.depthAttachmentPixelFormat = .depth32Float
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.layouts[0].stride = MemoryLayout<Particle>.size
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            descriptor.vertexDescriptor = vertexDescriptor
            
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func exportStates(pos:inout Array1<Particle>) {
        let posAccessor:ConstArrayAccessor1<Vector2F> = solver.particleSystemData().positions()
        if posAccessor.size() != numberOfpoints {
            pos.resize(size: posAccessor.size())
        }
        
        for i in 0..<posAccessor.size() {
            pos[i].position.x = posAccessor[i].x-0.5
            pos[i].position.y = posAccessor[i].y-0.5
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 3600 {
            frame.advance()
            
            solver.update(frame: frame)
            
            exportStates(pos: &GPUBuffer)
            
            if solver.particleSystemData().numberOfParticles() != numberOfpoints {
                for i in 0..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].color = ColorUtils.makeJet(value: Float.random(in: -1.0...1.0))
                }
                
                for i in 0..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].size = 10.0
                }
                
                numberOfpoints = solver.particleSystemData().numberOfParticles()
            }
        }
        
        //update to GPU
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBuffer(GPUBuffer._data,
                                       offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .point, vertexStart: 0,
                                      vertexCount: 1,
                                      instanceCount: numberOfpoints)
        
        renderEncoder?.endEncoding()
    }
    
    func reset() {
        
    }
}
