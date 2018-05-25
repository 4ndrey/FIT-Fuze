//
//  TrainingProgramHelper.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 27.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class TrainingProgramHelper
{
    
    class func handleProgram(trainingProgram : ParseTrainingProgram, object : PFObject!, createFromLocal : Bool, delegate : ParseInterface?)
    {
        if object.parseClassName == TableConstants.TABLE_TRAINING_PROGRAMS // loading a trainingProgram from backend or a local final program
        {
            
            var trainingIdentifier : String
            self.setProgramValues(trainingProgram, object: object)
            
            if createFromLocal == true // it is a local final program, make a copy
            {
                trainingIdentifier = TableConstants.WORKOUTS_DATA
                trainingProgram.parseObject = PFObject(className: TableConstants.TABLE_LOCAL_USER_PROGRMS)
                trainingProgram.identifier = randomString(10)
                trainingProgram.parseObject![TableConstants.IDENTIFIER] = trainingProgram.identifier
                trainingProgram.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_TYPE] = object[TableConstants.FIELD_TRAINING_PROGRAMS_TYPE] as? String
                trainingProgram.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_NAME] = object[TableConstants.FIELD_TRAINING_PROGRAMS_NAME] as? String
                trainingProgram.parseObject![TableConstants.FIELD_TRAINING_PROGRAMS_DESCRIPTION] = object[TableConstants.FIELD_TRAINING_PROGRAMS_DESCRIPTION] as? String
            }
            else // program from backend
            {
                trainingProgram.identifier = object.objectId
                trainingIdentifier = TableConstants.FIELD_TRAINING_PROGRAMS_TRAININGS
                trainingProgram.parseObject = object
            }
            
            if let trainings = object[trainingIdentifier] as? Array<PFObject> // copy trainings and meta
            {
                let countTrainings = trainings.count
                var currentTraining = 0
                for obj in trainings
                {
                    currentTraining++
                    self.createTrainings(trainingProgram, object: obj, createFromLocal: createFromLocal, delegate: delegate, countTrainings: countTrainings, currentTraining: currentTraining)
                }
            }
            
            
        }
        else if object.parseClassName == TableConstants.TABLE_LOCAL_USER_PROGRMS // loading a created user trainingProgram
        {
            trainingProgram.identifier = object[TableConstants.IDENTIFIER] as? String
            setProgramValues(trainingProgram, object: object)
            trainingProgram.parseObject = object
            
            if let trainings = object[TableConstants.WORKOUTS_DATA] as? Array<PFObject> // copy trainings and meta
            {
                for obj in trainings
                {
                    self.createTrainings(trainingProgram, object: obj, createFromLocal: createFromLocal, delegate: delegate, countTrainings: 0, currentTraining: 0)
                }
            }
        }
    }
    
    
    
    class func donwloadMetaData(trainingProgram : ParseTrainingProgram, metaID : String, exerciseID : String,  training : ParseTraining, delegate : ParseInterface?, countExercises : Int, currentExercise : Int, countTrainings : Int, currentTraining : Int)
    {
        var query = PFQuery(className:TableConstants.TABLE_EXERCISES_META)
        query.getObjectInBackgroundWithId(metaID) {
            (metaData: PFObject!, error: NSError!) -> Void in
            if error == nil {
                
                if LocalStorage.sharedInstance.isExerciseDownloaded(exerciseID) == true
                {
                    let mapping = ParseExerciseMetaMapping()
                    mapping.exerciseIdentifier = exerciseID
                    mapping.exerciseMeta = ParseExerciseMeta(object: metaData)
                    training.exercises.append(mapping)
                    if countTrainings == currentTraining && countExercises == currentExercise
                    {
                        self.saveLocal(trainingProgram, delegate: delegate)
                    }
                    
                }
                else
                {
                    var query = PFQuery(className:TableConstants.TABLE_EXERCISES)
                    query.includeKey(TableConstants.FIELD_EXERCISES_IMAGES)
                    query.getObjectInBackgroundWithId(exerciseID) {
                        (exercise: PFObject!, error: NSError!) -> Void in
                        if error == nil {
                            var ex = ParseExercise(object: exercise, createFromLocal: false, delegate: delegate)
                            let mapping = ParseExerciseMetaMapping()
                            mapping.exerciseIdentifier = exerciseID
                            mapping.exerciseMeta = ParseExerciseMeta(object: metaData)
                            training.exercises.append(mapping)
                            
                            if countTrainings == currentTraining && countExercises == currentExercise
                            {
                                self.saveLocal(trainingProgram, delegate: delegate)
                            }
                            
                        } else {
                            //NSLog("%@", error)
                        }
                        
                    }
                    
                }
                
                
            } else {
                //NSLog("%@", error)
            }
            
        }
    }
    
    
    class func createTrainings(trainingProgram : ParseTrainingProgram, object : PFObject, createFromLocal : Bool, delegate : ParseInterface?, countTrainings : Int, currentTraining : Int)
    {
        if object.parseClassName == TableConstants.TABLE_TRAININGS {
            
            let trainingName = object[TableConstants.FIELD_TRAININGS_NAME] as? String
            let trainingDescription = object[TableConstants.FIELD_TRAININGS_DESCRIPTION] as? String
            var identifier : String?
            
            if(object.objectId == nil)
            {
                identifier = object[TableConstants.IDENTIFIER] as? String
            }
            else
            {
                identifier = object.objectId
            }
            
            var training = ParseTraining(identifier: identifier!, trainingName: trainingName!, trainingDescription: trainingDescription!)
            trainingProgram.workouts.append(training)
            
            if createFromLocal == true
            {
                if let exercises = object["exercises"] as? Array<PFObject>//Dictionary<String, PFObject>
                {
                    
                    for value in exercises
                    {
                        value.fetchFromLocalDatastore()
                        var pfObject = value["exerciseMeta"] as PFObject
                        pfObject.fetchFromLocalDatastore()
                        var meta = ParseExerciseMeta(object: pfObject)
                        let mapping = ParseExerciseMetaMapping()
                        mapping.exerciseMeta = meta
                        mapping.exerciseIdentifier = value["exerciseIdentifier"] as? String
                        training.exercises.append(mapping)
                    }
                    
                }
            }
            else
            {
                if let exerciseMetaMapping = object[TableConstants.FIELD_TRAININGS_META] as? Array<PFObject!>
                {
                    let countExercises = exerciseMetaMapping.count
                    var currentExercise = 0
                    for obj in exerciseMetaMapping
                    {
                        currentExercise++
                        self.createTrainingsMeta(trainingProgram, training: training, metaObject: obj, createFromLocal: createFromLocal, delegate: delegate, countExercises: countExercises, currentExercise: currentExercise, countTrainings: countTrainings, currentTraining: currentTraining)
                    }
                }
                
            }
            
        }
    }
    
    class func createTrainingsMeta(trainingProgram : ParseTrainingProgram, training : ParseTraining, metaObject : PFObject, createFromLocal : Bool, delegate : ParseInterface?, countExercises : Int, currentExercise : Int, countTrainings : Int, currentTraining : Int)
    {
        let exerciseID = (metaObject[TableConstants.FIELD_EXERCISES_META_MAPPING_EXERCISE] as PFObject).objectId
        let metaID = (metaObject[TableConstants.FIELD_EXERCISES_META_MAPPING_META] as PFObject).objectId
        self.donwloadMetaData(trainingProgram, metaID: metaID, exerciseID: exerciseID, training: training, delegate: delegate, countExercises: countExercises, currentExercise : currentExercise, countTrainings: countTrainings, currentTraining: currentTraining)
        
    }
    
    
    class func saveLocal(trainingProgram : ParseTrainingProgram, delegate : ParseInterface?)
    {
        var obj = trainingProgram.parseObject!
        obj[TableConstants.WORKOUTS_DATA] = trainingProgram.workouts
        obj.pinWithName(trainingProgram.identifier)
        trainingProgram.localStorage.addTrainingProgram(trainingProgram)
        if delegate != nil
        {
            delegate?.onTrainingProgramDownloadFinished(trainingProgram)
        }
        
    }
    
    class func randomString (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    class func setProgramValues(trainingProgram : ParseTrainingProgram, object : PFObject!)
    {
        trainingProgram.programType = object[TableConstants.FIELD_TRAINING_PROGRAMS_TYPE] as? String
        trainingProgram.programName = object[TableConstants.FIELD_TRAINING_PROGRAMS_NAME] as? String
        trainingProgram.programDescription = object[TableConstants.FIELD_TRAINING_PROGRAMS_DESCRIPTION] as? String
    }

}
