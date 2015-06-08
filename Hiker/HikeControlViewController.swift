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
    @IBOutlet weak var timeLegendBackground: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    // Altitude
    @IBOutlet weak var altitudeLegendBackground: UIView!
    @IBOutlet weak var altitudeLabel: UILabel!
    // Steps
    @IBOutlet weak var stepsLegendBackground: UIView!
    @IBOutlet weak var stepsLabel: UILabel!
    // Start time
    @IBOutlet weak var startTimeLegendBackground: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    var altimeter = CMAltimeter()
    var pedometer = CMPedometer()
    var cumulativeAltitude: NSNumber = 0
    var maxAltitude: NSNumber = 0
    var hiking = false
    var startDate: NSDate!
    var endDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rotates = [timeLabel, altitudeLabel, stepsLabel, startTimeLabel]
        let corners = [timeLegendBackground, altitudeLegendBackground, stepsLegendBackground, startTimeLegendBackground, startStop]
        for corner in corners {
            corner.layer.cornerRadius = 3.0
        }
        
        for rotate in rotates {
            rotate.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleStartStop(sender: AnyObject) {
        if !hiking {
            startDate = NSDate()
            startDataCollection()
            startStop.setTitle("Stop", forState: .Normal)
            startStop.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 107/255, alpha: 1.0)
            hiking = true
        } else {
            endDate = NSDate()
            stopDataCollection()
            startStop.setTitle("Start", forState: .Normal)
            startStop.backgroundColor = UIColor(red: 46/255, green: 218/255, blue: 84/255, alpha: 1.0)
            hiking = false
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
//                        self!.steps.text = "\(pedometerData.numberOfSteps)"
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
}

