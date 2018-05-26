//
//  DataProvider.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 26.05.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class DataProvider {
    static let shared = DataProvider()
    
    func currentProgram() -> TrainingPlan {
        // no logic here so far
        return TrainingPlan()
    }
    
    func todayWorkoutIndex() -> Int {
        // no logic here so far
        return 0
    }
}
