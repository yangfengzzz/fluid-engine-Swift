//
//  triangle_mesh3.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation
import MetalKit

//MARK:- WindingNumberGather
let kDefaultFastWindingNumberAccuracy:Float = 2.0

struct WindingNumberGatherData {
    var areaSums:Float = 0
    var areaWeightedNormalSums:Vector3F = Vector3F()
    var areaWeightedPositionSums:Vector3F = Vector3F()
    
    static func +(lhs:WindingNumberGatherData,
                  other:WindingNumberGatherData)->WindingNumberGatherData {
        var sum = WindingNumberGatherData()
        sum.areaSums = lhs.areaSums + other.areaSums
        sum.areaWeightedNormalSums =
            lhs.areaWeightedNormalSums + other.areaWeightedNormalSums
        sum.areaWeightedPositionSums =
            lhs.areaWeightedPositionSums + other.areaWeightedPositionSums
        
        return sum
    }
}

typealias GatherFunc = (size_t, WindingNumberGatherData)->Void
typealias LeafGatherFunc = (size_t)->WindingNumberGatherData

func postOrderTraversal(bvh:Bvh3<size_t>, nodeIndex:size_t,
                        visitorFunc:GatherFunc,
                        leafFunc:LeafGatherFunc,
                        initGatherData:WindingNumberGatherData)->WindingNumberGatherData {
    var data = initGatherData
    
    if (bvh.isLeaf(i: nodeIndex)) {
        data = leafFunc(nodeIndex)
    } else {
        let children = bvh.children(i: nodeIndex)
        data = data + postOrderTraversal(bvh: bvh, nodeIndex: children.0, visitorFunc: visitorFunc,
                                         leafFunc: leafFunc, initGatherData: initGatherData)
        data = data + postOrderTraversal(bvh: bvh, nodeIndex: children.1, visitorFunc: visitorFunc,
                                         leafFunc: leafFunc, initGatherData: initGatherData)
    }
    visitorFunc(nodeIndex, data)
    
    return data
}

//MARK:- TriangleMesh3
/// This class represents 3-D triangle mesh geometry which extends Surface3 by
/// overriding surface-related queries. The mesh structure stores point,
/// normals, and UV coordinates.
final class TriangleMesh3 : Surface3{
    var transform: Transform3 = Transform3()
    
    var isNormalFlipped: Bool = false
    
    typealias Vector2FArray = Array<Vector2F>
    typealias Vector3FArray = Array<Vector3F>
    typealias IndexArray = Array<Point3UI>
    
    typealias PointArray = Vector3FArray
    typealias NormalArray = Vector3FArray
    typealias UvArray = Vector2FArray
    
    fileprivate var _points:PointArray = []
    fileprivate var _normals:NormalArray = []
    fileprivate var _uvs:UvArray = []
    fileprivate var _pointIndices:IndexArray = []
    fileprivate var _normalIndices:IndexArray = []
    fileprivate var _uvIndices:IndexArray = []
    
    fileprivate var _bvh:Bvh3<size_t> = Bvh3<size_t>()
    fileprivate var _bvhInvalidated:Bool = true
    
    fileprivate var _wnAreaWeightedNormalSums:[Vector3F] = []
    fileprivate var _wnAreaWeightedAvgPositions:[Vector3F] = []
    fileprivate var _wnInvalidated:Bool = true
    
    /// Default constructor.
    init(transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
    }
    
    /// Constructs mesh with points, normals, uvs, and their indices.
    init(points:PointArray, normals:NormalArray,
         uvs:UvArray, pointIndices:IndexArray,
         normalIndices:IndexArray, uvIndices:IndexArray,
         transform:Transform3 = Transform3(),
         isNormalFlipped:Bool = false) {
        self.transform = transform
        self.isNormalFlipped = isNormalFlipped
        
        self._points = points
        self._normals = normals
        self._uvs = uvs
        self._pointIndices = pointIndices
        self._normalIndices = normalIndices
        self._uvIndices = uvIndices
    }
    
    /// Copy constructor.
    init(other:TriangleMesh3) {
        self.transform = other.transform
        self.isNormalFlipped = other.isNormalFlipped
        set(other: other)
    }
    
    func updateQueryEngine(){
        buildBvh()
        buildWindingNumbers()
    }
    
