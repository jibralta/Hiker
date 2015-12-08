//
//  Hike.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/15/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import Foundation
import CoreData

class Hike : NSManagedObject {
    @NSManaged var name: String
    @NSManaged var start_date: NSDate
    @NSManaged var end_date: NSDate
    @NSManaged var altitude: Int64
    @NSManaged var steps: Int64
    @NSManaged var imageData: NSData?
}