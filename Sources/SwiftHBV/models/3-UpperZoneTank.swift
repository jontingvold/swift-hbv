

/*
extension ModelParameters {
    var KUZ1 = 1.0   // Quick discharge rate (1/timestep)
    var KUZ0 = 1.0   // Slow discharge rate (1/timestep)
    var UZ1 = 1.0    // Quick discharge level (mm)
    var perc = 1.5   // Percolation (mm/timestep)
                     // perc is adjusted if perc > UZ
}
*/
 

class UpperZoneTank {
    var cp: CatchmentParameters
    var mp: ModelParameters
    
    // State variables
    var UZ = 0.0      // Upper zone level (mm)
    
    init(cp: CatchmentParameters, mp: ModelParameters) {
        self.cp = cp
        self.mp = mp
    }
    
    func resetState() {
        UZ = 0.0
    }
    
    func simulateTimestepAndGetOutput(dUZ: Double)
    -> (perc: Double, Q1: Double, Q0: Double) {
        // Inputs: (mm/timestep)
        // Outputs: (mm/timestep)
        // dUZ = percepitation if no snow
        
        // Add input
        UZ = UZ + dUZ
        
        // Calculate output
        let Q1 = mp.KUZ1 * max(0.0, UZ - mp.UZ1)
        let Q0 = mp.KUZ0 * min(mp.UZ1, UZ)
        
        // Update state
        UZ = UZ - Q1 - Q0
        
        if (mp.perc > UZ) {
            // Adjust model parameter perc!
            mp.perc = UZ
        }
        
        UZ = UZ - mp.perc
        
        return (mp.perc, Q1, Q0) // (mm/timestep)
    }
}
