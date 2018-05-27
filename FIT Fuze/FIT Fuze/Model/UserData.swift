//
//  UserData.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 26.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct UserData {
    var selectedPlanId: TrainingPlan.Id      // current traning plan
    var weeks: Int                           // training weeks count
    var records: [WorkoutRecord]             // info about Workouts execution
}
