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
    var ingredients : Dictionary<String, Float>
    var orderedIngredients : Array<String>
    var orderedIncludedIngredients : Array<Float>
    // a short array which represents JUST the ingredients that are not 0.0 in this recipe
    var allIngredients : Array<String>
    
    init(title: String, rating: Float, ingredients: Dictionary<String, Float>, calories: Float, protein: Float, fat: Float, sodium: Float, orderedIngredients: Array<String>, orderedIncludedIngredients: Array<Float>, allIngredients : Array<String>) {
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
                          ingredients: dictionaryRepresentation["ingredients"] as! Dictionary<String, Float>,
                          calories: dictionaryRepresentation["calories"] as! Float,
                          protein: dictionaryRepresentation["protein"] as! Float,
                          fat: dictionaryRepresentation["fat"] as! Float,
                          sodium: dictionaryRepresentation["sodium"] as! Float,
                          orderedIngredients: dictionaryRepresentation["orderedIngredients"] as! Array<String>,
                          orderedIncludedIngredients: dictionaryRepresentation["orderedIncludedIngredients"] as! Array<Float>,
                          allIngredients: dictionaryRepresentation["allIngredients"] as! Array<String>)
            } else {
                return nil
            }
        } catch let error as NSError {
            print("JSON string to recipe failed: \(error.localizedDescription)")
            return nil
        }
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
    
    // create the training data from a single recipe, return
    func createTrainingData() {
        
    }
}
