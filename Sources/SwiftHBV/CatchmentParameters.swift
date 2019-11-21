import Foundation
import Yams


/// CatchmentParameters contain catchment characteristics needed for the HBV-model.
/// The parameters are usually set with a YAML file, by
///
///     let filepath = URL(fileURLWithPath: "file.yaml")
///     let catchmentParams = CatchmentParameters.fromYAML(path: filepath)
///
public class CatchmentParameters: Codable {
    
    var catchmentArea: Double    // (km^2)
    var seconds_per_timestep: Int
    var h_obs: Int               // Elevation of weather observations (masl)
    
    var H_min: Int               // Lowest elevation in catchment
    var H_10: Int                // 10-percentile elevation in catchment
    var H_20: Int                // 20-percentile elevation in catchment
    var H_30: Int                // 30-percentile elevation in catchment
    var H_40: Int                // 40-percentile elevation in catchment
    var H_50: Int                // 50-percentile elevation in catchment
    var H_60: Int                // 60-percentile elevation in catchment
    var H_70: Int                // 70-percentile elevation in catchment
    var H_80: Int                // 80-percentile elevation in catchment
    var H_90: Int                // 90-percentile elevation in catchment
    var H_max: Int               // Highest elevation in catchment
    
    // Snow tank
    var P_grad: Double           // Precipitation gradient per 100 meter
    var T_dry_grad: Double       // Temperature gradient per 100 meter if not rain
    var T_wet_grad: Double       // Temperature gradient per 100 meter if rain
    
    // Lower zone
    var lake_percentage: Double  // Percent land which is lakes
    
    var h_snow_levels: [Int] {
        return [H_min, H_10, H_20, H_30, H_40, H_50, H_60, H_70, H_80, H_90, H_max]
    }
    
    static func fromYAML(path: URL) -> CatchmentParameters {
        let decoder = YAMLDecoder()
        let yamlString = readFileContent(path: path)
        let catchmentParams = try! decoder.decode(CatchmentParameters.self, from: yamlString)
        return catchmentParams
    }
    
    init(
        catchmentArea: Double,    // (km^2)
        seconds_per_timestep: Int,
        h_obs: Int,               // Elevation of weather observations (masl)
        
        H_min: Int,               // Lowest elevation in catchment
        H_10: Int,                // 10-percentile elevation in catchment
        H_20: Int,                // 20-percentile elevation in catchment
        H_30: Int,                // 30-percentile elevation in catchment
        H_40: Int,                // 40-percentile elevation in catchment
        H_50: Int,                // 50-percentile elevation in catchment
        H_60: Int,                // 60-percentile elevation in catchment
        H_70: Int,                // 70-percentile elevation in catchment
        H_80: Int,                // 80-percentile elevation in catchment
        H_90: Int,                // 90-percentile elevation in catchment
        H_max: Int,               // Highest elevation in catchment
        
        // Snow tank
        P_grad: Double,           // Precipitation gradient per 100 meter
        T_dry_grad: Double,       // Temperature gradient per 100 meter if not rain
        T_wet_grad: Double,       // Temperature gradient per 100 meter if rain
        
        // Lower zone
        lake_percentage: Double  // Percent land which is lakes
    ) {
        self.catchmentArea = catchmentArea
        self.seconds_per_timestep = seconds_per_timestep
        self.h_obs = h_obs
        
        self.H_min = H_min
        self.H_10 = H_10
        self.H_20 = H_20
        self.H_30 = H_30
        self.H_40 = H_40
        self.H_50 = H_50
        self.H_60 = H_60
        self.H_70 = H_70
        self.H_80 = H_80
        self.H_90 = H_90
        self.H_max = H_max
        
        // Snow tank
        self.P_grad = P_grad
        self.T_dry_grad = T_dry_grad
        self.T_wet_grad = T_wet_grad
        
        // Lower zone
        self.lake_percentage = lake_percentage
    }
    
    /// Example from one catchment. Used for instance by tests.
    public static func getExample() -> CatchmentParameters {
        return CatchmentParameters(
            catchmentArea: 3059.5,
            seconds_per_timestep: 86400,
            h_obs: 738,
            H_min: 57,
            H_10: 445,
            H_20: 539,
            H_30: 601,
            H_40: 666,
            H_50: 739,
            H_60: 815,
            H_70: 880,
            H_80: 947,
            H_90: 1020,
            H_max: 1325,
            P_grad: 0.05,
            T_dry_grad: -1.0,
            T_wet_grad: -0.6,
            lake_percentage: 0.00
        )
    }
}