    /// Clears all content.
    func clear(){
        _points.removeAll()
        _normals.removeAll()
        _uvs.removeAll()
        _pointIndices.removeAll()
        _normalIndices.removeAll()
        _uvIndices.removeAll()
        
        invalidateCache()
    }
    
    /// Copies the contents from \p other mesh.
    func set(other:TriangleMesh3){
        _points = other._points
        _normals = other._normals
        _uvs = other._uvs
        _pointIndices = other._pointIndices
        _normalIndices = other._normalIndices
        _uvIndices = other._uvIndices
        
        invalidateCache()
    }
    
    // MARK:- Helper Function
    /// Returns area of this mesh.
    func area()->Float{
        var a:Float = 0
        for i in 0..<numberOfTriangles() {
            let tri = triangle(i: i)
            a += tri.area()
        }
        return a
    }
    
    /// Returns volume of this mesh.
    func volume()->Float{
        var vol:Float = 0
        for i in 0..<numberOfTriangles() {
            let tri = triangle(i: i)
            vol += dot(tri.points.0, cross(tri.points.1, tri.points.2)) / 6.0
        }
        return vol
    }
    
    /// Returns constant reference to the i-th point.
    func point(i:size_t)->Vector3F{
        return _points[i]
    }
    
    /// Returns constant reference to the i-th normal.
    func normal(i:size_t)->Vector3F{
        return _normals[i]
    }
    
    /// Returns constant reference to the i-th UV coordinates.
    func uv(i:size_t)->Vector2F{
        return _uvs[i]
    }
    
    /// Returns constant reference to the point indices of i-th triangle.
    func pointIndex(i:size_t)->Point3UI{
        return _pointIndices[i]
    }
    
    /// Returns constant reference to the normal indices of i-th triangle.
    func normalIndex(i:size_t)->Point3UI{
        return _normalIndices[i]
    }
    
    /// Returns constant reference to the UV indices of i-th triangle.
    func uvIndex(i:size_t)->Point3UI{
        return _uvIndices[i]
    }
    
    func triangle(i:size_t)->Triangle3{
        let tri = Triangle3()
        tri.points.0 = _points[_pointIndices[i][0]]
        tri.points.1 = _points[_pointIndices[i][1]]
        tri.points.2 = _points[_pointIndices[i][2]]
        if (hasUvs()) {
            tri.uvs.0 = _uvs[_uvIndices[i][0]]
            tri.uvs.1 = _uvs[_uvIndices[i][1]]
            tri.uvs.2 = _uvs[_uvIndices[i][2]]
        }
        
        let n = tri.faceNormal()
        
        if (hasNormals()) {
            tri.normals.0 = _normals[_normalIndices[i][0]]
            tri.normals.1 = _normals[_normalIndices[i][1]]
            tri.normals.2 = _normals[_normalIndices[i][2]]
        } else {
            tri.normals.0 = n
            tri.normals.1 = n
            tri.normals.2 = n
        }
        
        return tri
    }
    
    /// Returns number of points.
    func numberOfPoints()->size_t{
        return _points.count
    }
    
    /// Returns number of normals.
    func numberOfNormals()->size_t{
        return _normals.count
    }
    
    /// Returns number of UV coordinates.
    func numberOfUvs()->size_t{
        return _uvs.count
    }
    
    /// Returns number of triangles.
    func numberOfTriangles()->size_t{
        return _pointIndices.count
    }
    
    /// Returns true if the mesh has normals.
    func hasNormals()->Bool{
        return _normals.count > 0
    }
    
    /// Returns true if the mesh has UV coordinates.
    func hasUvs()->Bool{
        return _uvs.count > 0
    }
    
    /// Adds a point.
    func addPoint(pt:Vector3F){
        _points.append(pt)
    }
    
    /// Adds a normal.
    func addNormal(n:Vector3F){
        _normals.append(n)
    }
    
    /// Adds a UV.
    func addUv(t:Vector2F){
        _uvs.append(t)
    }
    
    /// Adds a triangle with points.
    func addPointTriangle(newPointIndices:Point3UI){
        _pointIndices.append(newPointIndices)
        
        invalidateCache()
    }
    
    /// Adds a triangle with normal.
    func addNormalTriangle(newNormalIndices:Point3UI){
        _normalIndices.append(newNormalIndices)
        
        invalidateCache()
    }
    
