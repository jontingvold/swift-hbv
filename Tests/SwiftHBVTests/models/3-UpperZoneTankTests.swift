import XCTest
@testable import SwiftHBV


final class UpperZoneTankTests: XCTestCase {
    var cp = CatchmentParameters.getExample()
    var mp = ModelParameters()
    var upperZoneTank: UpperZoneTank!

    override func setUp() {
        mp.KUZ1 = 1.0   // Quick discharge rate (1/timestep)
        mp.KUZ0 = 0.1   // Slow discharge rate (1/timestep)
        mp.UZ1 = 20.0    // Quick discharge level (mm)
        mp.perc = 1.5   // Perculation (mm/timestep)
                         // perc is adjusted if perc > UZ
        
        upperZoneTank = UpperZoneTank(cp: cp, mp: mp)
        
        super.setUp()
    }

    func testOfNothing() {
        let (perc, Q1, Q0) = upperZoneTank!.simulateTimestepAndGetOutput(dUZ: 0.0)
        
        XCTAssertEqual(perc, 0.0)
        XCTAssertEqual(Q1, 0.0)
        XCTAssertEqual(Q0, 0.0)
    }
    
    func testOfPercTurnOff() {
        upperZoneTank.UZ = 0.5
        var (perc, Q1, Q0) = upperZoneTank.simulateTimestepAndGetOutput(dUZ: 0.0)
        
        XCTAssertEqual(perc, 0.45, "Perc should be adjusted down if not enough water")
        XCTAssertEqual(Q1, 0.0)
        XCTAssertEqual(Q0, 0.05)
        XCTAssertEqual(upperZoneTank.UZ, 0.00)
        
        // Fill up with water
        (perc, Q1, Q0) = upperZoneTank.simulateTimestepAndGetOutput(dUZ: 10.0)
        
        XCTAssertEqual(perc, 0.45, "Perc should not go up again")
        XCTAssertEqual(Q1, 0.0)
        XCTAssertEqual(Q0, 1.00)
        XCTAssertEqual(upperZoneTank.UZ, 10.0-1.45)
        
    }
    
    func testFastResponse() {
        upperZoneTank.UZ = 30
        let (perc, Q1, Q0) = upperZoneTank.simulateTimestepAndGetOutput(dUZ: 0.0)
        
        XCTAssertEqual(perc, 1.5)
        XCTAssertEqual(Q1, 10.0)
        XCTAssertEqual(Q0, 2.0)
    }
    
    func testIfSameResponseIfNewWater() {
        upperZoneTank.UZ = 0
        let (perc, Q1, Q0) = upperZoneTank.simulateTimestepAndGetOutput(dUZ: 30.0)
        
        XCTAssertEqual(perc, 1.5)
        XCTAssertEqual(Q1, 10.0)
        XCTAssertEqual(Q0, 2.0)
    }
}
