//
//  TableViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UITableViewController, LocationMapViewControllerDelegate {
    
    let LOCATION_PICK_IDENTIFIER = "LOCATION_PICK_IDENTIFIER"
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    @IBOutlet weak var minPriceField: UITextField!
    @IBOutlet weak var maxPriceField: UITextField!

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var setButton: UIButton!
    
    var lat: Double!
    var lng: Double!
    var locationName: String!
    var radius: Double!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED) {
            setButton.enabled = false
        }
        
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.NOTIFICATION_SETTINGS) {
            mTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainMenuTableViewController.animateHelpButton), userInfo: nil, repeats: true)
        }
        
    }
    
    func animateHelpButton() {
        if helpBarButton.tintColor == UIColor.whiteColor() {
            helpBarButton.tintColor = UIColor.clearColor()
        }else {
            helpBarButton.tintColor = UIColor.whiteColor()
        }
    }
    
    // MARK: API Calls
    func callNotificationSettingApi() {
        
        var location = ""
        if !locationNameLabel.text!.isEmpty && lat != nil {
            location="\(self.lat!);\(self.lng!)"
        }
        var minPrice = "0"
        var maxPrice = "0"
        if !minPriceField.text!.isEmpty {
            minPrice = minPriceField.text!
            maxPrice = minPriceField.text!
        }
        
        var radius = "0"
        if self.radius != nil {
            radius = "\(self.radius!)"
        }
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.LOCATION : location,
            URLParams.MIN_PRICE : minPrice,
            URLParams.MAX_PRICE : maxPrice,
            URLParams.DESCRIPTION_TOKEN : descriptionField.text!,
            URLParams.RADIUS : radius
        ]
        UIUtils.showProcessing("Please wait")
        
        WebserviceUtils.callPostRequest(
            URLConstant.NOTIFICATION_SETTINGS,
            params: params,
            success: { (response) in
                UIUtils.hideProcessing()
                self.navigationController?.popViewControllerAnimated(true)
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
        
        
    }
    
    // MARK: LocationMapViewController Delegate Methods
    func showLocationDetails(latitude: Double?, longitude: Double?, locationName: String?, radius: Double) {
        self.lat = latitude
        self.lng = longitude
        self.locationName = locationName
        self.radius = radius
        
        if let l = locationName where !l.isEmpty {
            self.locationName = l
            self.locationNameLabel.text = self.locationName
        }else {
            self.locationNameLabel.text = "\(lat.roundToPlaces(2)),\(lng.roundToPlaces(2))"
        }
        
        self.radius = radius
        self.locationNameLabel.text?.appendContentsOf(" + \(radius/1000)KM")
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == LOCATION_PICK_IDENTIFIER {
                if let dvc = segue.destinationViewController as? LocationMapViewController {
                    dvc.delegate = self
                }
            }else if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.NOTIFICATION_SETTINGS_PAGE
                }
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func setButtonClick(sender: AnyObject) {
        if !minPriceField.text!.isEmpty && !maxPriceField.text!.isEmpty {
            if Int(minPriceField.text!) >= Int(maxPriceField.text!) {
                UIUtils.showToast("Min Price should be less than Max Price")
                return
            }
        }else {
            minPriceField.text = ""
            maxPriceField.text = ""
        }
        
        
        callNotificationSettingApi()
    }
 
    @IBAction func clearAllClick(sender: AnyObject) {
        lat = nil
        lng = nil
        locationName = nil
        radius = nil
        descriptionField.text = ""
        minPriceField.text = ""
        maxPriceField.text = ""
        locationNameLabel.text = ""
    }

}
