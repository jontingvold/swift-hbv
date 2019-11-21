import XCTest
@testable import SwiftHBV


final class SnowTankTests: XCTestCase {
    var cp = CatchmentParameters.getExample()
    var mp = ModelParameters()
    var snowTank: SnowTank!
    
    override func setUp() {
        cp.h_obs = 0
        cp.P_grad = 0.05
        cp.T_dry_grad = -1.0
        cp.T_wet_grad = -0.6
        
        mp.Cx = 5.0
        mp.Cfr = 3.0
        mp.Cpro = 0.04
        mp.Tx = 0.5
        mp.Ts = 0.5
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 0)
        
        super.setUp()
    }
    
    func testAllRain() {
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 100)
        let insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 10.0, T_obs: 10.0)
        
        XCTAssertEqual(insoil, 10.0*1.05)
    }
    
    func testAllSnowAtElevation() {
        var insoil: Double
        
        // 6 degrees colder at elevation than observation place
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 1000)
        
        insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 7.0, T_obs: 4.0)
        
        XCTAssertEqual(insoil, 0)
        XCTAssertEqual(snowTank!.SN, 7.0*(1+0.05*10.0))
    }
    
    func testAllRainOnSnow() {
        var insoil: Double
        
        snowTank!.SN = 100.0
        snowTank!.SW = 0.0
        
        insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 20.0, T_obs: 4.5)
        
        XCTAssertEqual(insoil, 16.0)
        XCTAssertEqual(snowTank!.SN, 100.0-20.0)
        XCTAssertEqual(snowTank!.SW, 20.0+4.0)
    }
    
    func testMelting() {
        var insoil: Double
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 0)
        snowTank.SN = 100.0
        
        insoil = snowTank!.simulateTimestepAndGetOutput(p_obs: 0.0, T_obs: 10.5)
        
        XCTAssertEqual(insoil, 0)
        XCTAssertEqual(snowTank!.SN, 100.0 - 5.0*10.0)
        XCTAssertEqual(snowTank!.SW, 5.0*10.0)
    }
    
    func testRefreeze() {
        var insoil: Double
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 0)
        snowTank.SN = 100.0
        snowTank.SW = 4.0
        
        insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 0.0, T_obs: -0.5)
        
        // Should freeze 3 mm of 4 mm
        
        XCTAssertEqual(insoil, 0)
        XCTAssertEqual(snowTank!.SN, 100.0 + 3.0)
        XCTAssertEqual(snowTank!.SW, 1.0)
    }
    
    func testRefreezeLimited() {
        var insoil: Double
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 0)
        snowTank.SN = 100.0
        snowTank.SW = 4.0
        
        // Should freeze 30 mm, but have only 4 available
        insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 0.0, T_obs: -9.5)
        
        XCTAssertEqual(insoil, 0)
        XCTAssertEqual(snowTank.SN, 100.0 + 4.0)
        XCTAssertEqual(snowTank.SW, 0.0)
    }
    
    func testRainingMelt() {
        var insoil: Double
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 1000)
        snowTank.SN = 100.0
        snowTank.SW = 4.0
        
        // Because of rain, T_elev is 4 C_deg
        insoil = snowTank.simulateTimestepAndGetOutput(p_obs: 1.0, T_obs: 10.5)
        
        // Melt 5*4 mm
        
        XCTAssertEqual(insoil, 1.5)
        XCTAssertEqual(snowTank.SN, 100.0 - 20.0)
        XCTAssertEqual(snowTank.SW, 20.0 + 4.0)
    }
    
    func testNotRainingMelting() {
        var insoil: Double
        
        snowTank = SnowTank(cp: cp, mp: mp, h_elev: 1000)
        snowTank!.SN = 100.0
        snowTank!.SW = 4.5
        
        // Without rain, T_elev is 1.5 C_deg
        insoil = snowTank!.simulateTimestepAndGetOutput(p_obs: 0.0, T_obs: 11.5)
        
        // Melt 1*5 mm
        
        XCTAssertEqual(insoil, 0.5)
        XCTAssertEqual(snowTank!.SN, 100.0 - 5.0)
        XCTAssertEqual(snowTank!.SW, 4.5 - 0.5 + 5.0)
    }
    
    /*
    func testPerformanceExample() {
       // This is an example of a performance test case.
       self.measure {
          // Put the code you want to measure the time of here.
       }
    }
    */
}

