//
//  Recipe.swift
//  recipe network
//
//  Created by Dee Chapman on 12/23/17.
//  Copyright © 2017 Dee Chapman. All rights reserved.
//

import Cocoa

class Recipe: NSObject {
    var title : String
    var rating : Float
    var calories : Float
    var protein : Float
    var fat : Float
    var sodium : Float
    var ingredients : Dictionary<String, Double>
    var orderedIngredients : Array<String>
    var orderedIncludedIngredients : Array<Double>
    // a short array which represents JUST the ingredients that are not 0.0 in this recipe
    var allIngredients : Array<String>
    
    // used for reading training data set
    var trainingData : Array<(input: Array<Double>, output: Array<Double>)>? = nil
    var trainingDataIndex : Int = 0
    
    init(title: String, rating: Float, ingredients: Dictionary<String, Double>, calories: Float, protein: Float, fat: Float, sodium: Float, orderedIngredients: Array<String>, orderedIncludedIngredients: Array<Double>, allIngredients : Array<String>) {
        self.title = title
        self.rating = rating
        self.ingredients = ingredients
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.sodium = sodium
        self.orderedIngredients = orderedIngredients
        self.orderedIncludedIngredients = orderedIncludedIngredients
        self.allIngredients = allIngredients
        
    }
    
    // convenience init that accepts a json string and creates a recipe
    convenience init?(jsonString: String) {
        // take string and convert to a json object
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        do {
            let jsonRepresentation = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())
            if let dictionaryRepresentation = jsonRepresentation as? Dictionary<String, Any> {
                // make recipe
                self.init(title: dictionaryRepresentation["title"] as! String,
                          rating: dictionaryRepresentation["rating"] as! Float,
                          ingredients: dictionaryRepresentation["ingredients"] as! Dictionary<String, Double>,
                          calories: dictionaryRepresentation["calories"] as! Float,
                          protein: dictionaryRepresentation["protein"] as! Float,
                          fat: dictionaryRepresentation["fat"] as! Float,
                          sodium: dictionaryRepresentation["sodium"] as! Float,
                          orderedIngredients: dictionaryRepresentation["orderedIngredients"] as! Array<String>,
                          orderedIncludedIngredients: dictionaryRepresentation["orderedIncludedIngredients"] as! Array<Double>,
                          allIngredients: dictionaryRepresentation["allIngredients"] as! Array<String>)
            } else {
                return nil
            }
        } catch let error as NSError {
            print("JSON string to recipe failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    //
    class func predictIngredientToAdd(input: Array<Double>, network: NeuralNetwork) -> (array: Array<Double>, index: Int) {
        var networkOutput = network.predict(input: input)
        var netOutMinusIn : Array<Double> = []
        
        var maxIndex = 0
        var maxValue = 0.0
        for i in 0..<networkOutput.count {
            let diff = networkOutput[i] - input[i]
            netOutMinusIn.append(diff)
            if diff > maxValue {
                maxValue = diff
                maxIndex = i
            }
        }
        var ingredientToAdd = Array(repeatElement(0.0, count: networkOutput.count))
        ingredientToAdd[maxIndex] = 1.0
        return (array: ingredientToAdd, index: maxIndex)
    }
    
    
    // create a dictionary and serialize an instance of recipe to a string
    func toJSON() -> String? {
        var jsonData: Data!
        do {
            let dictionaryRepresentation : Dictionary<String, Any> = [
                "title":self.title,
                "rating":self.rating,
                "ingredients":self.ingredients,
                "calories":self.calories,
                "protein":self.protein,
                "fat":self.fat,
                "sodium":self.sodium,
                "orderedIngredients":self.orderedIngredients,
                "orderedIncludedIngredients":self.orderedIncludedIngredients,
                "allIngredients":self.allIngredients
                ]
            jsonData = try JSONSerialization.data(withJSONObject: dictionaryRepresentation, options: JSONSerialization.WritingOptions())
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    // create the training data from a single recipe, return an array of tuples with
    // an input of a recipe missing an ingredient, and an output of the original recipe
    func createTrainingData() -> Array<(input: Array<Double>, output: Array<Double>)> {
        let output = self.orderedIncludedIngredients
        var trainingDataArray = Array<(input: Array<Double>, output: Array<Double>)>()
        // use allIngredients to find the indices for each ingredient.
        var arrayOfIndicesForIngredients = Array<Int>()
        for ingredient in self.allIngredients {
            arrayOfIndicesForIngredients.append(self.orderedIngredients.index(of: ingredient)!)
        }
        // remove one ingredient from original recipe
        for ingredientToRemove in arrayOfIndicesForIngredients {
            var inputDataForOneVariation = self.orderedIncludedIngredients
            inputDataForOneVariation[ingredientToRemove] = 0.0
            trainingDataArray.append((input: inputDataForOneVariation, output: output))
        }
        // remove two ingredients from original recipe
        for firstIngredientToRemove in arrayOfIndicesForIngredients {
            for secondIngredientToRemove in arrayOfIndicesForIngredients {
                var inputDataForOneVariation = self.orderedIncludedIngredients
                inputDataForOneVariation[firstIngredientToRemove] = 0.0
                inputDataForOneVariation[secondIngredientToRemove] = 0.0
                trainingDataArray.append((input: inputDataForOneVariation, output: output))
            }
        }
        
        self.trainingData = trainingDataArray
        return trainingDataArray
    }
    
    // return the next piece of training data
    func getNextTrainingData() -> (input: Array<Double>, output: Array<Double>)? {
        // check if training data array is nil
        if self.trainingData == nil {
            self.trainingData = createTrainingData()
        }
        if self.trainingDataIndex > ((self.trainingData?.endIndex ?? 0) - 1) {
            // too big, return nil
            return nil
        } else {
            let nextPieceOfTrainingData = self.trainingData![self.trainingDataIndex]
            self.trainingDataIndex += 1
            return nextPieceOfTrainingData
        }
    }
        
}
