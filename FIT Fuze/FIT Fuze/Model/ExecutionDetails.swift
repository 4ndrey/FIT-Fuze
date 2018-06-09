//
//  ExecutionDetails.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 31.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct ExecutionDetails: Codable {
    enum State: String, Codable {
        case done
        case changed
        case skipped
    }

    var weight: Double
    var reps: Int
    var state: State
}