    /// Adds a triangle with UV.
    func addUvTriangle(newUvIndices:Point3UI){
        _uvIndices.append(newUvIndices)
        
        invalidateCache()
    }
    
    /// Adds a triangle with point and normal.
    func addPointNormalTriangle(newPointIndices:Point3UI,
                                newNormalIndices:Point3UI){
        _pointIndices.append(newPointIndices)
        _normalIndices.append(newNormalIndices)
        
        invalidateCache()
    }
    
    /// Adds a triangle with point, normal, and UV.
    func addPointUvNormalTriangle(newPointIndices:Point3UI,
                                  newUvIndices:Point3UI,
                                  newNormalIndices:Point3UI){
        _pointIndices.append(newPointIndices)
        _normalIndices.append(newNormalIndices)
        _uvIndices.append(newUvIndices)
        
        invalidateCache()
    }
    
    /// Adds a triangle with point and UV.
    func addPointUvTriangle(newPointIndices:Point3UI,
                            newUvIndices:Point3UI){
        _pointIndices.append(newPointIndices)
        _uvIndices.append(newUvIndices)
        
        invalidateCache()
    }
    
    /// Add a triangle.
    func addTriangle(tri:Triangle3){
        let vStart = _points.count
        let nStart = _normals.count
        let tStart = _uvs.count
        var newPointIndices = Point3UI()
        var newNormalIndices = Point3UI()
        var newUvIndices = Point3UI()
        for i in 0..<3 {
            newPointIndices[i] = vStart + i
            newNormalIndices[i] = nStart + i
            newUvIndices[i] = tStart + i
        }
        _points.append(tri.points.0)
        _normals.append(tri.normals.0)
        _uvs.append(tri.uvs.0)
        _points.append(tri.points.1)
        _normals.append(tri.normals.1)
        _uvs.append(tri.uvs.1)
        _points.append(tri.points.1)
        _normals.append(tri.normals.1)
        _uvs.append(tri.uvs.1)
        
        _pointIndices.append(newPointIndices)
        _normalIndices.append(newNormalIndices)
        _uvIndices.append(newUvIndices)
        
        invalidateCache()
    }
    
    /// Sets entire normals to the face normals.
    func setFaceNormal(){
        _normals = Array<Vector3F>(repeating: Vector3F(), count: _points.count)
        _normalIndices = _pointIndices
        
        for i in 0..<numberOfTriangles() {
            let tri = triangle(i: i)
            let n = tri.faceNormal()
            let f = _pointIndices[i]
            _normals[f.x] = n
            _normals[f.y] = n
            _normals[f.z] = n
        }
    }
    
    /// Sets angle weighted vertex normal.
    func setAngleWeightedVertexNormal(){
        _normals.removeAll()
        _normalIndices.removeAll()
        
        var angleWeights:[Float] = Array<Float>(repeating: 0, count: _points.count)
        var pseudoNormals:[Vector3F] = Array<Vector3F>(repeating: Vector3F(), count: _points.count)
        
        for i in 0..<_points.count {
            angleWeights[i] = 0
            pseudoNormals[i] = Vector3F()
        }
        
        for i in 0..<numberOfTriangles() {
            var pts = [Vector3F(), Vector3F(), Vector3F()]
            var normal = Vector3F()
            var e0 = Vector3F()
            var e1 = Vector3F()
            var cosangle:Float = 0
            var angle:Float = 0
            var idx:[size_t] = [0, 0, 0]
            
            // Quick references
            for j in 0..<3 {
                idx[j] = _pointIndices[i][j]
                pts[j] = _points[idx[j]]
            }
            
            // Angle for point 0
            e0 = pts[1] - pts[0]
            e1 = pts[2] - pts[0]
            e0.normalized()
            e1.normalized()
            normal = cross(e0, e1)
            normal.normalized()
            cosangle = Math.clamp(val: dot(e0, e1), low: -1.0, high: 1.0)
            angle = acos(cosangle)
            angleWeights[idx[0]] += angle
            pseudoNormals[idx[0]] += angle * normal
            
            // Angle for point 1
            e0 = pts[2] - pts[1]
            e1 = pts[0] - pts[1]
            e0.normalized()
            e1.normalized()
            normal = cross(e0, e1)
            normal.normalized()
            cosangle = Math.clamp(val: dot(e0, e1), low: -1.0, high: 1.0)
            angle = acos(cosangle)
            angleWeights[idx[1]] += angle
            pseudoNormals[idx[1]] += angle * normal
            
            // Angle for point 2
            e0 = pts[0] - pts[2]
            e1 = pts[1] - pts[2]
            e0.normalized()
            e1.normalized()
            normal = cross(e0, e1)
            normal.normalized()
            cosangle = Math.clamp(val: dot(e0, e1), low: -1.0, high: 1.0)
            angle = acos(cosangle)
            angleWeights[idx[2]] += angle
            pseudoNormals[idx[2]] += angle * normal
        }
        
        for i in 0..<_points.count {
            if (angleWeights[i] > 0) {
                pseudoNormals[i] /= angleWeights[i]
            }
        }
        
        swap(&pseudoNormals, &_normals)
        _normalIndices = _pointIndices
    }
    
