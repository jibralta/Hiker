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
    
    var tableView: UITableView!
    var hikes: [Hike]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.hikes = self.getStoredHikes()
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
    
    func getStoredHikes() -> [Hike]? {
        let fetchRequest = NSFetchRequest(entityName: "Hike")
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Hike]
            return fetchResults
        } catch let fetchError as NSError {
            print("Error fetching historical data \(fetchError)")
            return nil
        }
    }
}

class HistoricalTableViewCell : UITableViewCell {
    @IBOutlet weak var hikeDate: UILabel!
}