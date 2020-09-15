//
//  custom_scalar_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D scalar field with custom field function.
class CustomScalarField3: ScalarField3 {
    var _resolution:Float = 1e-3
    var _customFunction:(Vector3F)->Float
    var _customGradientFunction:((Vector3F)->Vector3F)?
    var _customLaplacianFunction:((Vector3F)->Float)?
    
    /// Constructs a field with given function.
    ///
    /// This constructor creates a field with user-provided function object.
    /// To compute derivatives, such as gradient and Laplacian, finite
    /// differencing is used. Thus, the differencing resolution also can be
    /// provided as the last parameter.
    init(customFunction:@escaping (Vector3F)->Float,
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
    init(customFunction:@escaping (Vector3F)->Float,
         customGradientFunction:@escaping (Vector3F)->Vector3F,
         derivativeResolution:Float = 1e-3) {
        self._customFunction = customFunction
        self._customGradientFunction = customGradientFunction
        self._resolution = derivativeResolution
    }
    
    /// Constructs a field with given field, gradient, and Laplacian function.
    init(customFunction:@escaping (Vector3F)->Float,
         customGradientFunction:@escaping (Vector3F)->Vector3F,
         customLaplacianFunction:@escaping (Vector3F)->Float) {
        self._customFunction = customFunction
        self._customGradientFunction = customGradientFunction
        self._customLaplacianFunction = customLaplacianFunction
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector3F) -> Float {
        return _customFunction(x)
    }
    
    /// Returns the sampler function.
    func sampler()->(Vector3F)->Float {
        return self._customFunction
    }
    
    /// Returns the gradient vector at given position \p x.
    func gradient(x:Vector3F)->Vector3F {
        if _customGradientFunction != nil {
            return _customGradientFunction!(x)
        } else {
            let left:Float
                = _customFunction(x - Vector3F(0.5 * _resolution, 0.0, 0.0))
            let right:Float
                = _customFunction(x + Vector3F(0.5 * _resolution, 0.0, 0.0))
            let bottom:Float
                = _customFunction(x - Vector3F(0.0, 0.5 * _resolution, 0.0))
            let top:Float
                = _customFunction(x + Vector3F(0.0, 0.5 * _resolution, 0.0))
            let back:Float
                = _customFunction(x - Vector3F(0.0, 0.0, 0.5 * _resolution))
            let front:Float
                = _customFunction(x + Vector3F(0.0, 0.0, 0.5 * _resolution))
            
            return Vector3F(
                (right - left) / _resolution,
                (top - bottom) / _resolution,
                (front - back) / _resolution)
        }
    }
    
    /// Returns the Laplacian at given position \p x.
    func laplacian(x:Vector3F)->Float {
        if _customLaplacianFunction != nil {
            return _customLaplacianFunction!(x)
        } else {
            let center = _customFunction(x)
            let left:Float
                = _customFunction(x - Vector3F(0.5 * _resolution, 0.0, 0.0))
            let right:Float
                = _customFunction(x + Vector3F(0.5 * _resolution, 0.0, 0.0))
            let bottom:Float
                = _customFunction(x - Vector3F(0.0, 0.5 * _resolution, 0.0))
            let top:Float
                = _customFunction(x + Vector3F(0.0, 0.5 * _resolution, 0.0))
            let back:Float
                = _customFunction(x - Vector3F(0.0, 0.0, 0.5 * _resolution))
            let front:Float
                = _customFunction(x + Vector3F(0.0, 0.0, 0.5 * _resolution))
            
            return (left + right + bottom + top + back + front - 6.0 * center)
                / (_resolution * _resolution)
        }
    }
    
    //MARK:- Builder
    /// Front-end to create CustomScalarField3 objects step by step.
    class Builder {
        var _resolution:Float = 1e-3
        var _customFunction:((Vector3F)->Float)?
        var _customGradientFunction:((Vector3F)->Vector3F)?
        var _customLaplacianFunction:((Vector3F)->Float)?
        
        /// Returns builder with field function.
        func withFunction(function:@escaping (Vector3F)->Float)->Builder {
            self._customFunction = function
            return self
        }
        
        /// Returns builder with divergence function.
        func withGradientFunction(function:@escaping (Vector3F)->Vector3F)->Builder {
            self._customGradientFunction = function
            return self
        }
        
        /// Returns builder with curl function.
        func withLaplacianFunction(function:@escaping (Vector3F)->Float)->Builder {
            self._customLaplacianFunction = function
            return self
        }
        
        /// Returns builder with derivative resolution.
        func withDerivativeResolution(resolution:Float)->Builder {
            self._resolution = resolution
            return self
        }
        
        /// Builds CustomScalarField3.
        func build()->CustomScalarField3 {
            if _customLaplacianFunction != nil {
                return CustomScalarField3(
                    customFunction: _customFunction!,
                    customGradientFunction: _customGradientFunction!,
                    customLaplacianFunction: _customLaplacianFunction!)
            } else {
                return CustomScalarField3(
                    customFunction: _customFunction!,
                    customGradientFunction: _customGradientFunction!,
                    derivativeResolution: _resolution)
            }
        }
    }
    
    /// Returns builder fox CustomScalarField3.
    static func builder()->Builder{
        return Builder()
    }
}
