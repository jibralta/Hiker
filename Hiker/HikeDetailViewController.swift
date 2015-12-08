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
    
    @IBOutlet weak var image: UIImageView!
    
    var hike: Hike?
    var hikeManager: HikeManager!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let segueID = "CropImageSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hikeManager = HikeManager(managedObjectContext: self.appDelegate.managedObjectContext)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        self.name.text = self.hike?.name
        self.start.text = "\(UIUtility.formattedStringFromInterval(self.hike!.start_date.timeIntervalSince1970))"
        self.end.text = "\(UIUtility.formattedStringFromInterval(self.hike!.end_date.timeIntervalSince1970))"
        self.steps.text = "\(self.hike!.steps) steps"
        self.altitude.text = "\(self.hike!.altitude)fl"
        if let imageData = self.hike?.imageData {
            self.image.image = UIImage(data: imageData)
        } else {
            self.image.image = UIImage(named: "QMark")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDetailHike(hike: Hike) {
        self.hike = hike
    }
    
    func storeImage(image: UIImage) {
        if let h = self.hike, id = UIImagePNGRepresentation(image) {
            self.hikeManager.addImageToHike(h, imageData: id)
        } else {
            print("Could not cast!")
        }
    }
    
    @IBAction func setImageCrop(sender: AnyObject) {
        self.performSegueWithIdentifier(self.segueID, sender: nil)
    }
}
