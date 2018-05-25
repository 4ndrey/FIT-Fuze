//
//  PrimaryExerciseType.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 22.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

@objc(PrimaryExerciseType)
class PrimaryExerciseType: NSManagedObject, Mappable {

    @NSManaged var type: String?

    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "PrimaryExerciseType", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        type <- map["type"]
    }

    convenience required init(_ muscleGroupName: String) {
        _ = ContentProvider()
        guard let entity = NSEntityDescription.entity(forEntityName: "PrimaryExerciseType", in: NSManagedObjectContext.mr_default()) else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: NSManagedObjectContext.mr_default())
        self.type = muscleGroupName
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
