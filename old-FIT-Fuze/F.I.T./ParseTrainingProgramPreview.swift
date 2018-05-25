//
//  TrainingProgramPreview.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 18.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseTrainingProgramPreview : NSObject, Printable
{
    var identifier : String?
    var programType : String?
    var programName : String?
    var programDescription : String?

    override var description: String {
        var output = "identifier: " + self.identifier! + "\n" +
            "programName: " + self.programName! + "\n" +
            "programType: " + self.programType! + "\n" +
            "programDescription: " + self.programDescription!
        return output
    }
    
    init(object : PFObject!)
    {
        super.init()
        
        if object.parseClassName == TableConstants.TABLE_TRAINING_PROGRAMS {
          self.identifier = object.objectId
          self.programType = object[TableConstants.FIELD_TRAINING_PROGRAMS_TYPE] as? String
          self.programName = object[TableConstants.FIELD_TRAINING_PROGRAMS_NAME] as? String
          self.programDescription = object[TableConstants.FIELD_TRAINING_PROGRAMS_DESCRIPTION] as? String
        }

    }

    
}
