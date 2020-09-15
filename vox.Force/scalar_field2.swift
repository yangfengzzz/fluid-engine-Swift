//
//  scalar_field2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// Abstract base class for 2-D scalar field.
protocol ScalarField2 : Field2 {
    /// Returns sampled value at given position \p x.
    func sample(x:Vector2F)->Float
    
    /// Returns gradient vector at given position \p x.
    func gradient(x:Vector2F)->Vector2F
    
    /// Returns Laplacian at given position \p x.
    func laplacian(x:Vector2F)->Float
    
    /// Returns sampler function object.
    func sampler()->(Vector2F)->Float
}

extension ScalarField2 {
    func gradient(x:Vector2F)->Vector2F {
        return Vector2F()
    }
    
    func laplacian(x:Vector2F)->Float {
        return 0
    }
    
    func sampler()->(Vector2F)->Float {
        return {(x:Vector2F)->Float in
            return self.sample(x: x)
        }
    }
}
