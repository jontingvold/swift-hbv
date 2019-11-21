import Foundation


protocol Optimizable {
    var minInitSolution: Vector<Double> { get }
    var maxInitSolution: Vector<Double> { get }
    func testCost(solution: Vector<Double>) -> Double
}


/// ## Simplex/Nelder–Mead method
/// Optimizer that implements the Nelder–Mead method, also called the Simplex method.
/// However, this is not the simplex method that is used in linear programming.
///
/// For an optimization problem with `p`-dimensions, the NM-method creates `p+1` solutions that
/// makes up a hyper-triangle in `p`-dimensions, a so called **simplex**. The algorithm makes new solutions by going from the worst solution (highest cost) towards the direction of the
/// mid point of all other solutions (all except the worst). Each time one new solution is made, that replaces the worst solution. How far along this line the new point/solution is created, is determined by how good the solutions along this line are. If the solutions along the line are good (low cost), it creates a point further away that *expands* the "volume" of the hyper-triangle. This accelerates convergence. If the solutions along the line are less good, it creates a point closer to the mid point, or even between the mid point and worst solution. This *contracts* the volume, which decelerates convergence.
///
/// If the solutions along the line are quite bed, it thinks it has come to a narrow valley and contracts all the corners of hyper-triangle, to be able to make smaller solution steps.
///
/// For more information see [Wikipedia](https://en.wikipedia.org/wiki/Nelder–Mead_method)
///
/// This optimizer can be set up in two different ways:
/// 1. You can submit an Optimizable object to the initializer, which is than optimized. Then you specify the cost function and initial solutions by implementing the Optimizable protocol.
/// 2. You can submit a closure/function that is optimized. Then you specify the initial solutions in the initializer.
///
class SimplexSearcher {
    /// Number of iterations so far. One indexed.
    var iteration_nr = 1
    /// Number of runs so far. One indexed.
    var run_nr = 1
    /// Runs
    var totalRuns = 0
    /// The best solution so far
    var bestSolution: Vector<Double>!
    /// The value/objective/cost of the best solution
    var valueBestSolution: Double!
    /// Turns on prints of progress to the console
    var shouldPrintFeedback = false
    /// How often feedback is printed to the console
    var printFeedbackInterval = 100
    
    /// The best solutions from each run if multiple runs
    var solutions = [Vector<Double>]()
    /// The corresponding value/objective/cost
    var valueSolutions = [Double]()
    
    /// The best solutions from each iteration
    var recordOfSolutions = [Vector<Double>]()
    /// The corresponding value/objective/cost
    var valueRecordOfSolutions = [Double]()
    
    /// Current solutions in Simplex
    internal var X: [Vector<Double>]!
    /// Objective/cost-values of current solutions in Simplex
    internal var Y: [Double]!
    
    /// Objective/cost-function to evaluate solutions
    internal let f: (Vector<Double>) -> Double
    internal let p: Int
    
    internal let minInitSolution: Vector<Double>!
    internal let maxInitSolution: Vector<Double>!
    
    // MARK: Properties for debugging
    
    internal var x_mean: Vector<Double>? = nil
    internal var x_r: Vector<Double>? = nil
    internal var x_e: Vector<Double>? = nil
    internal var x_c: Vector<Double>? = nil
    internal var y_r: Double? = nil
    internal var y_e: Double? = nil
    internal var y_c: Double? = nil
    
    // MARK: Initializers
    
    public convenience init(optimizableModel: Optimizable) {
        self.init(
            f: optimizableModel.testCost,
            minInitSolution: optimizableModel.minInitSolution,
            maxInitSolution: optimizableModel.maxInitSolution
        )
    }
    
    private init(f: @escaping (Vector<Double>) -> Double, minInitSolution: Vector<Double>, maxInitSolution: Vector<Double>) {
        guard minInitSolution.dimensions == maxInitSolution.dimensions else {
            fatalError("Vectors different dimensions")
        }
        
        self.f = f
        self.p = minInitSolution.dimensions
        self.minInitSolution = minInitSolution
        self.maxInitSolution = maxInitSolution
        
        // Sets X and Y
        setRandomSolutions(minInitSolution: minInitSolution, maxInitSolution: maxInitSolution)
    }
    
    internal convenience init(f: @escaping (Vector<Double>) -> Double, vector_size: Int, from: Double, to: Double) {
        let minInitSolution = Vector<Double>([Double](repeating: from, count: vector_size))
        let maxInitSolution = Vector<Double>([Double](repeating: from, count: vector_size))
        self.init(f: f, minInitSolution: minInitSolution, maxInitSolution: maxInitSolution)
    }
    
