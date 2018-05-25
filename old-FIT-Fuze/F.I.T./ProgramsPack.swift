//
//  ProgramsPack.swift
//  F.I.T.
//
//  Created by Ivan Chernov on 02.08.17.
//  Copyright © 2017 FIT-Team. All rights reserved.
//

import Foundation
import ObjectMapper

class ProgramsPack: Mappable {
    var programGhosts: [ProgramGhost] = []
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        programGhosts <- map["trainingPrograms"]
    }
}

class ProgramGhost: Mappable {
    var programName: String = ""
    var programJSON: [String: Any] = [:]
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        programName <- map["name"]
        programJSON = map.JSON
    }
}
