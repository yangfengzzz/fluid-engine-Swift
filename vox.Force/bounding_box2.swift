//
//  bounding_box2.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/4/15.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import Foundation

/// 2-D box-ray intersection result.
struct BoundingBoxRayIntersection2<T:BinaryFloatingPoint>{
    /// True if the box and ray intersects.
    var isIntersecting:Bool = true
    
    /// Distance to the first intersection point.
    var tNear:T = T.greatestFiniteMagnitude
    
    /// Distance to the second (and the last) intersection point.s
    var tFar:T = T.greatestFiniteMagnitude
}

/// 2-D axis-aligned bounding box class.
struct BoundingBox2F {
    
    /// Lower corner of the bounding box.
    var lowerCorner:Vector2F = Vector2F(repeating: Float.greatestFiniteMagnitude)
    
    /// Upper corner of the bounding box.
    var upperCorner:Vector2F = Vector2F(repeating: -Float.greatestFiniteMagnitude)
    
    /// Default constructor.
    init(){
        reset()
    }
    
    /// Constructs a box that tightly covers two points.
    init(point1:Vector2F, point2:Vector2F){
        lowerCorner.x = min(point1.x, point2.x)
        lowerCorner.y = min(point1.y, point2.y)
        upperCorner.x = max(point1.x, point2.x)
        upperCorner.y = max(point1.y, point2.y)
    }
    
    /// Constructs a box with other box instance.
    init(other:BoundingBox2F){
        lowerCorner = other.lowerCorner
        upperCorner = other.upperCorner
    }
    
    /// Returns width of the box.
    func width()->Float{
        return upperCorner.x - lowerCorner.x
    }
    
    /// Returns height of the box.
    func height()->Float{
        return upperCorner.y - lowerCorner.y
    }
    
    /// Returns length of the box in given axis.
    func length(axis:size_t)->Float{
        return upperCorner[axis] - lowerCorner[axis]
    }
    
    /// Returns true of this box and other box overlaps.
    func overlaps(other:BoundingBox2F)->Bool{
        if (upperCorner.x < other.lowerCorner.x ||
            lowerCorner.x > other.upperCorner.x) {
            return false
        }
        
        if (upperCorner.y < other.lowerCorner.y ||
            lowerCorner.y > other.upperCorner.y) {
            return false
        }
        
        return true
    }
    
    /// Returns true if the input point is inside of this box.
    func contains(point:Vector2F)->Bool{
        if (upperCorner.x < point.x || lowerCorner.x > point.x) {
            return false
        }
        
        if (upperCorner.y < point.y || lowerCorner.y > point.y) {
            return false
        }
        
        return true
    }
    
    /// Returns true if the input ray is intersecting with this box.
    func intersects(ray:Ray2F)->Bool{
        var tMin:Float = 0
        var tMax:Float = Float.greatestFiniteMagnitude
        
        let rayInvDir = 1 / ray.direction
        
        for i in 0..<2 {
            var tNear:Float = (lowerCorner[i] - ray.origin[i]) * rayInvDir[i]
            var tFar:Float = (upperCorner[i] - ray.origin[i]) * rayInvDir[i]
            
            if (tNear > tFar) {
                swap(&tNear, &tFar)
            }
            
            tMin = max(tNear, tMin)
            tMax = min(tFar, tMax)
            
            if (tMin > tMax) {
                return false
            }
        }
        
        return true
    }
    
    
    /// Returns intersection.isIntersecting = true if the input ray is
    /// intersecting with this box. If interesects, intersection.tNear is
    /// assigned with distant to the closest intersecting point, and
    /// intersection.tFar with furthest.
    func closestIntersection(ray:Ray2F)->BoundingBoxRayIntersection2<Float>{
        var intersection = BoundingBoxRayIntersection2<Float>()
        
        var tMin:Float = 0
        var tMax:Float = Float.greatestFiniteMagnitude
        
        let rayInvDir =  1 / ray.direction
        
        for i in 0..<2 {
            var tNear:Float = (lowerCorner[i] - ray.origin[i]) * rayInvDir[i]
            var tFar:Float = (upperCorner[i] - ray.origin[i]) * rayInvDir[i]
            
            if (tNear > tFar) {
                swap(&tNear, &tFar)
            }
            
            tMin = max(tNear, tMin)
            tMax = min(tFar, tMax)
            
            if (tMin > tMax) {
                intersection.isIntersecting = false
                return intersection
            }
        }
        
        intersection.isIntersecting = true
        
        if (contains(point: ray.origin)) {
            intersection.tNear = tMax
            intersection.tFar = Float.greatestFiniteMagnitude
        } else {
            intersection.tNear = tMin
            intersection.tFar = tMax
        }
        
        return intersection
    }
    
