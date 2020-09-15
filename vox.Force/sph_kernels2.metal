//
//  sph_kernels2.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef INCLUDE_VOX_SPH_KERNELS2_METAL_
#define INCLUDE_VOX_SPH_KERNELS2_METAL_

//!
//! \brief Standard 2-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
struct SphStdKernel2 {
    //! Kernel radius.
    float h;
    
    //! Square of the kernel radius.
    float h2;
    
    //! Cubic of the kernel radius.
    float h3;
    
    //! Fourth-power of the kernel radius.
    float h4;
    
    //! Constructs a kernel object with zero radius.
    SphStdKernel2();
    
    //! Constructs a kernel object with given radius.
    explicit SphStdKernel2(float kernelRadius);
    
    //! Copy constructor
    SphStdKernel2(const thread SphStdKernel2& other);
    
    //! Returns kernel function value at given distance.
    float operator()(float distance) const;
    
    //! Returns the first derivative at given distance.
    float firstDerivative(float distance) const;
    
    //! Returns the gradient at a point.
    float2 gradient(const float2 point) const;
    
    //! Returns the gradient at a point defined by distance and direction.
    float2 gradient(float distance, const float2 direction) const;
    
    //! Returns the second derivative at given distance.
    float secondDerivative(float distance) const;
};

//!
//! \brief Spiky 2-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
struct SphSpikyKernel2 {
    //! Kernel radius.
    float h;
    
    //! Square of the kernel radius.
    float h2;
    
    //! Cubic of the kernel radius.
    float h3;
    
    //! Fourth-power of the kernel radius.
    float h4;
    
    //! Fifth-power of the kernel radius.
    float h5;
    
    //! Constructs a kernel object with zero radius.
    SphSpikyKernel2();
    
    //! Constructs a kernel object with given radius.
    explicit SphSpikyKernel2(float kernelRadius);
    
    //! Copy constructor
    SphSpikyKernel2(const thread SphSpikyKernel2& other);
    
    //! Returns kernel function value at given distance.
    float operator()(float distance) const;
    
    //! Returns the first derivative at given distance.
    float firstDerivative(float distance) const;
    
    //! Returns the gradient at a point.
    float2 gradient(const float2 point) const;
    
    //! Returns the gradient at a point defined by distance and direction.
    float2 gradient(float distance, const float2 direction) const;
    
    //! Returns the second derivative at given distance.
    float secondDerivative(float distance) const;
};

#endif  // INCLUDE_VOX_SPH_KERNELS2_METAL_
