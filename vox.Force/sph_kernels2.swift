//
//  sph_kernels2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/9.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Standard 2-D SPH kernel function object.
/// Müller, Matthias, David Charypar, and Markus Gross.
/// "Particle-based fluid simulation for interactive applications."
/// Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
/// animation. Eurographics Association, 2003.
struct SphStdKernel2 {
    //! Kernel radius.
    var h:Float
    
    //! Square of the kernel radius.
    var h2:Float
    
    //! Cubic of the kernel radius.
    var h3:Float
    
    //! Fourth-power of the kernel radius.
    var h4:Float
    
    /// Constructs a kernel object with zero radius.
    init() {
        self.h = 0
        self.h2 = 0
        self.h3 = 0
        self.h4 = 0
    }
    
    /// Constructs a kernel object with given radius.
    init(kernelRadius h_:Float) {
        self.h = h_
        self.h2 = h * h
        self.h3 = h2 * h
        self.h4 = h2 * h2
    }
    
    /// Copy constructor
    init(other:SphStdKernel2) {
        self.h = other.h
        self.h2 = other.h2
        self.h3 = other.h3
        self.h4 = other.h4
    }
    
    /// Returns kernel function value at given distance.
    subscript(distance:Float)->Float{
        get{
            let distanceSquared = distance * distance
            
            if (distanceSquared >= h2) {
                return 0.0
            } else {
                let x = 1.0 - distanceSquared / h2
                return 4.0 / (kPiF * h2) * x * x * x
            }
        }
    }
    
    /// Returns the first derivative at given distance.
    func firstDerivative(distance:Float)->Float {
        if (distance >= h) {
            return 0.0
        } else {
            let x = 1.0 - distance * distance / h2
            return -24.0 * distance / (kPiF * h4) * x * x
        }
    }
    
    /// Returns the gradient at a point.
    func gradient(point:Vector2F)->Vector2F {
        let dist = length(point)
        if (dist > 0.0) {
            return gradient(distance: dist, direction: point / dist)
        } else {
            return Vector2F(0, 0)
        }
    }
    
    /// Returns the gradient at a point defined by distance and direction.
    func gradient(distance:Float,
                  direction directionToCenter:Vector2F)->Vector2F {
        return -firstDerivative(distance: distance) * directionToCenter
    }
    
    /// Returns the second derivative at given distance.
    func secondDerivative(distance:Float)->Float {
        let distanceSquared = distance * distance
        
        if (distanceSquared >= h2) {
            return 0.0
        } else {
            let x = distanceSquared / h2
            return 24.0 / (kPiF * h4) * (1 - x) * (5 * x - 1)
        }
    }
}

/// Spiky 2-D SPH kernel function object.
///
/// Müller, Matthias, David Charypar, and Markus Gross.
/// "Particle-based fluid simulation for interactive applications."
/// Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
/// animation. Eurographics Association, 2003.
struct SphSpikyKernel2 {
    //! Kernel radius.
    var h:Float
    
    //! Square of the kernel radius.
    var h2:Float
    
    //! Cubic of the kernel radius.
    var h3:Float
    
    //! Fourth-power of the kernel radius.
    var h4:Float
    
    /// Fifth-power of the kernel radius.
    var h5:Float
    
    /// Constructs a kernel object with zero radius.
    init() {
        self.h = 0
        self.h2 = 0
        self.h3 = 0
        self.h4 = 0
        self.h5 = 0
    }
    
    /// Constructs a kernel object with given radius.
    init(kernelRadius h_:Float) {
        self.h = h_
        self.h2 = h * h
        self.h3 = h2 * h
        self.h4 = h2 * h2
        self.h5 = h3 * h2
    }
    
    /// Copy constructor
    init(other:SphSpikyKernel2) {
        self.h = other.h
        self.h2 = other.h2
        self.h3 = other.h3
        self.h4 = other.h4
        self.h5 = other.h5
    }
    
    /// Returns kernel function value at given distance.
    subscript(distance:Float)->Float{
        get{
            if (distance >= h) {
                return 0.0
            } else {
                let x = 1.0 - distance / h
                return 10.0 / (kPiF * h2) * x * x * x
            }
        }
    }
    
    /// Returns the first derivative at given distance.
    func firstDerivative(distance:Float)->Float {
        if (distance >= h) {
            return 0.0
        } else {
            let x = 1.0 - distance / h
            return -30.0 / (kPiF * h3) * x * x
        }
    }
    
    /// Returns the gradient at a point.
    func gradient(point:Vector2F)->Vector2F {
        let dist = length(point)
        if (dist > 0.0) {
            return gradient(distance: dist, direction: point / dist)
        } else {
            return Vector2F(0, 0)
        }
    }
    
    /// Returns the gradient at a point defined by distance and direction.
    func gradient(distance:Float,
                  direction directionToCenter:Vector2F)->Vector2F {
        return -firstDerivative(distance: distance) * directionToCenter
    }
    
    /// Returns the second derivative at given distance.
    func secondDerivative(distance:Float)->Float {
        if (distance >= h) {
            return 0.0
        } else {
            let x = 1.0 - distance / h
            return 60.0 / (kPiF * h4) * x
        }
    }
}
