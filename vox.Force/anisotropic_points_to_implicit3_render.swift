//
//  anisotropic_points_to_implicit3_render.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/9/4.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

class AnisotropicPointsToImplicit3Renderable: Renderable {
    var triMesh = TriangleMesh3()
    
    func ConvertTwo() {
        var points = Array1<Vector3F>()
        
        for _ in 0..<2 {
            points.append(other: [[Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8)]])
        }
        
        var grid: ScalarGrid3 = VertexCenteredScalarGrid3(resolutionX: 128, resolutionY: 128, resolutionZ: 128,
                                                          gridSpacingX: 1.0 / 128, gridSpacingY: 1.0 / 128, gridSpacingZ: 1.0 / 128)
        
        let converter = AnisotropicPointsToImplicit3(kernelRadius: 0.3)
        converter.convert(points: points.constAccessor(), output: &grid)
        
        marchingCubes(grid: grid.constDataAccessor(), gridSize: grid.gridSpacing(),
                      origin: grid.dataOrigin(), mesh: &triMesh, isoValue: 0, bndClose: kDirectionAll)
    }
    
    func ConvertMany() {
        var points = Array1<Vector3F>()
        
        for _ in 0..<500 {
            points.append(other: [[Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8),
                                   Float.random(in: 0.2...0.8)]])
        }
        
        var grid: ScalarGrid3 = VertexCenteredScalarGrid3(resolutionX: 128, resolutionY: 128, resolutionZ: 128,
                                                          gridSpacingX: 1.0 / 128, gridSpacingY: 1.0 / 128, gridSpacingZ: 1.0 / 128)
        
        let converter = AnisotropicPointsToImplicit3(kernelRadius: 0.1)
        converter.convert(points: points.constAccessor(), output: &grid)
        
        marchingCubes(grid: grid.constDataAccessor(), gridSize: grid.gridSpacing(),
                      origin: grid.dataOrigin(), mesh: &triMesh, isoValue: 0, bndClose: kDirectionAll)
    }
    
    func buildPipelineStates() {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    func reset() {
        
    }
}
