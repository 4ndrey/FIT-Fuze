//
//  ExercisesPack.swift
//  F.I.T.
//
//  Created by IVAN CHERNOV on 17.11.17.
//  Copyright © 2017 FIT-Team. All rights reserved.
//

import ObjectMapper

class ExercisesPack: Mappable {
    var exerciseGhosts: [ExerciseGhost] = []
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        exerciseGhosts <- map["exercises"]
    }
}

class ExerciseGhost: Mappable {
    var exerciseName: String = ""
    var exerciseJSON: [String: Any] = [:]
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        exerciseName <- map["name"]
        exerciseJSON = map.JSON
    }
}
