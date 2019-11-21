import Foundation


func isAlmostEqual<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T, accuracy: T) -> Bool {
    let diff = lhs - rhs
    return diff < accuracy
}

func isAlmostEqual<T: BinaryFloatingPoint>(_ lhs: [T], _ rhs: [T], accuracy: T) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    
    for i in 0..<lhs.count {
        if !(isAlmostEqual(lhs[i], rhs[i], accuracy: accuracy)) { return false }
    }
    
    // if not returned false yet
    return true
    
}

extension Array where Element: BinaryFloatingPoint {
    public func isAlmostEqual(_ other: [Double], accuracy: Double) -> Bool {
        let lhs = self
        let rhs = other
        
        if lhs.count != rhs.count {
            return false
        }
        
        for i in 0..<lhs.count {
            let diff = Double(lhs[i]) - rhs[i]
            if diff > accuracy { return false }
        }
        
        // if not returned false yet
        return true
    }
}
