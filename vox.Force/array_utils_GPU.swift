//
//  array_utils.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/30.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit

/// Assigns \p value to 1-D array \p output with \p size.
///
/// This function assigns \p value to 1-D array \p output with \p size. The
/// output array must support random access operator [].
func setRange1<T:ZeroInit>(size:size_t, value:T,
                           output: inout Array1<T>) {
    setRange1(begin: 0, end: size,
              value: value, output: &output)
}

/// Assigns \p value to 1-D array \p output from \p begin to \p end.
///
/// This function assigns \p value to 1-D array \p output from \p begin to \p
/// end. The output array must support random access operator [].
func setRange1<T:ZeroInit>(begin:size_t, end:size_t,
                           value:T, output: inout Array1<T>) {
    var function:String = ""
    switch T.getKernelType(value)() {
    case .float:
        function = "setRange1_float"
    case .float2:
        function = "setRange2_float"
    case .float3:
        function = "setRange3_float"
    case .float4:
        function = "setRange4_float"
    default:
        fatalError()
    }
    
    output.parallelForEachIndex(name: function) { (encoder:inout MTLComputeCommandEncoder, index:inout Int) in
        var begin:UInt32 = UInt32(begin)
        encoder.setBytes(&begin, length: 1 * MemoryLayout<UInt32>.stride, index: index)
        var end:UInt32 = UInt32(end)
        encoder.setBytes(&end, length: 1 * MemoryLayout<UInt32>.size, index: index+1)
        var value = value
        encoder.setBytes(&value, length: 1 * MemoryLayout<T>.size, index: index+2)
    }
}

//MARK:- copyRange
/// Copies \p input array to \p output array with \p size.
///
/// This function copies \p input array to \p output array with \p size. The
/// input and output array must support random access operator [].
func copyRange1<T:ZeroInit>(input:Array1<T>, size:size_t,
                            output: inout Array1<T>) {
    copyRange1(input: input, begin: 0,
               end: size, output: &output)
}

