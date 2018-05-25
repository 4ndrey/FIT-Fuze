//
//  ContentProvider.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ParseContentProvider: NSObject, ParseLocalInterface, ParseInterface {
    
    private var delegate : ParseContentProviderDelegate?
    private var parseController : ParseOnlineController?
    private var parseLocalController : ParseLocalController?
    private var localStorage = LocalStorage.sharedInstance
    
    
    init(delegate : ParseContentProviderDelegate)
    {
        super.init()
        self.delegate = delegate
        self.parseController = ParseOnlineController(delegate: self)
        self.parseLocalController = ParseLocalController(delegate: self)
        
    }
    
    func getLocalStorage() -> LocalStorage
    {
        return self.localStorage
    }
    
    func loadLocalData()
    {
        self.parseLocalController!.loadlocalData()
    }
    
    func fetchExercises()
    {
        self.parseController!.fetchExercises()
    }
    
    func fetchTrainingPrograms()
    {
        self.parseController!.fetchTrainingPrograms()
    }
    
    func downloadExercise(exerciseID : String)
    {
        self.parseController!.downloadExercise(exerciseID)
    }
    
    func downloadTrainingProgram(programID : String)
    {
        self.parseController!.donwloadTrainingProgram(programID)
    }
        
    
    
    // delegates
    
    func onLocalDataLoaded()
    {
        self.delegate?.onLocalDataLoaded()
    }
    
    func onTrainingProgramsFetched(trainingPrograms : [ParseTrainingProgramPreview])
    {
      self.delegate?.onTrainingProgramsFetched(trainingPrograms)
    }
    
    func onExercisesFetched(exercises : [ParseExercisePreview])
    {
       self.delegate?.onExercisesFetched(exercises)
    }
    
    func onExerciseDownloadFinished(exercise : ParseExercise)
    {
         self.delegate?.onExerciseDownloadFinished(exercise)
    }
    
    func onTrainingProgramDownloadFinished(trainingProgram : ParseTrainingProgram)
    {
        self.delegate?.onTrainingProgramDownloadFinished(trainingProgram)
    }
    
    
}