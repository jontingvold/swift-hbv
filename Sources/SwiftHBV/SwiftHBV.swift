import Foundation


public enum Dataset {
    case Trainingset
    case Validationset
    
    public var name: String {
        get { return String(describing: self) }
    }
}

/// `CatchmentTimestep` is a tuple that can store one timestep, or row, from the trainingset and validationset dataset.
public typealias CatchmentTimestep = (
    datetime: String,
    percepation_mm_per_timestep: Double,
    temp: Double,
    Q_m3_per_s: Double
)

/// `SimulatedCatchmentTimestep` is similar to `CatchmentTimestep` except that it also includes a simulated discharge `Q_sim`.
public typealias SimulatedCatchmentTimestep = (
    datetime: String,
    percepation_mm_per_timestep: Double,
    temp: Double,
    Q_observed: Double,
    Q_simulated: Double
)

/// `HBV` is an interface to the HBV package. It takes care of common tasks like initialize models, format results and export results and simulated data to files.
public class SwiftHBV {
    let trainingset: [CatchmentTimestep]
    let validationset: [CatchmentTimestep]
    
    let optimizableHBVModel: OptimizableHBVModel
    var searcher: SimplexSearcher
    
    // MARK: Initializers
    
    public convenience init?(trainingsetFilepath: URL, validationsetFilepath: URL, catchmentParamsYamlFilepath: URL) {
        
        let catchmentParams = CatchmentParameters.fromYAML(path: catchmentParamsYamlFilepath)
        
        self.init(
            trainingsetFilepath: trainingsetFilepath,
            validationsetFilepath: validationsetFilepath,
            catchmentParams: catchmentParams
        )
    }
    
    public convenience init?(trainingsetFilepath: URL, validationsetFilepath: URL, catchmentParams: CatchmentParameters) {
        let trainingset = try! parseCatchmentData(csv: readFileContent(path: trainingsetFilepath))
        let validationset = try! parseCatchmentData(csv: readFileContent(path: validationsetFilepath))
        
        self.init(trainingset: trainingset, validationset: validationset, catchmentParams: catchmentParams)
    }
    
    public init(trainingset: [CatchmentTimestep], validationset: [CatchmentTimestep], catchmentParams: CatchmentParameters) {
        self.trainingset = trainingset
        self.validationset = validationset
        
        self.optimizableHBVModel = OptimizableHBVModel(catchmentParams, trainingset: trainingset)
        self.searcher = SimplexSearcher(optimizableModel: optimizableHBVModel)
    }
    
    // MARK: Public methods
    
    /// Run optimalization. This takes time. Optimalization ends when the last 180 iterations have a standard deviation of the cost function is less than 0.001% of their average value. See SimplexSearcher.isTerminationTime() for more info.
    public func optimize(runs: Int, maxIterationsEachRun: Int, shouldPrintFeedback: Bool, printFeedbackInterval: Int) {
        searcher.shouldPrintFeedback = shouldPrintFeedback
        searcher.printFeedbackInterval = printFeedbackInterval
        searcher.optimizeMultipleRuns(runs: runs, maxIterationsEachRun: maxIterationsEachRun)
    }
    
    /// Returns dataset, ether training- or validationset based on input
    public func getDataset(_ dataset: Dataset) -> [CatchmentTimestep] {
        switch dataset {
        case .Trainingset:
            return trainingset
        case .Validationset:
            return validationset
        }
        fatalError("Illegal state")
    }
    
    /// Returns results from both training- and validationset and best model parameters
    public func getResults() -> String {
        let mp = ModelParameters(); mp.setAsVector(vector: searcher.bestSolution!.vector)
        
        let trainingsetResults = getResults(dataset: .Trainingset)
        let validationsetResults = getResults(dataset: .Validationset)
        
        var s = trainingsetResults
        s += "\n\n\n"
        s += validationsetResults
        s += "\n\n\n"
        s += mp.description
        
        return s
    }
    
    /// Writes results from both training- and validationset and best model parameters to readable plain text file.
    public func saveResults(filepath: URL) {
        writeFileContent(path: filepath, fileContent: getResults())
    }
    
    /// Returns results from either training- or validationset
    private func getResults(dataset: Dataset) -> String {
        let name = dataset.name
        let timeseries = getDataset(dataset)
        
        let (Q_sim, Q_sim_acc) = optimizableHBVModel.resetHBVAndSimulateDischarge(
            modelParams: searcher.bestSolution.vector,
            timeSequence: timeseries
        )
        
        let Q_obs = timeseries.map {$0.Q_m3_per_s}
        let Q_obs_acc = cumsum(timeseries.map {$0.Q_m3_per_s})
        
        let Q_sim_acc_mm = Q_sim_acc.map { optimizableHBVModel.convertToQ_mm_per_timestep(Q_m3_per_s: $0) }
        let Q_obs_acc_mm = Q_obs_acc.map { optimizableHBVModel.convertToQ_mm_per_timestep(Q_m3_per_s: $0) }
        
        let r2 = R2(y_sim: Q_sim, y_obs: Q_obs)
        let normAccAbsError = normalizedAbsoluteError(y_sim: Q_sim_acc_mm, y_obs: Q_obs_acc_mm)
        let waterInModel = optimizableHBVModel.accumulatedWaterIn - optimizableHBVModel.accumulatedWaterOut
            
        return  """
            RESULTS: \(name)
            Nash-Sutcliffe/R2: \(r2)
            
            Observed accumulated discharge: \(Q_obs_acc_mm.last!) mm
            Simulated accumulated discharge: \(Q_sim_acc_mm.last!) mm
            Normalized acc absolute error: \(normAccAbsError)
            Water in still in model: \(waterInModel) mm
            """
    }
       
    /// Returns timeseries of simulated discharge `Q_sim`, `Q_obs`, datetime, temperature and precipitation.
    func getSimulationData(dataset: Dataset) -> [SimulatedCatchmentTimestep] {
        let timeseries = getDataset(dataset)
        
        let (Q_sim, _) = optimizableHBVModel.resetHBVAndSimulateDischarge(
            modelParams: searcher.bestSolution.vector,
            timeSequence: timeseries
        )
        
        let simulatedTimeseries: [SimulatedCatchmentTimestep] = zip(timeseries, Q_sim).map { return (
            datetime: $0.datetime,
            percepation_mm_per_timestep: $0.percepation_mm_per_timestep,
            temp: $0.temp,
            Q_observed: $0.Q_m3_per_s,
            Q_simulated: $1
        )}
        
        return simulatedTimeseries
    }
    
    /// Writes timeseries of simulated discharge `Q_sim`, `Q_obs`, datetime, temperature and precipitation to CSV file.
    public func saveSimulationData(filepath: URL, dataset: Dataset) {
        let simulatedTimeseries = getSimulationData(dataset: dataset)
        let arrayOfStringArrays = simulatedTimeseries.map {
            return [
                String($0.datetime),
                String($0.percepation_mm_per_timestep),
                String($0.temp),
                String($0.Q_observed),
                String($0.Q_simulated)
            ]
        }
        
        let headers = ["Datetime", "Percepation (mm)", "Temperatur (C)", "Observed discharge (m3/s)", "Simulated discharge (m3/s)"]
        let csv = makeCSV(arrayOfStringArrays: arrayOfStringArrays, headers: headers)
        writeFileContent(path: filepath, fileContent: csv)
    }
}
