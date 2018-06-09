//
//  ExerciseExecutionHistory.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

struct ExerciseExecutionHistory {
    let id: Exercise.Id
    let date: Date
    let executions: [ExecutionDetails]
}
