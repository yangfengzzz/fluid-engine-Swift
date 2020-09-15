//
//  scalar_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D scalar field.
protocol ScalarField3 : Field3 {
    /// Returns sampled value at given position \p x.
    func sample(x:Vector3F)->Float
    
    /// Returns gradient vector at given position \p x.
    func gradient(x:Vector3F)->Vector3F
    
    /// Returns Laplacian at given position \p x.
    func laplacian(x:Vector3F)->Float
    
    /// Returns sampler function object.
    func sampler()->(Vector3F)->Float
}

extension ScalarField3 {
    func gradient(x:Vector3F)->Vector3F {
        return Vector3F()
    }
    
    func laplacian(x:Vector3F)->Float {
        return 0
    }
    
    func sampler()->(Vector3F)->Float {
        return {(x:Vector3F)->Float in
            return self.sample(x: x)
        }
    }
}
