import Foundation


/// `OptimizableHBVModel` is a subclass of `HBVModel` that implements the `Optimizable` protocol (costFunctions etc.)
/// This makes it searchable/optimizable by `SimplexSearcher`.
class OptimizableHBVModel: HBVModel, Optimizable {
    // Omit first x values when calculation the objective, since model not reached proper internal state yet
    let omitFirstXts = 30
    // Traningset
    let trainingset: [CatchmentTimestep]
    
    var minInitSolution: Vector<Double>
    var maxInitSolution: Vector<Double>
    
    // MARK: Prestored calculations to increase performance
    
    // Observed discharge (m3/s) except for X values
    let Q_obs: [Double]
    // Mean observed discharge (m3/s) for all values except X first
    let Q_obs_mean: Double
    // Accumulated discharge (m3/s) except for X values
    let Q_obs_acc: [Double]
    // Mean accumulated discharge (m3/s) for all values except X first
    let Q_obs_acc_mean: Double
    
    public convenience init(_ cp: CatchmentParameters, trainingset: [CatchmentTimestep]) {
        self.init(cp, ModelParameters(), trainingset: trainingset)
    }
    
    init(_ cp: CatchmentParameters, _ mp: ModelParameters, trainingset: [CatchmentTimestep]) {
        self.trainingset = trainingset
        
        let mp_vec = Vector<Double>(mp.asVector())
        self.minInitSolution = mp_vec - 0.4*mp_vec
        self.maxInitSolution = mp_vec + 0.9*mp_vec
        
        // Save Q_obs and Q_obs_mean for speedup
        // Omit the first x=30 timesteps
        Q_obs = trainingset[omitFirstXts...].map {$0.Q_m3_per_s}
        Q_obs_mean = mean(Q_obs)
        Q_obs_acc = cumsum(Q_obs)
        Q_obs_acc_mean = mean(Q_obs_acc)
        
        super.init(cp, mp)
    }
    
    /// Cost function.
    /// It has two objectives:
    /// - Make observed and simulated discharge as equal as possible at any given time
    /// - Match the accumulating discharge coming out of the model as equal as possible
    func testCost(solution: Vector<Double>) -> Double {
        
        let modelParams = solution.vector
        
        let (Q_sim_, Q_sim_acc_) = resetHBVAndSimulateDischarge(modelParams: modelParams, timeSequence: trainingset)
        let Q_sim = Array(Q_sim_[omitFirstXts...])
        let Q_sim_acc = Array(Q_sim_acc_[omitFirstXts...])
        
        // R2 or Nash Sutcliffe as it is called in hydrology
        let R2_Q = R2(y_sim: Q_sim, y_obs: Q_obs, y_obs_mean: Q_obs_mean)
        
        let nae_Q_acc = normalizedAbsoluteError(y_sim: Q_sim_acc, y_obs: Q_obs_acc, y_obs_mean: Q_obs_acc_mean)
        
        let cost1 = 1.0 - R2_Q
        let cost2 = 1.0 - nae_Q_acc
        
        return 0.8*cost1 + 0.2*cost2
    }
}
