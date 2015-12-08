//
//  ViewController.swift
//  SlideMe
//
//  Created by Sam Youtsey on 11/17/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import UIKit

class SelectImageCropViewController: UIViewController {
    
    var slideView: UIView!
    var topView: UIView!
    var bottomView: UIView!
    
    var lastTouch: UITouch?
    let paneHeight: CGFloat = 100
    
    @IBOutlet weak var imageSelectingUpon: UIImageView!
    @IBOutlet weak var setViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.slideView = UIView()
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(slideView)
        
        self.view.addConstraint(NSLayoutConstraint(item: slideView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: paneHeight))
        self.view.addConstraint(NSLayoutConstraint(item: slideView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: slideView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: slideView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        self.topView = UIView()
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.topView.backgroundColor = UIColor.grayColor()
        self.topView.layer.opacity = 0.75
        self.view.addSubview(self.topView)
        
        let windowHeight = UIApplication.sharedApplication().windows.first!.frame.height
        self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: windowHeight))
        self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: .Bottom, relatedBy: .Equal, toItem: self.slideView, attribute: .Top, multiplier: 1.0, constant: 0))
        
        self.bottomView = UIView()
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.backgroundColor = UIColor.grayColor()
        self.bottomView.layer.opacity = 0.75
        self.view.addSubview(self.bottomView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: windowHeight))
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomView, attribute: .Top, relatedBy: .Equal, toItem: self.slideView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(self.setViewButton)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        if let touchCenter = touch?.locationInView(self.view) {
            let slideViewFrame = slideView.frame
            if CGRectContainsPoint(slideViewFrame, touchCenter) {
                let properX = self.slideView.center.x
                let properY = self.slideView.center.y - (touch!.previousLocationInView(self.view).y - touchCenter.y)
                let properCenter = CGPointMake(properX, properY)
                
                let windowHeight = UIApplication.sharedApplication().windows.first!.frame.height
                if properCenter.y + (paneHeight / 2) > windowHeight || properCenter.y - (paneHeight / 2) < 0 {
                    return
                } else {
                    self.slideView.center = properCenter
                    self.topView.center = CGPointMake(properX, properY - ((self.paneHeight / 2) + windowHeight / 2))
                    self.bottomView.center = CGPointMake(properX, properY + ((self.paneHeight / 2) + windowHeight / 2))
                }
            }
        }
    }
    
    @IBAction func setReducedFrame(sender: AnyObject) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        let ctx = UIGraphicsGetCurrentContext()!
        self.imageSelectingUpon.layer.renderInContext(ctx)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let slideViewFrame = self.slideView.frame
        // TODO: unhardcode these values
        let newFrame = CGRectMake(slideViewFrame.origin.x, 567-slideViewFrame.origin.y, 375, 100)
        let ci = CIImage(image: scaledImage)!
        let reduced = ci.imageByCroppingToRect(newFrame)
        print("Reduced!")
        if let parent = self.presentingViewController as? HikeDetailViewController {
            let ctx = CIContext(options: nil)
            let cgImg = ctx.createCGImage(reduced, fromRect: reduced.extent)
            let img = UIImage(CGImage: cgImg)
            parent.storeImage(img)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

