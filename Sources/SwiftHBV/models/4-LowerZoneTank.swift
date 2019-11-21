

/*
extension CatchmentParameters {
    var lake_ratio = 0.02   // Ratio of land which is lakes
}


extension ModelParameters {
    var KLZ = 1.0   // Discharge rate (1/timestep)
    // Epot (already defined in soilMoisture)
}
*/


class LowerZoneTank {
    var cp: CatchmentParameters
    var mp: ModelParameters
    
    // State variables
    var LZ = 0.0      // Lower zone (mm)
    
    init(cp: CatchmentParameters, mp: ModelParameters) {
        self.cp = cp
        self.mp = mp
    }
    
    func resetState() {
        LZ = 0.0
    }
    
    func simulateTimestepAndGetOutput(p: Double, perc: Double)
    -> (Q_lz: Double, evapLake: Double) {
        // Inputs: (mm/timestep)
        // Outputs: (mm/timestep)
        
        let pLake = p * cp.lake_percentage/100.0
        let evapLake = cp.lake_percentage/100.0 * mp.epot
        
        // Add input
        LZ = LZ + pLake + perc
        
        // Calculate output
        let Q_lz = mp.KLZ * LZ
        
        // Update state
        LZ = LZ - Q_lz - evapLake
        
        return (Q_lz, evapLake)   // (mm/timestep)
    }
}
