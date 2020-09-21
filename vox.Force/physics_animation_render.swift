//
//  physics_animation_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/2.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class SimpleMassSpringAnimation: PhysicsAnimation {
    struct Edge
    {
        var first:size_t = 0
        var second:size_t = 0
    }
    
    struct Constraint
    {
        var pointIndex:size_t = 0
        var fixedPosition = Vector3F()
        var fixedVelocity = Vector3F()
    }
    
    var positions:[Vector3F] = []
    var velocities:[Vector3F] = []
    var forces:[Vector3F] = []
    var edges:[Edge] = []
    
    var mass:Float = 1.0
    var gravity = Vector3F(0.0, -9.8, 0.0)
    var stiffness:Float = 500.0
    var restLength:Float = 1.0
    var dampingCoefficient:Float = 1.0
    var dragCoefficient:Float = 0.1
    
    var floorPositionY:Float = -7.0
    var restitutionCoefficient:Float = 0.3
    
    var wind:VectorField3?
    var constraints:[Constraint] = []
    
    func makeChain(numberOfPoints:size_t) {
        if (numberOfPoints == 0) {
            return
        }
        
        let numberOfEdges = numberOfPoints - 1
        
        positions = Array<Vector3F>(repeating: Vector3F(), count: numberOfPoints)
        velocities = Array<Vector3F>(repeating: Vector3F(), count: numberOfPoints)
        forces = Array<Vector3F>(repeating: Vector3F(), count: numberOfPoints)
        edges = Array<Edge>(repeating: Edge(), count: numberOfEdges)
        
        for i in 0..<numberOfPoints {
            positions[i].x = Float(-i)
        }
        
        for i in 0..<numberOfEdges {
            edges[i] = Edge(first: i, second: i + 1)
        }
    }
    
    func exportStates(pos:inout Array1<Vector2F>) {
        pos.resize(size: positions.count)
        
        for i in 0..<positions.count {
            pos[i].x = positions[i].x/Float(positions.count)
            pos[i].y = positions[i].y/(abs(floorPositionY)+1)
        }
    }
    
    override func onAdvanceTimeStep(timeIntervalInSeconds:Double) {
        let numberOfPoints = positions.count
        let numberOfEdges = edges.count
        
        // Compute forces
        for i in 0..<numberOfPoints {
            // Gravity force
            forces[i] = mass * gravity
            
            // Air drag force
            var relativeVel = velocities[i]
            if (wind != nil)
            {
                relativeVel -= wind!.sample(x: positions[i])
            }
            forces[i] += -dragCoefficient * relativeVel
        }
        
        for i in 0..<numberOfEdges {
            let pointIndex0 = edges[i].first
            let pointIndex1 = edges[i].second
            
            // Compute spring force
            let pos0 = positions[pointIndex0]
            let pos1 = positions[pointIndex1]
            let r = pos0 - pos1
            let distance = length(r)
            if (distance > 0.0)
            {
                let force = -stiffness * (distance - restLength) * normalize(r)
                forces[pointIndex0] += force
                forces[pointIndex1] -= force
            }
            
            // Add damping force
            let vel0 = velocities[pointIndex0]
            let vel1 = velocities[pointIndex1]
            let relativeVel0 = vel0 - vel1
            let damping = -dampingCoefficient * relativeVel0
            forces[pointIndex0] += damping
            forces[pointIndex1] -= damping
        }
        
        // Update states
        for i in 0..<numberOfPoints {
            // Compute new states
            let newAcceleration = forces[i] / mass
            var newVelocity = velocities[i] + Float(timeIntervalInSeconds) * newAcceleration
            var newPosition = positions[i] + Float(timeIntervalInSeconds) * newVelocity
            
            // Collision
            if (newPosition.y < floorPositionY)
            {
                newPosition.y = floorPositionY
                
                if (newVelocity.y < 0.0)
                {
                    newVelocity.y *= -restitutionCoefficient
                    newPosition.y += Float(timeIntervalInSeconds) * newVelocity.y
                }
            }
            
            // Update states
            velocities[i] = newVelocity
            positions[i] = newPosition
        }
        
        // Apply constraints
        for i in 0..<constraints.count {
            let pointIndex = constraints[i].pointIndex
            positions[pointIndex] = constraints[i].fixedPosition
            velocities[pointIndex] = constraints[i].fixedVelocity
        }
    }
}

class SimpleMassSpringAnimationRenderable: Renderable {
    let anim = SimpleMassSpringAnimation()
    var frame = Frame()
    
    var renderPipelineState: MTLRenderPipelineState!
    var particleBuffer:Array1<Vector2F>
    var colorBuffer:Array1<Vector4F>
    let indexBuffer: MTLBuffer?
    var numberOfPoints:size_t
    
    init() {
        numberOfPoints = 50
        anim.restLength = 0.1
        anim.makeChain(numberOfPoints: numberOfPoints)
        anim.wind = ConstantVectorField3(value: Vector3F(30.0, 0.0, 0.0))
        anim.constraints.append(SimpleMassSpringAnimation.Constraint(pointIndex: 0, fixedPosition: Vector3F(),
                                                                     fixedVelocity: Vector3F()))
        
        particleBuffer = Array1<Vector2F>(size: numberOfPoints)
        colorBuffer = Array1<Vector4F>(size: numberOfPoints)
        for i in 0..<numberOfPoints {
            colorBuffer[i] = ColorUtils.makeJet(value: Float.random(in: -1.0...1.0))
        }
        
        let IndexSize = MemoryLayout<UInt32>.stride * numberOfPoints
        indexBuffer = Renderer.device.makeBuffer(length: IndexSize)!
        var Indexpointer = indexBuffer!.contents().bindMemory(to: UInt32.self,
                                                              capacity: numberOfPoints)
        for i in 0..<numberOfPoints {
            Indexpointer.pointee = UInt32(i)
            Indexpointer = Indexpointer.advanced(by: 1)
        }
        
        buildPipelineStates()
    }
    
    func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary() else { return }
            
            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_line")
            let fragmentFunction = library.makeFunction(name: "fragment_line")
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
            vertexDescriptor.layouts[0].stride = MemoryLayout<float2>.size
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            descriptor.vertexDescriptor = vertexDescriptor
            
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func draw(in view: MTKView) {
        if frame.index < 3600 {
            frame.advance()
            
            anim.update(frame: frame)
            anim.exportStates(pos: &particleBuffer)
        }
        
        //update to GPU
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = Renderer.commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBuffer(particleBuffer._data,
                                       offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(colorBuffer._data,
                                       offset: 0, index: 1)
        
        renderEncoder?.drawIndexedPrimitives(type: .lineStrip, indexCount: numberOfPoints,
                                             indexType: .uint32, indexBuffer: indexBuffer!,
                                             indexBufferOffset: 0)
        
        renderEncoder?.endEncoding()
    }
    
    func reset() {
        frame.index = 0
    }
}
