//
//  ContentLoader.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 22.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import ObjectMapper
import MagicalRecord

class ContentLoader: NSObject {
    
    
    func loadData()
    {
        loadMissingExercises()
        loadMissingPrograms()
    }
    
    func loadMissingExercises()
    {
        // get all existing exercises

        if let exercises = Exercise.mr_findAll() as? [Exercise] {
            // get all exercises from JSON
            let exercisesPath = Bundle.main.path(forResource: "exercises", ofType: "json")
            guard let jsonDataForExercises = try? Data(contentsOf: URL(fileURLWithPath: exercisesPath!)) else { return }
            guard let stringDataForExercises = String(data: jsonDataForExercises, encoding: String.Encoding.utf8) else { return }
            guard let ghostExercisesPack = Mapper<ExercisesPack>().map(JSONString: stringDataForExercises) else { return }
            
            // merge them
            
            for exerciseGhost in ghostExercisesPack.exerciseGhosts {
                if (exercises.filter(){ $0.name == exerciseGhost.exerciseName }).count == 0 {
                    _ = Exercise(JSON: exerciseGhost.exerciseJSON)
                }
            }
        }
    }
    
    func loadMissingPrograms() {
        if let programs = TrainingProgram.mr_findAll() as? [TrainingProgram] {
            let programsPath = Bundle.main.path(forResource: "program", ofType: "json")
            guard let jsonDataForPrograms = try? Data(contentsOf: URL(fileURLWithPath: programsPath!)) else { return }
            guard let stringDataForPrograms = String(data: jsonDataForPrograms, encoding: String.Encoding.utf8) else { return }
            guard let ghostProgramsPack = Mapper<ProgramsPack>().map(JSONString: stringDataForPrograms) else { return }
            
            // merge them
            
            for programGhost in ghostProgramsPack.programGhosts {
                if (programs.filter(){ $0.name == programGhost.programName }).count == 0 {
                    _ = TrainingProgram(JSON: programGhost.programJSON)
                }
            }
        }
    }
    
    fileprivate func loadTrainingPrograms()
    {
       /* let path = Bundle.main.path(forResource: "program", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let jsonDecoder = JSONDecoder(jsonData! as AnyObject)
        
        if let programsArray = try jsonDecoder["trainingPrograms"].get() {
            for programDecoder in programsArray {
                var program = TrainingProgram(programDecoder)
            }
        } */
    }
    
    fileprivate func loadExercises()
    {
       /*  let path = Bundle.main.path(forResource: "exercises", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let jsonDecoder = JSONDecoder(jsonData! as AnyObject)
        
        if let exercisesArray = try jsonDecoder["exercises"].get() {
            for exerciseDecoder in exercisesArray {
                var exercise = Exercise(exerciseDecoder)
            }
        } */
    }
    
    
    
    fileprivate func fetchPrograms()
    {
        let contentProvider = ContentProvider()
        let programs = contentProvider.getTrainingPrograms()
        let userPrograms = contentProvider.getUserTrainingPrograms()
    }
    
    fileprivate func fetchExercises()
    {
        let exercises = Exercise.mr_findAll() as! [Exercise]
    }
    
    

    
    
}
