//
//  WorkoutExecutionHistory.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct WorkoutExecutionHistory: Codable {
    let id: Workout.Id
    let repsDone: Int
    let records: [ExerciseExecutionHistory]
}
