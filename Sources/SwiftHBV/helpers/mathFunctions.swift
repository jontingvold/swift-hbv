//
//  File.swift
//  
//
//  Created by Jon Tingvold on 13/11/2019.
//
import Foundation


func sum<T: Numeric>(_ array: [T]) -> T {
    return array.reduce(T.zero, +)
}

// Calculate mean of an array of doubles
func mean<T: BinaryFloatingPoint>(_ array: [T]) -> Double {
    if array.isEmpty {
        return 0.0
    } else {
        return Double(sum(array))/Double(array.count)
    }
}

// Calculate mean of an array of integers
func mean<T: BinaryInteger>(_ array: [T]) -> Double {
    if array.isEmpty {
        return 0.0
    } else {
        return Double(sum(array))/Double(array.count)
    }
}

// Calculate standard diviation of an array
func stDev<T: BinaryFloatingPoint>(_ array: [T]) -> Double {
    let x_avg = mean(array)
    let dof = Double(array.count - 1)    // Degree-of-freedom
    return (1/dof) * sum(array.map { pow(Double($0) - x_avg, 2.0) })
}

func stDev<T: BinaryInteger>(_ array: [T]) -> Double {
    let x_avg = mean(array)
    let dof = Double(array.count - 1)    // Degree-of-freedom
    return (1/dof) * sum(array.map { pow(Double($0) - x_avg, 2.0) })
}

// Calculate cumulative sum of array
func cumsum<T: BinaryFloatingPoint>(_ array: [T]) -> [T] {
    let cumsum = Array(array.scan(initial: T.zero, +).dropFirst())
    return cumsum
}
