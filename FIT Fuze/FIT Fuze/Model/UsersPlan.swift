//
//  UsersPlan.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 26.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct UsersPlan {
    var planId: TrainingPlan.Id
    var weeks: Int
    var records: [WorkoutExecutionHistory]    
}
