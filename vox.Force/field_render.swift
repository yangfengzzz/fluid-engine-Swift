//
//  field_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/3.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class MyCustomScalarField3: ScalarField3 {
    func sample(x:Vector3F)->Float {
        return sin(x.x) * sin(x.y) * sin(x.z)
    }
    
    func gradient(x:Vector3F)->Vector3F {
        return Vector3F(
            cos(x.x) * sin(x.y) * sin(x.z),
            sin(x.x) * cos(x.y) * sin(x.z),
            sin(x.x) * sin(x.y) * cos(x.z))
    }
    
    func laplacian(x:Vector3F)->Float {
        return -sin(x.x) * sin(x.y) * sin(x.z) - sin(x.x) * sin(x.y) * sin(x.z) - sin(x.x) * sin(x.y) * sin(x.z)
    }
}

class ScalarField3Renderable: Renderable {
    let field = MyCustomScalarField3()
    var data = Array2<Float>(width: 50, height: 50)
    var dataU = Array2<Float>(width: 20, height: 20)
    var dataV = Array2<Float>(width: 20, height: 20)
    
    func Sample() {
        for j in 0..<50 {
            for i in 0..<50 {
                let x = Vector3F(0.04 * kPiF * Float(i), 0.04 * kPiF * Float(j), kHalfPiF)
                data[i, j] = field.sample(x: x)
            }
        }
    }
    
    func Gradient() {
        for j in 0..<20 {
            for i in 0..<20 {
                let x = Vector3F(0.1 * kPiF * Float(i), 0.1 * kPiF * Float(j), kHalfPiF)
                let g = field.gradient(x: x)
                dataU[i, j] = g.x
                dataV[i, j] = g.y
            }
        }
    }
    
    func Laplacian() {
        for j in 0..<50 {
            for i in 0..<50 {
                let x = Vector3F(0.04 * kPiF * Float(i), 0.04 * kPiF * Float(j), kHalfPiF)
                data[i, j] = field.laplacian(x: x)
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}

class MyCustomVectorField3: VectorField3 {
    func sample(x:Vector3F)->Vector3F {
        return Vector3F(sin(x.x) * sin(x.y),
                        sin(x.y) * sin(x.z),
                        sin(x.z) * sin(x.x))
    }
    
    func divergence(x:Vector3F)->Float {
        return cos(x.x) * sin(x.y)
            + cos(x.y) * sin(x.z)
            + cos(x.z) * sin(x.x)
    }
    
    func curl(x:Vector3F)->Vector3F {
        return Vector3F(-sin(x.y) * cos(x.z),
                        -sin(x.z) * cos(x.x),
                        -sin(x.x) * cos(x.y))
    }
}

class MyCustomVectorField3_2: VectorField3 {
    func sample(x:Vector3F)->Vector3F {
        return Vector3F(-x.y, x.x, 0.0)
    }
}

class VectorField3Renderable: Renderable {
    let field = MyCustomVectorField3()
    var data = Array2<Float>(width: 50, height: 50)
    var dataU = Array2<Float>(width: 20, height: 20)
    var dataV = Array2<Float>(width: 20, height: 20)
    
    func Sample() {
        for j in 0..<20 {
            for i in 0..<20 {
                let x = Vector3F(0.1 * kPiF * Float(i), 0.1 * kPiF * Float(j), kHalfPiF)
                dataU[i, j] = field.sample(x: x).x
                dataV[i, j] = field.sample(x: x).y
            }
        }
    }
    
    func Divergence() {
        for j in 0..<50 {
            for i in 0..<50 {
                let x = Vector3F(0.04 * kPiF * Float(i), 0.04 * kPiF * Float(j), kHalfPiF)
                data[i, j] = field.divergence(x: x)
            }
        }
    }
    
    func Curl() {
        for j in 0..<20 {
            for i in 0..<20 {
                let x = Vector3F(0.1 * kPiF * Float(i), 0.1 * kPiF * Float(j), 0.5 * kHalfPiF)
                dataU[i, j] = field.curl(x: x).x
                dataV[i, j] = field.curl(x: x).y
            }
        }
    }
    
    func Sample2() {
        let field = MyCustomVectorField3_2()
        for j in 0..<20 {
            for i in 0..<20 {
                let x = Vector3F(0.05 * Float(i) - 0.5, 0.05 * Float(j) - 0.5, 0.5)
                dataU[i, j] = field.sample(x: x).x
                dataV[i, j] = field.sample(x: x).y
            }
        }
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
