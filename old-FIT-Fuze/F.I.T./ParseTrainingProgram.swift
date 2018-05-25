//
//  TrainingProgram.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseTrainingProgram : NSObject, Printable
{
    var identifier : String?
    var programType : String?
    var programName : String?
    var programDescription : String?
    var workouts : [ParseTraining]  = []
    
    var parseObject : PFObject?
    var localStorage = LocalStorage.sharedInstance

    override var description: String {
        return getProgramDescription()
    }
    
    override init()
    {
        super.init()
        self.parseObject = PFObject(className: TableConstants.TABLE_LOCAL_USER_PROGRMS)
        self.identifier = TrainingProgramHelper.randomString(10)
    }
    
    init(object : PFObject!, createFromLocal : Bool, delegate : ParseInterface?)
    {
        super.init()
        TrainingProgramHelper.handleProgram(self, object: object, createFromLocal: createFromLocal, delegate: delegate)
        
    }
    
    
    func saveTrainingProgram()
    {
        self.parseObject![TableConstants.IDENTIFIER] = self.identifier
        self.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_TYPE] = self.programType
        self.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_NAME] = self.programName
        self.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_DESCRIPTION] = self.programDescription
        TrainingProgramHelper.saveLocal(self, delegate: nil)
    }
    
    func deleteTrainingProgram()
    {
        var obj = self.parseObject!
        
        if obj.parseClassName == TableConstants.TABLE_LOCAL_USER_PROGRMS
        {
            obj.unpinWithName(self.identifier)
        }
    }
    
    
    private func getProgramDescription() -> String
    {
        var output = "programIdentifier: " + self.identifier! + "\n" +
                     "programName: " + self.programName! + "\n" +
                     "programDescription: " + self.programDescription! + "\n" +
                     "programType: " + self.programType! + "\n" + "\n"
        
        for training in self.workouts
        {
            output += "trainingIdentifier: " + training.identifier + "\n" +
                      "trainingName: " + training.trainingName + "\n" +
                      "trainingDescription: " + training.trainingDescription + "\n" + "\n"
            
            for mapping in training.exercises
            {
                output += "exerciseIdentifier: " + mapping.exerciseIdentifier! + "\n" +
                          "exerciseRepetitions: " + mapping.exerciseMeta!.exerciseRepetitions!.stringValue + "\n" +
                          "exerciseRestTime: " + mapping.exerciseMeta!.exerciseRestTime!.stringValue + "\n" +
                          "exerciseSets: " + mapping.exerciseMeta!.exerciseSets!.stringValue + "\n"

                if(mapping.exerciseMeta!.sets != nil)
                {
                    for set in mapping.exerciseMeta!.sets!
                    {
                        output += "Weights: " + set.weights!.stringValue
                        output += " Reps: " + set.repetitions!.stringValue + "\n"
                    }
                }
                
                
//                if value.setWeights != nil
//                {
//                    for (key, value) in value.setWeights!
//                    {
//                        output += "Satz: " + key + " - Weights: " + String(value) + "\n"
//                    }
//                }
//
//                
//                if value.setRepetitions != nil
//                {
//                    for (key, value) in value.setRepetitions!
//                    {
//                        output += "Satz: " + key + " - Reps: " + String(value) + "\n"
//                    }
//                }
                 output +=  "\n"
            }
            
        }
        return output
    }
    

    
}