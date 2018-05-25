//
//  Exercise.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 19.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseExercise : NSObject, Printable

{
    let identifier : String?
    var name : String?
    var exerciseDescription : String?
    var type : String?
    var primary : Array<String>?
    var secondary : Array<String>?
    var equipment : Array<String>?
    var steps : Array<String>?
    
    var exerciseImages : Array<UIImage>?
    
    var localImagesData : Array<PFFile>?
    var localStorage = LocalStorage.sharedInstance
    
    override var description: String {
        var output = "identifier: " + self.identifier! + "\n" +
            "name: " + self.name! + "\n" +
            "description: " + self.exerciseDescription! + "\n" +
            "type: " + self.type! + "\n" +
            "primary: " + self.primary!.description + "\n" +
            "secondary: " + self.secondary!.description + "\n" +
            "equipment: " + self.equipment!.description +
            "steps: " + self.steps!.description
        return output
    }
    
    init(object : PFObject!, createFromLocal : Bool, delegate : ParseInterface?)
    {
        super.init()
        if object.parseClassName == TableConstants.TABLE_EXERCISES {
            self.identifier = object.objectId
            self.name = object[TableConstants.FIELD_EXERCISES_NAME] as? String
            self.exerciseDescription = object[TableConstants.FIELD_EXERCISES_DESCRIPTION] as? String
            self.primary = object[TableConstants.FIELD_EXERCISES_PRIMARY] as? Array<String>
            self.secondary = object[TableConstants.FIELD_EXERCISES_SECONDARY] as? Array<String>
            self.equipment = object[TableConstants.FIELD_EXERCISES_EQUIPMENT] as? Array<String>
            self.steps = object[TableConstants.FIELD_EXERCISES_STEPS] as? Array<String>
            self.type = object[TableConstants.FIELD_EXERCISES_TYPE] as? String
            
            
            ExerciseHelper.handleImages(object, exerciseObject: self, createFromLocal: createFromLocal, delegate: delegate)
        }
        
    }
    
    
}