    /// Scales the mesh by given factor.
    func scale(factor:Float){
        _points = _points.map {
            $0 * factor
        }
        invalidateCache()
    }
    
    /// Translates the mesh.
    func translate(t:Vector3F){
        _points = _points.map {
            $0 + t
        }
        invalidateCache()
    }
    
    /// Rotates the mesh.
    func rotate(q:simd_quatf){
        _points = _points.map {
            q.act($0)
        }
        _normals = _normals.map {
            q.act($0)
        }
        invalidateCache()
    }
    
    func writeObj(strm: inout String) {
        // vertex
        for pt in _points {
            strm += "v \(pt)\n"
        }
        
        // uv coords
        for uv in _uvs {
            strm += "vt \(uv)\n"
        }
        
        // normals
        for n in _normals {
            strm += "vn \(n)\n"
        }
        
        // faces
        let hasUvs_ = hasUvs();
        let hasNormals_ = hasNormals();
        for i in 0..<numberOfTriangles() {
            strm += "f "
            for j in 0..<3 {
                strm += "\(_pointIndices[i][j] + 1)"
                if (hasNormals_ || hasUvs_) {
                    strm += "/"
                }
                if (hasUvs_) {
                    strm += "\(_uvIndices[i][j] + 1)"
                }
                if (hasNormals_) {
                    strm += "/\(_normalIndices[i][j] + 1)"
                }
                strm += " "
            }
            strm += "\n"
        }
    }
    
    func writeObj(filename:String)->Bool {
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil, create: true)
        let fileURL = dir?.appendingPathComponent(filename).appendingPathExtension("obj")
        
        
        var text:String = ""
        writeObj(strm: &text)
        
