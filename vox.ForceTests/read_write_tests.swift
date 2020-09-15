//
//  read_write_tests.swift
//  vox.ForceTests
//
//  Created by Feng Yang on 2020/8/26.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import XCTest
import MetalKit

class read_write_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadText() throws {
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil, create: true)
        let fileURL = dir?.appendingPathComponent("alphabetics").appendingPathExtension("txt")
        let text2 = try String(contentsOf: fileURL!, encoding: .utf8)
        print(text2)
    }
    
    func testWriteText() throws {
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil, create: true)
        let fileURL = dir?.appendingPathComponent("alphabetics").appendingPathExtension("txt")
        let text = "some text"
        try text.write(to: fileURL!, atomically: false, encoding: .utf8)
        
        let text2 = try String(contentsOf: fileURL!, encoding: .utf8)
        print(text2)
    }
    
    func testReadModel() {
        let name = "kCubeTriMesh3x3x3As.obj"
        let device = MTLCreateSystemDefaultDevice()
        guard let assetUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: device!)
        let asset = MDLAsset(url: assetUrl,
                             vertexDescriptor: MDLVertexDescriptor.defaultVertexDescriptor,
                             bufferAllocator: allocator)
        
        // load Model I/O textures
        asset.loadTextures()
        
        // load meshes
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        _ = mdlMeshes.map { mdlMesh in
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
                MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: device!))
        }
        
        print("Vertex Info:")
        print(mdlMeshes[0].vertexCount)
        let vertex = mdlMeshes[0].vertexAttributeData(forAttributeNamed: MDLVertexAttributePosition)
        for i in 0..<mdlMeshes[0].vertexCount {
            let ptr = vertex!.dataStart + i * vertex!.stride
            print(ptr.bindMemory(to: SIMD3<Float>.self, capacity: 1).pointee)
        }
        
        print("Face Info:")
        print(mtkMeshes[0].submeshes[0].indexCount)
        let index = mtkMeshes[0].submeshes[0].indexBuffer.buffer.contents()
            + mtkMeshes[0].submeshes[0].indexBuffer.offset
        var indexPtr = index.bindMemory(to: Int32.self, capacity: mtkMeshes[0].submeshes[0].indexCount)
        for _ in 0..<mtkMeshes[0].submeshes[0].indexCount/3 {
            print("\(indexPtr.pointee), \(indexPtr.advanced(by: 1).pointee), \(indexPtr.advanced(by: 2).pointee)")
            indexPtr = indexPtr.advanced(by: 3)
        }
        
        print("Normal Info:")
        let normal = mdlMeshes[0].vertexAttributeData(forAttributeNamed: MDLVertexAttributeNormal)
        for i in 0..<mdlMeshes[0].vertexCount {
            let ptr = normal!.dataStart + i * normal!.stride
            print(ptr.bindMemory(to: SIMD3<Float>.self, capacity: 1).pointee)
        }
    }
}

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
