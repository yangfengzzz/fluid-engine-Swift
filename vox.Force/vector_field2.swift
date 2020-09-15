//
//  vector_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D vector field.
protocol VectorField2 : Field2 {
    /// Returns sampled value at given position \p x.
    func sample(x:Vector2F)->Vector2F
    
    /// Returns divergence at given position \p x.
    func divergence(x:Vector2F)->Float
    
    /// Returns curl at given position \p x.
    func curl(x:Vector2F)->Float
    
    /// Returns sampler function object.
    func sampler()->(Vector2F)->Vector2F
}

extension VectorField2 {
    func divergence(x:Vector2F)->Float {
        return 0.0
    }
    
    func curl(x:Vector2F)->Float {
        return 0.0
    }
    
    func sampler()->(Vector2F)->Vector2F {
        return {(x:Vector2F)->Vector2F in
            return self.sample(x: x)
        }
    }
}
