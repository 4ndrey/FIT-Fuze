//
//  ExecutionDetails.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct ExecutionDetails {
    enum State {
        case done
        case changed
        case skipped
    }

    let weight: Double
    let reps: Int
    let state: State
}
