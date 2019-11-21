import Foundation
import XCTest


func sum<T: Numeric>(_ vectors: [Vector<T>]) -> Vector<T> {
    let p = vectors[0].dimensions
    let zeros = Vector(repeatedValue: T.zero, dimensions: p)
    
    let sum = vectors.reduce(zeros, { partial_sum, vector in
        
        guard vector.dimensions == p else {
            fatalError("Vectors must be of same length")
        }
        
        return partial_sum + vector
    })
    
    return sum
}

func mean<T: BinaryFloatingPoint>(_ vectors: [Vector<T>]) -> Vector<T> {
    let sum_ = sum(vectors)
    let count = T(vectors.count)
    let average = (1/count) * sum_
    return average
}

func isAlmostEqual<T: BinaryFloatingPoint>(_ lhs: Vector<T>, _ rhs: Vector<T>, accuracy: Double) -> Bool {
    return lhs.isAlmostEqual(rhs, accuracy: accuracy)
}

func isAlmostEqual<T: BinaryFloatingPoint>(_ lhs: [Vector<T>], _ rhs: [Vector<T>], accuracy: Double) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    
    for i in 0..<lhs.count {
        if !rhs[i].isAlmostEqual(lhs[i], accuracy: accuracy) {
            return false
        }
    }
    
    // if not returned false yet
    return true
}

func pow(_ array: [Double], _ exp: Double) -> [Double] {
    return array.map { pow($0, exp)}
}

func pow(_ array: [Double], _ exp: Int) -> [Double] {
    return array.map { pow($0, Double(exp))}
}

func pow(_ vec: Vector<Double>, _ exp: Double) -> Vector<Double> {
    let array = pow(vec.vector, exp)
    return Vector<Double>(array)
}

infix operator **
func **(_ vec: Vector<Double>, _ exp: Double) -> Vector<Double> {
    return pow(vec, exp)
}
