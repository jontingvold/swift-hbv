//
//  VectorTests.swift
//  
//
//  Created by Jon Tingvold on 07/11/2019.
//

import Foundation
import XCTest
@testable import SwiftHBV


final class VectorTests: XCTestCase {
    func testInitRepeat() {
        let vector = Vector(repeatedValue: 0.0, dimensions: 10)
        XCTAssertEqual(vector.dimensions, 10, "Simple repeated constractor does not work")
        XCTAssertTrue(isAlmostEqual(vector[0], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[1], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[2], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[3], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[4], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[5], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[6], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[7], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[8], 0.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[9], 0.0, accuracy: 0.00001))
    }
    
    func testInitFromArray() {
        let vector = Vector([1.0, 2.0, 3.0])
        XCTAssertEqual(vector.dimensions, 3)
        XCTAssertTrue(isAlmostEqual(vector[0], 1.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[1], 2.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[2], 3.0, accuracy: 0.00001))
    }
    
    func testInitFromArguments() {
        let vector = Vector(1.0, 2.0, 3.0)
        XCTAssertEqual(vector.dimensions, 3)
        XCTAssertTrue(isAlmostEqual(vector[0], 1.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[1], 2.0, accuracy: 0.00001))
        XCTAssertTrue(isAlmostEqual(vector[2], 3.0, accuracy: 0.00001))
    }
    
    func testSettingIndex() {
        var v1 = Vector(1.0, 2.0)
        v1[1] = 3.0
        let correct_v1 = Vector(1.0, 3.0)
        
        XCTAssertTrue(isAlmostEqual(v1, correct_v1, accuracy: 0.00001), "Set value of one dimension by index gives wrong result.")
    }
    
    func testEqual() {
        let v1 = Vector(1.0, 2.0)
        let equal_v1 = Vector(1.0, 2.0)
        let not_equal_v1 = Vector(0.0, 2.0)
        
        XCTAssertTrue(isAlmostEqual(v1, equal_v1, accuracy: 0.00001), "These vectors should be equal")
        XCTAssertFalse(isAlmostEqual(v1, not_equal_v1, accuracy: 0.00001), "These vectors should NOT be equal")
    }
    
    func testEqualDouble2() {
         let v1 = Vector(1.0, 2.0)
         let equal_v1 = Vector(1.0, 1.999999999999)
         let not_equal_v1 = Vector(1.0, 1.90)
         
         XCTAssertTrue(isAlmostEqual(v1, equal_v1, accuracy: 0.00001), "These vectors should be equal")
         XCTAssertFalse(isAlmostEqual(v1, not_equal_v1, accuracy: 0.00001), "These vectors should NOT be equal")
     }
    
    func testEqualDouble3() {
         XCTAssertTrue(isAlmostEqual(
                Vector([-3.36, -0.15999999999999992, 0.0]),
                Vector([-3.36, -0.16, 0.0]),
                accuracy: 0.00001
            ), "These vectors should be equal")
     }
    
    func testAddition() {
        let v1 = Vector(1.0, 2.0)
        let v2 = Vector(1.0, 2.0)
        let scalar = 2.0
        
        XCTAssertTrue(isAlmostEqual(v1 + v2, Vector(2.0, 4.0), accuracy: 0.00001), "Adding two vectors gives wrong result")
        
        XCTAssertTrue(isAlmostEqual(scalar + v1, Vector(3.0, 4.0), accuracy: 0.00001), "Adding scalar and vector gives wrong result")
        XCTAssertTrue(isAlmostEqual(v1 + scalar, Vector(3.0, 4.0), accuracy: 0.00001), "Adding vector and scalar gives wrong result")
    }
    
    func testSubtraction() {
        let v1 = Vector(1.0, 2.0)
        let v2 = Vector(1.0, 1.0)
        let scalar = 2.0
        
        XCTAssertTrue(isAlmostEqual(v1 - v2, Vector(0.0, 1.0), accuracy: 0.00001), "Subtracting two vectors gives wrong result")
        XCTAssertTrue(isAlmostEqual(v1 - scalar, Vector(-1.0, 0.0), accuracy: 0.00001), "Subtracting scalar from vector gives wrong result")
        XCTAssertTrue(isAlmostEqual(scalar - v1, Vector(1.0, 0.0), accuracy: 0.00001), "Subtracting vector from scalar gives wrong result")
    }
    
    func testDotProduct() {
        let v1 = Vector(1.0, 2.0)
        let v2 = Vector(2.0, 3.0)
        let scalar = 2.0
        
        XCTAssertTrue(isAlmostEqual(v1 * v2, Vector(2.0, 6.0), accuracy: 0.00001), "The dot product of two vectors gives wrong result")
        XCTAssertTrue(isAlmostEqual(v1 * scalar, Vector(2.0, 4.0), accuracy: 0.00001), "Multiplying vector and scalar gives wrong result")
        XCTAssertTrue(isAlmostEqual(scalar * v1, Vector(2.0, 4.0), accuracy: 0.00001), "Multiplying vector and scalar gives wrong result")
    }
    
    func testDescription() {
        let v1 = Vector(1.0, 2.0)
        
        let v1String = v1.description
        let v1Correct = "[1.000, 2.000]"
        
        XCTAssertEqual(v1String, v1Correct, "Vector description not correct")
    }
    
    func testDebugDescription() {
        let v1 = Vector(1.0, 2.0)
        
        let v1String = v1.debugDescription
        let v1Correct = "Vector(1.0, 2.0)"
        
        XCTAssertEqual(v1String, v1Correct, "Vector description not correct")
    }
}
