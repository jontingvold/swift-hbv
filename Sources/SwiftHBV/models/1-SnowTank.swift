

/*
extension CatchmentParameters {
    var h_obs = 500     // Elevation of weather observations (masl-meter above sea level)
    var P_grad = 0.05   // Precipitation gradient per 100 meter
    var T_dry_grad = -1.0 // Temperature gradient per 100 meter if not rain
    var T_wet_grad = -0.6 // Temperature gradient per 100 meter if rain
}


extension ModelParameters {
    var Cx = 5.0    // Melt constant (mm/°C)
    var Cfr = 3.0   // Freeze constant (mm/°C)
    var Cpro = 0.04 // Max ratio of water content in snow depth (1)
    var Tx = 0.5    // Snow/rain threshold (°C)
    var Ts = 0.5    // Melt/refreeze threshold (°C)
    
    var P_corr = 1.05 // Precipitation correction rain
    var S_corr = 1.15 // Precipitation correction snow
}
*/


class SnowTank {
    var cp: CatchmentParameters
    var mp: ModelParameters
    var h_elev: Int     // Elevation of snow tank (masl)
    
    // State variables
    var SN = 0.0    // Snow depth water equivalent (mm)
    var SW = 0.0    // Freewater in snow (mm)
    
    init(cp: CatchmentParameters, mp: ModelParameters, h_elev: Int) {
        self.cp = cp
        self.mp = mp
        self.h_elev = h_elev
    }
    
    func resetState() {
        SN = 0.0
        SW = 0.0
    }
    
    func simulateTimestepAndGetOutput(p_obs: Double, T_obs: Double) -> Double {
        // p - precipitation at elevation (mm/timestep)
        // T - temperature at elevation (°C)
        // One timestep is usually one day
        
        let T: Double
        
        // Correct temperature
        let is_raining = p_obs > 0.0
        if(is_raining) {
            T = T_obs + (cp.T_wet_grad * Double(h_elev - cp.h_obs)/100.0)
        } else {
            T = T_obs + (cp.T_dry_grad * Double(h_elev - cp.h_obs)/100.0)
        }
        
        // Correct precipitation
        let p = p_obs + (p_obs * cp.P_grad * Double(h_elev - cp.h_obs)/100.0)
        
        // Add input
        let is_snow = T < mp.Tx
        if(is_snow) {SN = SN + p} else {SW = SW + p}
        
        // Calculate melt, refreeze snow, insoil
        let insoil = max(0.0, SW - mp.Cpro*SN)                    // (mm/timestep)
        let melt = min(SN, max(0.0, mp.Cx*(T - mp.Ts) ))          // (mm/timestep)
        let refreeze = min(SW, max(0.0, mp.Cfr*(mp.Ts - T) ))     // (mm/timestep)
        
        // Update state
        SN = SN - melt + refreeze
        SW = SW - insoil + melt - refreeze
        
        return insoil // (mm/timestep)
    }
}
