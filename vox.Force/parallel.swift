//
//  parallel.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/31.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

enum ExecutionPolicy {
    case kSerial
    case kParallel
}

/// Fills from \p begin to \p end with \p value in parallel.
///
/// This function fills a container specified by begin and end iterators in
/// parallel. The order of the filling is not guaranteed due to the nature of
/// parallel execution.
/// - Parameters:
///   - array: container
///   - value: The value to fill a container.
///   - policy:  The execution policy (parallel or serial).
func parallelFill<T>(array:inout [T], value:T,
                     policy:ExecutionPolicy = .kParallel) {
    parallelFor(beginIndex: 0, endIndex: array.count,
                function: {(i:size_t) in
                    array[i] = value;
                }, policy: policy)
}

typealias IndexCallBack = (size_t)->Void
typealias IndexCallBack2 = (size_t, size_t)->Void
typealias IndexCallBack3 = (size_t, size_t, size_t)->Void
typealias RangeCallBack = (size_t, size_t)->Void
typealias RangeCallBack2 = (size_t, size_t, size_t, size_t)->Void
typealias RangeCallBack3 = (size_t, size_t, size_t, size_t, size_t, size_t)->Void
/// Makes a for-loop from \p beginIndex \p to endIndex in parallel.
///
/// This function makes a for-loop specified by begin and end indices in
/// parallel. The order of the visit is not guaranteed due to the nature of
/// parallel execution.
/// - Parameters:
///   - start: The begin index.
///   - end: The end index.
///   - function: The function to call for each index.
///   - policy: The execution policy (parallel or serial).
func parallelFor(beginIndex start:Int, endIndex end:Int,
                 function:IndexCallBack,
                 policy:ExecutionPolicy = .kParallel) {
    if (start > end) {
        return
    }
    
    if (policy == .kParallel) {
        DispatchQueue.concurrentPerform(iterations: end - start) { (index:Int) in
            function(index + start)
        }
    } else {
        for i in start..<end {
            function(i)
        }
    }
}

/// Makes a range-loop from \p beginIndex \p to endIndex in parallel.
///
/// This function makes a for-loop specified by begin and end indices in
/// parallel. Unlike parallelFor function, the input function object takes range
/// instead of single index. The order of the visit is not guaranteed due to the
/// nature of parallel execution.
/// - Parameters:
///   - start: The begin index.
///   - end:  The end index.
///   - function: The function to call for each index range.
///   - policy: The execution policy (parallel or serial).
func parallelRangeFor(beginIndex start:Int, endIndex end:Int,
                      function:RangeCallBack,
                      policy:ExecutionPolicy = .kParallel) {
    if (start > end) {
        return
    }
    
    if (policy == .kParallel) {
        DispatchQueue.concurrentPerform(iterations: end - start) { (index:Int) in
            function(index + start, index + start + 1)
        }
    } else {
        function(start, end)
    }
}

/// Makes a 2D nested for-loop in parallel.
///
/// This function makes a 2D nested for-loop specified by begin and end indices
/// for each dimension. X will be the inner-most loop while Y is the outer-most.
/// The order of the visit is not guaranteed due to the nature of parallel
/// execution.
/// - Parameters:
///   - beginIndexX: The begin index in X dimension.
///   - endIndexX:  The end index in X dimension.
///   - beginIndexY: The begin index in Y dimension.
///   - endIndexY: The end index in Y dimension.
///   - function:  The function to call for each index (i, j).
///   - policy:  The execution policy (parallel or serial).
func parallelFor(beginIndexX:Int, endIndexX:Int,
                 beginIndexY:Int, endIndexY:Int,
                 function:IndexCallBack2,
                 policy:ExecutionPolicy = .kParallel) {
    parallelFor(beginIndex: beginIndexY, endIndex: endIndexY,
                function: { (j:size_t) in
                    for i in beginIndexX..<endIndexX {
                        function(i, j)
                    }
                }, policy: policy)
}

