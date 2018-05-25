//
//  TableConstants.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 18.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation

struct TableConstants {
    
    static let IDENTIFIER = "identifier"
    
    //Parse Tables
    static let TABLE_EXERCISES_IMAGES = "ExerciseImages"
    static let TABLE_EXERCISES = "Exercises"
    static let TABLE_EXERCISES_META = "ExerciseMeta"
    static let TABLE_EXERCISES_META_MAPPING = "ExerciseMetaMapping"
    static let TABLE_TRAINING_PROGRAMS = "TrainingPrograms"
    static let TABLE_TRAININGS = "Trainings"

    
    
    //Local User Training Programs Table
    static let TABLE_LOCAL_USER_PROGRMS = "localUserPrograms"
    
    //Local Sets Table
    static let TABLE_LOCAL_SETS = "localSets"
    
    //Local Sets Fields
    static let FIELD_SETS_REPETITIONS = "repetitions"
    static let FIELD_SETS_WEIGHTS = "weights"
    
    
    //TABLE_TRAININGS Fields
    static let FIELD_TRAININGS_NAME = "trainingName"
    static let FIELD_TRAININGS_DESCRIPTION = "trainingDescription"
    static let FIELD_TRAININGS_META = "exerciseMetaMapping"
    
    //TABLE_TRAINING_PROGRAMS Fields
    static let FIELD_TRAINING_PROGRAMS_TYPE = "programType"
    static let FIELD_TRAINING_PROGRAMS_NAME = "programName"
    static let FIELD_TRAINING_PROGRAMS_DESCRIPTION = "programDescription"
    static let WORKOUTS_DATA = "workouts"
    
    static let FIELD_TRAINING_PROGRAMS_TRAININGS = "trainingsPointer"
    
    //TABLE_EXERCISES_META_MAPPING Fields
    static let FIELD_EXERCISES_META_MAPPING_META = "exerciseMeta"
    static let FIELD_EXERCISES_META_MAPPING_EXERCISE = "exercise"
    
     //TABLE_EXERCISES_META Fields
    static let FIELD_EXERCISES_META_REPETITIONS_DEFAULT = "exerciseRepetitions"
    static let FIELD_EXERCISES_META_REST_DEFAULT = "exerciseRestTime"
    static let FIELD_EXERCISES_META_SETS_DEFAULT = "exerciseSets"
    static let FIELD_EXERCISES_META_SETS = "sets"
    
     //TABLE_EXERCISES Fields
    static let FIELD_EXERCISES_DESCRIPTION = "description"
    static let FIELD_EXERCISES_NAME = "name"
    static let FIELD_EXERCISES_STEPS = "steps"
    static let FIELD_EXERCISES_TYPE = "type"
    static let FIELD_EXERCISES_PRIMARY = "primary"
    static let FIELD_EXERCISES_SECONDARY = "secondary"
    static let FIELD_EXERCISES_EQUIPMENT = "equipment"
    static let FIELD_EXERCISES_IMAGES = "exerciseImages"

    
     //TABLE_EXERCISES_IMAGES Fields
    static let TABLE_EXERCISES_IMAGES_IMAGE = "image"
    
    
    
}