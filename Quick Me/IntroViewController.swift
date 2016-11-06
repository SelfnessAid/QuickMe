//
//  IntroViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 8/3/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import MediaPlayer

class IntroViewController: UIViewController {
    
    let SHOW_MAIN_MENU_IDENTIFIER = "SHOW_MAIN_MENU_IDENTIFIER"
    var check = true
    
    
    
    var controller: MPMoviePlayerViewController!
    var mTimer: NSTimer!
    
    
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initViews()
        controller?.moviePlayer.play()
    }
    
    func initViews() {
        if let path = NSBundle.mainBundle().pathForResource("intro", ofType: "mp4") {
            let url = NSURL(fileURLWithPath: path)
            controller = MPMoviePlayerViewController(contentURL: url)
            controller.moviePlayer.controlStyle = MPMovieControlStyle.None
            // To Rotate Player in Landscape mode
//            controller.moviePlayer.view.transform = CGAffineTransformConcat(controller.moviePlayer.view.transform, CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
            
                controller.moviePlayer.view.frame = self.view.frame
                controller.moviePlayer.view.backgroundColor = UIColor.whiteColor()
                controller.moviePlayer.backgroundView.backgroundColor = UIColor.whiteColor()
                self.view.addSubview(controller.moviePlayer.view)
            }
         mTimer = NSTimer.scheduledTimerWithTimeInterval(9, target: self, selector: #selector(IntroViewController.showMainMenu), userInfo: nil, repeats: false)
    }
    
    func showMainMenu() {
        if check {
            check = false
            performSegueWithIdentifier(SHOW_MAIN_MENU_IDENTIFIER, sender: self)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}
