//
//  implicit_triangle_mesh3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/8/10.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

class ImplicitTriangleMesh3: ImplicitSurface3 {
    var transform: Transform3 = Transform3()
    var isNormalFlipped: Bool = false
    
    var _mesh:TriangleMesh3
    var _grid:VertexCenteredScalarGrid3?
    var _customImplicitSurface:CustomImplicitSurface3?
    
    init(mesh:TriangleMesh3,
         resolutionX:size_t = 32, margin:Float = 0.2,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self._mesh = mesh
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        if (mesh.numberOfTriangles() > 0 && mesh.numberOfPoints() > 0) {
            var box = _mesh.boundingBox()
            let scale = Vector3F(box.width(), box.height(), box.depth())
            box.lowerCorner -= margin * scale
            box.upperCorner += margin * scale
            let resolutionY:size_t = size_t(ceil(Float(resolutionX) * box.height() / box.width()))
            let resolutionZ:size_t = size_t(ceil(Float(resolutionX) * box.depth() / box.width()))
            
            let dx:Float = box.width() / Float(resolutionX)
            
            self._grid = VertexCenteredScalarGrid3()
            _grid!.resize(resolutionX: resolutionX,
                         resolutionY: resolutionY,
                         resolutionZ: resolutionZ,
                         gridSpacingX: dx,
                         gridSpacingY: dx,
                         gridSpacingZ: dx,
                         originX: box.lowerCorner.x,
                         originY: box.lowerCorner.y,
                         originZ: box.lowerCorner.z)
            
            var father_grid = _grid! as ScalarGrid3
            triangleMeshToSdf(mesh: _mesh, sdf: &father_grid)
            
            self._customImplicitSurface = CustomImplicitSurface3.builder()
                .withSignedDistanceFunction(function: {(pt:Vector3F)->Float in
                    return self._grid!.sample(x: pt)
                })
                .withDomain(domain: _grid!.boundingBox())
                .withResolution(resolution: dx)
                .build()
        } else {
            // Empty mesh -- return big/uniform number
            self._customImplicitSurface = CustomImplicitSurface3.builder()
                .withSignedDistanceFunction(function: {(_:Vector3F)->Float in
                    return Float.greatestFiniteMagnitude
                })
                .build()
        }
    }
    
    /// Returns grid data.
    func grid()->VertexCenteredScalarGrid3 {
        return _grid!
    }
    
    func closestPointLocal(otherPoint:Vector3F)->Vector3F {
        return _customImplicitSurface!.closestPoint(otherPoint: otherPoint)
    }
    
    func closestDistanceLocal(otherPoint:Vector3F)->Float {
        return _customImplicitSurface!.closestDistance(otherPoint: otherPoint)
    }
    
    func intersectsLocal(ray:Ray3F)->Bool {
        return _customImplicitSurface!.intersects(ray: ray)
    }
    
    func boundingBoxLocal()->BoundingBox3F {
        return _mesh.boundingBox()
    }
    
    func closestNormalLocal(otherPoint:Vector3F)->Vector3F {
        return _customImplicitSurface!.closestNormal(otherPoint: otherPoint)
    }
    
    func signedDistanceLocal(otherPoint:Vector3F)->Float {
        return _customImplicitSurface!.signedDistance(otherPoint: otherPoint)
    }
    
    func closestIntersectionLocal(ray:Ray3F)->SurfaceRayIntersection3 {
        return _customImplicitSurface!.closestIntersection(ray: ray)
    }
    
    //MARK:- Builder
    class Builder: SurfaceBuilderBase3<Builder> {
        var _mesh:TriangleMesh3?
        var _resolutionX:size_t = 32
        var _margin:Float = 0.2
        
        /// Returns builder with triangle mesh.
        func withTriangleMesh(mesh:TriangleMesh3)->Builder {
            _mesh = mesh
            return self
        }
        
        /// Returns builder with resolution in x axis.
        func withResolutionX(resolutionX:size_t)->Builder {
            _resolutionX = resolutionX
            return self
        }
        
        /// Returns builder with margin around the mesh.
        func withMargin(margin:Float)->Builder {
            _margin = margin
            return self
        }
        
        /// Builds ImplicitTriangleMesh3.
        func build()->ImplicitTriangleMesh3 {
            return ImplicitTriangleMesh3(mesh: _mesh!, resolutionX: _resolutionX,
                                         margin: _margin, transform: _transform,
                                         isNormalFlipped: _isNormalFlipped)
        }
    }
    
    /// Returns builder fox ImplicitTriangleMesh3.
    static func builder()->Builder{
        return Builder()
    }
}
