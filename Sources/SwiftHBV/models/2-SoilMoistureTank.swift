import Foundation


/*
extension ModelParameters {
    var FC = 40.0     // Field capacity (mm)
    var ET = 2.0      // Full evaporation threshold (mm)
    var beta = 1.5    // Infiltration coef.
    var epot = 4.0    // Evaporation potential (mm)
}
*/


class SoilMoistureTank {
    var cp: CatchmentParameters
    var mp: ModelParameters
    
    // State variables
    var SM = 0.0      // Soil moisture (mm)
    
    init(cp: CatchmentParameters, mp: ModelParameters) {
        self.cp = cp
        self.mp = mp
    }
    
    func resetState() {
        SM = 0.0
    }
    
    func simulateTimestepAndGetOutput(insoil: Double)
    -> (dUZ: Double, evapSoil: Double) {
        // Inputs: (mm/timestep)
        // Outputs: (mm/timestep)
            
        // Add input
        SM = SM + insoil
        
        // Calculte to upper zone
        let dUZ_ = pow(SM/mp.FC, mp.beta) * insoil
        let dUZ = min(dUZ_, SM)                 // (mm)
        
        // Calculate evaporation
        let evap_r = min(SM/mp.ET, 1.0)
        let evapSoil_ = evap_r * mp.epot               // (mm)
        let evapSoil = min(evapSoil_, SM - dUZ)
        
        // Update state
        SM = SM - dUZ - evapSoil
        
        return (dUZ, evapSoil) // (mm/timestep)
    }
}
