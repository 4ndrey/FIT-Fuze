//
//  History.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 29.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData

@objc(History)
class History: NSManagedObject {
    
    @NSManaged var weight: NSNumber
    @NSManaged var repetitions: NSNumber
    @NSManaged var date: Date
    @NSManaged var exercise: Exercise
    
    override var description: String {
        return getExerciseDescription()
    }
    
    fileprivate func getExerciseDescription() -> String
    {
        var output = "exerciseName: " + self.exercise.name! + "\n"
        
        output += "weight: " + self.weight.stringValue + "\n" + "repetitions: " + self.repetitions.stringValue + "\n"
        
        return output
    }
    
    internal var convertedWeight: NSNumber
    {

            let userDefaults = UserDefaults(suiteName: "group.fitfuze");
            if let kilogrammChoosen : NSNumber  = userDefaults!.object(forKey: "kilogrammChoosenKey") as? NSNumber
            {
                let convertedWeight = (kilogrammChoosen.boolValue ? self.weight.floatValue : ceil(self.weight.floatValue * 2.205));
                let convertedWeightInteger : NSInteger = NSInteger(convertedWeight);
                return NSNumber(value: convertedWeightInteger);
            }
            
            return self.weight;
    }
    
}