    /// Returns the mid-point of this box.
    func midPoint()->Vector2F{
        return (upperCorner + lowerCorner) / 2
    }
    
    /// Returns diagonal length of this box.
    func diagonalLength()->Float{
        return simd.length(upperCorner - lowerCorner)
    }
    
    /// Returns squared diagonal length of this box.
    func diagonalLengthSquared()->Float{
        return length_squared(upperCorner - lowerCorner)
    }
    
    /// Resets this box to initial state (min=infinite, max=-infinite).
    mutating func reset(){
        lowerCorner.replace(with: Float.greatestFiniteMagnitude, where: [true, true])
        upperCorner.replace(with: -Float.greatestFiniteMagnitude, where: [true, true])
    }
    
    /// Merges this and other point.
    mutating func merge(point:Vector2F){
        lowerCorner.x = min(lowerCorner.x, point.x)
        lowerCorner.y = min(lowerCorner.y, point.y)
        upperCorner.x = max(upperCorner.x, point.x)
        upperCorner.y = max(upperCorner.y, point.y)
    }
    
    /// Merges this and other box.
    mutating func merge(other:BoundingBox2F){
        lowerCorner.x = min(lowerCorner.x, other.lowerCorner.x)
        lowerCorner.y = min(lowerCorner.y, other.lowerCorner.y)
        upperCorner.x = max(upperCorner.x, other.upperCorner.x)
        upperCorner.y = max(upperCorner.y, other.upperCorner.y)
    }
    
    /// Expands this box by given delta to all direction.
    /// If the width of the box was x, expand(y) will result a box with
    /// x+y+y width.
    mutating func expand(delta:Float){
        lowerCorner -= delta
        upperCorner += delta
    }
    
    /// Returns corner position. Index starts from x-first order.
    func corner(idx:size_t)->Vector2F{
        let h:Float = 1 / 2
        let offset:[Vector2F] = [[-h, -h], [+h, -h], [-h, +h], [+h, +h]]
        
        return Vector2F(width(), height()) * offset[idx] + midPoint()
    }
    
    /// Returns the clamped point.
    func clamp(pt:Vector2F)->Vector2F{
        return pt.clamped(lowerBound: lowerCorner, upperBound: upperCorner)
    }
    
    /// Returns true if the box is empty.
    func isEmpty()->Bool{
        return (lowerCorner.x >= upperCorner.x || lowerCorner.y >= upperCorner.y)
    }
}

/// 2-D axis-aligned bounding box class.
struct BoundingBox2D {
    
    /// Lower corner of the bounding box.
    var lowerCorner:Vector2D = Vector2D(repeating: Double.greatestFiniteMagnitude)
    
    /// Upper corner of the bounding box.
    var upperCorner:Vector2D = Vector2D(repeating: -Double.greatestFiniteMagnitude)
    
    /// Default constructor.
    init(){
        reset()
    }
    
    /// Constructs a box that tightly covers two points.
    init(point1:Vector2D, point2:Vector2D){
        lowerCorner.x = min(point1.x, point2.x)
        lowerCorner.y = min(point1.y, point2.y)
        upperCorner.x = max(point1.x, point2.x)
        upperCorner.y = max(point1.y, point2.y)
    }
    
    /// Constructs a box with other box instance.
    init(other:BoundingBox2D){
        lowerCorner = other.lowerCorner
        upperCorner = other.upperCorner
    }
    
    /// Returns width of the box.
    func width()->Double{
        return upperCorner.x - lowerCorner.x
    }
    
    /// Returns height of the box.
    func height()->Double{
        return upperCorner.y - lowerCorner.y
    }
    
    /// Returns length of the box in given axis.
    func length(axis:size_t)->Double{
        return upperCorner[axis] - lowerCorner[axis]
    }
    
    /// Returns true of this box and other box overlaps.
    func overlaps(other:BoundingBox2D)->Bool{
        if (upperCorner.x < other.lowerCorner.x ||
            lowerCorner.x > other.upperCorner.x) {
            return false
        }
        
        if (upperCorner.y < other.lowerCorner.y ||
            lowerCorner.y > other.upperCorner.y) {
            return false
        }
        
        return true
    }
    
    /// Returns true if the input point is inside of this box.
    func contains(point:Vector2D)->Bool{
        if (upperCorner.x < point.x || lowerCorner.x > point.x) {
            return false
        }
        
        if (upperCorner.y < point.y || lowerCorner.y > point.y) {
            return false
        }
        
        return true
    }
    
