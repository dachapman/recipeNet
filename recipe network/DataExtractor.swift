//
//  DataExtractor.swift
//  recipe network
//
//  Created by Dee Chapman on 12/23/17.
//  Copyright © 2017 Dee Chapman. All rights reserved.
//

import Cocoa

enum Dataset {
    case train
    case test
    case dev
}

class DataExtractor: NSObject {
    var dataTitles : Array<String> = Array()
    
    // properties used for getting training data
    var fileIndex : Int = 1
    var fileData : Array<Recipe>? = nil
    var recipeIndex : Int = -1
    var recipe : Recipe? = nil
    
    // split the data
    var testPercent : Int = 15
    var devPercent : Int = 15
    var trainingPercent : Int = 70
    var currentDataIndex : Int = 0
    
    func readDataFromFile(filename:String, ofType:String) -> String! {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: ofType)
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func getRecipeStringArray() -> Array<String?>! {
        var dataString = readDataFromFile(filename: "epi_r", ofType: "csv")!
        var extractData = dataString.components(separatedBy: CharacterSet(charactersIn: "\""))
        dataString = ""
        for i in 0..<extractData.count {
            if i % 2 == 0 {
                dataString = dataString + extractData[i]
            } else {
                dataString = dataString + extractData[i].components(separatedBy: CharacterSet(charactersIn:"\n,")).joined(separator: "")
            }
        }
        
        var lines: [String] = dataString.components(separatedBy: CharacterSet(charactersIn:"\n"))

        //data set is structured such that the 0th element contains the titles of the columns
        let titles = lines[0]

        self.dataTitles = titles.components(separatedBy: CharacterSet(charactersIn: ","))
        return Array<String>(lines.suffix(lines.count-2))
    }
    
    func recipeDictionary(recipeString: String) -> Dictionary<String, String> {
        var recipeArray = Array<String>()
        var recipeString = recipeString
        if recipeString.contains("\"") {
            let extractTitle = recipeString.components(separatedBy: CharacterSet(charactersIn: "\""))
            if extractTitle.count > 2 {
                recipeString = extractTitle[2]
                recipeArray = recipeString.components(separatedBy: CharacterSet(charactersIn: ","))
                recipeArray[0] = extractTitle[1]
            }
        } else {
            recipeArray = recipeString.components(separatedBy: CharacterSet(charactersIn: ","))
        }
        var recipeDictionary = Dictionary<String, String>()
        for i in 0..<recipeArray.count {
            let title = self.dataTitles[i]
            let value = recipeArray[i]
            recipeDictionary[title] = value
        }
        return recipeDictionary
    }
    
    func recipes() -> Array<Recipe> {
        var recipeArray = Array<Recipe>()
        let recipeStringArray = getRecipeStringArray()!
        var i = 0
        let ingredListString = readDataFromFile(filename: "ingredients", ofType: "txt")
        let ingredListArray = ingredListString?.components(separatedBy: CharacterSet(charactersIn: "\r\n"))
        
        for recipeString in recipeStringArray {
            i = i + 1
            print("processing \(i) of \(recipeStringArray.count)")
            let dictionary = recipeDictionary(recipeString: recipeString!)
            var ingredientsDictionary = Dictionary<String, Double>()
            var ingredientsInRecipe = Array<Double>()
            var includedIngredients = Array<String>()

            for key in ingredListArray! {
                ingredientsDictionary[key] = Double(dictionary[key] ?? "0.0")
                ingredientsInRecipe.append(Double(dictionary[key] ?? "0.0")!)
                if (dictionary[key] != "0.0") {
                    includedIngredients.append(key)
                }
            }
            
            recipeArray.append(Recipe(title: dictionary["title"]!,
                                      rating: Float(dictionary["rating"] ?? "0.0") ?? 0.0,
                                      ingredients: ingredientsDictionary,
                                      calories: Float(dictionary["calories"] ?? "0.0") ?? 0.0,
                                      protein: Float(dictionary["protein"] ?? "0.0") ?? 0.0,
                                      fat: Float(dictionary["fat"] ?? "0.0") ?? 0.0,
                                      sodium: Float(dictionary["sodium"] ?? "0.0") ?? 0.0,
                                      orderedIngredients: ingredListArray!,
                                      orderedIncludedIngredients: ingredientsInRecipe,
                                      allIngredients: includedIngredients))
        }
        
        return recipeArray
    }
    
