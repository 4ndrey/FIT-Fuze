//
//  ExerciseStore.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 09.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class ExerciseStore: Store {
    typealias T = Exercise
    static let shared = ExerciseStore()
}