/// Makes a 2D nested range-loop in parallel.
///
/// This function makes a 2D nested for-loop specified by begin and end indices
/// for each dimension. X will be the inner-most loop while Y is the outer-most.
/// Unlike parallelFor function, the input function object takes range instead
/// of single index. The order of the visit is not guaranteed due to the nature
/// of parallel execution.
/// - Parameters:
///   - beginIndexX: The begin index in X dimension.
///   - endIndexX: The end index in X dimension.
///   - beginIndexY: The begin index in Y dimension.
///   - endIndexY:  The end index in Y dimension.
///   - function:  The function to call for each index range.
///   - policy: The execution policy (parallel or serial).
func parallelRangeFor(beginIndexX:Int, endIndexX:Int,
                      beginIndexY:Int, endIndexY:Int,
                      function:RangeCallBack2,
                      policy:ExecutionPolicy = .kParallel) {
    parallelRangeFor(beginIndex: beginIndexY, endIndex: endIndexY,
                     function: { (jBegin:size_t, jEnd:size_t) in
                        function(beginIndexX, endIndexX, jBegin, jEnd)
                     }, policy: policy)
}

/// Makes a 3D nested for-loop in parallel.
///
/// This function makes a 3D nested for-loop specified by begin and end indices
/// for each dimension. X will be the inner-most loop while Z is the outer-most.
/// The order of the visit is not guaranteed due to the nature of parallel
/// execution.
/// - Parameters:
///   - beginIndexX: The begin index in X dimension.
///   - endIndexX:  The end index in X dimension.
///   - beginIndexY: The begin index in Y dimension.
///   - endIndexY: The end index in Y dimension.
///   - beginIndexZ: The begin index in Z dimension.
///   - endIndexZ: The end index in Z dimension.
///   - function:  The function to call for each index (i, j, k).
///   - policy: The execution policy (parallel or serial).
func parallelFor(beginIndexX:Int, endIndexX:Int,
                 beginIndexY:Int, endIndexY:Int,
                 beginIndexZ:Int, endIndexZ:Int,
                 function:IndexCallBack3,
                 policy:ExecutionPolicy = .kParallel) {
    parallelFor(beginIndex: beginIndexZ, endIndex: endIndexZ,
                function: { (k:size_t) in
                    for j in beginIndexY..<endIndexY {
                        for i in beginIndexX..<endIndexX {
                            function(i, j, k)
                        }
                    }
                }, policy: policy)
}

/// Makes a 3D nested range-loop in parallel.
///
/// This function makes a 3D nested for-loop specified by begin and end indices
/// for each dimension. X will be the inner-most loop while Z is the outer-most.
/// Unlike parallelFor function, the input function object takes range instead
/// of single index. The order of the visit is not guaranteed due to the nature
/// of parallel execution.
/// - Parameters:
///   - beginIndexX: The begin index in X dimension.
///   - endIndexX: The end index in X dimension.
///   - beginIndexY: The begin index in Y dimension.
///   - endIndexY: The end index in Y dimension.
///   - beginIndexZ: The begin index in Z dimension.
///   - endIndexZ: The end index in Z dimension.
///   - function: The function to call for each index (i, j, k).
///   - policy: The execution policy (parallel or serial).
func parallelRangeFor(beginIndexX:Int, endIndexX:Int,
                      beginIndexY:Int, endIndexY:Int,
                      beginIndexZ:Int, endIndexZ:Int,
                      function:RangeCallBack3,
                      policy:ExecutionPolicy = .kParallel) {
    parallelRangeFor(beginIndex: beginIndexZ, endIndex: endIndexZ,
                     function: { (kBegin:size_t, kEnd:size_t) in
                        function(beginIndexX, endIndexX,
                                 beginIndexY, endIndexY,
                                 kBegin, kEnd)
                     }, policy: policy)
}