/// Copies \p input array to \p output array from \p begin to \p end.
///
/// This function copies \p input array to \p output array from \p begin to
/// \p end. The input and output array must support random access operator [].
func copyRange1<T:ZeroInit>(input:Array1<T>, begin:size_t,
                            end:size_t, output: inout Array1<T>) {
    var arrayPipelineState: MTLComputePipelineState!
    
    let functionConstants = MTLFunctionConstantValues()
    var property:Int = T.getKernelType(input[0])().rawValue
    functionConstants.setConstantValue(&property, type: .int, index: 0)
    
    let function: MTLFunction?
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = try library.makeFunction(name: "copyRange1",
                                            constantValues: functionConstants)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // first command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let width = arrayPipelineState.threadExecutionWidth
    let threadsPerGroup = MTLSizeMake(width, 1, 1)
    let threadsPerGrid = MTLSizeMake(output.size(), 1, 1)
    
    computeEncoder.setBuffer(input.data(), offset: 0, index: 0)
    computeEncoder.setBuffer(output.data(), offset: 0, index: 1)
    var begin:UInt32 = UInt32(begin)
    computeEncoder.setBytes(&begin, length: 1 * MemoryLayout<UInt32>.stride, index: 2)
    var end:UInt32 = UInt32(end)
    computeEncoder.setBytes(&end, length: 1 * MemoryLayout<UInt32>.size, index: 3)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

/// Copies 2-D \p input array to \p output array with \p sizeX and  \p sizeY.
///
/// This function copies 2-D \p input array to \p output array with \p sizeX and
/// \p sizeY. The input and output array must support 2-D random access operator (i, j).
func copyRange2<T:ZeroInit>(input:Array2<T>,
                            sizeX:size_t,
                            sizeY:size_t,
                            output: inout Array2<T>) {
    copyRange2(input: input, beginX: 0, endX: sizeX,
               beginY: 0, endY: sizeY, output: &output)
}

/// Copies 2-D \p input array to \p output array from
/// (\p beginX, \p beginY) to (\p endX, \p endY).
///
/// This function copies 2-D \p input array to \p output array from
/// (\p beginX, \p beginY) to (\p endX, \p endY). The input and output array
/// must support 2-D random access operator (i, j).
func copyRange2<T:ZeroInit>(input:Array2<T>,
                            beginX:size_t,
                            endX:size_t,
                            beginY:size_t,
                            endY:size_t,
                            output: inout Array2<T>) {
    var arrayPipelineState: MTLComputePipelineState!
    
    let functionConstants = MTLFunctionConstantValues()
    var property:Int = T.getKernelType(input[0])().rawValue
    functionConstants.setConstantValue(&property, type: .int, index: 0)
    
    let function: MTLFunction?
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = try library.makeFunction(name: "copyRange2",
                                            constantValues: functionConstants)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // first command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let w = arrayPipelineState.threadExecutionWidth
    let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
    let threadsPerGroup = MTLSizeMake(w, h, 1)
    let threadsPerGrid = MTLSizeMake(output.width(), output.height(), 1)
    
    computeEncoder.setBuffer(input.data(), offset: 0, index: 0)
    computeEncoder.setBuffer(output.data(), offset: 0, index: 1)
    var beginX:UInt32 = UInt32(beginX)
    computeEncoder.setBytes(&beginX, length: 1 * MemoryLayout<UInt32>.stride, index: 2)
    var endX:UInt32 = UInt32(endX)
    computeEncoder.setBytes(&endX, length: 1 * MemoryLayout<UInt32>.size, index: 3)
    var beginY:UInt32 = UInt32(beginY)
    computeEncoder.setBytes(&beginY, length: 1 * MemoryLayout<UInt32>.stride, index: 4)
    var endY:UInt32 = UInt32(endY)
    computeEncoder.setBytes(&endY, length: 1 * MemoryLayout<UInt32>.size, index: 5)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

/// Copies 3-D \p input array to \p output array with \p sizeX and \p sizeY.
///
/// This function copies 3-D \p input array to \p output array with \p sizeX and
/// \p sizeY. The input and output array must support 3-D random access operator  (i, j, k).
func copyRange3<T:ZeroInit>(input:Array3<T>,
                            sizeX:size_t,
                            sizeY:size_t,
                            sizeZ:size_t,
                            output: inout Array3<T>) {
    copyRange3(input: input, beginX: 0, endX: sizeX,
               beginY: 0, endY: sizeY, beginZ: 0, endZ: sizeZ, output: &output)
}

/// Copies 3-D \p input array to \p output array from
/// (\p beginX, \p beginY, \p beginZ) to (\p endX, \p endY, \p endZ).
///
/// This function copies 3-D \p input array to \p output array from
/// (\p beginX, \p beginY, \p beginZ) to (\p endX, \p endY, \p endZ). The input
/// and output array must support 3-D random access operator (i, j, k).
func copyRange3<T:ZeroInit>(input:Array3<T>,
                            beginX:size_t,
                            endX:size_t,
                            beginY:size_t,
                            endY:size_t,
                            beginZ:size_t,
                            endZ:size_t,
                            output: inout Array3<T>) {
    var arrayPipelineState: MTLComputePipelineState!
    
    let functionConstants = MTLFunctionConstantValues()
    var property:Int = T.getKernelType(input[0])().rawValue
    functionConstants.setConstantValue(&property, type: .int, index: 0)
    
    let function: MTLFunction?
    do {
        guard let library = Renderer.device.makeDefaultLibrary() else {
            return
        }
        
        function = try library.makeFunction(name: "copyRange3",
                                            constantValues: functionConstants)
        
        // array update pipeline state
        arrayPipelineState = try Renderer.device.makeComputePipelineState(function: function!)
    } catch let error {
        print(error.localizedDescription)
    }
    
    // first command encoder
    guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
    
    computeEncoder.setComputePipelineState(arrayPipelineState)
    let w = arrayPipelineState.threadExecutionWidth
    let h = arrayPipelineState.maxTotalThreadsPerThreadgroup / w
    let threadsPerGroup = MTLSizeMake(w, h, 1)
    let threadsPerGrid = MTLSizeMake(output.width(), output.height(), output.depth())
    
    computeEncoder.setBuffer(input.data(), offset: 0, index: 0)
    computeEncoder.setBuffer(output.data(), offset: 0, index: 1)
    var beginX:UInt32 = UInt32(beginX)
    computeEncoder.setBytes(&beginX, length: 1 * MemoryLayout<UInt32>.stride, index: 2)
    var endX:UInt32 = UInt32(endX)
    computeEncoder.setBytes(&endX, length: 1 * MemoryLayout<UInt32>.size, index: 3)
    var beginY:UInt32 = UInt32(beginY)
    computeEncoder.setBytes(&beginY, length: 1 * MemoryLayout<UInt32>.stride, index: 4)
    var endY:UInt32 = UInt32(endY)
    computeEncoder.setBytes(&endY, length: 1 * MemoryLayout<UInt32>.size, index: 5)
    var beginZ:UInt32 = UInt32(beginZ)
    computeEncoder.setBytes(&beginZ, length: 1 * MemoryLayout<UInt32>.stride, index: 6)
    var endZ:UInt32 = UInt32(endZ)
    computeEncoder.setBytes(&endZ, length: 1 * MemoryLayout<UInt32>.size, index: 7)
    
    computeEncoder.dispatchThreads(threadsPerGrid,
                                   threadsPerThreadgroup: threadsPerGroup)
    computeEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}
