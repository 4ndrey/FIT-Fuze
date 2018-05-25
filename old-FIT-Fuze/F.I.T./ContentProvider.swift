//
//  ContentProvider.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 16.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ContentProvider: NSObject {
    

    func createNewUserProgram() -> TrainingProgram
    {
        let newUserProgram : TrainingProgram = NSEntityDescription.insertNewObject(forEntityName: "TrainingProgram", into: NSManagedObjectContext.mr_default()) as! TrainingProgram;
        newUserProgram.name = NSLocalizedString("CustomTrainingPlanDefault_Title", comment : "")
        newUserProgram.userProgram = 1
        newUserProgram.workoutRepetition = 8
        newUserProgram.programId = randomStringWithLength(10) as String
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()

        return newUserProgram
    }
    
    func copyTrainingProgram(_ trainingProgram : TrainingProgram) -> TrainingProgram
    {
        var exclude = Array<String>()
        exclude.append("Exercise")
        let userProgram = trainingProgram.clone(in: NSManagedObjectContext.mr_default(), exludeEntities: exclude) as! TrainingProgram
        
        var exercises = Array<Exercise>()
        
        trainingProgram.trainings!.enumerateObjects({ (elem, idx, stop) -> Void in
            
            let trainingObj = elem as! Training
            trainingObj.exerciseMetaMappings!.enumerateObjects({ (elem, idx, stop) -> Void in
                
                let meta = elem as! ExerciseMetaMapping
                exercises.append(meta.exercise as Exercise!)
                
            })
        })
        
        var counter = 0
        userProgram.trainings!.enumerateObjects({ (elem, idx, stop) -> Void in
            
            let trainingObj = elem as! Training
            trainingObj.name = NSLocalizedString(trainingObj.name!, comment : "");
            trainingObj.exerciseMetaMappings!.enumerateObjects({ (elem, idx, stop) -> Void in
                
                let meta = elem as! ExerciseMetaMapping
                meta.exercise = exercises[counter]
                counter += 1
                
            })
        })
        
        userProgram.userProgram = 1
        userProgram.programId = randomStringWithLength(10) as String
        userProgram.name = NSLocalizedString(trainingProgram.name!, comment : "");
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        return userProgram
    }
    
    func getExercises() -> [Exercise]
    {
        return Exercise.mr_findAll() as! [Exercise]
    }
    
    func getTrainingPrograms() -> [TrainingProgram]
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        var finalPrograms = [TrainingProgram]()
        for program in programs
        {
            if program.userProgram != 1
            {
                finalPrograms.append(program)
            }
        }
        return finalPrograms
    }
    
    func getTrainingProgramWithId(_ programId : String) -> TrainingProgram?
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        for program in programs
        {
            if program.userProgram != 1
            {
                if program.programId == programId
                {
                    return program
                }
            }
        }
        return nil
    }
    
    func getAllTrainingProgramWithId(_ programId : String) -> TrainingProgram?
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        for program in programs
        {
            if program.programId == programId
            {
                return program
            }
        }
        return nil
    }
    
    func getUserTrainingPrograms() -> [TrainingProgram]
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        var userPrograms = [TrainingProgram]()
        for program in programs
        {
            if program.userProgram == 1
            {
                userPrograms.append(program)
            }
        }
        return userPrograms
    }
    
    
    
    
    func getFreeTrainingPrograms() -> [TrainingProgram]
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        var userPrograms = [TrainingProgram]()
        for program in programs
        {
            if program.userProgram == 0 && program.isFree == 1
            {
                userPrograms.append(program)
            }
        }
        return userPrograms
    }
    
    func getPaidTrainingPrograms() -> [TrainingProgram]
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        var userPrograms = [TrainingProgram]()
        for program in programs
        {
            if program.userProgram == 0 && program.isFree == 0 && program.isPurchased == 0
            {
                userPrograms.append(program)
            }
        }
        return userPrograms
    }
    
    func getPurchasedTrainingPrograms() -> [TrainingProgram]
    {
        let programs = TrainingProgram.mr_findAll() as! [TrainingProgram]
        var userPrograms = [TrainingProgram]()
        for program in programs
        {
            if program.userProgram == 0 && program.isFree == 0 && program.isPurchased == 1
            {
                userPrograms.append(program)
            }
        }
        return userPrograms
    }
    
    func getExerciseMetaMapping(_ mappingIdentifier: String?) -> ExerciseMetaMapping?
    {
        if mappingIdentifier == nil{
            return nil
        }
        
        let exerciseMetaMappings = ExerciseMetaMapping.mr_findAll() as! [ExerciseMetaMapping]
        
        for exerciseMetaMapping in exerciseMetaMappings
        {
            if exerciseMetaMapping.mappingIdentifier == mappingIdentifier
            {
                return exerciseMetaMapping
            }
        }
        return nil
    }
    
    func getExercisesWithType(_ type : String) -> [Exercise]
    {
        let exercises = Exercise.mr_findAll() as! [Exercise]
        var filteredExercises : [Exercise] = [Exercise]()
        
        for exercise in exercises {
            for primary in exercise.primary!
            {
                let prim = primary as! PrimaryExerciseType
                let group = getMuscleGroup(prim.type!)
                if (group == type)&&(!filteredExercises.contains(exercise)) {
                    filteredExercises.append(exercise)
                }
            }
        }
        return filteredExercises
    }
    
    func getExerciseWithName(_ name : String) -> Exercise?
    {
        let exercises = Exercise.mr_findAll() as! [Exercise]
        
        for exercise in exercises
        {
            if exercise.name == name
            {
                return exercise
            }
        }
        return nil
    }
    
    
    func getProgramDictionary(_ programId : String) -> NSMutableDictionary?
    {
        let program = getAllTrainingProgramWithId(programId)
        
        if program == nil
        {
            return nil
        }
        
        let dic : NSMutableDictionary = NSMutableDictionary()
        let imagesDic : NSMutableDictionary = NSMutableDictionary()
        var trainingArray : NSArray = NSArray()
        dic.setValue(program!.name!, forKey: "planName")
        
        program!.trainings!.enumerateObjects({ (elem, idx, stop) -> Void in
            let training = elem as! Training
            let trainingDic : NSMutableDictionary = NSMutableDictionary()
            trainingDic.setValue(training.name!, forKey: "workoutName")
            var exerciseTupelArray : NSArray = NSArray()
            
            training.exerciseMetaMappings!.enumerateObjects({ (elem, idx, stop) -> Void in
                let map = elem as! ExerciseMetaMapping
                let exercise = map.exercise as Exercise!
                let meta = map.exerciseMeta as ExerciseMeta!
                
                let exerciseDic : NSMutableDictionary = NSMutableDictionary()
                var imageArray : NSArray = NSArray()
                
                exercise?.images!.enumerateObjects ({ (elem, idx, stop) -> Void in
                    let image = elem as! Images
                    let imageData = image.image ?? nil
                    let size = CGSize(width: 100, height: 100)
                    let uiImage = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "Start")
                    let newImageData = self.imageResize(uiImage!, sizeChange: size)
                    imageArray = imageArray.adding(newImageData) as NSArray
                    
                })
                exerciseDic.setValue(exercise!.name!, forKey: "exerciseName")
                exerciseDic.setValue(map.withNext, forKey: "withNext")
                imagesDic.setValue(imageArray, forKey: exercise!.name!)
                var setArray : NSArray = NSArray()
                
                meta?.sets!.enumerateObjects ({ (elem, idx, stop) -> Void in
                    let setDic : NSMutableDictionary = NSMutableDictionary()
                    let set = elem as! WorkoutSet
                    setDic.setValue(set.repetitions, forKey: "repetitions")
                    setDic.setValue(set.weights, forKey: "weight")
                    setArray = setArray.adding(setDic) as NSArray
                    
                })
                let exerciseTupelDic : NSMutableDictionary = NSMutableDictionary()
                exerciseTupelDic.setValue(exerciseDic, forKey: "exercise")
                exerciseTupelDic.setValue(setArray, forKey: "sets")
                
                exerciseTupelArray = exerciseTupelArray.adding(exerciseTupelDic) as NSArray
            })
            trainingDic.setValue(exerciseTupelArray, forKey: "workoutObjectsSet")
            trainingArray = trainingArray.adding(trainingDic) as NSArray
            
        })
        dic.setValue(trainingArray, forKey: "workouts")
        dic.setValue(imagesDic.copy(), forKey: "images")
        return dic        
    }
    
    func imageResize(_ imageObj:UIImage, sizeChange:CGSize)-> Data{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = UIImageJPEGRepresentation(scaledImage!, 0.5)
        return imageData!
    }
    
    func getAllMuscles() -> [String]
    {
        let allMuscles = ["calves", "glutes", "hamstrings", "quads", "hipabductors",
            "lowerback", "middleback", "trapezius", "lats",
            "posteriordeltoid", "lateraldeltoid", "anteriordeltoid",
            "forearms", "biceps", "triceps",
            "abdominals", "lowerabdominals", "obliques", "chest"];
        return allMuscles;
    }
    
    func getMuscleDetails(_ exercise : Exercise) -> Dictionary<String, Dictionary<String, Array<String>>>
    {
        var front = Dictionary<String, Array<String>>()
        var back = Dictionary<String, Array<String>>()
        var primaryFront = Array<String>()
        var secondaryFront = Array<String>()
        var primaryBack = Array<String>()
        var secondaryBack = Array<String>()
        
        for primary in exercise.primary!
        {
            let prim = primary as! PrimaryExerciseType
            
            if prim.type!.isEmpty
            {
                continue
            }
            
            let position = getMusclePosition(prim.type!)
            if position == "front"
            {
               primaryFront.append(prim.type!)
                
            }
            else
            {
                primaryBack.append(prim.type!)
            }
            
        }
        
        for secondary in exercise.secondary!
        {
            let sec = secondary as! SecondaryExerciseType
            if sec.type!.isEmpty
            {
                continue
            }
            let position = getMusclePosition(sec.type!)
            if position == "front"
            {
                secondaryFront.append(sec.type!)
            }
            else
            {
                secondaryBack.append(sec.type!)
            }
            
        }
        front["primary"] = primaryFront
        front["secondary"] = secondaryFront
        back["primary"] = primaryBack
        back["secondary"] = secondaryBack
        var result = Dictionary<String, Dictionary<String, Array<String>>>()
      
        if primaryBack.count >= 1 || secondaryBack.count >= 1
        {
            result["back"] = back
        }
        
        if primaryFront.count >= 1 || secondaryFront.count >= 1
        {
            result["front"] = front
        }

        return result
        
    }
    
    func getMusclePosition(_ muscle : String) -> String
    {
        let front = "front"
        let back = "back"
        
        switch muscle
        {
            case "calves": return back
            case "glutes": return back
            case "hamstrings": return back
            case "lowerback": return back
            case "middleback": return back
            case "trapezius": return back
            case "triceps": return back
            case "lats": return back
            case "posteriordeltoid": return back
            case "lateraldeltoid": return back
            
            case "abdominals": return front
            case "lowerabdominals": return front
            case "biceps": return front
            case "chest": return front
            case "forearms": return front
            case "quads": return front
            case "anteriordeltoid": return front
            case "hipabductors": return front
            case "obliques": return front
         
            default : return front
        }
        
    }
    
    fileprivate func getMuscleGroup(_ muscle : String) -> String
    {
        let legs = "legs"
        let back = "back"
        let shoulders = "shoulders"
        let arms = "arms"
        let abs = "abs"
        let chest = "chest"
        
        switch muscle
        {
        case "calves": return legs
        case "glutes": return legs
        case "hamstrings": return legs
        case "quads": return legs
        case "hipabductors": return legs
            
        case "lowerback": return back
        case "middleback": return back
        case "trapezius": return back
        case "lats": return back
            
        case "posteriordeltoid": return shoulders
        case "lateraldeltoid": return shoulders
        case "anteriordeltoid": return shoulders
            
        case "forearms": return arms
        case "biceps": return arms
        case "triceps": return arms
            
        case "abdominals": return abs
        case "lowerabdominals": return abs
        case "obliques": return abs
            
        case "chest": return chest
            
        default : return ""
        }
    }
    
    fileprivate func randomStringWithLength (_ len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0...len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    

}
