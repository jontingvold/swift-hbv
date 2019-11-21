import Foundation


// MARK: R2

/// Calculates R2 (or the Nash Sutcliffe as it is called in hydrology) between predicted and actual values
/// 1.0 is best, 0.0 is the trivial mean prediction. Can be negative.
func R2(y_sim: [Double], y_obs: [Double]) -> Double {
    let y_obs_mean = mean(y_obs)
    return 1 - squaredError(y_sim, y_obs) / squaredError(y_obs, y_obs_mean)
}

/// Calculates R2 (or the Nash Sutcliffe as it is called in hydrology) between predicted and actual values
/// Includes mean as a parameters to increase performance of multiple calls with the same observed values.
/// 1.0 is best, 0.0 is the trivial mean prediction. Can be negative.
func R2(y_sim: [Double], y_obs: [Double], y_obs_mean: Double) -> Double {
    return 1 - squaredError(y_sim, y_obs) / squaredError(y_obs, y_obs_mean)
}

// MARK: Normalizes absolute error (aka R-squared without the square).

/// Normalizes absolute error (aka R-squared without the square). 1.0 is best, 0.0 is the trivial mean prediction. Can be negative.
func normalizedAbsoluteError(y_sim: [Double], y_obs: [Double]) -> Double {
    return 1 - absoluteError(y_sim, y_obs) / absoluteError(y_obs, mean(y_obs))
}

/// Normalizes absolute error (aka R-squared without the square). 1.0 is best, 0.0 is the trivial mean prediction. Can be negative.
func normalizedAbsoluteError(y_sim: [Double], y_obs: [Double], y_obs_mean: Double) -> Double {
    return 1 - absoluteError(y_sim, y_obs) / absoluteError(y_obs, y_obs_mean)
}

// MARK: Squared error

/// Calculates mean squared error/difference between two arrays
func squaredError(_ array1: [Double], _ array2: [Double]) -> Double {
    return sum(pow(zip(array1, array2).map(-), 2.0))
}

/// Calculates mean squared error/difference between array and a number
func squaredError(_ array: [Double], _ num: Double) -> Double {
    return sum(pow(array - num, 2.0))
}

/// Calculates mean squared error/difference between array and a number
func squaredError(_ num: Double, _ array: [Double]) -> Double {
    return sum(pow(array - num, 2.0))
}

// MARK: Absolute error

/// Calculates mean absolute error/difference between two arrays
func absoluteError(_ array1: [Double], _ array2: [Double]) -> Double {
    return sum(abs(zip(array1, array2).map(-)))
}

/// Calculates mean absolute error/difference between array and a number
func absoluteError(_ array: [Double], _ num: Double) -> Double {
    return sum(abs(array - num))
}

/// Calculates mean absolute error/difference between array and a number
func absoluteError(_ num: Double, _ array: [Double]) -> Double {
    return sum(abs(array - num))
}

// MARK: Mean squared error

/// Calculates mean squared error/difference between two arrays
func mse(_ array1: [Double], _ array2: [Double]) -> Double {
    return mean(pow(zip(array1, array2).map(-), 2.0))
}

/// Calculates mean squared error/difference between array and a number
func mse(_ array: [Double], _ num: Double) -> Double {
    return mean(pow(array - num, 2.0))
}

/// Calculates mean squared error/difference between array and a number
func mse(_ num: Double, _ array: [Double]) -> Double {
    return mean(pow(array - num, 2.0))
}

// MARK: Mean absolute error

/// Calculates mean absolute error/difference between two arrays
func mae(_ array1: [Double], _ array2: [Double]) -> Double {
    return mean(abs(zip(array1, array2).map(-)))
}

/// Calculates mean absolute error/difference between array and a number
func mae(_ array: [Double], _ num: Double) -> Double {
    return mean(abs(array - num))
}

/// Calculates mean absolute error/difference between array and a number
func mae(_ num: Double, _ array: [Double]) -> Double {
    return mean(abs(array - num))
}

//MARK: Absolute

/// Compute absolute of an array
func abs(_ array: [Double]) -> [Double] {
    return array.map(abs)
}

