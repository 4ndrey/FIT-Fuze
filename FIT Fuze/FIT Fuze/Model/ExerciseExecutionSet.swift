//
//  ExerciseExecutionSet.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 27.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct ExerciseExecutionSet {
    enum State {
        case completed
        case skipped
        case modified
    }

    let state: State     
    let repetitions: Int  // number of repetitions in set
    let weight: Double    // weight in set
}
