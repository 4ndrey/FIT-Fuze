//
//  TrainingPlan.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 26.05.18.
//  Copyright © 2018 FIT. All rights reserved.
//

struct TrainingPlan: Codable {
    typealias Id = String

    let id: Id
    let name: String
    let description: String
    let type: String
    let level: String
    let defaultWeeks: Int?
    let isFree: Bool
    var workouts: [Workout]
}

extension TrainingPlan {
    static var empty: TrainingPlan {
        return TrainingPlan(id: "empty",
                            name: "",
                            description: "",
                            type: "",
                            level: "",
                            defaultWeeks: 0,
                            isFree: true,
                            workouts: [])
    }
}
