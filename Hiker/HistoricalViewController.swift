//
//  HistoryViewViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/15/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import UIKit
import CoreData

class HistoricalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var tableView: UITableView!
    
    var hikes: [Hike]?
    var selectedHike: Hike?
    
    let segueIDToHikeDetail = "HistoricalViewToHikeDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadHikes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.hikes != nil) ? self.hikes!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoricalTableViewCell", forIndexPath: indexPath) as! HistoricalTableViewCell
        
        cell.hikeDate.text = "Hike #\(indexPath.row)"
        
        return cell
    }
    
    func reloadHikes() {
        self.hikes = self.getStoredHikes()
        print(self.hikes)
        for (index, hike) in self.hikes!.enumerate() {
            print("Hike \(index)")
        }
        self.tableView.reloadData()
    }
    
    func getStoredHikes() -> [Hike] {
        let fetchRequest = NSFetchRequest(entityName: "Hike")
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Hike]
            return fetchResults
        } catch let fetchError as NSError {
            print("Error fetching historical data \(fetchError)")
            return [Hike]()
        }
    }
    
    func saveHike(name: String, totalSteps: NSNumber, totalElevation: NSNumber, startDate: NSDate, endDate: NSDate) {
        let hike = NSEntityDescription.insertNewObjectForEntityForName("Hike", inManagedObjectContext: self.managedObjectContext) as! Hike
        
        //3
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedHike = self.hikes![indexPath.row]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueIDToHikeDetail {
            let dVC = segue.destinationViewController as! HikeDetailViewController
            if let selected = self.selectedHike {
                dVC.setDetailHike(selected)
            }
        }
    }
}

class HistoricalTableViewCell : UITableViewCell {
    @IBOutlet weak var hikeDate: UILabel!
}