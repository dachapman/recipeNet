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
    
    // default value is sigmoid activation function, but can also set it to relu
    var activationType : NetworkActivation = NetworkActivation.sigmoid
    
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
}