    internal convenience init(f: @escaping (Vector<Double>) -> Double, X_base_init: Vector<Double>, spread: Double = 1.0) {
        let minInitSolution = X_base_init - spread*X_base_init
        let maxInitSolution = X_base_init + spread*X_base_init
        self.init(f: f, minInitSolution: minInitSolution, maxInitSolution: maxInitSolution)
    }
    
    /// This initializer should only be called by tester
    internal init(f: @escaping (Vector<Double>) -> Double, X_inits: [Vector<Double>]) {
        self.f = f
        self.p = X_inits[0].dimensions
        
        guard X_inits.count == p+1 else {
            fatalError("X_inits contain p+1 vector of dimension p")
        }
        
        for x in X_inits {
            guard x.dimensions == p else {
                fatalError("All vectors in X_inits must be of dimension p")
            }
        }
        
        X = X_inits
        Y = X.map { f($0) }
        // Sort
        (X, Y) = SimplexSearcher.sortXandY(X: X, Y: Y)
        
        minInitSolution = X[0]
        maxInitSolution = X[p]
    }
    
    private func setRandomSolutions(minInitSolution: Vector<Double>, maxInitSolution: Vector<Double>) {
        let X: [Vector<Double>] = (0..<p+1).map { _ in
            let x = Vector<Double>(
                (0..<p).map { i in
                    Double.random(in: minInitSolution[i]...maxInitSolution[i])
                }
            )
            return x
        }
        self.X = X
        self.Y = X.map { f($0) }
        sortXandY()
        bestSolution = X[0]
        valueBestSolution = Y[0]
    }
    
    /// Run optimizer multiple times. First time starting from a random solution, and gradually starting from solutions equal to the
    /// average of best solution from each run. This avoids extreme solutions.
    func optimizeMultipleRuns(runs: Int, maxIterationsEachRun: Int = 10000000) {
        totalRuns = runs
        
        for i in 1...runs {
            run_nr = i
            iteration_nr = 1
            
            /*
            let weightBest = Double(iteration_nr-1)/Double(runs)
            
            let meanSolution = solutions.isEmpty ? bestSolution! : mean(solutions)
            
            let newMinInitSolution = weightBest*meanSolution + (1.0-weightBest)*minInitSolution
            let newMaxInitSolution = weightBest*meanSolution + (1.0-weightBest)*maxInitSolution
             
             setRandomSolutions(minInitSolution: newMinInitSolution, maxInitSolution: newMaxInitSolution)
            */
            
            setRandomSolutions(minInitSolution: minInitSolution, maxInitSolution: maxInitSolution)
            
            optimize(maxIterations: maxIterationsEachRun)
            
            let bestSolutionFromRun = X[0]
            let valueBestSolutionFromRun = Y[0]
            
            solutions.append(bestSolutionFromRun)
            valueSolutions.append(valueBestSolutionFromRun)
            
            if valueBestSolutionFromRun < valueBestSolution {
                bestSolution = bestSolutionFromRun
                valueBestSolution = valueBestSolutionFromRun
            }
        }
    }
    
    /// Runs optimizer one run
    /// Terminates when isTerminationTime() returns true or when maxIterations is reached.
    /// Shakes up solutions by adding 5% noise every 20*(p+1) iteration
    func optimize(maxIterations: Int = 10000000) {
        printFeedback()
        while true {
            recordProgress()
            if shouldPrintFeedback && (iteration_nr % printFeedbackInterval == 0) {
                printFeedback()
            }
            
            // Check if should terminate
            if isTerminationTime() || iteration_nr >= maxIterations {
                break
            }
             
            // Add 5% noise to all solutions every 20*17=340 iteration
            let howOften = 5*(p+1)
            let noisePercent = iteration_nr <= 3*howOften ? 0.1 : 5.00/Double(iteration_nr)
            if (iteration_nr % howOften == 0) {shakeUpSolutions(addNoisePercent: noisePercent) }
            
            nextIteration()
            sortXandY()
            iteration_nr += 1
        }
        
        bestSolution = X[0]
        valueBestSolution = Y[0]
    }
    
    /// Adds X% noise to all solutions
    private func shakeUpSolutions(addNoisePercent: Double) {
        for i in 0..<(p+1) {
            for j in 0..<p {
                X[i][j] = X[i][j] + X[i][j]*Double.random(in: -1...1)*addNoisePercent
            }
            Y[i] = f(X[i])
        }
        sortXandY()
    }
    
