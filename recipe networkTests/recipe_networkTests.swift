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
        extractor.createAllTrainingData()
    }
    
    func trainNN() {
        
    }
    
}
