//
//  ExerciseMeta.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 22.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

@objc(ExerciseMeta)
class ExerciseMeta: NSManagedObject, Mappable {

    @NSManaged var defaultRepetitions: NSNumber?
    @NSManaged var defaultRestTime: NSNumber?
    @NSManaged var defaultSets: NSNumber?
    @NSManaged var exerciseMetaMapping: ExerciseMetaMapping?
    @NSManaged var sets: NSOrderedSet?
    
    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "ExerciseMeta", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        fillDefaultSets()
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        defaultRepetitions <- map["defaultRepetitions"]
        defaultRestTime <- map["defaultRestTime"]
        defaultSets <- map["defaultSets"]
        sets <- map["steps"]
    }
    
    func fillDefaultSets() {
        var newSets = Array<WorkoutSet>()
        for _ in 0 ..< self.defaultSets!.intValue
        {
            let set = WorkoutSet.mr_createEntity() as? WorkoutSet
            set!.repetitions = defaultRepetitions!
            set!.weights = 5
            set!.exerciseMeta = self
            newSets.append(set!)
        }
        
        if newSets.count > 0
        {
            self.sets = NSOrderedSet(array: newSets)
        }
    }
}
