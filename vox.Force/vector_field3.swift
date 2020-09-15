//
//  vector_field3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 3-D vector field.
protocol VectorField3 : Field3 {
    /// Returns sampled value at given position \p x.
    func sample(x:Vector3F)->Vector3F
    
    /// Returns divergence at given position \p x.
    func divergence(x:Vector3F)->Float
    
    /// Returns curl at given position \p x.
    func curl(x:Vector3F)->Vector3F
    
    /// Returns sampler function object.
    func sampler()->(Vector3F)->Vector3F
}

extension VectorField3 {
    func divergence(x:Vector3F)->Float {
        return 0.0
    }
    
    func curl(x:Vector3F)->Vector3F {
        return Vector3F()
    }
    
    func sampler()->(Vector3F)->Vector3F {
        return {(x:Vector3F)->Vector3F in
            return self.sample(x: x)
        }
    }
}
