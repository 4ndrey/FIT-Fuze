//
//  Set.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData

@objc(WorkoutSet)
class WorkoutSet: NSManagedObject {

    @NSManaged var repetitions: NSNumber
    @NSManaged var weights: NSNumber
    @NSManaged var exerciseMeta: ExerciseMeta

    internal var convertedWeight: NSNumber
    {
        let userDefaults = UserDefaults(suiteName: "group.fitfuze");
        if let kilogrammChoosen : NSNumber  = userDefaults!.object(forKey: "kilogrammChoosenKey") as? NSNumber
        {
            let convertedWeight = (kilogrammChoosen.boolValue ? self.weights.floatValue : ceil(self.weights.floatValue * 2.205));
            let convertedWeightInteger : NSInteger = NSInteger(convertedWeight);
            return NSNumber(value: convertedWeightInteger);
        }
        
        return self.weights;
    }
}
