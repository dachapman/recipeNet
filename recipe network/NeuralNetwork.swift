//
//  NeuralNetwork.swift
//  recipe network
//
//  Created by Dee Chapman on 12/25/17.
//  Copyright © 2017 Dee Chapman. All rights reserved.
//

import Foundation

enum NetworkActivation {
    case sigmoid
    case relu
}

struct NeuralNetwork {
    // compute error over last 100 iterations
    var averageError = 0.0
    var averageErrorCount = 0
    
    // "weights" holds all the weight values between layers.
    var weights : [[[Double]]] = []
    
    // default value is sigmoid activation function, but can also set it to relu
    var activationType : NetworkActivation = NetworkActivation.sigmoid
    
    // learning rate controls how much "delta" impacts weight adjustments
    var learningRate : Double = 0.1
    
    // keep track of training iterations in order to write out weights after every 500th iteration
    var trainingIterationCount : Int = 0
    
    // if mini validation set is provided, this will validate every 5000 training iterations
    var miniValidation : Array<(input: Array<Double>, output: Array<Double>)>?
    
    init (layerWidth: Array<Int>) {
//        initRandomWeights(layerWidth: layerWidth)
       getWeightsArray(layerWidth: layerWidth)
    }

    // read in weights from training session
    func readWeightsString() -> String? {
        guard let weightsList = getWeightFilesSortedByMostRecent() else {
            return nil
        }
        guard let mostRecentWeights = weightsList.first else {
            return nil
        }
        
        // remove ".json" from filename
 //       let filename = String(mostRecentWeights.characters.dropLast(5))
        let filename = String(mostRecentWeights)
        if filename.range(of: "weights") != nil {
            let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            var documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
            documentsDirectoryPath = documentsDirectoryPath.appendingPathComponent("weights", isDirectory: true) as! NSURL
            
            let jsonFilePath = documentsDirectoryPath.appendingPathComponent(filename)
            
            do {
                guard let filepath = jsonFilePath else {
                    return nil
                }
                let contents = try String(contentsOfFile: filepath.absoluteString)
                return contents
            } catch {
                print("File Read Error for file \(jsonFilePath)")
                return nil
            }
        }
        return nil
    }
    
    func getWeightFilesSortedByMostRecent() -> Array<String>? {
        // get last edited weight file
        var directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        directory = directory.appendingPathComponent("weights", isDirectory: true)

        if let urlArray = try? FileManager.default.contentsOfDirectory(at: directory,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles) {
            
            return urlArray.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            
        } else {
            return nil
        }
    }
    
    mutating func getWeightsArray(layerWidth: Array<Int>) {
        var dataString = readWeightsString()
        
        if dataString != nil {
            let jsonData = dataString!.data(using: String.Encoding.utf8)
            do {
                let jsonRepresentation = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())
                if let arrayRepresentation = jsonRepresentation as? [[[Double]]] {
                    weights = arrayRepresentation
                } else {
                    initRandomWeights(layerWidth: layerWidth)
                }
            } catch let error as NSError {
                print("JSON string to recipe failed: \(error.localizedDescription)")
                initRandomWeights(layerWidth: layerWidth)
            }
        } else {
            initRandomWeights(layerWidth: layerWidth)
        }
    }
    
    
    private mutating func initRandomWeights(layerWidth: Array<Int>) {
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
    mutating func train(input: Array<Double>, desiredOutput: Array<Double>) -> Array<Double>{
        
        trainingIterationCount += 1
        
        // write out the weights every 5000 times
        if trainingIterationCount % 5000 == 0 {
            saveWeightsToFile(index: trainingIterationCount)
            if self.miniValidation != nil {
                var numCorrect = 0.0
                var totalNum = 0.0
                for example in miniValidation! {
                    let predictedIngredientToAdd = Recipe.predictIngredientToAdd(input: example.input, network:self)
                    if example.output[predictedIngredientToAdd.index] == 1.0 {
                        numCorrect += 1.0
                    }
                    totalNum += 1.0
                }
                print("mini validation accuracy: \(numCorrect / totalNum)")
            }
        }
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
        // initialize delta array which holds one delta for each activation.
        var delta: [[Double]] = []
        for layer in 0..<neuronActivation.count {
            // one delta for each neuron
            delta.append(Array(repeatElement(0.0, count: neuronActivation[layer].count)))
        }
        // compute gradient for the output using our observed error
        let lastIndexActivation = neuronActivation.count - 1
        // loop through output and determine error
        
        var avgError = 0.0
        for neuron in 0..<output.count {
            //
            let error = desiredOutput[neuron] - output[neuron]
            avgError += error
            // compute how much we want to change (delta)
            // compute delta for output layer
            delta[lastIndexActivation][neuron] = activationDerivative(number: neuronActivation[lastIndexActivation][neuron]) * error
        }
        
        self.averageError += avgError
        self.averageErrorCount += 1
        
        if trainingIterationCount % 100 == 0 {
            print("Avg Error: \(self.averageError/Double(averageErrorCount))")
            averageError = 0.0
            averageErrorCount = 0
        }

        // back propagate the rest of the deltas all the way back to our input
        // iterate over the layers backward
        for layer in (0..<weights.count).reversed() {
            for neuron in 0..<weights[layer].count {
                // sum the error for this layer using dot product
                let sum = dotProduct(array1: weights[layer][neuron], array2: delta[layer + 1])
                delta[layer][neuron] = activationDerivative(number: neuronActivation[layer][neuron]) * sum
            }
        }
        
        // update the weights
        for layer in 0..<weights.count {
            for i in 0..<weights[layer].count {
                for j in 0..<weights[layer][i].count {
                    let multActDelta = neuronActivation[layer][i] * delta[layer + 1][j]
                    weights[layer][i][j] += (learningRate * multActDelta)
                }
            }
        }
        return output
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
    
    func dotProduct(array1: Array<Double>, array2: Array<Double>) -> Double {
        // check that array1 is the same size as array2
        guard array1.count == array2.count else {
            print("array1 (size \(array1.count)) is not the same size as array2 (\(array2.count))")
            return -1.0
        }
        return zip(array1, array2).map(*).reduce(0, +)
    }
    
    // write weights array to a file for possible future use
    // create a "weights" directory in your Documents folder for store these weights
    func saveWeightsToFile(index: Int) {
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let filename = "weights/weights_\(index).json"
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(filename)
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
            if created {
                print("File created \(String(describing: jsonFilePath)) ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists: \(String(describing: jsonFilePath))")
        }
        
        // creating JSON out of the above array
        var jsonData: Data!
        do {
            jsonData = try JSONSerialization.data(withJSONObject: weights as NSArray, options: JSONSerialization.WritingOptions());
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath!)
            file.write(jsonData)
            print("JSON data was written to the file successfully! \(String(describing: jsonFilePath))")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
}
