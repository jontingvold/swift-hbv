

/// Full HBV-model. Includes and updates all underlying tanks:
///
/// - 10 snow tanks (for different elevation levels)
/// - Soil moisture tank
/// - Upper zone tank
/// - Lower zone tank
///
/// Because of performance issues it is encouraged to reuse the model for different time series and different model parameters.
/// Creating new instances takes a lot of time if you do it a lot.

public class HBVModel {
    var cp: CatchmentParameters
    var mp: ModelParameters
    
    var snowTanks: [SnowTank]
    var soilMoistureTank: SoilMoistureTank
    var upperZoneTank: UpperZoneTank
    var lowerZoneTank: LowerZoneTank
    
    var accumulatedWaterIn = 0.0    // mm, after correction
    var accumulatedWaterOut = 0.0   // mm
    
    // MARK: Allocations for performance reasons
    /// Allocation of array of simulated discharges to speed up performance
    private var Qs = [Double]()
    /// Allocation of array of simulated accumulated discharges to speed up performance
    private var Qs_acc = [Double]()
    
    public convenience init(_ cp: CatchmentParameters) {
        self.init(cp, ModelParameters())
    }
    
    public init(_ cp: CatchmentParameters, _ mp: ModelParameters) {
        self.cp = cp
        self.mp = mp
        
        // Calculate elevations
        var elevations = [Int]()
        
        for i in 1..<cp.h_snow_levels.count {
            let mean_elev = Int(Double(cp.h_snow_levels[i-1] +   cp.h_snow_levels[i]) / 2.0)
            elevations.append(mean_elev)
        }
        
        snowTanks = [SnowTank]()
        for elevation in elevations {
            let snowTank = SnowTank(cp: cp, mp: mp, h_elev: elevation)
            snowTanks.append(snowTank)
        }
        
        soilMoistureTank = SoilMoistureTank(cp: cp, mp: mp)
        upperZoneTank = UpperZoneTank(cp: cp, mp: mp)
        lowerZoneTank = LowerZoneTank(cp: cp, mp: mp)
    }
    
    public func setNewModelParameters(_ modelParam: ModelParameters) {
        mp = modelParam
    }
    
    public func setNewModelParameters(_ modelParam: Vector<Double>) {
        mp.setAsVector(vector: modelParam.vector)
    }
    
    public func setNewModelParameters(_ modelParam: [Double]) {
        mp.setAsVector(vector: modelParam)
    }
    
    /// Resets all the state, e.g. the water level, of all tanks.
    public func resetState() {
        for snowTank in snowTanks { snowTank.resetState() }
        soilMoistureTank.resetState()
        upperZoneTank.resetState()
        lowerZoneTank.resetState()
        
        accumulatedWaterIn = 0.0
        accumulatedWaterOut = 0.0
    }
    
    
    /// Takes in perception and temperature, simulates a time-step and returns the discharge `Q_sim`
    /// Remember to call resetState() if you start on a new time-serie.
    public func simulateTimestepAndGetDischarge(p_obs: Double, T_obs: Double) -> Double {
        
        let p: Double
        
        // Correct observed temperature and precipitation
        let T = T_obs
        
        let is_snow = T < mp.Tx
        if(is_snow) {
            p = p_obs * mp.S_corr
        } else {
            p = p_obs * mp.P_corr
        }
        
        accumulatedWaterIn += p
        
        // Snow tank
        let insoils: [Double] = snowTanks.map {
            (snowTank: SnowTank) -> Double in
            
            let insoil_e = snowTank.simulateTimestepAndGetOutput(p_obs: p, T_obs: T)
            return insoil_e
        }
        
        let insoil = mean(insoils)
        
        // Soil moisture tank
        let (dUZ, evapSoil) = soilMoistureTank.simulateTimestepAndGetOutput(insoil: insoil)
        
        // UpperZone tank
        let (perc, Q1, Q0) = upperZoneTank.simulateTimestepAndGetOutput(dUZ: dUZ)
        
        // LowerZone tank
        let (Q_lz, evapLake) = lowerZoneTank.simulateTimestepAndGetOutput(p: p, perc: perc)
        
        // Calculate outputs
        let Q_mm_per_timestep = Q1 + Q0 + Q_lz
        let evap_mm_per_timestep = evapSoil + evapLake
        
        accumulatedWaterOut += Q_mm_per_timestep + evap_mm_per_timestep
        
        let Q_m3_per_s = convertToQ_m3_per_s(Q_mm_per_timestep: Q_mm_per_timestep)
        
        return Q_m3_per_s
    }
    
    /// Simulates a run from the timeSequence provided and returns `Q_sim` and `Q_sim_acc` from the run.
    /// NB! This sets new model parameters and resets all states (water level in the tanks).
    public func resetHBVAndSimulateDischarge(modelParams: [Double], timeSequence: [CatchmentTimestep]) -> ([Double], [Double]) {
        setNewModelParameters(modelParams)
        resetState()
    
        let sequenceLength = timeSequence.count
        if Qs.count != timeSequence.count { Qs = [Double](repeating: 0.0, count: sequenceLength) }
        if Qs_acc.count != timeSequence.count { Qs_acc = [Double](repeating: 0.0, count: sequenceLength) }
        
        var Q_acc = 0.0
        for i in 0..<sequenceLength {
            let timestep = timeSequence[i]
            let Q = simulateTimestepAndGetDischarge(p_obs: timestep.percepation_mm_per_timestep, T_obs: timestep.temp)
            Qs[i] = Q
            Q_acc = Q_acc + Q
            Qs_acc[i] = Q_acc
        }
        
        return (Qs, Qs_acc)
    }
    
    public func convertToQ_mm_per_timestep(Q_m3_per_s: Double) -> Double {
        let Q_mm_per_timestep = Q_m3_per_s / cp.catchmentArea / 1000.0 * Double(cp.seconds_per_timestep)
        return Q_mm_per_timestep
    }
    
    public func convertToQ_m3_per_s(Q_mm_per_timestep: Double) -> Double {
        let Q_m3_per_s = Q_mm_per_timestep * cp.catchmentArea * 1000.0 / Double(cp.seconds_per_timestep)
        return Q_m3_per_s
    }
}
