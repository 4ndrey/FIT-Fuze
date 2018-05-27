//
//  WorkoutRecord.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 26.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

struct WorkoutRecord {
    let workoutId: Workout.Id   // linked Workout
    let date: Date              // execution Date
    var executions: [WorkoutExerciseExecution]
}