    func dataArrayToJSONFile(index: Int, array: Array<String>) {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let filename = "dataset_\(index).json"
        
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
            jsonData = try JSONSerialization.data(withJSONObject: array as NSArray, options: JSONSerialization.WritingOptions());
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
    
    func toJSON() {
        let recipeArray = self.recipes()
        var recipeStringArray = Array<String>()
        
        var i = 0
        
        for recipe in recipeArray {
            if recipeStringArray.count > 100 {
                i = i + 1
                dataArrayToJSONFile(index: i, array: recipeStringArray)
                recipeStringArray = Array<String>()
            }
            recipeStringArray.append(recipe.toJSON()!)
        }
    }
    
    // extract individual recipe object strings, return an array of recipes
    func fromJSON(dataSetNum: Int) -> Array<Recipe>? {
        guard let dataString = readDataFromFile(filename: "json_data/dataset_\(dataSetNum)", ofType: "json") else {
            return nil
        }
        
        let jsonData = dataString.data(using: String.Encoding.utf8)
        do {
            let jsonRepresentation = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())
            if jsonRepresentation is Array<String> {
                let arrayRepresentation = jsonRepresentation as! Array<String>
                var arrayOfRecipes: Array<Recipe> = Array<Recipe>()
                for recipeString in arrayRepresentation {
                    arrayOfRecipes.append(Recipe(jsonString: recipeString)!)
                }
                return arrayOfRecipes
            }
        } catch let error as NSError {
            print("JSON string to recipe failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    // create an array of training data sets for all the recipes
    func createAllTrainingData(datasetNum: Int) -> Array<(input: Array<Double>, output: Array<Double>)> {
        var allTrainingData = Array<(input: Array<Double>, output: Array<Double>)>()
        for recipe in fromJSON(dataSetNum: datasetNum)! {
            allTrainingData = allTrainingData + recipe.createTrainingData()
        }
        return allTrainingData
    }
    
    // get the next recipe from the data
    func getNextRecipe() -> Recipe? {
        if self.fileData == nil && self.fileIndex == 1 {
            self.fileData = fromJSON(dataSetNum: self.fileIndex)
            self.fileIndex += 1
        }
        
        self.recipeIndex += 1
        
        if self.fileData == nil {
            return nil
        }

        if self.recipeIndex > (self.fileData?.endIndex)! - 1 {
            // get the next data file
            self.fileData = fromJSON(dataSetNum: self.fileIndex)
            self.fileIndex += 1
            self.recipeIndex = 0
        }
        if self.fileData == nil {
            return nil
        }
        return self.fileData?[self.recipeIndex]
    }
    
    // return the next piece of data from the dataset
    func getNextData() -> (input: Array<Double>, output: Array<Double>)? {
        
        var nextTrainingData : (input: Array<Double>, output: Array<Double>)? = nil
        if self.recipe == nil {
            self.recipe = getNextRecipe()
        }
        if self.recipe != nil {
            nextTrainingData = self.recipe?.getNextTrainingData()
            if nextTrainingData == nil {
                self.recipe = getNextRecipe()
                nextTrainingData = self.recipe?.getNextTrainingData()
            }
        } else {
            return nil
        }
        self.currentDataIndex += 1
        return nextTrainingData
    }
    
    // create a test, dev, training split of all the data
    // suggested split:  training: 70%, dev: 15%, test: 15%
    func getNextData(dataset: Dataset) -> (input: Array<Double>, output: Array<Double>)? {
        var pieceOfDataToReturn : (input: Array<Double>, output: Array<Double>)? = nil
        var flagInCorrectRange = false
        
        // purposely incurring a performance hit in order to:
        //     1) ensure reproducibility of results,
        //     2) limit amount of the dataset that needs to be stored in RAM (at most, 100 recipes at a time)
        while (flagInCorrectRange == false) {
            switch dataset {
            case .train:
                if self.currentDataIndex % 100 < self.trainingPercent {
                    pieceOfDataToReturn = self.getNextData()
                    if pieceOfDataToReturn == nil {
                        print("Error retreiving data in training at index: \(currentDataIndex)")
                    }
                    flagInCorrectRange = true
                } else {
                    _ = self.getNextData()
                }
            case .dev:
                if self.currentDataIndex % 100 >= self.trainingPercent && self.currentDataIndex < (self.trainingPercent + self.devPercent) {
                    pieceOfDataToReturn = self.getNextData()
                    flagInCorrectRange = true
                } else {
                    _ = self.getNextData()
                }
            case .test:
                if self.currentDataIndex % 100 >= (self.trainingPercent + self.devPercent) && self.currentDataIndex < (self.trainingPercent + self.devPercent + self.testPercent) {
                    pieceOfDataToReturn = self.getNextData()
                    flagInCorrectRange = true
                } else {
                    _ = self.getNextData()
                }
            }
        }
        return pieceOfDataToReturn
    }

}
