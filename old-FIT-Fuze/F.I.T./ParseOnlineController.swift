//
//  ParseController.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 18.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseOnlineController: NSObject {
    
    var delegate : ParseInterface?
    var lastFetch : NSDate?
    var localStorage = LocalStorage.sharedInstance
    
    init(delegate : ParseInterface)
    {
        self.delegate = delegate
    }
    
    
    func fetchTrainingPrograms()
    {
        var query = PFQuery(className:TableConstants.TABLE_TRAINING_PROGRAMS)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                var trainingPrograms = Array<ParseTrainingProgramPreview>()
                if objects.count > 0
                {
                    for object in objects {
                        var trainingProgram = ParseTrainingProgramPreview(object: object as PFObject)
                        trainingPrograms.append(trainingProgram)
                    }
                }
                self.delegate?.onTrainingProgramsFetched(trainingPrograms)
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func fetchExercises()
    {
        var query = PFQuery(className:TableConstants.TABLE_EXERCISES)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                var exercises = Array<ParseExercisePreview>()
                if objects.count > 0
                {
                    for object in objects {
                        var exercise = ParseExercisePreview(object: object as PFObject)
                        exercises.append(exercise)
                    }
                }
                self.delegate?.onExercisesFetched(exercises)
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func downloadExercise(exerciseID : String)
    {
        var query = PFQuery(className:TableConstants.TABLE_EXERCISES)
        query.includeKey(TableConstants.FIELD_EXERCISES_IMAGES)
        query.getObjectInBackgroundWithId(exerciseID) {
            (exercise: PFObject!, error: NSError!) -> Void in
            if error == nil {
                var ex = ParseExercise(object: exercise, createFromLocal: false, delegate: self.delegate)
                
            } else {
                NSLog("%@", error)
            }
            
        }
        
    
    }
    
    func donwloadTrainingProgram(trainingsProgramID : String)
    {
        var queryProgram = PFQuery(className:TableConstants.TABLE_TRAINING_PROGRAMS)
        queryProgram.includeKey(TableConstants.FIELD_TRAINING_PROGRAMS_TRAININGS)
        queryProgram.includeKey(TableConstants.FIELD_TRAINING_PROGRAMS_TRAININGS + "." + TableConstants.FIELD_TRAININGS_META)
        
        queryProgram.getObjectInBackgroundWithId(trainingsProgramID) {
            (trainingProg: PFObject!, error: NSError!) -> Void in
            if error == nil {
                var trainingProgram = ParseTrainingProgram(object: trainingProg, createFromLocal: false, delegate: self.delegate)
                
            } else {
                NSLog("%@", error)
            }
            
        }
    }
    

    
    
    func setLastFetchTime() -> ()
    {
        var query = PFQuery(className:"localConfig")
        query.fromLocalDatastore();
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                if(objects.count > 0)
                {
                    let localConfig = objects[0] as PFObject
                    localConfig["lastfetch"] = NSDate()
                    localConfig.pinInBackgroundWithBlock({ (succeed: Bool, error: NSError!) -> Void in})
                }
                else
                {
                    let localConfig = PFObject(className:"localConfig")
                    localConfig["lastfetch"] = NSDate()
                    localConfig.pinInBackgroundWithBlock({ (succeed: Bool, error: NSError!) -> Void in})
                }
                
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
            
            
    func checkLastFetchTime()
    {
        var query = PFQuery(className:"localConfig")
        query.fromLocalDatastore();
        query.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if(objects.count > 0)
                {
                    let localConfig = objects[0] as PFObject
                    self.lastFetch = localConfig["lastfetch"] as? NSDate
                }
                else
                {
                    self.lastFetch = nil
                }
                } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
                
                
                
                
                
    func getAllObjectsFromClass(classname name : String)
    {
        
        var query = PFQuery(className:"Trainings")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    NSLog("%@", object.objectId)
                    
                }
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
        
    }
                
                
    
}
