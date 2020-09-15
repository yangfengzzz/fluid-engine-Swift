//
//  apic_solver3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/6.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class ApicSolver3Renderable: Renderable {
    var solver = ApicSolver3()
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
        WaterDrop()
        buildPipelineStates()
    }
    
    func WaterDrop() {
        let resolutionX:size_t = 32
        
        // Build solver
        solver = ApicSolver3.builder()
            .withResolution(resolution: [resolutionX, 2 * resolutionX, resolutionX])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        let grids = solver.gridSystemData()
        let gridSpacing = grids.gridSpacing()
        let dx = gridSpacing.x
        let domain = grids.boundingBox()
        
        // Build emitter
        let plane = Plane3.builder()
            .withNormal(normal: [0, 1, 0])
            .withPoint(point: [0, 0.25 * domain.height(), 0])
            .build()
        
        let sphere = Sphere3.builder()
            .withCenter(center: domain.midPoint())
            .withRadius(radius: 0.15 * domain.width())
            .build()
        
        let emitter1 = VolumeParticleEmitter3.builder()
            .withSurface(surface: plane)
            .withSpacing(spacing: 0.5 * dx)
            .withMaxRegion(bounds: domain)
            .withIsOneShot(isOneShot: true)
            .build()
        emitter1.setPointGenerator(newPointsGen: GridPointGenerator3())
        
        let emitter2 = VolumeParticleEmitter3.builder()
            .withSurface(surface: sphere)
            .withSpacing(spacing: 0.5 * dx)
            .withMaxRegion(bounds: domain)
            .withIsOneShot(isOneShot: true)
            .build()
        emitter2.setPointGenerator(newPointsGen: GridPointGenerator3())
        
        let emitterSet = ParticleEmitterSet3.builder()
            .withEmitters(emitters: [emitter1, emitter2])
            .build()
        
        solver.setParticleEmitter(newEmitter: emitterSet)
    }
    
    func DamBreakingWithCollider() {
        let resolutionX:size_t = 50
        
        // Build solver
        let resolution = Size3(3 * resolutionX, 2 * resolutionX, (3 * resolutionX) / 2)
        solver = ApicSolver3.builder()
            .withResolution(resolution: resolution)
            .withDomainSizeX(domainSizeX: 3.0)
            .build()
        
        let grids = solver.gridSystemData()
        let dx = grids.gridSpacing().x
        let domain = grids.boundingBox()
        let lz = domain.depth()
        
        // Build emitter
        let box1 = Box3.builder()
            .withLowerCorner(pt: [0, 0, 0])
            .withUpperCorner(pt: [Float(0.5 + 0.001), Float(0.75 + 0.001), 0.75 * lz + 0.001])
            .build()
        
        let box2 = Box3.builder()
            .withLowerCorner(pt: [Float(2.5 - 0.001), 0, 0.25 * lz - 0.001])
            .withUpperCorner(pt: [Float(3.5 + 0.001), Float(0.75 + 0.001), 1.5 * lz + 0.001])
            .build()
        
        let boxSet = ImplicitSurfaceSet3.builder()
            .withExplicitSurfaces(surfaces: [box1, box2])
            .build()
        
        let emitter = VolumeParticleEmitter3.builder()
            .withSurface(surface: boxSet)
            .withMaxRegion(bounds: domain)
            .withSpacing(spacing: 0.5 * dx)
            .build()
        
        emitter.setPointGenerator(newPointsGen: GridPointGenerator3())
        solver.setParticleEmitter(newEmitter: emitter)
        
        // Build collider
        let cyl1 = Cylinder3.builder()
            .withCenter(center: [1, 0.375, 0.375])
            .withRadius(radius: 0.1)
            .withHeight(height: 0.75)
            .build()
        
        let cyl2 = Cylinder3.builder()
            .withCenter(center: [1.5, 0.375, 0.75])
            .withRadius(radius: 0.1)
            .withHeight(height: 0.75)
            .build()
        
        let cyl3 = Cylinder3.builder()
            .withCenter(center: [2, 0.375, 1.125])
            .withRadius(radius: 0.1)
            .withHeight(height: 0.75)
            .build()
        
        let cylSet = ImplicitSurfaceSet3.builder()
            .withExplicitSurfaces(surfaces: [cyl1, cyl2, cyl3])
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: cylSet)
            .build()
        
        solver.setCollider(newCollider: collider)
    }
    
    func Spherical() {
        // Build solver
        solver = ApicSolver3.builder()
            .withResolution(resolution: [30, 30, 30])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        // Build collider
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.5, 0.5])
            .withRadius(radius: 0.4)
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
        
        // Manually emit particles
        let resX = solver.resolution().x
        for _ in 0..<8 * resX * resX {
            let pt = Vector3F(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1))
            if (length(pt - sphere.center) < sphere.radius && pt.x > 0.5) {
                solver.particleSystemData().addParticle(newPosition: pt)
            }
        }
    }
    
    func SphericalNonVariational() {
        // Build solver
        solver = ApicSolver3.builder()
            .withResolution(resolution: [30, 30, 30])
            .withDomainSizeX(domainSizeX: 1.0)
            .build()
        
        solver.setPressureSolver(newSolver: GridSinglePhasePressureSolver3())
        
        // Build collider
        let sphere = Sphere3.builder()
            .withCenter(center: [0.5, 0.5, 0.5])
            .withRadius(radius: 0.4)
            .withIsNormalFlipped(isNormalFlipped: true)
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: sphere)
            .build()
        
        solver.setCollider(newCollider: collider)
        
        // Manually emit particles
        let resX = solver.resolution().x
        for _ in 0..<8 * resX * resX {
            let pt = Vector3F(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1))
            if (length(pt - sphere.center) < sphere.radius && pt.x > 0.5) {
                solver.particleSystemData().addParticle(newPosition: pt)
            }
        }
    }
    
    func TriangleMeshDemo() {
        let resX:size_t = 50
        
        solver = ApicSolver3.builder()
            .withResolution(resolution: [resX, 3 * resX, resX])
            .withDomainSizeX(domainSizeX: 4)
            .withOrigin(gridOrigin: [-2, -2, -2])
            .build()
        
        let gridSpacing = solver.gridSpacing().x
        
        let sphere1 = Sphere3.builder()
            .withCenter(center: [-0.01, 1.0, -0.01])
            .withRadius(radius: 0.4)
            .build()
        let sphere2 = Sphere3.builder()
            .withCenter(center: [0.01, 2.0, 0.01])
            .withRadius(radius: 0.4)
            .build()
        let spheres = SurfaceSet3.builder()
            .withSurfaces(others: [sphere1, sphere2])
            .build()
        
        let emitter = VolumeParticleEmitter3.builder()
            .withSurface(surface: spheres)
            .withSpacing(spacing: 0.5 * gridSpacing)
            .withJitter(jitter: 0.1)
            .build()
        
        solver.setParticleEmitter(newEmitter: emitter)
        
        let cupMesh = TriangleMesh3.builder().build()
        cupMesh.readObj(filename: "cup.obj")
        
        let cup = ImplicitTriangleMesh3.builder()
            .withTriangleMesh(mesh: cupMesh)
            .withResolutionX(resolutionX: 100)
            .build()
        
        let collider = RigidBodyCollider3.builder()
            .withSurface(surface: cup)
            .build()
        
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