        do {
            try text.write(to: fileURL!, atomically: false, encoding: .utf8)
            return true
        } catch  {
            return false
        }
    }
    
    func readObj(filename:String) {
        guard let assetUrl = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Model: \(filename) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetUrl,
                             vertexDescriptor: MDLVertexDescriptor.defaultVertexDescriptor,
                             bufferAllocator: allocator)
        
        // load Model I/O textures
        asset.loadTextures()
        
        invalidateCache();
        
        // load meshes
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        _ = mdlMeshes.map { mdlMesh in
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
                MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: Renderer.device))
        }
        
        //add Vertex
        let vertex = mdlMeshes[0].vertexAttributeData(forAttributeNamed: MDLVertexAttributePosition)
        for i in 0..<mdlMeshes[0].vertexCount {
            let ptr = vertex!.dataStart + i * vertex!.stride
            addPoint(pt: ptr.bindMemory(to: SIMD3<Float>.self, capacity: 1).pointee)
        }
        
        //add Normal
        let normal = mdlMeshes[0].vertexAttributeData(forAttributeNamed: MDLVertexAttributeNormal)
        for i in 0..<mdlMeshes[0].vertexCount {
            let ptr = normal!.dataStart + i * normal!.stride
            addNormal(n: ptr.bindMemory(to: SIMD3<Float>.self, capacity: 1).pointee)
        }
        
        //add Index
        let index = mtkMeshes[0].submeshes[0].indexBuffer.buffer.contents()
            + mtkMeshes[0].submeshes[0].indexBuffer.offset
        var indexPtr = index.bindMemory(to: Int32.self, capacity: mtkMeshes[0].submeshes[0].indexCount)
        for _ in 0..<mtkMeshes[0].submeshes[0].indexCount/3 {
            addPointTriangle(newPointIndices: [Int(indexPtr.pointee),
                                               Int(indexPtr.advanced(by: 1).pointee),
                                               Int(indexPtr.advanced(by: 2).pointee)])
            addNormalTriangle(newNormalIndices: [Int(indexPtr.pointee),
                                                 Int(indexPtr.advanced(by: 1).pointee),
                                                 Int(indexPtr.advanced(by: 2).pointee)])
            indexPtr = indexPtr.advanced(by: 3)
        }
    }
    
    // MARK:- Local Operator
    func closestPointLocal(otherPoint: Vector3F) -> Vector3F {
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<size_t> = {(triIdx:size_t, pt:Vector3F) in
            let tri = self.triangle(i: triIdx)
            return tri.closestDistance(otherPoint: pt)
        }
        
        let queryResult = _bvh.nearest(pt: otherPoint, distanceFunc: distanceFunc)
        return triangle(i: queryResult.item!).closestPoint(otherPoint: otherPoint)
    }
    
    func closestDistanceLocal(otherPointLocal:Vector3F)->Float{
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<size_t> = {(triIdx:size_t, pt:Vector3F) in
            let tri = self.triangle(i: triIdx)
            return tri.closestDistance(otherPoint: pt)
        }
        
        let queryResult = _bvh.nearest(pt: otherPointLocal, distanceFunc: distanceFunc)
        return queryResult.distance
    }
    
    func intersectsLocal(rayLocal:Ray3F)->Bool{
        buildBvh()
        
        let testFunc:RayIntersectionTestFunc3<size_t> = {(triIdx:size_t, ray:Ray3F) in
            let tri = self.triangle(i: triIdx)
            return tri.intersects(ray: ray)
        }
        
        return _bvh.intersects(ray: rayLocal, testFunc: testFunc)
    }
    
    func boundingBoxLocal() -> BoundingBox3F {
        buildBvh()
        
        return _bvh.boundingBox()
    }
    
    func closestNormalLocal(otherPoint: Vector3F) -> Vector3F {
        buildBvh()
        
        let distanceFunc:NearestNeighborDistanceFunc3<size_t> = {(triIdx:size_t, pt:Vector3F) in
            let tri = self.triangle(i: triIdx)
            return tri.closestDistance(otherPoint: pt)
        }
        
        let queryResult = _bvh.nearest(pt: otherPoint, distanceFunc: distanceFunc)
        return triangle(i: queryResult.item!).closestNormal(otherPoint: otherPoint)
    }
    
    func closestIntersectionLocal(ray: Ray3F) -> SurfaceRayIntersection3 {
        buildBvh()
        
        let testFunc:GetRayIntersectionFunc3<size_t> = {(triIdx:size_t, ray:Ray3F) in
            let tri = self.triangle(i: triIdx)
            let result = tri.closestIntersection(ray: ray)
            return result.distance
        }
        
        let queryResult = _bvh.closestIntersection(ray: ray, testFunc: testFunc)
        var result = SurfaceRayIntersection3()
        result.distance = queryResult.distance
        result.isIntersecting = queryResult.item != nil
        if (queryResult.item != nil) {
            result.point = ray.pointAt(t: queryResult.distance)
            result.normal = triangle(i: queryResult.item!).closestNormal(otherPoint: result.point)
        }
        return result
    }
    
    func isInsideLocal(otherPointLocal:Vector3F)->Bool{
        return fastWindingNumber(queryPoint: otherPointLocal,
                                 accuracy: kDefaultFastWindingNumberAccuracy) > 0.5
    }
    
    // MARK:- Private
    fileprivate func invalidateCache(){
        _bvhInvalidated = true
        _wnInvalidated = true
    }
    
    fileprivate func buildBvh(){
        if (_bvhInvalidated) {
            let nTris = numberOfTriangles()
            var ids:[size_t] = Array<size_t>(repeating: 0, count: nTris)
            var bounds:[BoundingBox3F] = Array<BoundingBox3F>(repeating: BoundingBox3F(), count: nTris)
            for i in 0..<nTris {
                ids[i] = i
                bounds[i] = triangle(i: i).boundingBox()
            }
            _bvh.build(items: ids, itemsBounds: bounds)
            _bvhInvalidated = false
        }
    }
    
    fileprivate func buildWindingNumbers(){
        // Barill et al., Fast Winding Numbers for Soups and Clouds, ACM SIGGRAPH
        // 2018
        if (_wnInvalidated) {
            buildBvh()
            
            let nNodes = _bvh.numberOfNodes()
            _wnAreaWeightedNormalSums = Array<Vector3F>(repeating: Vector3F(), count: nNodes)
            _wnAreaWeightedAvgPositions = Array<Vector3F>(repeating: Vector3F(), count: nNodes)
            
            let visitorFunc:GatherFunc = {(nodeIndex:size_t, data:WindingNumberGatherData) in
                self._wnAreaWeightedNormalSums[nodeIndex] = data.areaWeightedNormalSums
                self._wnAreaWeightedAvgPositions[nodeIndex] =
                    data.areaWeightedPositionSums / data.areaSums
                
            }
            let leafFunc:LeafGatherFunc = {(nodeIndex:size_t) -> WindingNumberGatherData in
                var result = WindingNumberGatherData()
                
                let iter = self._bvh.itemOfNode(i: nodeIndex)
                
                let tri:Triangle3 = self.triangle(i: iter)
                let area = tri.area()
                result.areaSums = area
                result.areaWeightedNormalSums = area * tri.faceNormal()
                result.areaWeightedPositionSums = tri.points.0
                result.areaWeightedPositionSums += tri.points.1
                result.areaWeightedPositionSums += tri.points.2
                result.areaWeightedPositionSums *= area / 3.0
                
                return result
            }
            
            _ = postOrderTraversal(bvh: _bvh, nodeIndex: 0, visitorFunc: visitorFunc, leafFunc: leafFunc,
                                   initGatherData: WindingNumberGatherData())
            
            _wnInvalidated = false
        }
    }
    
    fileprivate func fastWindingNumber(queryPoint:Vector3F,
                                       accuracy:Float)->Float{
        buildWindingNumbers()
        
        return fastWindingNumber(q: queryPoint,
                                 rootNodeIndex: 0,
                                 accuracy: accuracy)
    }
    
    fileprivate func fastWindingNumber(q:Vector3F, rootNodeIndex:size_t,
                                       accuracy:Float)->Float{
        // Barill et al., Fast Winding Numbers for Soups and Clouds, ACM SIGGRAPH
        // 2018.
        let treeP = _wnAreaWeightedAvgPositions[rootNodeIndex]
        let qToP2 = length_squared(q-treeP)
        
        let treeN = _wnAreaWeightedNormalSums[rootNodeIndex]
        let treeBound = _bvh.nodeBound(i: rootNodeIndex)
        let treeRVec = max(treeP - treeBound.lowerCorner, treeBound.upperCorner - treeP)
        let treeR = length(treeRVec)
        
        if (qToP2 > Math.square(of: accuracy * treeR)) {
            // Case: q is sufficiently far from all elements in tree
            // TODO: This is zero-th order approximation. Higher-order approximation
            // from Section 3.2.1 could be implemented for better accuracy in the
            // future.
            return dot(treeP - q, treeN) / (kFourPiF * Math.cubic(of: sqrt(qToP2)))
        } else {
            if (_bvh.isLeaf(i: rootNodeIndex)) {
                // Case: q is nearby use direct sum for tree’s elements
                let iter = _bvh.itemOfNode(i: rootNodeIndex)
                return windingNumber(queryPoint: q, triIndex: iter) * kInvFourPiF
            } else {
                // Case: Recursive call
                let children = _bvh.children(i: rootNodeIndex)
                var wn:Float = 0.0
                wn += fastWindingNumber(q: q, rootNodeIndex: children.0, accuracy: accuracy)
                wn += fastWindingNumber(q: q, rootNodeIndex: children.1, accuracy: accuracy)
                return wn
            }
        }
    }
    
    fileprivate func windingNumber(queryPoint:Vector3F,
                                   triIndex:size_t)->Float{
        // Jacobson et al., Robust Inside-Outside Segmentation using Generalized
        // Winding Numbers, ACM SIGGRAPH 2013.
        let vi = _points[_pointIndices[triIndex][0]]
        let vj = _points[_pointIndices[triIndex][1]]
        let vk = _points[_pointIndices[triIndex][2]]
        let va = vi - queryPoint
        let vb = vj - queryPoint
        let vc = vk - queryPoint
        let a = length(va)
        let b = length(vb)
        let c = length(vc)
        
        let mat = matrix_float3x3(rows: [SIMD3<Float>(va.x, vb.x, vc.x),
                                         SIMD3<Float>(va.y, vb.y, vc.y),
                                         SIMD3<Float>(va.z, vb.z, vc.z)])
        let det = mat.determinant
        var denom = a * b * c
        denom += dot(va, vb) * c
        denom += dot(vb, vc) * a
        denom += dot(vc, va) * b
        
        let solidAngle = 2.0 * atan2(det, denom)
        
        return solidAngle
    }
    
    //MARK:- Builder
    /// Front-end to create TriangleMesh3 objects step by step.
    class Builder : SurfaceBuilderBase3<Builder>{
        private var _points:PointArray = []
        private var _normals:NormalArray = []
        private var _uvs:UvArray = []
        private var _pointIndices:IndexArray = []
        private var _normalIndices:IndexArray = []
        private var _uvIndices:IndexArray = []
        
        /// Returns builder with points.
        func withPoints(points:PointArray)->Builder{
            _points = points
            return self
        }
        
        /// Returns builder with normals.
        func withNormals(normals:NormalArray)->Builder{
            _normals = normals
            return self
        }
        
        /// Returns builder with uvs.
        func withUvs(uvs:UvArray)->Builder{
            _uvs = uvs
            return self
        }
        
        /// Returns builder with point indices.
        func withPointIndices(pointIndices:IndexArray)->Builder{
            _pointIndices = pointIndices
            return self
        }
        
        /// Returns builder with normal indices.
        func withNormalIndices(normalIndices:IndexArray)->Builder{
            _normalIndices = normalIndices
            return self
        }
        
        /// Returns builder with uv indices.
        func withUvIndices(uvIndices:IndexArray)->Builder{
            _uvIndices = uvIndices
            return self
        }
        
        /// Builds TriangleMesh3.
        func build()->TriangleMesh3{
            return TriangleMesh3(points: _points, normals: _normals, uvs: _uvs,
                                 pointIndices: _pointIndices,
                                 normalIndices: _normalIndices,
                                 uvIndices: _uvIndices)
        }
    }
    
    /// Returns builder fox TriangleMesh3.
    static func builder()->Builder{
        return Builder()
    }
}

