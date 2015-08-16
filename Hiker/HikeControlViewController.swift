//
//  ViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/4/15.
//  Copyright (c) 2015 samswiches. All rights reserved.
//

import UIKit
import CoreMotion

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
    
    var altimeter = CMAltimeter()
    var pedometer = CMPedometer()
    var cumulativeAltitude: NSNumber = 0
    var maxAltitude: NSNumber = 0
    var hiking = false
    var startDate: NSDate!
    var endDate: NSDate!
    var updateTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleStartStop(sender: AnyObject) {
        if !hiking {
            removeStartButton()
            setActiveLabels(true)
            startDataCollection()
            startDate = NSDate()
            setStartLabel(startDate)
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "minuteUpdate", userInfo: nil, repeats: true)
            startStop.setTitle("Stop", forState: .Normal)
            hiking = true
        } else {
            self.setActiveLabels(false)
            endDate = NSDate()
            stopDataCollection()
            startStop.setTitle("Start", forState: .Normal)
            hiking = false
        }
    }
    
    func minuteUpdate() {
        let hikeTime = NSDate().timeIntervalSinceDate(startDate)
        let formattedHikeTime = self.formattedStringFromInterval(hikeTime)
        print("Formatted hike time: \(formattedHikeTime)")
        dispatch_async(dispatch_get_main_queue()) {
            self.runningTimeActual.text = formattedHikeTime
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
            print(pause.frame)
        
        // Animate onscreen
        self.view.addConstraint(NSLayoutConstraint(item: pause, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
            UIView.animateWithDuration(0.5, animations: { pause.layoutIfNeeded() }) {
                (success) in
                print(pause.frame)
            }
        }
    }
    
    func startDataCollection() {
        initiateAltitudeCollection()
        initiatePedometerCollection()
    }
    
    func stopDataCollection() {
        ceaseAltitudeCollection()
        ceasePedometerCollection()
    }
    
    func initiateAltitudeCollection() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            self.altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (altitudeData, error) in
                if error != nil {
                    print("Error starting altitude updates")
                } else {
                    if altitudeData!.relativeAltitude == 0 {
                        print("First event!")
                    } else {
                        print("Altitude changed: \(altitudeData!.relativeAltitude)")
                        if altitudeData!.relativeAltitude.doubleValue > self!.maxAltitude.doubleValue {
                            self!.maxAltitude = altitudeData!.relativeAltitude
                        }
                    }
                }
            }
        }
    }
    
    func ceaseAltitudeCollection() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            self.altimeter.stopRelativeAltitudeUpdates()
        }
        print("Max altitude: \(maxAltitude)")
    }
    
    func initiatePedometerCollection() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startPedometerUpdatesFromDate(NSDate()) {
                (pedometerData, error) in
                if error != nil {
                    print("Error starting pedometer updates!")
                } else {
                    print("Number of steps: \(pedometerData!.numberOfSteps)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.steps.text = "\(pedometerData!.numberOfSteps)"
                    }
                }
            }
        }
    }
    
    func ceasePedometerCollection() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.stopPedometerUpdates()
            print("start: \(startDate)")
            print("end: \(endDate)")
            self.pedometer.queryPedometerDataFromDate(startDate, toDate: endDate) {
                (pedometerData, error) in
                if error != nil {
                    print("Error getting range of pedometer values")
                } else {
                    print("Total steps: \(pedometerData!.numberOfSteps)")
                    dispatch_async(dispatch_get_main_queue()) {
//                        self!.totalSteps.text = "\(pedometerData.numberOfSteps)"
                    }
                }
            }
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

