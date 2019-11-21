//
//  VectorTests.swift
//  
//
//  Created by Jon Tingvold on 07/11/2019.
//

import Foundation
import XCTest
@testable import SwiftHBV


final class HelpersTests: XCTestCase {
    func testExponents() {
        XCTAssertEqual(4.0**2.0, 16.0)
        XCTAssertEqual(4.0**2, 16.0, "Int as exponent")
        XCTAssertEqual([2.0, 4.0]**2, [4.0, 16.0], "Array")
        
        /*
        CANT TEST FOR SINCE IT IS IN ANOTHER PACKET, BUT IT WORKS
        XCTAssertEqual(2.0 * 3.0**2, 18.0, "Exponents higher priorty than multiplication")
        XCTAssertEqual(2.0**3.0**2.0, 512.0, "Exponents not right assosiative")
        XCTAssertEqual((2.0 ** 3.0) ** 2.0, 64.0)
        */
    }
}
