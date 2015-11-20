//
//  HikeDetailViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 10/10/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import UIKit

class HikeDetailViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var altitude: UILabel!
    
    var hike: Hike!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.text = self.hike.name
        self.start.text = "\(self.hike.start_date)"
        self.end.text = "\(self.hike.end_date)"
        self.steps.text = "\(self.hike.steps)"
        self.altitude.text = "\(self.hike.altitude)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDetailHike(hike: Hike) {
        self.hike = hike
    }
}
