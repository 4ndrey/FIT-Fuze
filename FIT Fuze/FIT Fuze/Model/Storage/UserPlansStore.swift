//
//  UserPlansStore.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 09.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class UserPlansStore: Store {
    typealias T = UsersPlan
    static let shared = UserPlansStore()
}