//MARK:- GPU Method
func parallelFor(beginIndex start:Int, endIndex end:Int,
                 name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
    var arrayPipelineState: MTLComputePipelineState!
    var function: MTLFunction? = nil
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = library.makeFunction(name: name)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          var computeEncoder = commandBuffer.makeComputeCommandEncoder()
    else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let width = arrayPipelineState.threadExecutionWidth
    let threadsPerGroup = MTLSizeMake(width, 1, 1)
    let threadsPerGrid = MTLSizeMake(end - start, 1, 1)
    
    //Other Variables
    var index:Int = 0
    callBack(&computeEncoder, &index)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

func parallelFor(beginIndexX:Int, endIndexX:Int,
                 beginIndexY:Int, endIndexY:Int,
                 name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
    var arrayPipelineState: MTLComputePipelineState!
    var function: MTLFunction? = nil
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = library.makeFunction(name: name)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          var computeEncoder = commandBuffer.makeComputeCommandEncoder()
    else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let w = arrayPipelineState.threadExecutionWidth
    let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
    let threadsPerGroup = MTLSizeMake(w, h, 1)
    let threadsPerGrid = MTLSizeMake(endIndexX - beginIndexX,
                                     endIndexY - beginIndexY, 1)
    
    //Other Variables
    var index:Int = 0
    callBack(&computeEncoder, &index)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

func parallelFor(beginIndexX:Int, endIndexX:Int,
                 beginIndexY:Int, endIndexY:Int,
                 beginIndexZ:Int, endIndexZ:Int,
                 name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
    var arrayPipelineState: MTLComputePipelineState!
    var function: MTLFunction? = nil
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = library.makeFunction(name: name)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          var computeEncoder = commandBuffer.makeComputeCommandEncoder()
    else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let w = arrayPipelineState.threadExecutionWidth
    let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
    let threadsPerGroup = MTLSizeMake(w, h, 1)
    let threadsPerGrid = MTLSizeMake(endIndexX - beginIndexX,
                                     endIndexY - beginIndexY,
                                     endIndexZ - beginIndexZ)
    
    //Other Variables
    var index:Int = 0
    callBack(&computeEncoder, &index)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

func parallelRangeFor(beginIndexX:Int, endIndexX:Int,
                      beginIndexY:Int, endIndexY:Int,
                      name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
    var arrayPipelineState: MTLComputePipelineState!
    var function: MTLFunction? = nil
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = library.makeFunction(name: name)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          var computeEncoder = commandBuffer.makeComputeCommandEncoder()
    else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let width = arrayPipelineState.threadExecutionWidth
    let threadsPerGroup = MTLSizeMake(width, 1, 1)
    let threadsPerGrid = MTLSizeMake(endIndexY - beginIndexY, 1, 1)
    
    var beginIndexX:UInt32 = UInt32(beginIndexX)
    computeEncoder.setBytes(&beginIndexX, length: MemoryLayout<UInt32>.stride, index: 0)
    var endIndexX:UInt32 = UInt32(endIndexX)
    computeEncoder.setBytes(&endIndexX, length: MemoryLayout<UInt32>.stride, index: 1)
    //Other Variables
    var index:Int = 2
    callBack(&computeEncoder, &index)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

func parallelRangeFor(beginIndexX:Int, endIndexX:Int,
                      beginIndexY:Int, endIndexY:Int,
                      beginIndexZ:Int, endIndexZ:Int,
                      name:String, _ callBack:(inout MTLComputeCommandEncoder, inout Int)->Void) {
    var arrayPipelineState: MTLComputePipelineState!
    var function: MTLFunction? = nil
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = library.makeFunction(name: name)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
          var computeEncoder = commandBuffer.makeComputeCommandEncoder()
    else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let width = arrayPipelineState.threadExecutionWidth
    let threadsPerGroup = MTLSizeMake(width, 1, 1)
    let threadsPerGrid = MTLSizeMake(endIndexZ - beginIndexZ, 1, 1)
    
    var beginIndexX:UInt32 = UInt32(beginIndexX)
    computeEncoder.setBytes(&beginIndexX, length: MemoryLayout<UInt32>.stride, index: 0)
    var endIndexX:UInt32 = UInt32(endIndexX)
    computeEncoder.setBytes(&endIndexX, length: MemoryLayout<UInt32>.stride, index: 1)
    var beginIndexY:UInt32 = UInt32(beginIndexY)
    computeEncoder.setBytes(&beginIndexY, length: MemoryLayout<UInt32>.stride, index: 2)
    var endIndexY:UInt32 = UInt32(endIndexY)
    computeEncoder.setBytes(&endIndexY, length: MemoryLayout<UInt32>.stride, index: 3)
    //Other Variables
    var index:Int = 4
    callBack(&computeEncoder, &index)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}
