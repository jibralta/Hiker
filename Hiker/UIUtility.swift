//
//  UIUtility.swift
//  Hiker
//
//  Created by Sam Youtsey on 12/8/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import Foundation

class UIUtility {
    class func formattedStringFromInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d", hours, minutes)
    }
}