//
//  WorkoutStore.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 09.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class WorkoutStore: Store {
    typealias T = Workout
    static let shared = WorkoutStore()
}
