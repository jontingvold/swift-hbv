import Foundation


// MARK: Multiply Double and Int

func *(_ rhs: Double, _ lhs: Int) -> Double {
    return rhs * Double(lhs)
}

func *(_ rhs: Int, _ lhs: Double) -> Double {
    return Double(rhs) * lhs
}

func /(_ rhs: Double, _ lhs: Int) -> Double {
    return rhs / Double(lhs)
}

func /(_ rhs: Int, _ lhs: Double) -> Double {
    return Double(rhs) / lhs
}

// MARK: Create exponent operator **

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
func **(_ base: Double, _ exp: Double) -> Double {
    return pow(base, exp)
}

func **(_ base: Double, _ exp: Int) -> Double {
    return pow(base, Double(exp))
}

// MARK: Math operation on scalar and array

func +<T: Numeric>(_ array: [T], _ scalar: T) -> [T] {
    return array.map { $0 + scalar }
}

func +<T: Numeric>(_ scalar: T, _ array: [T]) -> [T] {
    return array.map { scalar + $0 }
}

func -<T: Numeric>(_ array: [T], _ scalar: T) -> [T] {
    return array.map { $0 - scalar }
}

func -<T: Numeric>(_ scalar: T, _ array: [T]) -> [T] {
    return array.map { scalar - $0 }
}

func *<T: Numeric>(_ array: [T], _ scalar: T) -> [T] {
    return array.map { $0 * scalar }
}

func *<T: Numeric>(_ scalar: T, _ array: [T]) -> [T] {
    return array.map { scalar * $0 }
}

func **(_ array: [Double], _ exp: Double) -> [Double] {
    return array.map { pow($0, exp) }
}

func **(_ array: [Double], _ exp: Int) -> [Double] {
    return array.map { pow($0, Double(exp)) }
}

func /(_ array: [Double], _ denominator: Double) -> [Double] {
    return array.map { $0 / denominator }
}

func /(_ array: [Double], _ denominator: Int) -> [Double] {
    return array.map { $0 / Double(denominator) }
}
