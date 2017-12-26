//
//  NeuralNetwork.swift
//  recipe network
//
//  Created by Dee Chapman on 12/25/17.
//  Copyright © 2017 Bri. All rights reserved.
//

import Foundation

enum NetworkActivation {
    case sigmoid
    case relu
}

class NeuralNetwork: NSObject {
    
    var weights : [[[Double]]] = []
    
    // default value is sigmoid activation function, but can also set it to relu
    var activationType : NetworkActivation = NetworkActivation.sigmoid
    
    init (layerWidth: Array<Int>) {
        initRandomWeights(layerWidth: layerWidth)
    }
    
    func initRandomWeights(layerWidth: Array<Int>) {
        for layer in 0..<(layerWidth.endIndex - 1) {
            var nextLayerWidth = layerWidth[layer + 1]
            var layerWeights : [[Double]] = []
            // create random weights for each layer
            for _ in 0..<layerWidth[layer] {
                var randomLayerWeights : [Double] = []
                
                // construct the weights
                for _ in 0..<nextLayerWidth {
                    let randomInt = self.makeRandomValue(range: -10000..<10000)
                    randomLayerWeights.append(Double(randomInt) / 10000.0)
                }
                layerWeights.append(randomLayerWeights)
            }
            self.weights.append(layerWeights)
        }
    }
    
    func train() {
        
    }
    
    func predict() {
        
    }
    
    func inference() {
        
    }
    
    func activation(number: Double) -> Double {
        switch self.activationType {
        case .sigmoid:
            return sigmoid(number: number)
        case .relu:
            return relu(number: number)
        }
        
    }
    
    func activationDerivative(number: Double) -> Double {
        switch self.activationType {
        case .sigmoid:
            return sigmoidDerivative(number: number)
        case .relu:
            return reluDerivative(number: number)
        }
    }
    
    func sigmoid(number: Double) -> Double {
        return 1.0 / (1.0 + exp(-number))
    }
    
    func sigmoidDerivative(number: Double) -> Double {
        let sigX = sigmoid(number:number)
        return sigX * (1.0 - sigX)
    }
    
    func relu(number: Double) -> Double {
        if number <= 0.0 {
            return 0.0
        }
        else {
            return number
        }
    }
    
    func reluDerivative(number: Double) -> Double {
        if number <= 0.0 {
            return 0.0
        }
        else {
            return 1.0
        }

    }
    
    func makeRandomValue(range:Range<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
    }
}
