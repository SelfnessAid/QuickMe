//
//  UIUtils.swift
//  Tazligen
//
//  Created by Abdul Wahib on 1/14/16.
//  Copyright © 2016 Arc Coders. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import JLToast
import SVProgressHUD

class UIUtils {

    class func ChangeStatusBarColor(style: UIStatusBarStyle) {
        UIApplication.sharedApplication().statusBarStyle = style
    }
    
    class func addBackgroundColorOfStatusBar(rootView: UIView) -> UIView {
        let view = UIView(frame:
            CGRect(x: 0.0, y: -20.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        view.backgroundColor = UIColor(red: 0, green: 121/255, blue: 107/255, alpha: 1) // Primary Dark Color #00796B
        rootView.addSubview(view)
        return view
    }
    
    class func removeBackButtonTitleOfNavigationBar(navigationItem: UINavigationItem) {
        let backItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    static func showToast(message: String) {
        JLToast.makeText(message, duration: JLToastDelay.ShortDelay).show()
    }

    static func showProcessing(message: String) {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Gradient)
        SVProgressHUD.setForegroundColor(UIColor(red: 2/255, green: 232/255, blue: 178/255, alpha: 1))
        SVProgressHUD.showWithStatus(message)
    }

    static func hideProcessing() {
        SVProgressHUD.dismiss()
    }

    static func showMessage(title: String, message: String, controller: UIViewController, okHandler: () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            okHandler()
        }
        
        alertController.addAction(dismissAction)
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func drawShadow(view: UIView, size: CGSize, color: UIColor, opacity: Float, shadowRadius: CGFloat) {
        view.layer.shadowOffset = size
        view.layer.shadowColor = color.CGColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = shadowRadius
    
    }
    
    static func removeShadow(view: UIView) {
        view.layer.shadowOffset = CGSize()
        view.layer.shadowColor = UIColor.clearColor().CGColor
        view.layer.shadowOpacity = 0
        view.layer.shadowRadius = 0
        
    }
    
    static func addBorder(view: UIView, color: UIColor, width: CGFloat) {
        view.layer.borderColor = color.CGColor
        view.layer.borderWidth = width
    }
    
    
}