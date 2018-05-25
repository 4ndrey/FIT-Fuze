//
//  Training.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

@objc(Training)
class Training: NSManagedObject, Mappable {
    
    @NSManaged var name: String?
    @NSManaged var trainingDescription: String?
    @NSManaged var trainingProgram: TrainingProgram?
    @NSManaged var exerciseMetaMappings: NSOrderedSet?
    @NSManaged var repetitionCounter: NSNumber?
    
    /*convenience required init(_ decoder: JSONDecoder) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Training", in: NSManagedObjectContext.mr_default())
        self.init(entity: entity!, insertInto: NSManagedObjectContext.mr_default())
        self.name = decoder["name"].string
        self.trainingDescription = decoder["description"].string
        
        if let mappingsArray = decoder["exerciseMetaMappings"].array {
            var mappingsTmp = Array<ExerciseMetaMapping>()
            for mappingDecoder in mappingsArray {
                let mapping = ExerciseMetaMapping(mappingDecoder)
                mapping.training = self
                mappingsTmp.append(mapping)
            }
            exerciseMetaMappings = NSOrderedSet(array: mappingsTmp)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
    }*/
    
    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "Training", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        trainingDescription <- map["description"]

        var mappingsTmp = Array<ExerciseMetaMapping>()
        mappingsTmp <- map["exerciseMetaMappings"]
        for mapping in mappingsTmp {
            mapping.training = self
        }        
        exerciseMetaMappings = NSOrderedSet(array: mappingsTmp)
        
        repetitionCounter = 0
    }
}


