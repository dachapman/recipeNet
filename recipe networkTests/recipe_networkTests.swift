//
//  recipe_networkTests.swift
//  recipe networkTests
//
//  Created by Dee Chapman on 12/23/17.
//  Copyright © 2017 Dee Chapman. All rights reserved.
//

import XCTest

class recipe_networkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseString() {
        // This is an example of a functional test case.
        var dataString : String? = nil
        self.measure {
            dataString = DataExtractor().readDataFromFile(filename: "epi_r", ofType: "csv")
        }
        assert(dataString != nil)
    }
    
    func testRecipesStringArray() {
        var recipesStringArray : Array<String?>? = nil
        self.measure {
            recipesStringArray = DataExtractor().getRecipeStringArray()
        }
        
        assert(recipesStringArray != nil)
        
        let count = recipesStringArray?.count
        assert(count != 0)

        let randomElement = arc4random_uniform(UInt32(count!))
        
        print("printing element \(randomElement) out of \(count!) total elements: \(recipesStringArray![Int(randomElement)]!)")
    }
    
    func testRecipeDictionary() {
        let extractor = DataExtractor()
        let recipesStringArray = extractor.getRecipeStringArray()
        let count = recipesStringArray?.count

        let randomElement = arc4random_uniform(UInt32(count!))
        let recipeString = recipesStringArray![Int(randomElement)]!
        let dictionary = extractor.recipeDictionary(recipeString: recipeString)
        
        assert(dictionary["title"] != nil)
        print(dictionary["title"] ?? "nil")
    }
    
    func testRecipeExtractor() {
        let extractor = DataExtractor()
        let recipes = extractor.recipes()
        
        assert(recipes.count != 0)
        print(recipes[0].title)
    }
    
    //this test takes a long time to run and was mainly used for creating the cleaned dataset.
    func testJSON() {
        let extractor = DataExtractor()
        extractor.toJSON()
    }
    
    func testFromJSON() {
        let extractor = DataExtractor()
        extractor.fromJSON(dataSetNum: 1)
    }
    
    func testCreateAllTrainingData() {
        let extractor = DataExtractor()
        extractor.createAllTrainingData(datasetNum: 1)
    }
    
    func testTrainNN() {
        let extractor = DataExtractor()
        var currentPieceOfData = extractor.getNextData(dataset: .train)
        var neuralNet = NeuralNetwork(layerWidth:[(currentPieceOfData?.input.count)!,16,16,(currentPieceOfData?.output.count)!])

        while currentPieceOfData != nil {
            neuralNet.train(input: currentPieceOfData!.input, desiredOutput: currentPieceOfData!.output)
            currentPieceOfData = extractor.getNextData(dataset: .train)
        }
        
        neuralNet.saveWeightsToFile(index: neuralNet.trainingIterationCount)
    }
    
    func testGeneralizationAccuracy() {
        let extractor = DataExtractor()
        var currentPieceOfData = extractor.getNextData(dataset: .test)
        var numCorrect = 0.0
        var totalNum = 0.0
        var neuralNet = NeuralNetwork(layerWidth:[(currentPieceOfData?.input.count)!,16,16,(currentPieceOfData?.output.count)!])
        
        while currentPieceOfData != nil {
            let predictedIngredientToAdd = Recipe.predictIngredientToAdd(input: currentPieceOfData!.input, network:neuralNet)
            if currentPieceOfData!.output[predictedIngredientToAdd.index] == 1.0 {
                numCorrect += 1.0
            }
            totalNum += 1.0
            currentPieceOfData = extractor.getNextData(dataset: .test)
        }
        print("Accuracy is \(numCorrect/totalNum)")
    }
    

}
