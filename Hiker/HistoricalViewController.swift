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
    var hikeManager: HikeManager!
    
    @IBOutlet weak var tableView: UITableView!
    
    var hikes: [Hike]?
    var selectedHike: Hike?
    
    let segueIDToHikeDetail = "HistoricalViewToHikeDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hikeManager = HikeManager(managedObjectContext: self.managedObjectContext)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadHikes()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.hikes != nil) ? self.hikes!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoricalTableViewCell", forIndexPath: indexPath) as! HistoricalTableViewCell
        let hike = self.hikes![indexPath.row]
        
        cell.hikeDate.text = hike.name
        if let imageData = hike.imageData {
            cell.hikeImage.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    func reloadHikes() {
        self.hikes = self.hikeManager.getRecordedHikes()
        print(self.hikes)
        for (index, hike) in self.hikes!.enumerate() {
            print("Hike \(index)")
        }
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedHike = self.hikes![indexPath.row]
        return indexPath
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
    @IBOutlet weak var hikeImage: UIImageView!
}