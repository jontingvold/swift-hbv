import Foundation
import SwiftHBV


let root = "/Users/jont/Google Drive/Kode/Github/HBV/example-Hagabru/"

// FILE-PATHS

let trainingsetFilepath = URL(fileURLWithPath: root + "data/Prepared-trainingset.csv")
let validationsetFilepath = URL(fileURLWithPath: root + "data/Prepared-validationset.csv")

let resultsFilepath = URL(fileURLWithPath: root + "outputs/Results.txt")
let trainingsetSimDataFilepath = URL(fileURLWithPath: root + "outputs/Testset-output.csv")
let validationsetSimDataFilepath = URL(fileURLWithPath: root + "outputs/Validationset-output.csv")

let catchmentParamsYamlFilepath = URL(fileURLWithPath: root + "data/CatchmentParameters.yaml")


let swiftHBV = SwiftHBV(
    trainingsetFilepath: trainingsetFilepath,
    validationsetFilepath: validationsetFilepath,
    catchmentParamsYamlFilepath: catchmentParamsYamlFilepath
)!

// RUN OPTIMALIZATION.
// Optimized with the Nelder–Mead method

swiftHBV.optimize(runs: 1, maxIterationsEachRun: 1500, shouldPrintFeedback: true, printFeedbackInterval: 50)

// PRINT RESULTS

print(swiftHBV.getResults())

// SAVE RESULTS

swiftHBV.saveResults(filepath: resultsFilepath)
swiftHBV.saveSimulationData(filepath: trainingsetSimDataFilepath, dataset: .Trainingset)
swiftHBV.saveSimulationData(filepath: validationsetSimDataFilepath, dataset: .Validationset)
