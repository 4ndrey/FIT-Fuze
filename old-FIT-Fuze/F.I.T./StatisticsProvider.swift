//
//  StatisticsProvider.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 29.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData

class StatisticsProvider: NSObject {
    
    func getHistoryWithExercise(_ exercise : String) -> [History]
    {
        let history = History.mr_findAllSorted(by: "date", ascending: true) as! [History]
        var filteredHistory : [History] = [History]()
        
        for value in history {
            if (value.exercise.name == exercise) {
                filteredHistory.append(value)
            }
        }
        return filteredHistory
    }
    
    func getHistoryExercises() -> [String]
    {
        let history = History.mr_findAll() as! [History]
        var exercises : [String:AnyObject] = [String:AnyObject]()
        
        for value in history {
          exercises[value.exercise.name!] = "" as AnyObject
        }
        return Array(exercises.keys)
    }
    
    func createHistoryEntry(_ exercise : Exercise, reps : Int, weight : Int, date : Date)
    {
        let entry = History.mr_createEntity() as! History
        entry.exercise = exercise
        entry.weight = NSNumber(value: weight)
        entry.repetitions = NSNumber(value: reps)
        entry.date = date
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
