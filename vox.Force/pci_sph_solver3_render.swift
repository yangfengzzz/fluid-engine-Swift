//
//  pci_sph_solver3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class PciSphSolver3Renderable: Renderable {
    let solver = PciSphSolver3()
    var frame = Frame(newIndex: 0, newTimeIntervalInSeconds: 1.0 / 60.0)
    
    struct Particle : ZeroInit {
        init() {
            position = float3()
            color = float4(1, 0, 0, 1)
            size = 0
        }
        
        func getKernelType() -> KernelType {
            .unsupported
        }
        
        var position: float3
        var color: float4
        var size: Float
    }
    
    var renderPipelineState: MTLRenderPipelineState!
    var GPUBuffer = Array1<Particle>()
    var numberOfpoints:Int = 0
    
    init() {
        SteadyState()
        buildPipelineStates()
    }
    
    func SteadyState() {
        solver.setViscosityCoefficient(newViscosityCoefficient: 0.1)
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 10.0)
        
        let particles = solver.sphSystemData()
        particles.setTargetDensity(targetDensity: 1000.0)
        let targetSpacing = particles.targetSpacing()
        
        var initialBound = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 0.5, 1))
        initialBound.expand(delta: -targetSpacing)
        
        let emitter = VolumeParticleEmitter3(implicitSurface: SurfaceToImplicit3(surface: Sphere3(center: Vector3F(),
                                                                                                  radiustransform: 10.0)),
                                             maxRegion: initialBound,
                                             spacing: targetSpacing,
                                             initialVel: Vector3F())
        emitter.setJitter(newJitter: 0.0)
        solver.setEmitter(newEmitter: emitter)
        
        let box = Box3(lowerCorner: Vector3F(), upperCorner: Vector3F(1, 1, 1))
        box.isNormalFlipped = true
        let collider = RigidBodyCollider3(surface: box)
        solver.setCollider(newCollider: collider)
    }
    
    func WaterDrop() {
        let targetSpacing:Float = 0.02
        
        let domain = BoundingBox3F(point1: Vector3F(), point2: Vector3F(1, 2, 0.5))
        
        // Initialize solvers
        solver.setPseudoViscosityCoefficient(newPseudoViscosityCoefficient: 0.0)
        
        let particles = solver.sphSystemData()
        particles.setTargetDensity(targetDensity: 1000.0)
        particles.setTargetSpacing(spacing: targetSpacing)
        
        // Initialize source
        let surfaceSet = ImplicitSurfaceSet3()
        surfaceSet.addExplicitSurface(surface: Plane3(
            normal: Vector3F(0, 1, 0), point: Vector3F(0, 0.25 * domain.height(), 0)))
        surfaceSet.addExplicitSurface(surface: Sphere3(
            center: domain.midPoint(), radiustransform: 0.15 * domain.width()))
        
        var sourceBound = BoundingBox3F(other: domain)
        sourceBound.expand(delta: -targetSpacing)
        
        let emitter = VolumeParticleEmitter3(
            implicitSurface: surfaceSet,
            maxRegion: sourceBound,
            spacing: targetSpacing,
            initialVel: Vector3F())
        solver.setEmitter(newEmitter: emitter)
        
        // Initialize boundary
        let box = Box3(boundingBox: domain)
        box.isNormalFlipped = true
        let collider = RigidBodyCollider3(surface: box)
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
            vertexDescriptor.attributes[0].format = .float3
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
        let posAccessor:ConstArrayAccessor1<Vector3F> = solver.particleSystemData().positions()
        pos.resize(size: posAccessor.size())
        
        for i in 0..<posAccessor.size() {
            pos[i].position.x = posAccessor[i].x/3
            pos[i].position.y = posAccessor[i].y/3-0.6
            pos[i].position.z = posAccessor[i].z
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 360 {
            frame.advance()
            
            solver.update(frame: frame)
            
            exportStates(pos: &GPUBuffer)
            
            if solver.particleSystemData().numberOfParticles() > numberOfpoints {
                for i in numberOfpoints..<solver.particleSystemData().numberOfParticles() {
                    GPUBuffer[i].color = ColorUtils.makeJet(value: Float.random(in: -1.0...1.0))
                }
                
                for i in numberOfpoints..<solver.particleSystemData().numberOfParticles() {
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
