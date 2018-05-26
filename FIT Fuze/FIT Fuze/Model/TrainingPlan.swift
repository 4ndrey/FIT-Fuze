//
//  TrainingPlan.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 26.05.18.
//  Copyright © 2018 FIT. All rights reserved.
//

struct TrainingPlan {
    let id: String
    let name: String
    let description: String
    let type: String
    let level: String
    let repetitions: Int
    let isFree: Bool
    let workouts: [Workout]
}

extension TrainingPlan {
    static var empty: TrainingPlan {
        return TrainingPlan(id: "", name: "", description: "", type: "", level: "", repetitions: 0, isFree: true, workouts: [])
    }
}
