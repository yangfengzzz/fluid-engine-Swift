//
//  Emitter.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/7.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

struct Particle {
    var startPosition: float2
    var position: float2
    var direction: Float
    var speed: Float
    var color: float4
    var age: Float
    var life: Float
    var size: Float
    var scale: Float = 1.0
    var startScale: Float = 1.0
    var endScale: Float = 1.0
}

struct ParticleDescriptor {
    var position: float2 = [0, 0]
    var positionXRange: ClosedRange<Float> = 0...0
    var positionYRange: ClosedRange<Float> = 0...0
    var direction: Float = 0
    var directionRange: ClosedRange<Float> = 0...0
    var speed: Float = 0
    var speedRange: ClosedRange<Float> = 0...0
    var pointSize: Float = 80
    var pointSizeRange: ClosedRange<Float> = 0...0
    var startScale: Float = 0
    var startScaleRange: ClosedRange<Float> = 1...1
    var endScale: Float = 0
    var endScaleRange: ClosedRange<Float>?
    var life: Float = 0
    var lifeRange: ClosedRange<Float> = 1...1
    var color: float4 = [0, 0, 0, 1]
}

class Emitter {
    var position: float2 = [0, 0]
    var currentParticles = 0
    var particleCount: Int = 0 {
        didSet {
            let bufferSize = MemoryLayout<Particle>.stride * particleCount
            particleBuffer = Renderer.device.makeBuffer(length: bufferSize)!
        }
    }
    var birthRate = 0
    var birthDelay = 0 {
        didSet {
            birthTimer = birthDelay
        }
    }
    private var birthTimer = 0
    
    var particleTexture: MTLTexture!
    var particleBuffer: MTLBuffer?
    
    var particleDescriptor: ParticleDescriptor?
    
    func emit() {
        if currentParticles >= particleCount {
            return
        }
        guard let particleBuffer = particleBuffer,
            let pd = particleDescriptor else {
                return
        }
        birthTimer += 1
        if birthTimer < birthDelay {
            return
        }
        birthTimer = 0
        var pointer = particleBuffer.contents().bindMemory(to: Particle.self,
                                                           capacity: particleCount)
        pointer = pointer.advanced(by: currentParticles)
        for _ in 0..<birthRate {
            let positionX = pd.position.x + .random(in: pd.positionXRange)
            let positionY = pd.position.y + .random(in: pd.positionYRange)
            pointer.pointee.position = [positionX, positionY]
            pointer.pointee.startPosition = pointer.pointee.position
            pointer.pointee.size = pd.pointSize + .random(in: pd.pointSizeRange)
            pointer.pointee.direction = pd.direction + .random(in: pd.directionRange)
            pointer.pointee.speed = pd.speed + .random(in: pd.speedRange)
            pointer.pointee.scale = pd.startScale + .random(in: pd.startScaleRange)
            pointer.pointee.startScale = pointer.pointee.scale
            if let range = pd.endScaleRange {
                pointer.pointee.endScale = pd.endScale + .random(in: range)
            } else {
                pointer.pointee.endScale = pointer.pointee.startScale
            }
            
            pointer.pointee.age = 0
            pointer.pointee.life = pd.life + .random(in: pd.lifeRange)
            pointer.pointee.color = pd.color
            pointer = pointer.advanced(by: 1)
        }
        currentParticles += birthRate
    }
    
    static func loadTexture(imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        var texture: MTLTexture?
        let textureLoaderOptions: [MTKTextureLoader.Option : Any]
        textureLoaderOptions = [.origin: MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        do {
            let fileExtension: String? = URL(fileURLWithPath: imageName).pathExtension.count == 0 ? "png" : nil
            if let url: URL = Bundle.main.url(forResource: imageName, withExtension: fileExtension) {
                texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
            } else {
                print("Failed to load \(imageName)")
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return texture
    }
}
