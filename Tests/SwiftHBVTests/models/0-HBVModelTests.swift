import XCTest
@testable import SwiftHBV


final class HBVModelTests: XCTestCase {
    var hbvModel: HBVModel!

    func testInit() {
        //let cp = ConfigurationParameters()
        //let mp = ModelParameters()
        
        hbvModel = HBVModel(CatchmentParameters.getExample(), ModelParameters())
    }
}
