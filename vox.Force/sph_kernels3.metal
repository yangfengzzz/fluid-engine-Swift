//
//  sph_kernels3.metal
//  vox.Force
//
//  Created by Feng Yang on 2020/9/11.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_SPH_KERNELS3_METAL_
#define INCLUDE_VOX_SPH_KERNELS3_METAL_

#include <metal_stdlib>
using namespace metal;

//!
//! \brief Standard 3-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
struct SphStdKernel3 {
    //! Kernel radius.
    float h;
    
    //! Square of the kernel radius.
    float h2;
    
    //! Cubic of the kernel radius.
    float h3;
    
    //! Fifth-power of the kernel radius.
    float h5;
    
    //! Constructs a kernel object with zero radius.
    SphStdKernel3();
    
    //! Constructs a kernel object with given radius.
    explicit SphStdKernel3(float kernelRadius);
    
    //! Copy constructor
    SphStdKernel3(const thread SphStdKernel3& other);
    
    //! Returns kernel function value at given distance.
    float operator()(float distance) const;
    
    //! Returns the first derivative at given distance.
    float firstDerivative(float distance) const;
    
    //! Returns the gradient at a point.
    float3 gradient(const float3 point) const;
    
    //! Returns the gradient at a point defined by distance and direction.
    float3 gradient(float distance, const float3 direction) const;
    
    //! Returns the second derivative at given distance.
    float secondDerivative(float distance) const;
};

//!
//! \brief Spiky 3-D SPH kernel function object.
//!
//! \see Müller, Matthias, David Charypar, and Markus Gross.
//!     "Particle-based fluid simulation for interactive applications."
//!     Proceedings of the 2003 ACM SIGGRAPH/Eurographics symposium on Computer
//!     animation. Eurographics Association, 2003.
//!
struct SphSpikyKernel3 {
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
    SphSpikyKernel3();
    
    //! Constructs a kernel object with given radius.
    explicit SphSpikyKernel3(float kernelRadius);
    
    //! Copy constructor
    SphSpikyKernel3(const thread SphSpikyKernel3& other);
    
    //! Returns kernel function value at given distance.
    float operator()(float distance) const;
    
    //! Returns the first derivative at given distance.
    float firstDerivative(float distance) const;
    
    //! Returns the gradient at a point.
    float3 gradient(const float3 point) const;
    
    //! Returns the gradient at a point defined by distance and direction.
    float3 gradient(float distance, const float3 direction) const;
    
    //! Returns the second derivative at given distance.
    float secondDerivative(float distance) const;
};

#endif  // INCLUDE_VOX_SPH_KERNELS3_METAL_
