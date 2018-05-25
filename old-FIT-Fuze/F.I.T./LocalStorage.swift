//
//  LocalStorage.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class LocalStorage: NSObject {
    
    private var exercises : [String : ParseExercise] = [String: ParseExercise]()
    private var trainingPrograms : [String : ParseTrainingProgram] = [String: ParseTrainingProgram]()
    private var localUserTrainingPrograms : [String : ParseTrainingProgram] = [String: ParseTrainingProgram]()
    
    class var sharedInstance: LocalStorage {
        struct Static {
            static var instance: LocalStorage?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = LocalStorage()
        }
        return Static.instance!
    }
    
    func isExerciseDownloaded(exerciseIdentifier : String) -> Bool
    {
        let ex = exercises[exerciseIdentifier]
        if ex == nil
        {
            return false
        }
        else
        {
            return true
        }
        
    }
    
    
    
    func addExercise(exercise : ParseExercise)
    {
      self.exercises[exercise.identifier!] = exercise
    }
    
    
    func getExercise(exerciseIdentifier : String) -> ParseExercise?
    {
        return self.exercises[exerciseIdentifier]
        
    }
    
    func getExercises() -> [ParseExercise]
    {
        return Array(self.exercises.values)
    }
    
    
    
    
    func addTrainingProgram(trainingProgram : ParseTrainingProgram)
    {
        self.trainingPrograms[trainingProgram.identifier!] = trainingProgram
    }
    
    
    func getTrainingProgram(trainingProgramIdentifier : String) -> ParseTrainingProgram?
    {
        return self.trainingPrograms[trainingProgramIdentifier]
        
    }
    
    func getTrainingPrograms() -> [ParseTrainingProgram]
    {
        return Array(self.trainingPrograms.values)
        
    }
    
    
    
    
    func addUserTrainingProgram(trainingProgram : ParseTrainingProgram)
    {
        self.localUserTrainingPrograms[trainingProgram.identifier!] = trainingProgram
    }
    
    
    func getUserTrainingProgram(trainingProgramIdentifier : String) -> ParseTrainingProgram?
    {
        return self.localUserTrainingPrograms[trainingProgramIdentifier]
        
    }
    
    func getUserTrainingPrograms() -> [ParseTrainingProgram]
    {
        return Array(self.localUserTrainingPrograms.values)
        
    }
    

}