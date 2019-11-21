import XCTest
@testable import SwiftHBV


final class SoilMoistureTankTests: XCTestCase {
    var cp = CatchmentParameters.getExample()
    var mp = ModelParameters()
    var soilMoistureTank: SoilMoistureTank!

    override func setUp() {
        mp.FC = 40.0     // Field capacity (mm)
        mp.ET = 20.0     // Full evaporation threshold (mm)
        mp.beta = 1.5    // Infiltration coef.
        mp.epot = 4.0    // Evaporation potential (mm)
        
        soilMoistureTank = SoilMoistureTank(cp: cp, mp: mp)
        
        super.setUp()
    }

    func testOfNothing() {
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 0.0)
        
        XCTAssertEqual(dUZ, 0.0)
        XCTAssertEqual(evapSoil, 0.0)
    }

    func testFullEvaporation() {
        soilMoistureTank.SM = 30
        let (_, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 0.0)
        XCTAssertEqual(evapSoil, 4.0)
    }
    
    func testPartialEvaporation() {
        soilMoistureTank.SM = 10
        let (_, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 0.0)
        XCTAssertEqual(evapSoil, 2.0)
    }
    
    func testOutflow() {
        soilMoistureTank.SM = 40
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 10.0)
        XCTAssertEqual(dUZ, 1.3975*10.0, accuracy: 0.1)
        XCTAssertEqual(evapSoil, 4.0)
        XCTAssertEqual(soilMoistureTank.SM, 40+10-13.975-4.0, accuracy: 0.1)
    }

    func testOutflow2() {
        soilMoistureTank.SM = 30
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 10.0)
        XCTAssertEqual(dUZ, 10.00, accuracy: 0.1)
        XCTAssertEqual(evapSoil, 4.0)
        XCTAssertEqual(soilMoistureTank.SM, 30+10-10.0-4.0, accuracy: 0.1)
        
    }
    
    func testOutflow3() {
        soilMoistureTank.SM = 20
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 10.0)
        XCTAssertEqual(dUZ, 6.49, accuracy: 0.1)
        XCTAssertEqual(evapSoil, 4.0)
        XCTAssertEqual(soilMoistureTank.SM, 20+10-6.49-4.0, accuracy: 0.1)
    }
    
    func testOutflow4() {
        soilMoistureTank.SM = 0
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: 10.0)
        XCTAssertEqual(dUZ, 1.25, accuracy: 0.1)
        XCTAssertEqual(evapSoil, 2.0)
        XCTAssertEqual(soilMoistureTank.SM, 10-1.25-2.0, accuracy: 0.1)
    }
}

