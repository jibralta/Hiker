//
//  ViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/4/15.
//  Copyright (c) 2015 samswiches. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData

class HikeControlViewController: UIViewController {

    // Start/Stop
    @IBOutlet weak var startStop: UIButton!
    // Running time
    @IBOutlet weak var runningTime: UILabel!
    @IBOutlet weak var runningTimeLegendConstraint: NSLayoutConstraint!
    @IBOutlet weak var runningTimeConstraint: NSLayoutConstraint!
    @IBOutlet weak var runningTimeActual: UILabel!
    
    // Altitude
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var altitudeLegendConstraint: NSLayoutConstraint!
    @IBOutlet weak var altitudeConstraint: NSLayoutConstraint!
    
    // Steps
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var stepsLegendConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsConstraint: NSLayoutConstraint!
    
    // Start time
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var startTimeLegendConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTimeConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTimeActual: UILabel!
    
    let legendOffScreenConstant: CGFloat = -300
    let labelOnScreenShiftConstant: CGFloat = -20
    let legendOnScreenConstant: CGFloat = 20
    let labelOffScreenShiftConstant: CGFloat = 250
    
    let segueIDToHistorical = "ActiveHikeToHistoricalHikes"
    let segueIDToStaticImage = "HistoryImage"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var hikeManager: HikeManager!
    var updateTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becameActive", name: "UIApplicationDidBecomeActiveNotification", object: nil)
        
        self.view.clipsToBounds = true
        
        self.hikeManager = HikeManager(managedObjectContext: self.managedObjectContext)
    }
    
    func becameActive() {
        print("Became active")
        self.refreshStatsLabels()
    }
    
    @IBAction func toggleStartStop(sender: AnyObject) {
        if !self.hikeManager.isHiking() {
            removeStartButton()
            setActiveLabels(true)
            let startDate = self.hikeManager.startHiking()
            setStartLabel(startDate)
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "refreshStatsLabels", userInfo: nil, repeats: true)
            startStop.setTitle("Stop", forState: .Normal)
        } else {
            let totalSteps = self.hikeManager.getTotalSteps()!
            let flightsAscended = self.hikeManager.getFlightsAscended()!
            let startDate = self.hikeManager.getStartDate()!

            let endDate = self.hikeManager.stopHiking()
            self.displayRecordHikeAlert(totalSteps, totalFlightsAscended: flightsAscended, startDate: startDate, endDate: endDate)
            startStop.setTitle("Start", forState: .Normal)
        }
    }
    
    func refreshStatsLabels() {
        if self.hikeManager.isHiking() {
            print("Refreshing labels")
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshActiveTime()
                self.refreshStepsLabel()
                self.refreshAltitudeLabel()
            }
        }
    }
    
    func refreshActiveTime() {
        if let start = self.hikeManager.getStartDate() {
            let hikeTime = NSDate().timeIntervalSinceDate(start)
            let formattedHikeTime = self.formattedStringFromInterval(hikeTime)
            self.runningTimeActual.text = formattedHikeTime
        }
    }
    
    func refreshStepsLabel() {
        if let steps = self.hikeManager.getTotalSteps() {
            self.steps.text = "\(steps.longValue)"
        }
    }
    
    func refreshAltitudeLabel() {
        if let flightsAscended = self.hikeManager.getFlightsAscended() {
            self.altitude.text = "\(flightsAscended.longValue)fl"
        }
    }
    
    func formattedStringFromInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    func setActiveLabels(active: Bool) {
        let labelsArr = [(self.runningTimeLegendConstraint, self.runningTimeConstraint),
            (self.altitudeLegendConstraint, self.altitudeConstraint),
            (self.stepsLegendConstraint, self.stepsConstraint),
            (self.startTimeLegendConstraint, self.startTimeConstraint)]
        for labelSet in labelsArr {
            shiftLabelsToActive(active, legendConstraint: labelSet.0, valueConstraint: labelSet.1)
        }
    }
    
    func setStartLabel(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mma"
        
        dispatch_async(dispatch_get_main_queue()) {
            self.startTimeActual.text = formatter.stringFromDate(date)
        }
    }
    
    func removeStartButton() {
        dispatch_async(dispatch_get_main_queue()) {
            self.view.layoutIfNeeded()
        let pause = UIButton()
        pause.translatesAutoresizingMaskIntoConstraints = false
        pause.setTitle("Pause", forState: .Normal)
        pause.setTitleColor(UIColor.blackColor(), forState: .Normal)
        pause.titleLabel?.font = UIFont(name: "SanFrancisco-Display", size: 25.0)
        pause.backgroundColor = UIColor.blueColor()
        self.view.addSubview(pause)
        
        // Position offscreen
        self.view.addConstraint(NSLayoutConstraint(item: pause, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pause]|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: ["pause" : pause]))
        self.view.layoutIfNeeded()
        
        // Animate onscreen
        self.view.addConstraint(NSLayoutConstraint(item: pause, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
            UIView.animateWithDuration(0.5, animations: { pause.layoutIfNeeded() }) {
                (success) in
                print(pause.frame)
            }
        }
    }
    
    func displayRecordHikeAlert(totalSteps: NSNumber, totalFlightsAscended: NSNumber, startDate: NSDate, endDate: NSDate) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Save Hike", message: "Would you like to name and save this hike?", preferredStyle: .Alert)
            let saveAction = UIAlertAction(title: "Save", style: .Default) {
                (action) in
                print("Saving!")
                let nameField = alert.textFields![0] as UITextField
                self.hikeManager.recordHike(nameField.text!, totalSteps: totalSteps, totalElevation: totalFlightsAscended, startDate: startDate, endDate: endDate)
                self.performSegueWithIdentifier(self.segueIDToHistorical, sender: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) {
                (action) in
                print("Canceling!")
            }
            
            alert.addTextFieldWithConfigurationHandler {
                (textField) in
                textField.text = "New Hike"
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shiftLabelsToActive(active: Bool, legendConstraint: NSLayoutConstraint, valueConstraint: NSLayoutConstraint) {
        dispatch_async(dispatch_get_main_queue()) {
            
            let legendShift: CGFloat
            let labelShift: CGFloat
            if active {
                legendShift = self.legendOffScreenConstant
                labelShift = self.labelOnScreenShiftConstant
            } else {
                legendShift = self.legendOnScreenConstant
                labelShift = self.labelOffScreenShiftConstant
            }
            legendConstraint.constant = legendShift
            valueConstraint.constant = labelShift
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.view.layoutIfNeeded() }, completion: nil)
        }
    }
}

