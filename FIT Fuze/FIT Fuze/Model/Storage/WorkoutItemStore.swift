//
//  WorkoutItemStore.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 09.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class WorkoutItemStore: Store {
    typealias T = WorkoutItem
    static let shared = WorkoutItemStore()
}
