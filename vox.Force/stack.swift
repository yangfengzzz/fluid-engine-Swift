//
//  stack.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/17.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

public struct Stack<T> {
    /// Datastructure consisting of a generic item.
    fileprivate var array = [T]()
    
    /// The number of items in the stack.
    public var count: Int {
        return array.count
    }
    
    /// Verifies if the stack is empty.
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    /// Pushes an item to the top of the stack.
    /// - Parameter element: The item being pushed.
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    /// Removes and returns the item at the top of the stack.
    /// - Returns: The item at the top of the stack.
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    /// Returns the item at the top of the stack.
    public var top: T? {
        return array.last
    }
}

extension Stack: Sequence {
    public func makeIterator() -> AnyIterator<T> {
        var curr = self
        return AnyIterator {
            return curr.pop()
        }
    }
}
