//
//  Walk.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/9/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import Foundation
import CoreData

class Walk: NSManagedObject {

    @NSManaged var distance: NSNumber
    @NSManaged var startTimestamp: NSDate
    @NSManaged var endTimestamp: NSDate
    @NSManaged var locations: AnyObject
    
    var duration: NSTimeInterval {
        get {
            return endTimestamp.timeIntervalSinceDate(startTimestamp)
        }
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        locations = [AnyObject]()
        startTimestamp = NSDate()
        distance = 0.0
    }

}
