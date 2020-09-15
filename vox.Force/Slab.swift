//
//  Slab.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

final class Slab {
    var source: MTLTexture
    var dest: MTLTexture
    
    init(source: MTLTexture, dest: MTLTexture) {
        self.source = source
        self.dest = dest
    }
    
    func swap() {
        let temp = source
        source = dest
        dest = temp
    }
}
