//
//  ContentProviderDelegate.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 20.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

@objc protocol ParseContentProviderDelegate
{
    //local
    func onLocalDataLoaded()
    
    //online
    func onTrainingProgramsFetched(trainingPrograms : [ParseTrainingProgramPreview])
    func onExercisesFetched(exercises : [ParseExercisePreview])
    func onExerciseDownloadFinished(exercise : ParseExercise)
    func onTrainingProgramDownloadFinished(trainingProgram : ParseTrainingProgram)
}