//MARK:- MDLVertexDescriptor
extension MDLVertexDescriptor {
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        
        var offset = 0
        //MARK:- position attribute
        vertexDescriptor.attributes[Int(Position.rawValue)]
            = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                 format: .float3,
                                 offset: 0,
                                 bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        //MARK:- normal attribute
        vertexDescriptor.attributes[Int(Normal.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float3,
                               offset: offset,
                               bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        //MARK:- add the uv attribute here
        vertexDescriptor.attributes[Int(UV.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                               format: .float2,
                               offset: offset,
                               bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        vertexDescriptor.attributes[Int(Tangent.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeTangent,
                               format: .float3,
                               offset: 0,
                               bufferIndex: 1)
        
        vertexDescriptor.attributes[Int(Bitangent.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeBitangent,
                               format: .float3,
                               offset: 0,
                               bufferIndex: 2)
        
        //MARK:- color attribute
        vertexDescriptor.attributes[Int(Color.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeColor,
                               format: .float3,
                               offset: offset,
                               bufferIndex: Int(BufferIndexVertices.rawValue))
        
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        //MARK:- joints attribute
        vertexDescriptor.attributes[Int(Joints.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeJointIndices,
                               format: .uShort4,
                               offset: offset,
                               bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<ushort>.stride * 4
        
        vertexDescriptor.attributes[Int(Weights.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeJointWeights,
                               format: .float4,
                               offset: offset,
                               bufferIndex: Int(BufferIndexVertices.rawValue))
        offset += MemoryLayout<SIMD4<Float>>.stride
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        vertexDescriptor.layouts[1] =
            MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        vertexDescriptor.layouts[2] =
            MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        return vertexDescriptor
        
    }()
}
