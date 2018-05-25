//
//  Images.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import CoreData

@objc(Images)
class Images: NSManagedObject {

    @NSManaged var image: Data?
    @NSManaged var exercise: NSManagedObject?

}
