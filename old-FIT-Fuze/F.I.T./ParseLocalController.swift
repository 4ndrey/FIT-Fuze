//
//  ParseLocalController.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 19.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseLocalController: NSObject {
    
    var delegate : ParseLocalInterface?
    var localStorage = LocalStorage.sharedInstance
    
    
    init(delegate : ParseLocalInterface)
    {
        self.delegate = delegate
    }
    
    func loadlocalData()
    {
        loadLocalExercises()
    }
    
    private func loadLocalExercises()
    {
        var query = PFQuery(className:TableConstants.TABLE_EXERCISES)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                if objects.count > 0
                {
                    for object in objects {
                        var ex = ParseExercise(object: object as PFObject, createFromLocal: true, delegate: nil)
                        self.localStorage.addExercise(ex)
                    }
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.loadLocalTrainingPrograms()
        }
    }
    
    private func loadLocalTrainingPrograms()
    {
        var query = PFQuery(className:TableConstants.TABLE_TRAINING_PROGRAMS)
        query.includeKey(TableConstants.WORKOUTS_DATA)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                if objects.count > 0
                {
                    for object in objects {
                        
                        var trainingPrg = ParseTrainingProgram(object: object as PFObject, createFromLocal: true, delegate: nil)
                        self.localStorage.addTrainingProgram(trainingPrg)
                    }
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.loadLocalUserTrainingPrograms()
        }
    }
    
    private func loadLocalUserTrainingPrograms()
    {
        var query = PFQuery(className:TableConstants.TABLE_LOCAL_USER_PROGRMS)
        query.includeKey(TableConstants.WORKOUTS_DATA)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                if objects.count > 0
                {
                    for object in objects {
                        
                        var trainingPrg = ParseTrainingProgram(object: object as PFObject, createFromLocal: true, delegate: nil)
                        self.localStorage.addUserTrainingProgram(trainingPrg)
                        
                   }
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.delegate?.onLocalDataLoaded()
        }
    }
    
    
    private func loadLocalMetas()
    {
        var query = PFQuery(className:TableConstants.TABLE_EXERCISES_META)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                if objects.count > 0
                {
                    for object in objects {
                      NSLog("%@", "metaObject")
                        
                    }
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
//    func deleteUserTrainingProgram(programID : String)
//    {
//        var query = PFQuery(className:TableConstants.TABLE_LOCAL_USER_PROGRMS)
//        query.fromLocalDatastore()
//        query.getObjectInBackgroundWithId(programID){
//            (trainingProgram: PFObject!, error: NSError!) -> Void in
//            if error == nil {
//               trainingProgram.unpin()
//            } else {
//                // Log details of the failure
//                NSLog("Error: %@ %@", error, error.userInfo!)
//            }
//        }
//    }
    
    
    
    private func deleteAll()
    {
        deleteLocalTrainingPrograms()
        deleteLocalUserTrainingPrograms()
        deleteLocalTrainings()
        deleteLocalExercises()
        deleteLocalMeta()
    }
    
    
    private func deleteLocalExercises()
    {
        deleteTable(TableConstants.TABLE_EXERCISES)
    }
    
    private func deleteLocalTrainingPrograms()
    {
        deleteTable(TableConstants.TABLE_TRAINING_PROGRAMS)
    }
    
    private func deleteLocalUserTrainingPrograms()
    {
        deleteTable(TableConstants.TABLE_LOCAL_USER_PROGRMS)
    }
    
    private func deleteLocalTrainings()
    {
        deleteTable(TableConstants.TABLE_TRAININGS)
    }
    
    private func deleteLocalMeta()
    {
        deleteTable(TableConstants.TABLE_EXERCISES_META)
    }
    
    private func deleteTable(tableName : String)
    {
        var query = PFQuery(className:tableName)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if objects.count > 0
                {
                    for object in objects {
                        var deleteObject = object as PFObject
                        deleteObject.unpin()
                    }
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }

}