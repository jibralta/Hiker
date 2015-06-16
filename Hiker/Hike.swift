//
//  Hike.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/15/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import Foundation

class Hike : NSObject {
    var startDate: NSDate
    var endDate: NSDate
    var altitude: Int
    var steps: Int
    
    init(startDate: NSDate, endDate: NSDate, altitude: Int, steps: Int) {
        self.startDate = startDate
        self.endDate = endDate
        self.altitude = altitude
        self.steps = steps
    }
}