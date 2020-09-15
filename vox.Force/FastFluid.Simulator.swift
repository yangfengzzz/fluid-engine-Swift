//
//  FastFluid.Simulator.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

extension FastFluid {
    class Simulator {
        // Resources
        private(set) var fluid: Grids
        
        // Commands
        private let advect: Advect
        private let addForce: AddForce
        private let divergence: Divergence
        private let jacobi: Jacobi
        private let subtractGradient: SubtractGradient
        private let clearAll: ClearAll
        
        init?(width: Int, height: Int) {            
            do {
                advect = try Advect(device: Renderer.device, library: Renderer.library)
                addForce = try AddForce(device: Renderer.device, library: Renderer.library)
                divergence = try Divergence(device: Renderer.device, library: Renderer.library)
                jacobi = try Jacobi(device: Renderer.device, library: Renderer.library)
                subtractGradient = try SubtractGradient(device: Renderer.device, library: Renderer.library)
                clearAll = try ClearAll(device: Renderer.device, library: Renderer.library)
            } catch {
                print("Failed to create shader program: \(error)")
                return nil
            }
            
            guard let fluid = Grids(device: Renderer.device,
                                    width: width,
                                    height: height) else {
                                        print("Failed to create Fluid")
                                        return nil
            }
            
            self.fluid = fluid
        }
        
        func initializeFluid(with width: Int, height: Int) {
            guard let fluid = Grids(device: Renderer.device,
                                    width: width,
                                    height: height) else {
                                        return
            }
            
            self.fluid = fluid
        }
        
        func encode(in buffer: MTLCommandBuffer, touchEvents: [TouchEvent]? = nil) {
            // Advect Velocity
            advect.encode(in: buffer, source: fluid.velocity.source,
                          velocity: fluid.velocity.source,
                          dest: fluid.velocity.dest,
                          dissipation: 0.99)
            fluid.velocity.swap()
            
            // Advect Pressure
            advect.encode(in: buffer, source: fluid.pressure.source,
                          velocity: fluid.velocity.source,
                          dest: fluid.pressure.dest,
                          dissipation: 0.99)
            fluid.pressure.swap()
            
            // Advect Density
            advect.encode(in: buffer, source: fluid.density.source,
                          velocity: fluid.velocity.source,
                          dest: fluid.density.dest,
                          dissipation: 0.99)
            fluid.density.swap()
            
            // Add Force
            if let touchEvents = touchEvents {
                addForce.encode(in: buffer, texture: fluid.velocity,
                                touchEvents: touchEvents)
                fluid.velocity.swap()
            }
            
            // Compute Divergence
            divergence.encode(in: buffer, source: fluid.velocity.source,
                              dest: fluid.divergence)
            
            // Compute Jacobi
            jacobi.encode(in: buffer, slab: fluid.pressure,
                          divergence: fluid.divergence)
            
            // Subtract Gradient
            subtractGradient.encode(in: buffer, pressure: fluid.pressure.source,
                                    w: fluid.velocity.source,
                                    target: fluid.velocity.dest)
            fluid.velocity.swap()
            
            // Clear Pressure
            clearAll.encode(in: buffer, target: fluid.pressure.source, value: 0.0)
        }
        
        var currentTexture: MTLTexture {
            return fluid.density.source
        }
    }
}
