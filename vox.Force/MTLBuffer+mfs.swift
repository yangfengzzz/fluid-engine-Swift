//
//  MTLBuffer+mfs.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import Metal

extension MTLBuffer {
    func set<T>(singleValue: T) {
        let binded = contents().bindMemory(to: T.self, capacity: 1)
        binded[0] = singleValue
    }
    
    func set<T>(multipleValues: [T]) {
        let binded = contents().bindMemory(to: T.self, capacity: multipleValues.count)
        for i in 0..<multipleValues.count {
            binded[i] = multipleValues[i]
        }
    }
}
