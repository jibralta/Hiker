//
//  HikeDetailViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 10/10/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import UIKit

class HikeDetailViewController: UIViewController {
    
    var hike: Hike!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDetailHike(hike: Hike) {
        self.hike = hike
    }
}
