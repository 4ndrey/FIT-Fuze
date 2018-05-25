//
//  Exercise.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 29.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import ObjectMapper

@objc(Exercise)
class Exercise: NSManagedObject, Mappable {
    
    @NSManaged var equipment: AnyObject?
    @NSManaged var exerciseDescription: String?
    @NSManaged var name: String?
    @NSManaged var steps: AnyObject?
    @NSManaged var type: String?
    @NSManaged var exerciseMetaMapping: NSSet?
    @NSManaged var images: NSOrderedSet?
    @NSManaged var primary: NSSet?
    @NSManaged var secondary: NSSet?
    @NSManaged var history: NSSet?
    
    override var description: String {
        return getExerciseDescription()
    }
    
    required convenience init?(map: Map) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        mapping(map: map)
        addImages()
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        exerciseDescription <- map["description"]
        type <- map["type"]
        equipment <- map["equipment"]
        steps <- map["steps"]
        var primaryTmp = Array<PrimaryExerciseType>()
        primaryTmp <- map["primary"]
        primary = NSSet(array: primaryTmp)
        var secondaryTmp = Array<SecondaryExerciseType>()
        secondaryTmp <- map["secondary"]
        secondary = NSSet(array: secondaryTmp)
    }
    
    convenience init(name: String, exerciseImage: UIImage, muscles : Array<String>) {
        let ctx = NSManagedObjectContext.mr_default()
        let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: ctx!)
        self.init(entity: entity!, insertInto: ctx)
        
        self.name = name
        self.exerciseDescription = ""
        self.type = "own"
        
        var primaryTmp = Array<PrimaryExerciseType>()
        for muscle in muscles {
            let primary = PrimaryExerciseType(muscle)
            primaryTmp.append(primary)
        }
        self.primary = NSSet(array: primaryTmp)
        
        var images = Array<Images>()
        let image = Images.mr_createEntity() as! Images
        image.image = UIImageJPEGRepresentation(exerciseImage, 0.9)!
        image.exercise = self
        for _ in 0...7 {
            images.append(image)
        }
        self.images = NSOrderedSet(array: images)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func setImage(_ exerciseImage: UIImage)
    {
        var images = Array<Images>()
        let image = Images.mr_createEntity() as! Images
        image.image = UIImageJPEGRepresentation(exerciseImage, 0.9)!
        image.exercise = self
        for _ in 0...7 {
            images.append(image)
        }
        self.images = NSOrderedSet(array: images)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    class func removeExerciseWithName(_ name: String)
    {
        let exercises = Exercise.mr_findAll(with: NSPredicate(format: "name = %@", name))
        let exercise = exercises?[0] as? Exercise
        if let realExerciseToDelete = exercise {
            let programs = TrainingProgram.mr_findAll()
            for program in programs! {
                if let realTrainigProgram = program as? TrainingProgram {
                    realTrainigProgram.trainings!.enumerateObjects({ (elem, idx, stop) -> Void in
                        let training = elem as! Training
                        training.exerciseMetaMappings!.enumerateObjects({ (elem, idx, stop) -> Void in
                            let map = elem as! ExerciseMetaMapping
                            let exercise = map.exercise as Exercise!
                            if(exercise == realExerciseToDelete) {
                                if let meta = map.exerciseMeta {
                                    NSManagedObjectContext.mr_default().delete(meta)
                                }
                                NSManagedObjectContext.mr_default().delete(map)
                            }
                        })
                    })
                }
                
            }
            
            NSManagedObjectContext.mr_default().delete(realExerciseToDelete)
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
    }
    
    fileprivate func addImages()
    {
        let resPath = Bundle.main.resourcePath!
        let path = resPath + "/ExerciseImages/" + self.name!
        let fileManager = FileManager.default
        if let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: path)
        {
            var images = Array<Images>()
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix("jpeg") {
                    let imagePath = path + "/" + element
                    let image = Images.mr_createEntity() as! Images
                    image.image = try? Data(contentsOf: URL(fileURLWithPath: imagePath))
                    image.exercise = self
                    images.append(image)
                }
            }
            self.images = NSOrderedSet(array: images)
            
        }
        else
        {
            return;
        }
    }
    
    
    fileprivate func getExerciseDescription() -> String
    {
        var output = "exerciseName: " + self.name!
        output += "\n" + "exerciseDescription: "
        output += self.exerciseDescription! + "\n"
        output += "exerciseType: " + self.type! + "\n\n"
        
        let equipments = self.equipment as! [String]
        output += "equipments: " + "\n"
        for equ in equipments
        {
            output += equ + "\n"
        }
        
        let steps = self.steps as! [String]
        output += "\n" + "steps: " + "\n"
        for step in steps
        {
            output += step + "\n"
        }
        
        let primarys = self.primary?.allObjects as! [PrimaryExerciseType]
        output += "\n" + "primary: " + "\n"
        for primary in primarys
        {
            output += primary.type! + "\n"
        }
        
        let secondarys = self.secondary?.allObjects as! [SecondaryExerciseType]
        output += "\n" + "secondary: " + "\n"
        for secondary in secondarys
        {
            output += secondary.type! + "\n"
        }
        
        
        return output
    }
    
}
