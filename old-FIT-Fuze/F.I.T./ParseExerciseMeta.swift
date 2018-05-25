//
//  ExerciseMeta.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseExerciseMeta : PFObject, PFSubclassing
{
    @NSManaged var exerciseSets : NSNumber? // default values
    @NSManaged var exerciseRepetitions : NSNumber? // default values
    @NSManaged var exerciseRestTime : NSNumber? // default values
    
    @NSManaged var sets : [ParseSet]?
    
    override init()
    {
        super.init()
    }
    
    init(object : PFObject!)
    {
        super.init()
        
        if object.parseClassName == TableConstants.TABLE_EXERCISES_META {
            self.exerciseRepetitions = object[TableConstants.FIELD_EXERCISES_META_REPETITIONS_DEFAULT] as? NSNumber
            self.exerciseRestTime = object[TableConstants.FIELD_EXERCISES_META_REST_DEFAULT] as? NSNumber
            self.exerciseSets = object[TableConstants.FIELD_EXERCISES_META_SETS_DEFAULT] as? NSNumber
            self.sets = object[TableConstants.FIELD_EXERCISES_META_SETS] as? Array<ParseSet>
            
            if self.sets != nil
            {
                for set in sets!
                {
                    set.fetchFromLocalDatastore()
                }
            }
            else
            {
                self.sets = Array<ParseSet>()
            }
            
        }
        
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String! {
        
        return TableConstants.TABLE_EXERCISES_META
    }
    
    
}