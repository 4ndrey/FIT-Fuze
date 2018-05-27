//
//  Workout.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 26.05.18.
//  Copyright © 2018 FIT. All rights reserved.
//

struct Workout {
    typealias Id = String

    let id: Id
    let name: String
    var exercises: [Exercise]
}
