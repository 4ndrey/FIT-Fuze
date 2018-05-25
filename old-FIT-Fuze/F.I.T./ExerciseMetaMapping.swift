//
//  ExerciseMetaMapping.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

@objc(ExerciseMetaMapping)
class ExerciseMetaMapping: NSManagedObject, Mappable {
    
    @NSManaged var mappingIdentifier: String?
    @NSManaged var withNext: Bool
    @NSManaged var exercise: Exercise?
    @NSManaged var exerciseMeta: ExerciseMeta?
    @NSManaged var training: Training?
    
    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "ExerciseMetaMapping", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        mappingIdentifier <- map["mappingIdentifier"]
        withNext <- map["withNext"]
        exercise <- map["exercise"]
        exerciseMeta <- map["exerciseMeta"]

        var exerciseName: String = ""
        exerciseName <- map["exerciseName"]
        postProcessExercise(with: exerciseName)
    }

    
    func postProcessExercise(with name: String) {
        let contentProvider = ContentProvider()
        self.exercise = contentProvider.getExerciseWithName(name)
        let exercise = self.exercise as Exercise!
        if exercise?.exerciseMetaMapping == nil
        {
            let tmpMeta = [self]
            exercise?.exerciseMetaMapping = NSSet(array: tmpMeta)
        }
        else
        {
            var tmpMeta = exercise?.exerciseMetaMapping?.allObjects as! [ExerciseMetaMapping]
            tmpMeta.append(self)
            exercise?.exerciseMetaMapping = NSSet(array: tmpMeta)
        }
        
        if exercise?.exerciseMetaMapping == nil
        {
            let tmpMeta = [self]
            exercise?.exerciseMetaMapping = NSSet(array: tmpMeta)
        }
        else
        {
            var tmpMeta = exercise?.exerciseMetaMapping?.allObjects as! [ExerciseMetaMapping]
            tmpMeta.append(self)
            exercise?.exerciseMetaMapping = NSSet(array: tmpMeta)
        }

        
    }

}
