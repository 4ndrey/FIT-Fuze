//
//  Set.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseSet : PFObject, PFSubclassing
{
    @NSManaged var repetitions : NSNumber?
    @NSManaged var weights : NSNumber?

    
    override init()
    {
        super.init()
        self.repetitions = 0
        self.weights = 0
    }
    
    init(repetitions : Int, weights : Int)
    {
        super.init()
        self.repetitions = repetitions
        self.weights = weights
    }
    
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String! {
        
        return TableConstants.TABLE_LOCAL_SETS
    }
    
    
}