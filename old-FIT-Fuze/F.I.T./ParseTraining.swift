//
//  Training.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseTraining :  PFObject, PFSubclassing
{

    @NSManaged var trainingName : String
    @NSManaged var trainingDescription : String
    @NSManaged var identifier : String
    @NSManaged var exercises : [ParseExerciseMetaMapping]
    
    override init()
    {
        super.init()
    }
    
    init(identifier : String!, trainingName : String!, trainingDescription : String!)
    {        
        super.init()
        self.trainingName = trainingName
        self.trainingDescription = trainingDescription
        self.identifier = identifier
        self.exercises = Array<ParseExerciseMetaMapping>()

    }
    

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String! {
        return TableConstants.TABLE_TRAININGS
    }
    
    
}