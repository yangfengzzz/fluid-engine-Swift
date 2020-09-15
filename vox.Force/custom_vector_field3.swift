//
//  custom_vector_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 3-D vector field with custom field function.
class CustomVectorField3: VectorField3 {
    var _resolution:Float = 1e-3
    var _customFunction:(Vector3F)->Vector3F
    var _customDivergenceFunction:((Vector3F)->Float)?
    var _customCurlFunction:((Vector3F)->Vector3F)?
    
    /// Constructs a field with given function.
    ///
    /// This constructor creates a field with user-provided function object.
    /// To compute derivatives, such as gradient and Laplacian, finite
    /// differencing is used. Thus, the differencing resolution also can be
    /// provided as the last parameter.
    init(customFunction:@escaping (Vector3F)->Vector3F,
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
    init(customFunction:@escaping (Vector3F)->Vector3F,
         customDivergenceFunction:((Vector3F)->Float)?,
         derivativeResolution:Float = 1e-3) {
        self._customFunction = customFunction
        self._customDivergenceFunction = customDivergenceFunction
        self._resolution = derivativeResolution
    }
    
    /// Constructs a field with given field, gradient, and Laplacian function.
    init(customFunction:@escaping (Vector3F)->Vector3F,
         customDivergenceFunction:((Vector3F)->Float)?,
         customCurlFunction:((Vector3F)->Vector3F)?) {
        self._customFunction = customFunction
        self._customDivergenceFunction = customDivergenceFunction
        self._customCurlFunction = customCurlFunction
    }
    
    /// Returns the sampled value at given position \p x.
    func sample(x: Vector3F) -> Vector3F {
        return _customFunction(x)
    }
    
    /// Returns the sampler function.
    func sampler()->(Vector3F)->Vector3F {
        return _customFunction
    }
    
    /// Returns the divergence at given position \p x.
    func divergence(x:Vector3F)->Float {
        if _customDivergenceFunction != nil {
            return _customDivergenceFunction!(x)
        } else {
            let left
            = _customFunction(x - Vector3F(0.5 * _resolution, 0.0, 0.0)).x
            let right
            = _customFunction(x + Vector3F(0.5 * _resolution, 0.0, 0.0)).x
            let bottom
            = _customFunction(x - Vector3F(0.0, 0.5 * _resolution, 0.0)).y
            let top
            = _customFunction(x + Vector3F(0.0, 0.5 * _resolution, 0.0)).y
            let back
            = _customFunction(x - Vector3F(0.0, 0.0, 0.5 * _resolution)).z
            let front
            = _customFunction(x + Vector3F(0.0, 0.0, 0.5 * _resolution)).z
            
            return (right - left + top - bottom + front - back) / _resolution
        }
    }
    
    /// Returns the curl at given position \p x.
    func curl(x:Vector3F)->Vector3F {
        if _customCurlFunction != nil {
            return _customCurlFunction!(x)
        } else {
            let left
            = _customFunction(x - Vector3F(0.5 * _resolution, 0.0, 0.0))
            let right
            = _customFunction(x + Vector3F(0.5 * _resolution, 0.0, 0.0))
            let bottom
            = _customFunction(x - Vector3F(0.0, 0.5 * _resolution, 0.0))
            let top
            = _customFunction(x + Vector3F(0.0, 0.5 * _resolution, 0.0))
            let back
            = _customFunction(x - Vector3F(0.0, 0.0, 0.5 * _resolution))
            let front
            = _customFunction(x + Vector3F(0.0, 0.0, 0.5 * _resolution))
            
            let Fx_ym = bottom.x
            let Fx_yp = top.x
            let Fx_zm = back.x
            let Fx_zp = front.x
            
            let Fy_xm = left.y
            let Fy_xp = right.y
            let Fy_zm = back.y
            let Fy_zp = front.y
            
            let Fz_xm = left.z
            let Fz_xp = right.z
            let Fz_ym = bottom.z
            let Fz_yp = top.z
            
            return Vector3F(
                            (Fz_yp - Fz_ym) - (Fy_zp - Fy_zm),
                            (Fx_zp - Fx_zm) - (Fz_xp - Fz_xm),
                            (Fy_xp - Fy_xm) - (Fx_yp - Fx_ym)) / _resolution
        }
    }
    
    //MARK:- Builder
    /// Front-end to create CustomVectorField3 objects step by step.
    class Builder {
        var _resolution:Float = 1e-3
        var _customFunction:((Vector3F)->Vector3F)?
        var _customDivergenceFunction:((Vector3F)->Float)?
        var _customCurlFunction:((Vector3F)->Vector3F)?
        
        /// Returns builder with field function.
        func withFunction(function:@escaping (Vector3F)->Vector3F)->Builder {
            self._customFunction = function
            return self
        }
        
        /// Returns builder with divergence function.
        func withDivergenceFunction(function:@escaping (Vector3F)->Float)->Builder {
            self._customDivergenceFunction = function
            return self
        }
        
        /// Returns builder with curl function.
        func withCurlFunction(function:@escaping (Vector3F)->Vector3F)->Builder {
            self._customCurlFunction = function
            return self
        }
        
        /// Returns builder with derivative resolution.
        func withDerivativeResolution(resolution:Float)->Builder {
            self._resolution = resolution
            return self
        }
        
        /// Builds CustomVectorField3.
        func build()->CustomVectorField3 {
            if _customCurlFunction != nil {
                return CustomVectorField3(
                    customFunction: _customFunction!,
                    customDivergenceFunction: _customDivergenceFunction,
                    customCurlFunction: _customCurlFunction!)
            } else {
                return CustomVectorField3(
                    customFunction: _customFunction!,
                    customDivergenceFunction: _customDivergenceFunction,
                    derivativeResolution: _resolution)
            }
        }
    }
    
    /// Returns builder fox CustomVectorField3.
    static func builder()->Builder{
        return Builder()
    }
}
