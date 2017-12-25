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
}
