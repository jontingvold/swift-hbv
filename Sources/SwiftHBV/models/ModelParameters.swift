import Foundation


public class ModelParameters: Codable {
    // HBV
    var P_corr = 1.05   // Percipitation correction rain
    var S_corr = 1.15   // Percipitation correction snow
    
    // Snow tank
    var Cx = 5.0        // Melt constant (mm/°C)
    var Cfr = 3.0       // Freeze contant (mm/°C)
    var Cpro = 0.04     // Max ratio of water content in snow depth (1)
    var Tx = 0.5        // Snow/rain threshold (°C)
    var Ts = 0.5        // Melt/refreeze threshold (°C)
    
    // Soil moisture
    var FC = 40.0       // Field capacity (mm)
    var ET = 2.0        // Full evaporation threshold (mm)
    var beta = 1.5      // Infiltration coef.
    var epot = 4.0      // Evaporation potential (mm)
    
    // Upper zone
    var KUZ1 = 1.0      // Quick discharge rate (1/timestep)
    var KUZ0 = 0.1      // Slow discharge rate (1/timestep)
    var UZ1 = 10.0      // Quick discharge level (mm)
    var perc = 1.5      // Percolation (mm/timestep)
    // NB! perc is adjusted if perc > UZ
    
    // Lower zone
    var KLZ = 1.0       // Discharge rate (1/timestep)
    //epot              (already defined)
    
    
    // METHODS
    
    // Return model parameters as a vector
    func asVector() -> [Double] {
        return [
            P_corr,
            S_corr,
            Cx,
            Cfr,
            Cpro,
            Tx,
            Ts,
            FC,
            ET,
            beta,
            epot,
            KUZ1,
            KUZ0,
            UZ1,
            perc,
            KLZ
        ]
    }
    
    // Set model parameters as a vector
    public func setAsVector(vector: [Double]) {
        guard vector.count == 16 else {
            fatalError("Array does not contain 16 elements")
        }
        
        P_corr = vector[0]
        S_corr = vector[1]
        Cx = vector[2]
        Cfr = vector[3]
        Cpro = vector[4]
        Tx = vector[5]
        Ts = vector[6]
        FC = vector[7]
        ET = vector[8]
        beta = vector[9]
        epot = vector[10]
        KUZ1 = vector[11]
        KUZ0 = vector[12]
        UZ1 = vector[13]
        perc = vector[14]
        KLZ = vector[15]
    }
    
    public var description: String {
        return """
            MODEL PARAMETERS:
            
            P_corr: \(P_corr)
            S_corr: \(S_corr)
            Cx: \(Cx)
            Cfr: \(Cfr)
            Cpro: \(Cpro)
            Tx: \(Tx)
            Ts: \(Ts)
            FC: \(FC)
            ET: \(ET)
            beta: \(beta)
            epot: \(epot)
            KUZ1: \(KUZ1)
            KUZ0: \(KUZ0)
            UZ1: \(UZ1)
            perc: \(perc)
            KLZ: \(KLZ)
            """
        }
}

public class ModelParameters2: Codable {
    // HBV
    var P_corr = 1.05   // Percipitation correction rain
    var S_corr = 1.15   // Percipitation correction snow
    
    // Snow tank
    var Cx = 5.0        // Melt constant (mm/°C)
    var Cfr = 3.0       // Freeze contant (mm/°C)
    var Cpro = 0.04     // Max ratio of water content in snow depth (1)
    var Tx = 0.5        // Snow/rain threshold (°C)
    var Ts = 0.5        // Melt/refreeze threshold (°C)
    
    // Soil moisture
    var FC = 40.0       // Field capacity (mm)
    var ET = 2.0        // Full evaporation threshold (mm)
    var beta = 1.5      // Infiltration coef.
    var epot = 4.0      // Evaporation potential (mm)
    
    // Upper zone
    var KUZ1 = 1.0      // Quick discharge rate (1/timestep)
    var KUZ0 = 0.1      // Slow discharge rate (1/timestep)
    var UZ1 = 10.0      // Quick discharge level (mm)
    var perc = 1.5      // Percolation (mm/timestep)
    // NB! perc is adjusted if perc > UZ
    
    // Lower zone
    var KLZ = 1.0       // Discharge rate (1/timestep)
    //epot              (already defined)
    
    
    // METHODS
    
    // Return model parameters as a vector
    func asVector() -> [Double] {
        return [
            P_corr,
            S_corr,
            Cx,
            Cfr,
            Cpro,
            Tx,
            Ts,
            FC,
            ET,
            beta,
            epot,
            KUZ1,
            KUZ0,
            UZ1,
            perc,
            KLZ
        ]
    }
    
    // Set model parameters as a vector
    public func setAsVector(vector: [Double]) {
        guard vector.count == 16 else {
            fatalError("Array does not contain 16 elements")
        }
        
        P_corr = vector[0]
        S_corr = vector[1]
        Cx = vector[2]
        Cfr = vector[3]
        Cpro = vector[4]
        Tx = vector[5]
        Ts = vector[6]
        FC = vector[7]
        ET = vector[8]
        beta = vector[9]
        epot = vector[10]
        KUZ1 = vector[11]
        KUZ0 = vector[12]
        UZ1 = vector[13]
        perc = vector[14]
        KLZ = vector[15]
    }
    
    public var description: String {
        return """
            MODEL PARAMETERS:
            
            P_corr: \(P_corr)
            S_corr: \(S_corr)
            Cx: \(Cx)
            Cfr: \(Cfr)
            Cpro: \(Cpro)
            Tx: \(Tx)
            Ts: \(Ts)
            FC: \(FC)
            ET: \(ET)
            beta: \(beta)
            epot: \(epot)
            KUZ1: \(KUZ1)
            KUZ0: \(KUZ0)
            UZ1: \(UZ1)
            perc: \(perc)
            KLZ: \(KLZ)
            """
        }
}
