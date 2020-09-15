//
//  custom_scalar_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D scalar field with custom field function.
class CustomScalarField2: ScalarField2 {
    var _resolution:Float = 1e-3
    var _customFunction:(Vector2F)->Float
    var _customGradientFunction:((Vector2F)->Vector2F)?
    var _customLaplacianFunction:((Vector2F)->Float)?
    
    /// Constructs a field with given function.
    ///
    /// This constructor creates a field with user-provided function object.
    /// To compute derivatives, such as gradient and Laplacian, finite
    /// differencing is used. Thus, the differencing resolution also can be
    /// provided as the last parameter.
    init(customFunction:@escaping (Vector2F)->Float,
         derivativeResolution:Float = 1e-3) {
        self._customFunction = customFunction
        self._resolution = derivativeResolution
    }
    
    /// Constructs a field with given field and gradient function.
    ///
    /// This constructor creates a field with user-provided field and gradient
    /// function objects. To compute Laplacian, finite differencing is used.
    /// Thus, the differencing resolution also can be provided as the last
    /// parameter.
    init(customFunction:@escaping (Vector2F)->Float,
         customGradientFunction:@escaping (Vector2F)->Vector2F,
         derivativeResolution:Float = 1e-3) {
        self._customFunction = customFunction
        self._customGradientFunction = customGradientFunction
        self._resolution = derivativeResolution
    }
    
    /// Constructs a field with given field, gradient, and Laplacian function.
    init(customFunction:@escaping (Vector2F)->Float,
         customGradientFunction:@escaping (Vector2F)->Vector2F,
         customLaplacianFunction:@escaping (Vector2F)->Float) {
        self._customFunction = customFunction
        self._customGradientFunction = customGradientFunction
        self._customLaplacianFunction = customLaplacianFunction
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector2F) -> Float {
        return _customFunction(x)
    }
    
    /// Returns the sampler function.
    func sampler()->(Vector2F)->Float {
        return self._customFunction
    }
    
    /// Returns the gradient vector at given position \p x.
    func gradient(x:Vector2F)->Vector2F {
        if _customGradientFunction != nil {
            return _customGradientFunction!(x)
        } else {
            let left:Float = _customFunction(x - Vector2F(0.5 * _resolution, 0.0))
            let right:Float = _customFunction(x + Vector2F(0.5 * _resolution, 0.0))
            let bottom:Float = _customFunction(x - Vector2F(0.0, 0.5 * _resolution))
            let top:Float = _customFunction(x + Vector2F(0.0, 0.5 * _resolution))
            
            return Vector2F(
                (right - left) / _resolution,
                (top - bottom) / _resolution)
        }
    }
    
    /// Returns the Laplacian at given position \p x.
    func laplacian(x:Vector2F)->Float {
        if _customLaplacianFunction != nil {
            return _customLaplacianFunction!(x)
        } else {
            let center:Float = _customFunction(x)
            let left:Float = _customFunction(x - Vector2F(0.5 * _resolution, 0.0))
            let right:Float = _customFunction(x + Vector2F(0.5 * _resolution, 0.0))
            let bottom:Float = _customFunction(x - Vector2F(0.0, 0.5 * _resolution))
            let top:Float = _customFunction(x + Vector2F(0.0, 0.5 * _resolution))
            
            return (left + right + bottom + top - 4.0 * center)
                / (_resolution * _resolution)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create CustomScalarField2 objects step by step.
    class Builder {
        var _resolution:Float = 1e-3
        var _customFunction:((Vector2F)->Float)?
        var _customGradientFunction:((Vector2F)->Vector2F)?
        var _customLaplacianFunction:((Vector2F)->Float)?
        
        /// Returns builder with field function.
        func withFunction(function:@escaping (Vector2F)->Float)->Builder {
            self._customFunction = function
            return self
        }
        
        /// Returns builder with divergence function.
        func withGradientFunction(function:@escaping (Vector2F)->Vector2F)->Builder {
            self._customGradientFunction = function
            return self
        }
        
        /// Returns builder with curl function.
        func withLaplacianFunction(function:@escaping (Vector2F)->Float)->Builder {
            self._customLaplacianFunction = function
            return self
        }
        
        /// Returns builder with derivative resolution.
        func withDerivativeResolution(resolution:Float)->Builder {
            self._resolution = resolution
            return self
        }
        
        /// Builds CustomScalarField2.
        func build()->CustomScalarField2 {
            if _customLaplacianFunction != nil {
                return CustomScalarField2(
                    customFunction: _customFunction!,
                    customGradientFunction: _customGradientFunction!,
                    customLaplacianFunction: _customLaplacianFunction!)
            } else {
                return CustomScalarField2(
                    customFunction: _customFunction!,
                    customGradientFunction: _customGradientFunction!,
                    derivativeResolution: _resolution)
            }
        }
    }
    
    /// Returns builder fox CustomScalarField2.
    static func builder()->Builder{
        return Builder()
    }
}
