//
//  WorkoutExerciseExecution.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 27.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

protocol WorkoutExerciseExecution {
    var exerciseId: Exercise.Id { get }
    var sets: [ExerciseExecutionSet] { get }
}

struct WorkoutSimpleSetExecution: WorkoutExerciseExecution {
    let exerciseId: Exercise.Id
    var sets: [ExerciseExecutionSet]
}

struct WorkoutSuperSetExecution: WorkoutExerciseExecution {
    let simpleSets: [WorkoutSimpleSetExecution]

    let exerciseId: Exercise.Id
    var sets: [ExerciseExecutionSet] {
        return simpleSets.flatMap { $0.sets }
    }
}
