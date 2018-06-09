//
//  WorkoutItem.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

class WorkoutItem: Codable {
    typealias Id = String

    let id: Id
    let exerciseId: Exercise.Id
    var executions: [ExecutionDetails]
    var nextItem: WorkoutItem?

    init(id: Id, exerciseId: Exercise.Id, executions: [ExecutionDetails], nextItem: WorkoutItem?) {
        self.id = id
        self.exerciseId = exerciseId
        self.executions = executions
        self.nextItem = nextItem
    }
}
