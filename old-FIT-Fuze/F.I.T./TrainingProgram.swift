//
//  TrainingProgram.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 16.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

@objc(TrainingProgram)
class TrainingProgram: NSManagedObject, Mappable {
    
    @NSManaged var name: String?
    @NSManaged var programDescription: String?
    @NSManaged var type: String?
    @NSManaged var userProgram: NSNumber?
    @NSManaged var trainings: NSOrderedSet?
    @NSManaged var programId: String?
    @NSManaged var isFree: NSNumber?
    @NSManaged var isPurchased: NSNumber?
    @NSManaged var workoutRepetition: NSNumber?
    @NSManaged var level: String?

    var trainingsTmp: Array<Training>?

    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "TrainingProgram", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        programDescription <- map["programDescription"]
        type <- map["type"]
        trainingsTmp <- map["trainings"]
        programId <- map["programId"]
        if let trainingsTemp = trainingsTmp {
            trainings = NSOrderedSet(array: trainingsTemp)
        }
        isFree <- map["free"]
        isPurchased <- map["purchased"]
        if isPurchased == nil {
            isPurchased = 0
        }
        workoutRepetition <- map["repetitions"]
        level <- map["level"]
        userProgram = 0
    }
}
