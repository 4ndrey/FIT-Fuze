//
//  SecondaryExerciseType.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 22.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
import ObjectMapper

@objc(SecondaryExerciseType)
class SecondaryExerciseType: NSManagedObject, Mappable {

    @NSManaged var type: String?
    @NSManaged var exercise: Exercise?

    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "SecondaryExerciseType", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        exercise <- map["exercise"]
    }
}
