//
//  Exercise.swift
//  FIT Fuze
//
//  Created by Andrey Toropchin on 26.05.2018.
//  Copyright © 2018 FIT. All rights reserved.
//

struct Exercise: Codable {
    typealias Id = String

    let id: Id
    let name: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
}
