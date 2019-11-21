//
//  SimplexTests.swift
//  
//
//  Created by Jon Tingvold on 07/11/2019.
//

import XCTest
@testable import SwiftHBV


final class SimplexTests: XCTestCase {
    
    func testSimple2D() {
        /*
            Test simple convex optimalization function with optimal point x1=2,x2=4 and min_value = 2
            
            f(x1,x2) = 2 + (x1-2)**2 + (x2-4)**2
        */
        
        func f(x_vec: Vector<Double>) -> Double { return 2 + pow(x_vec[0]-2.0, 2.0) + pow(x_vec[1]-4.0, 2.0) }
        
        let searcher = SimplexSearcher(f: f, vector_size: 2, from: -10.0, to: 10.0)
        searcher.optimize(maxIterations: 100)
        
        let bestSolution = searcher.bestSolution
        let bestScore = searcher.valueBestSolution
        
        XCTAssertLessThan(bestScore, 2.1, "Global minimum = 2. Should at least be able to get lower than 2.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[0], 2.0, accuracy: 0.1, "Global minimum is at x_0 = 2. Should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[1], 4.0, accuracy: 0.1, "Global minimum is at x_1 = 4. Should at least be within ±0.1 in 100 iterations.")
    }
    
    func testSimple6D() {
        /*
            Test simple convex optimalization function with optimal point x=(1,2,7,2,-3,-4) and min_value = 2
        */
        
        let X = [2.0, 4.0, 7.0, 2.0, -3.0, -4.0]
        let globalMinimum = 2.0
        
        func f(x_vec: Vector<Double>) -> Double {
            return (
                2
                + pow(x_vec[0] - X[0], 2.0)
                + pow(x_vec[1] - X[1], 2.0)
                + pow(x_vec[2] - X[2], 2.0)
                + pow(x_vec[3] - X[3], 2.0)
                + pow(x_vec[4] - X[4], 2.0)
                + pow(x_vec[5] - X[5], 2.0)
            )
        }
        
        let searcher = SimplexSearcher(f: f, vector_size: 6, from: -10.0, to: 10.0)
        searcher.optimize(maxIterations: 100000)
        
        let bestSolution = searcher.bestSolution
        let bestScore = searcher.valueBestSolution
        
        XCTAssertLessThan(bestScore, 2.1, "Global minimum = 2. Should at least be able to get lower than 2.1 in 100 iterations.")
        
        XCTAssertEqual(bestSolution[0], X[0], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[1], X[1], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[2], X[2], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[3], X[3], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[4], X[4], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
        XCTAssertEqual(bestSolution[5], X[5], accuracy: 0.2, "Global minimum should at least be within ±0.1 in 100 iterations.")
    }
    
    func testRosenbrockFunction() {
        /*
            Non-convex function that is hard to estimate.
        
            Finding the valley is easy. Converting to the global minimum is hard.
        */
        
        let a = 1.0
        let b = 100.0
        func rosenbrock_function(x_vec: Vector<Double>) -> Double {
            return pow(a - x_vec[0], 2.0) + pow(x_vec[1] - x_vec[0], 2.0)
        }
        //let f = lambda x,y: (a-x)**2 + b*(y-x**2)**2
        
        let searcher = SimplexSearcher(f: rosenbrock_function, vector_size: 2, from: -10.0, to: 1000.0)
        searcher.optimize(maxIterations: 100)
        let bestScore1 = searcher.valueBestSolution
        XCTAssertLessThan(bestScore1, 0.1, "Should at least get lower than 0.1 in less than 100 iterations")
        
        searcher.optimize(maxIterations: 1000)
        let bestScore2 = searcher.valueBestSolution
        XCTAssertLessThan(bestScore2, 0.01, "Should at least get lower than 0.01 in less than 1000 iterations")
    }
    
    func testSorting() {
        func f(x_vec: Vector<Double>) -> Double {
            return pow(x_vec[0], 2.0) + pow(x_vec[1], 2.0)
        }
        
        let X = [
            Vector(1.0, 3.0), // y=10
            Vector(2.0, 1.0), // y=5
            Vector(1.0, 1.0)  // y=2
        ]

        let searcher = SimplexSearcher(f: f, X_inits: X)
        
        let X_correct = [X[2], X[1], X[0]]
        let Y_correct = [2.0, 5.0, 10.0]
        
        XCTAssertTrue(isAlmostEqual(searcher.X[0], X_correct[0], accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.X[1], X_correct[1], accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.X[2], X_correct[2], accuracy: 0.001))
        
        XCTAssertTrue(isAlmostEqual(searcher.Y[0], Y_correct[0], accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y[1], Y_correct[1], accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y[2], Y_correct[2], accuracy: 0.001))
        
        XCTAssertTrue(isAlmostEqual(searcher.X, X_correct, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y_correct, accuracy: 0.001))
    }
    
    func test_full_example() {
        /*
            Example from: http://www.jasoncantarella.com/downloads/NelderMeadProof.pdf
        */
        
        func f(x_vec: Vector<Double>) -> Double {
            return pow(x_vec[0], 2.0) - 4.0*x_vec[0] + pow(x_vec[1], 2.0) - x_vec[1] - (x_vec[0]*x_vec[1])
        }
        //let f = lambda x,y: x**2 - 4*x + y**2 - y - x*y
        
        let X0 = [Vector(0.0, 0.0), Vector(1.2, 0.0), Vector(0.0, 0.8)]
        //let Y0 = [0.0, -3.36, -0.16]
        
        let searcher = SimplexSearcher(f: f, X_inits: X0)
        
        // Check if sorted
        let X1 = [Vector(1.2, 0.0), Vector(0.0, 0.8), Vector(0.0, 0.0)]
        let Y1 = [-3.36, -0.16, 0.0]
        XCTAssertTrue(isAlmostEqual(searcher.X, X1, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y1, accuracy: 0.001))
        
        // FIRST ITERATION
        searcher.optimize(maxIterations: 1)
        
        let x_mean = Vector(0.6, 0.4)
        XCTAssertTrue(isAlmostEqual(searcher.x_mean!, x_mean, accuracy: 0.001))
        
        let x_r = Vector(1.2,0.8)
        let y_r = -4.48
        XCTAssertTrue(isAlmostEqual(searcher.x_r!, x_r, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.y_r!, y_r, accuracy: 0.001))
        
        // Since x_r is the best we should get expansion
        
        let x_e = Vector(1.8, 1.2)
        let y_e = -5.88
        XCTAssertTrue(isAlmostEqual(searcher.x_e!, x_e, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.y_e!, y_e, accuracy: 0.001))
        
        // New points should now be
        var X = [Vector(1.2,0.8), Vector(1.2, 0.0), Vector(0.0, 0.8)]
        var Y = [-5.88, -3.36, -0.16]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 3
        searcher.optimize(maxIterations: 2)
        X = [Vector(1.8, 1.2), Vector(3.0, 0.4), Vector(1.2, 0.0)]
        Y = [-5.88, -4.44, -3.36]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 4
        searcher.optimize(maxIterations: 3)
        X = [Vector(3.6, 1.6), Vector(1.8, 1.2), Vector(3.0, 0.4)]
        Y = [-6.24, -5.88, -4.44]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 5
        searcher.optimize(maxIterations: 4)
        X = [Vector(3.6, 1.6), Vector(2.4, 2.4), Vector(1.8, 1.2)]
        Y = [-6.24, -6.24, -5.88]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 6
        searcher.optimize(maxIterations: 5)
        X = [Vector(2.4, 1.6), Vector(3.6, 1.6), Vector(2.4, 2.4)]
        Y = [-6.72, -6.24, -6.24]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 7
        searcher.optimize(maxIterations: 6)
        X = [Vector(2.7, 2.0), Vector(2.4, 1.6), Vector(3.6, 1.6)]
        Y = [-6.91, -6.72, -6.24]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 8
        searcher.optimize(maxIterations: 7)
        X = [Vector(2.7, 2.0), Vector(3.075, 1.7), Vector(2.4, 1.6)]
        Y = [-6.91, -6.881875, -6.72]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.001))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.001))
        
        // SOLUTION 9
        searcher.optimize(maxIterations: 8)
        X = [Vector(2.70, 2.00), Vector(3.375, 2.1), Vector(3.075, 1.7)]
        Y = [-6.91, -6.886875, -6.881875]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.01))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.01))
        
        // SOLUTION 10
        searcher.optimize(maxIterations: 9)
        X = [Vector(3.0562, 1.8750), Vector(2.7, 2.0), Vector(3.375, 2.1)]
        Y = [-6.9741796874999995, -6.91, -6.8868750]
        XCTAssertTrue(isAlmostEqual(searcher.X, X, accuracy: 0.01))
        XCTAssertTrue(isAlmostEqual(searcher.Y, Y, accuracy: 0.01))
        
        // FIND SOLUTION
        searcher.optimize(maxIterations: 100)
        let x_minimum = Vector(3.0, 2.0)
        let y_minimum = -7.0
        
        let msg = "Should be able to find global minimum in 100 iterations."
        XCTAssertTrue(isAlmostEqual(searcher.bestSolution, x_minimum, accuracy: 0.01), msg)
        XCTAssertEqual(searcher.valueBestSolution, y_minimum, accuracy: 0.01, msg)
    }
}
