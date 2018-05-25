//
//  ExerciseMetaMapping.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseExerciseMetaMapping : PFObject, PFSubclassing
{
    @NSManaged var exerciseIdentifier : String?
    @NSManaged var exerciseMeta : ParseExerciseMeta?
    
    override init()
    {
        super.init()
    }
    
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String! {
        
        return TableConstants.TABLE_EXERCISES_META_MAPPING
    }
}
    