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
    
    // "weights" holds all the weight values between layers.
    var weights : [[[Double]]] = []
    
    // default value is sigmoid activation function, but can also set it to relu
    var activationType : NetworkActivation = NetworkActivation.sigmoid
    
    init (layerWidth: Array<Int>) {
        initRandomWeights(layerWidth: layerWidth)
    }
    
    func initRandomWeights(layerWidth: Array<Int>) {
        for layer in 0..<(layerWidth.endIndex - 1) {
            let nextLayerWidth = layerWidth[layer + 1]
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
    
    // try inference, figure out direction of error, update weights to move closer to correct answer
    // returns actual output
    func train(input: Array<Double>, desiredOutput: Array<Double>) -> Array<Double>{
        // check that input is the same size as the first layer of our network
        guard input.count == weights.first?.count else {
            print("Input (size \(input.count)) is not the same size as first layer of network (\(weights.first?.count))")
            return []
        }
        // forward propagation (inference)
        var neuronActivation: [[Double]] = inference(input: input)
        // make sure inference worked
        guard let output = neuronActivation.last else {
            print("inference failed to produce output")
            return []
        }
        // initialize delta array which holds one delta for each activation
        var delta: [[Double]] = []
        for layer in 0..<neuronActivation.count {
            // one delta for each neuron
            delta.append(Array(repeatElement(0.0, count: neuronActivation[layer].count)))
        }
        // compute gradient for the output using our observed error
        let lastIndexActivation = neuronActivation.count - 1
        // loop through output and determine error
        for neuron in 0..<output.count {
            //
            let error = desiredOutput[neuron] - output[neuron]
            // compute how much we want to change
            
        }
    }
    
    // returns output from network (all ingredients in a complete recipe)
    func predict(input: Array<Double>) -> Array<Double> {
        // check that input is the same size as the first layer of our network
        guard input.count == weights.first?.count else {
            print("Input (size \(input.count)) is not the same size as first layer of network (\(weights.first?.count))")
            return []
        }
        // output will be the last layer of the network activation values
        // "guard" handles a failure on inference to produce output
        guard let output = inference(input: input).last else {
            print("inference failed to produce output")
            return []
        }
        return output
    }
    
    // run input through network and return output, which will be a 2d array of activations (0.0-1.0) of each neuron
    func inference(input: Array<Double>) -> Array<Array<Double>> {
        var neuronActivation: [[Double]] = []
        // first layer is always the input we are given
        neuronActivation.append(input)
        for layer in 0..<weights.count {
            let numberNeuronsInNextLayerWidth = weights[layer][0].count
            // initialize activations to 0.0 for next layer neurons
            neuronActivation.append(Array(repeatElement(0.0, count: numberNeuronsInNextLayerWidth)))
            // calculate the new activations
            for i in 0..<weights[layer].count {
                // iterate over next layer
                for j in 0..<weights[layer][i].count {
                    // accumulate the activations from all inbound previous layer activations * weights
                    neuronActivation[layer+1][j] += (weights[layer][i][j] * neuronActivation[layer][i])
                }
            }
            // use activation function as our nonlinearity to force neuronActivations to be between 0.0 - 1.0
            // on our layer + 1 (type of activation is defined by NetworkActivation enum (sigmoid or relu)
            neuronActivation[layer + 1] = neuronActivation[layer + 1].map({activation(number: $0)})
        }
        return neuronActivation
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
