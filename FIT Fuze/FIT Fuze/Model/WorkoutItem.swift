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
    let metaData: MetaData
    var executions: [ExecutionDetails]
    var nextItem: WorkoutItem?

    init(id: Id, exerciseId: Exercise.Id, metaData: MetaData, executions: [ExecutionDetails], nextItem: WorkoutItem?) {
        self.id = id
        self.exerciseId = exerciseId
        self.metaData = metaData
        self.executions = executions
        self.nextItem = nextItem
    }

    struct MetaData: Codable {
        let defaultRepetitions: Int
        let defaultRestTime: Int
        let defaultSets: Int
    }
}