    /// Returns true if the input ray is intersecting with this box.
    func intersects(ray:Ray2D)->Bool{
        var tMin:Double = 0
        var tMax:Double = Double.greatestFiniteMagnitude
        
        let rayInvDir = 1 / ray.direction
        
        for i in 0..<2 {
            var tNear:Double = (lowerCorner[i] - ray.origin[i]) * rayInvDir[i]
            var tFar:Double = (upperCorner[i] - ray.origin[i]) * rayInvDir[i]
            
            if (tNear > tFar) {
                swap(&tNear, &tFar)
            }
            
            tMin = max(tNear, tMin)
            tMax = min(tFar, tMax)
            
            if (tMin > tMax) {
                return false
            }
        }
        
        return true
    }
    
    
    /// Returns intersection.isIntersecting = true if the input ray is
    /// intersecting with this box. If interesects, intersection.tNear is
    /// assigned with distant to the closest intersecting point, and
    /// intersection.tFar with furthest.
    func closestIntersection(ray:Ray2D)->BoundingBoxRayIntersection2<Double>{
        var intersection = BoundingBoxRayIntersection2<Double>()
        
        var tMin:Double = 0
        var tMax:Double = Double.greatestFiniteMagnitude
        
        let rayInvDir =  1 / ray.direction
        
        for i in 0..<2 {
            var tNear:Double = (lowerCorner[i] - ray.origin[i]) * rayInvDir[i]
            var tFar:Double = (upperCorner[i] - ray.origin[i]) * rayInvDir[i]
            
            if (tNear > tFar) {
                swap(&tNear, &tFar)
            }
            
            tMin = max(tNear, tMin)
            tMax = min(tFar, tMax)
            
            if (tMin > tMax) {
                intersection.isIntersecting = false
                return intersection
            }
        }
        
        intersection.isIntersecting = true
        
        if (contains(point: ray.origin)) {
            intersection.tNear = tMax
            intersection.tFar = Double.greatestFiniteMagnitude
        } else {
            intersection.tNear = tMin
            intersection.tFar = tMax
        }
        
        return intersection
    }
    
    /// Returns the mid-point of this box.
    func midPoint()->Vector2D{
        return (upperCorner + lowerCorner) / 2
    }
    
    /// Returns diagonal length of this box.
    func diagonalLength()->Double{
        return simd.length(upperCorner - lowerCorner)
    }
    
    /// Returns squared diagonal length of this box.
    func diagonalLengthSquared()->Double{
        return length_squared(upperCorner - lowerCorner)
    }
    
    /// Resets this box to initial state (min=infinite, max=-infinite).
    mutating func reset(){
        lowerCorner.replace(with: Double.greatestFiniteMagnitude, where: [true, true])
        upperCorner.replace(with: -Double.greatestFiniteMagnitude, where: [true, true])
    }
    
    /// Merges this and other point.
    mutating func merge(point:Vector2D){
        lowerCorner.x = min(lowerCorner.x, point.x)
        lowerCorner.y = min(lowerCorner.y, point.y)
        upperCorner.x = max(upperCorner.x, point.x)
        upperCorner.y = max(upperCorner.y, point.y)
    }
    
    /// Merges this and other box.
    mutating func merge(other:BoundingBox2D){
        lowerCorner.x = min(lowerCorner.x, other.lowerCorner.x)
        lowerCorner.y = min(lowerCorner.y, other.lowerCorner.y)
        upperCorner.x = max(upperCorner.x, other.upperCorner.x)
        upperCorner.y = max(upperCorner.y, other.upperCorner.y)
    }
    
    /// Expands this box by given delta to all direction.
    /// If the width of the box was x, expand(y) will result a box with
    /// x+y+y width.
    mutating func expand(delta:Double){
        lowerCorner -= delta
        upperCorner += delta
    }
    
    /// Returns corner position. Index starts from x-first order.
    func corner(idx:size_t)->Vector2D{
        let h:Double = 1 / 2
        let offset:[Vector2D] = [[-h, -h], [+h, -h], [-h, +h], [+h, +h]]
        
        return Vector2D(width(), height()) * offset[idx] + midPoint()
    }
    
    /// Returns the clamped point.
    func clamp(pt:Vector2D)->Vector2D{
        return pt.clamped(lowerBound: lowerCorner, upperBound: upperCorner)
    }
    
    /// Returns true if the box is empty.
    func isEmpty()->Bool{
        return (lowerCorner.x >= upperCorner.x || lowerCorner.y >= upperCorner.y)
    }
}
