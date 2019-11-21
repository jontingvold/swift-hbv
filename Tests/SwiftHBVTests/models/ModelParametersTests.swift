import XCTest
@testable import SwiftHBV


final class ModelParametersTests: XCTestCase {
    func testAsVector() {
        let mp = ModelParameters()
        let randomVector: [Double] = (0..<16).map { _ in Double.random(in: 1...100) }
        
        mp.setAsVector(vector: randomVector)
        let returnedVector = mp.asVector()
        
        XCTAssertTrue(isAlmostEqual(returnedVector, returnedVector, accuracy: 0.0001), "Vector return not the same as set")
    }
}
