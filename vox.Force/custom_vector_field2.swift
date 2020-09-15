//
//  custom_vector_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D vector field with custom field function.
class CustomVectorField2: VectorField2 {
    var _resolution:Float = 1e-3
    var _customFunction:(Vector2F)->Vector2F
    var _customDivergenceFunction:((Vector2F)->Float)?
    var _customCurlFunction:((Vector2F)->Float)?
    
    /// Constructs a field with given function.
    ///
    /// This constructor creates a field with user-provided function object.
    /// To compute derivatives, such as gradient and Laplacian, finite
    /// differencing is used. Thus, the differencing resolution also can be
    /// provided as the last parameter.
    init(customFunction:@escaping (Vector2F)->Vector2F,
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
    init(customFunction:@escaping (Vector2F)->Vector2F,
         customDivergenceFunction: ((Vector2F)->Float)?,
         derivativeResolution:Float = 1e-3) {
        self._customFunction = customFunction
        self._customDivergenceFunction = customDivergenceFunction
        self._resolution = derivativeResolution
    }
    
    /// Constructs a field with given field, gradient, and Laplacian function.
    init(customFunction:@escaping (Vector2F)->Vector2F,
         customDivergenceFunction:((Vector2F)->Float)?,
         customCurlFunction:((Vector2F)->Float)?) {
        self._customFunction = customFunction
        self._customDivergenceFunction = customDivergenceFunction
        self._customCurlFunction = customCurlFunction
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector2F) -> Vector2F {
        return _customFunction(x)
    }
    
    /// Returns the sampler function.
    func sampler()->(Vector2F)->Vector2F {
        return _customFunction
    }
    
    /// Returns the divergence at given position \p x.
    func divergence(x:Vector2F)->Float {
        if _customDivergenceFunction != nil {
            return _customDivergenceFunction!(x)
        } else {
            let left:Float = _customFunction(x - Vector2F(0.5 * _resolution, 0.0)).x
            let right:Float = _customFunction(x + Vector2F(0.5 * _resolution, 0.0)).x
            let bottom:Float = _customFunction(x - Vector2F(0.0, 0.5 * _resolution)).y
            let top:Float = _customFunction(x + Vector2F(0.0, 0.5 * _resolution)).y
            
            return (right - left + top - bottom) / _resolution
        }
    }
    
    /// Returns the curl at given position \p x.
    func curl(x:Vector2F)->Float {
        if _customCurlFunction != nil {
            return _customCurlFunction!(x)
        } else {
            let left:Float = _customFunction(x - Vector2F(0.5 * _resolution, 0.0)).y
            let right:Float = _customFunction(x + Vector2F(0.5 * _resolution, 0.0)).y
            let bottom:Float = _customFunction(x - Vector2F(0.0, 0.5 * _resolution)).x
            let top:Float = _customFunction(x + Vector2F(0.0, 0.5 * _resolution)).x
            
            return (top - bottom - right + left) / _resolution
        }
    }
    
    //MARK:- Builder
    /// Front-end to create CustomVectorField2 objects step by step.
    class Builder {
        var _resolution:Float = 1e-3
        var _customFunction:((Vector2F)->Vector2F)?
        var _customDivergenceFunction:((Vector2F)->Float)?
        var _customCurlFunction:((Vector2F)->Float)?
        
        /// Returns builder with field function.
        func withFunction(function:@escaping (Vector2F)->Vector2F)->Builder {
            self._customFunction = function
            return self
        }
        
        /// Returns builder with divergence function.
        func withDivergenceFunction(function:@escaping (Vector2F)->Float)->Builder {
            self._customDivergenceFunction = function
            return self
        }
        
        /// Returns builder with curl function.
        func withCurlFunction(function:@escaping (Vector2F)->Float)->Builder {
            self._customCurlFunction = function
            return self
        }
        
        /// Returns builder with derivative resolution.
        func withDerivativeResolution(resolution:Float)->Builder {
            self._resolution = resolution
            return self
        }
        
        /// Builds CustomVectorField2.
        func build()->CustomVectorField2 {
            if _customCurlFunction != nil {
                return CustomVectorField2(
                    customFunction: _customFunction!,
                    customDivergenceFunction: _customDivergenceFunction,
                    customCurlFunction: _customCurlFunction!)
            } else {
                return CustomVectorField2(
                    customFunction: _customFunction!,
                    customDivergenceFunction: _customDivergenceFunction,
                    derivativeResolution: _resolution)
            }
        }
    }
    
    /// Returns builder fox CustomVectorField2.
    static func builder()->Builder{
        return Builder()
    }
}