    /// Store best solution and its cost from each iteration
    private func recordProgress() {
        let bestSolution = X[0]
        let valueBestSolution = Y[0]
        
        recordOfSolutions.append(bestSolution)
        valueRecordOfSolutions.append(valueBestSolution)
    }
    
    /// Print progress to console
    private func printFeedback() {
        let valueBestSimplexSolution = Y[p]
        if totalRuns == 0 {
            print("Iteration \(iteration_nr): \(valueBestSimplexSolution)")
        } else {
            print("Run \(run_nr) of \(totalRuns), iteration \(iteration_nr): \(valueBestSimplexSolution)")
        }
    }
    
    /// Advance solution search by one step/iteration
    private func nextIteration() {
        let best = 0
        let worst = p
        let next_worst = p-1
        
        // Mean/central point for all points except worst
        let x_mean = mean( Array(X[0..<p]) )
        self.x_mean = x_mean  // For debugging
        
        // Reflection point
        let x_r = X[worst] + 2.0*(x_mean - X[worst])
        let y_r = f(x_r)
        self.x_r = x_r  // For debugging
        self.y_r = y_r  // For debugging
        
        if(Y[best] < y_r && y_r <= Y[next_worst]) {
            // MARK: Maintain volume
            // Replace worst point with reflection point
            X[worst] = x_r
            Y[worst] = y_r
            return
        }
        
        else if(y_r < Y[best]) {
            
            // Define expansion point
            let x_e = X[worst] + 3.0*(x_mean - X[worst])
            let y_e = f(x_e)
            self.x_e = x_e  // For debugging
            self.y_e = y_e  // For debugging
            
            if(y_e < y_r) {
                // MARK: Expand volume
                // Replace worst point with expansion point
                X[worst] = x_e
                Y[worst] = y_e
                return
            } else {
                // MARK: Maintain volume
                // Replace worst point with relection point
                X[worst] = x_r
                Y[worst] = y_r
                return
            }
        
        } else {
            // Contract volume, but how much?
            
            // Reflection point should be worse than next_worst point
            assert(y_r > Y[next_worst], "Illegal state.")
    
            // Define contraction point
            let x_c = X[worst] + 0.5*(x_mean - X[worst])
            let y_c = f(x_c)
            self.x_c = x_c  // For debugging
            self.y_c = y_c  // For debugging
    
            if(y_c < Y[worst]) {
                // MARK: Normal contraction
                // Replace worst point with contraction point
                X[worst] = x_c
                Y[worst] = y_c
                return
            
            } else {
                // MARK: Shrink/Big contraction.
                // Replace all points except best with, so they are all closer to the best point (solution)
                for i in 1...worst {
                    X[i] = X[i] + 0.5*(X[best] - X[i])
                    Y[i] = f(X[i])
                    return
                }
            }
        }
    }
    
    /// Sort current solution `X` and corresponding cost/objective-values `Y` according cost/objective. Best/smallest first.
    private func sortXandY() {
        (X, Y) = SimplexSearcher.sortXandY(X: X, Y: Y)
    }
    
    /// Sort current solution `X` and corresponding cost/objective-values `Y` according cost/objective. Best/smallest first.
    private static func sortXandY(X: [Vector<Double>], Y: [Double]) -> ([Vector<Double>], [Double]) {
        let XY_zipped = Array(zip(X, Y))
        let XY_zip_sorted = XY_zipped.sorted(by: {$0.1 < $1.1})
        return unzip(XY_zip_sorted)
    }
    
    /// Check if search should terminate.
    /// Returns `true` when the standard deviation of the objectives of the last `20*p`-solutions are lo less than 0.001% of average objective.
    /// ... in other words, when there are no progress.
    ///
    /// This method does not control termination alone. Search is also terminated when maxIterations is reached.
    ///
    private func isTerminationTime() -> Bool {
        let criteriaSdPercent = 0.001
        let criteriaPercentImprovement = 0.001
        
        let lookbackIterations = 10*(p+1)
        let test_each_x_iteration = 10*(p+1)
        
        if valueRecordOfSolutions.count - lookbackIterations < 0 {
            return false
        }
        
        if iteration_nr % test_each_x_iteration != 0 {
            return false
        }
        
        let sdPercent = stDev(Y)/Y.first!
        
        let lookBackIndex = valueRecordOfSolutions.count - lookbackIterations
        let percentImprovement = 1.0 - valueRecordOfSolutions.last!/valueRecordOfSolutions[lookBackIndex]
        
        let is_termination_time = (sdPercent < criteriaSdPercent
            && percentImprovement < criteriaPercentImprovement)
        return is_termination_time
    }
}
