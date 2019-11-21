import Foundation


/// A Vector is a fixed size Double collection.
/// You can set and get elements using subscript notation. Example:
/// `vector[index] = value`
///
/// This collection also provides algebra functions and operators such as
/// `+`, `-` and `*` using Apple's Accelerate framework.
/// Check the `Functions` section for more information.
///
/// Conforms to `SequenceType`, `MutableCollectionType`,
/// `ArrayLiteralConvertible`, `Printable` and `DebugPrintable`.
public struct Vector<T: BinaryFloatingPoint> {
    
    // MARK: Creating a Vector
    
    /// Constructs a new vector with all positions set to the specified value.
    public init(repeatedValue: T, dimensions: Int) {
        if dimensions <= 0 {
            fatalError("Can't create vector. Invalid number of dimensions.")
        }
        
        self.dimensions = dimensions
        vector = Array(repeating: repeatedValue, count: dimensions)
    }
    
    /// Constructs a new vector using an array.
    public init(_ array: [T]) {
        let dimensions = array.count
        if dimensions <= 0 {
            fatalError("Can't create an empty vector.")
        }
        
        self.dimensions = dimensions
        vector = array
    }
    
    /// Constructs a new vector using a variadic function.
    public init(_ array: T...) {
        self.init(array)
    }
    
    // MARK: Properties
    
    /// The number of dimensions in the vector.
    public let dimensions: Int
    
    /// The vector
    public internal(set) var vector: [T]
    
    
    // MARK: Getting and Setting elements
    
    // Provides random access for getting and setting elements using square bracket notation.
    public subscript(i: Int) -> T {
        get {
            if !indexIsValidForRow(index: i) {
                fatalError("Index out of range")
            }
            return vector[i]
        }
        set {
            if !indexIsValidForRow(index: i) {
                fatalError("Index out of range")
            }
            vector[i] = newValue
        }
    }
    
    // MARK: Methods
    
    public func isAlmostEqual(_ other: Vector<T>, accuracy: Double) -> Bool {
        
        if self.dimensions != other.dimensions {
            return false
        }
        
        for i in 0..<self.dimensions {
            let diff = Double(self[i] - other[i])
            if diff > accuracy {
                return false
            }
        }
        
        // if not returned false yet
        return true
    }
    
    // MARK: Private Properties and Helper Methods
    
    private func indexIsValidForRow(index: Int) -> Bool {
        return index >= 0 && index < dimensions
    }
}

// MARK: Static methods

extension Vector {
    
    static public func random(dimensions: Int, from: Double = -1.0, to: Double = 1.0) -> Vector<Double> {
        let array = (0..<dimensions).map { _ in
            Double.random(in: from ... to)
        }
        
        return Vector<Double>(array)
    }
}

// MARK: -

extension Vector: Sequence {
    
    // MARK: SequenceType Protocol Conformance
    
    /// Provides for-in loop functionality.
    ///
    /// - returns: A generator over the elements.
    public func generate() -> AnyIterator<T> {
        return AnyIterator(IndexingIterator(_elements: self))
    }
}

extension Vector: Collection {
    // MARK: MutableCollectionType Protocol Conformance
    
    /// Always zero
    public var startIndex : Int {
        return 0
    }
    
    /// Always `dimensions`
    public var endIndex : Int {
        return dimensions-1
    }
    
    public func index(after i: Int) -> Int {
        return i+1
    }
}

extension Vector: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the vector.
    public var description: String {
        let result = "[" + vector.map {String(format: "%.3f", Double($0))}.joined(separator: ", ") + "]"
        return result
    }
}

extension Vector: CustomDebugStringConvertible {
    
    // MARK: CustomDebugStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the vector that is used in the debug console.
    public var debugDescription: String {
        let result = "Vector(" + vector.map {"\($0)"}.joined(separator: ", ") + ")"
        return result
    }
}

    
// MARK: Vector Algebra Operations


// Addition

/// Performs vector and vector addition.
public func +<T: Numeric>(lhs: Vector<T>, rhs: Vector<T>) -> Vector<T> {
    if lhs.dimensions != rhs.dimensions {
        fatalError("Impossible to add different size vectors")
    }
    var result = lhs
    for i in 0..<lhs.dimensions {
        result[i] = lhs[i] + rhs[i]
    }
    return result
}

/// Performs vector and vector addition.
public func +=<T: Numeric>(lhs: inout Vector<T>, rhs: Vector<T>) {
    lhs.vector = (lhs + rhs).vector
}

/// Performs vector and scalar addition.
public func +<T: Numeric>(lhs: Vector<T>, rhs: T) -> Vector<T> {
    let scalar = rhs
    var result = lhs
    for i in 0..<lhs.dimensions {
        result[i] = scalar + result[i]
    }
    return result
}

/// Performs scalar and vector addition.
public func +<T: Numeric>(lhs: T, rhs: Vector<T>) -> Vector<T> {
    return rhs + lhs
}

/// Performs vector and scalar addition.
public func +=<T: Numeric>(lhs: inout Vector<T>, rhs: T) {
    lhs.vector = (lhs + rhs).vector
}

// Subtraction

/// Performs vector and vector subtraction.
public func -<T: Numeric>(lhs: Vector<T>, rhs: Vector<T>) -> Vector<T> {
    if lhs.dimensions != rhs.dimensions {
        fatalError("Impossible to add different size vectors")
    }
    var result = lhs
    for i in 0..<result.dimensions {
        result[i] = lhs[i] - rhs[i]
    }
    return result
}

/// Performs vector and vector subtraction.
public func -=<T: Numeric>(lhs: inout Vector<T>, rhs: Vector<T>) {
    lhs.vector = (lhs - rhs).vector
}

/// Performs vector and scalar subtraction.
public func -<T: Numeric>(lhs: Vector<T>, rhs: T) -> Vector<T> {
    return lhs + (-rhs)
}

/// Performs scalar and vector subtraction.
public func -<T: Numeric>(lhs: T, rhs: Vector<T>) -> Vector<T> {
    return lhs + (-rhs)
}

/// Performs vector and scalar subtraction.
public func -=<T: Numeric>(lhs: inout Vector<T>, rhs: T) {
    lhs.vector = (lhs - rhs).vector
}

// Negation

/// Negates all the values in a vector.
public prefix func -<T: Numeric>(m: Vector<T>) -> Vector<T> {
    var result = m
    for i in 0..<result.dimensions {
        result[i] = -1 * result[i]
    }
    return result
}

/// Negates all the values in a vector.
public prefix func -<T: Numeric>(m: T) -> T {
    return -1 * m
}

// Dot-product

/// Calculates the dot product between two vectors
public func *<T: Numeric>(lhs: Vector<T>, rhs: Vector<T>) -> Vector<T> {
    if lhs.dimensions != rhs.dimensions {
        fatalError("Impossible to add different size vectors")
    }
    var result = lhs
    for i in 0..<result.dimensions {
        result[i] = lhs[i] * rhs[i]
    }
    return result
}

/// Performs vector and scalar multiplication.
public func *<T: Numeric>(lhs: Vector<T>, rhs: T) -> Vector<T> {
    let scalar = rhs
    var result = lhs
    for i in 0..<result.dimensions {
        result[i] = scalar * result[i]
    }
    return result
}

/// Performs scalar and vector multiplication.
public func *<T: Numeric>(lhs: T, rhs: Vector<T>) -> Vector<T> {
    return rhs * lhs
}

/// Performs vector and scalar multiplication.
public func *=<T: Numeric>(lhs: inout Vector<T>, rhs: T) {
    lhs.vector = (lhs * rhs).vector
}
