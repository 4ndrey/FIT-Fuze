//
//  WorkoutItem.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct WorkoutItem: Codable {
    typealias Id = String

    let id: Id
    let exerciseId: Exercise.Id
    var executions: [ExecutionDetails]
    let nextItemId: WorkoutItem.Id?
}
