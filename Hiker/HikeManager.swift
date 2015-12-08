//
//  HikeManager.swift
//  Hiker
//
//  Created by Sam Youtsey on 11/20/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import Foundation
import CoreData
import CoreMotion

class HikeManager : NSObject {
    
    private var managedObjectContext: NSManagedObjectContext
    
    private var altimeter = CMAltimeter()
    private var pedometer = CMPedometer()
    private var hiking = false
    private var startDate: NSDate?
    private var endDate: NSDate?
    
    required init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    // TODO: recordHike needs to manage it's own save, not rely on passed in info
    func recordHike(name: String, totalSteps: NSNumber, totalElevation: NSNumber, startDate: NSDate, endDate: NSDate) {
        let hike = NSEntityDescription.insertNewObjectForEntityForName("Hike", inManagedObjectContext: self.managedObjectContext) as! Hike
        
        //3
        hike.name = name
        hike.steps = totalSteps.longLongValue
        hike.altitude = totalElevation.longLongValue
        hike.start_date = startDate
        hike.end_date = endDate
        
        //4
        do {
            try self.managedObjectContext.save()
            print("Saved hike!")
        } catch let saveError as NSError {
            print("Error saving to CoreData: \(saveError)")
        }
    }
    
    func getRecordedHikes() -> [Hike]? {
        let fetchRequest = NSFetchRequest(entityName: "Hike")
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Hike]
            return fetchResults
        } catch let fetchError as NSError {
            print("Error fetching historical data \(fetchError)")
            return nil
        }
    }
    
    func addImageToHike(hike: Hike, imageData: NSData) {
        hike.imageData = imageData
        self.managedObjectContext.refreshObject(hike, mergeChanges: true)
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error saving!")
        }
    }
    
    func startHiking() -> NSDate {
        let start = NSDate()
        self.startDate = start
        self.hiking = true
        
        return start
    }
    
    func stopHiking() -> NSDate {
        let end = NSDate()
        self.endDate = end
        self.hiking = false
        
        return end
    }
    
    func isHiking() -> Bool {
        return hiking
    }
    
    func getStartDate() -> NSDate? {
        return self.startDate
    }
    
    func getEndDate() -> NSDate? {
        return self.endDate
    }
    
    // Could we combine these two functions into one? Or do we need to separate if data is unavailable?
    func getTotalStepsSync() -> NSNumber? {
        if let start = self.startDate {
            let sema = dispatch_semaphore_create(0)
            var retVal: NSNumber!
            
            self.pedometer.queryPedometerDataFromDate(start, toDate: NSDate()) {
                (pedometerData, error) in
                    if error != nil {
                        print("Error! ", error)
                        dispatch_semaphore_signal(sema)
                    } else {
                        let steps = pedometerData!.numberOfSteps
                        retVal = steps
                        dispatch_semaphore_signal(sema)
                    }
            }
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
            return retVal
        } else {
            return nil
        }
    }
    
    func getFlightsAscendedSync() -> NSNumber? {
        if let start = self.startDate {
            let sema = dispatch_semaphore_create(0)
            var retVal: NSNumber!
            
            self.pedometer.queryPedometerDataFromDate(start, toDate: NSDate()) {
                (pedometerData, error) in
                    if error != nil {
                        print("Error! ", error)
                    } else {
                        let floorsAscended = pedometerData!.floorsAscended
                        retVal = floorsAscended
                        dispatch_semaphore_signal(sema)
                    }
            }
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
            return retVal
        } else {
            return nil
        }
    }
}
