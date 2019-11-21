import XCTest
@testable import SwiftHBV


final class LowerZoneTankTests: XCTestCase {
    var cp = CatchmentParameters.getExample()
    var mp = ModelParameters()
    var lowerZoneTank: LowerZoneTank!

    override func setUp() {
        cp.lake_percentage = 2.00   // Percent land which is lakes
        mp.epot = 4.0    // Evaporation potential (mm)
        mp.KLZ = 0.15   // Discharge rate (1/timestep)
        
        lowerZoneTank = LowerZoneTank(cp: cp, mp: mp)
        
        super.setUp()
    }

    func testOfNothing() {
        lowerZoneTank.LZ = 0.0
        let (Q_lz, evapLake) = lowerZoneTank.simulateTimestepAndGetOutput(p: 0.0, perc: 0.0)
        
        XCTAssertEqual(Q_lz, 0.0)
        XCTAssertEqual(evapLake, 0.08)
    }
    
    func testOfPerc() {
        lowerZoneTank.LZ = 0.0
        let (Q_lz, evapLake) = lowerZoneTank.simulateTimestepAndGetOutput(p: 0.0, perc: 1.5)
        
        XCTAssertEqual(Q_lz, 0.225, accuracy: 0.01)
        XCTAssertEqual(evapLake, 0.08)
        XCTAssertEqual(lowerZoneTank.LZ, 1.5-0.225-0.08, accuracy: 0.01)
    }
    
    func testOfLZLevel() {
        lowerZoneTank.LZ = 1.5
        let (Q_lz, evapLake) = lowerZoneTank.simulateTimestepAndGetOutput(p: 0.0, perc: 0.5)
        
        XCTAssertEqual(Q_lz, 0.30, accuracy: 0.01)
        XCTAssertEqual(evapLake, 0.08, accuracy: 0.01)
        XCTAssertEqual(lowerZoneTank.LZ, 2.0-0.3-0.08, accuracy: 0.01)
    }
    
    func testP() {
        lowerZoneTank.LZ = 0.0
        let (Q_lz, evapLake) = lowerZoneTank.simulateTimestepAndGetOutput(p: 5.0, perc: 0.0)
        
        XCTAssertEqual(Q_lz, 0.015, accuracy: 0.01)
        XCTAssertEqual(evapLake, 0.08, accuracy: 0.01)
        XCTAssertEqual(lowerZoneTank.LZ, 0.0, accuracy: 0.01)
    }
}
