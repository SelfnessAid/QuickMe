//
//  ReportProblemTableViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import INTULocationManager

class ReportProblemTableViewController: UITableViewController {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var offersShowList = [String]()
    var mOffers = [Offer]()
    var mSelectedOffer: Offer!
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"

    @IBOutlet weak var offerButton: UIButton!
    @IBOutlet weak var problemTextArea: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        mOffers = RealmUtils.OfferTable.readAll()
        
        for offer in mOffers {
            let item = "\(offer.serverName!) - \(offer.price) - \(offer.readyBy.formattedDate)"
            offersShowList.append(item)
        }
        
        getCurrentLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.REPORT_PAGE
                }
            }
        }
    }
    
    // MARK: Helper Methods
    func initViews() {
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED) {
            sendButton.enabled = false
        }
        
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.REPORT_PAGE) {
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
    
    func showOffersList() {
        ActionSheetStringPicker.showPickerWithTitle(
            "Select Offer",
            rows: offersShowList,
            initialSelection: 2,
            doneBlock: { (pickerView, index, value) in
                if let offer = value as? String {
                    self.offerButton.setTitle(offer, forState: .Normal)
                    self.mSelectedOffer = self.mOffers[index]
                }
            },
            cancelBlock: { (pickerView) in
                
            },
            origin: self.view)
    }
    
    func sendReportApiCall() {
        let phoneNumber = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
        let password = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
        
        var params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber!,
            URLParams.PASSWORD_PARAM: password!,
            URLParams.LOCATION: "\(latitude);\(longitude)",
            URLParams.COMMENT: problemTextArea.text!
        ]
        
        if mSelectedOffer != nil {
            params[URLParams.OFFER_ID] = mSelectedOffer.offerId!
        }else {
            params[URLParams.OFFER_ID] = "0"
        }
        
        print(params)
        
        UIUtils.showProcessing("Please wait")
        WebserviceUtils.callPostRequest(URLConstant.REPORT, params: params, success: { (response) in
            UIUtils.hideProcessing()
            if let json = response as? NSDictionary {
                print(json)
            }
            self.navigationController?.popViewControllerAnimated(true)
            }) { (error) in
                UIUtils.hideProcessing()
                print(error.localizedDescription)
        }
        
    }

    // MARK: IBOutlets
    @IBAction func offerSwitchValueChanged(sender: UISwitch) {
        if sender.on {
            offerButton.enabled = true
            if offerButton.titleLabel?.text == "Offers" && mOffers.count > 0 {
                mSelectedOffer = mOffers[0]
                offerButton.setTitle(offersShowList[0], forState: .Normal)
            }
            offerButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        }else {
            offerButton.enabled = false
            offerButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    @IBAction func offersButtonClicked(sender: UIButton) {
        showOffersList()
    }
    
    @IBAction func sendButtonClick(sender: UIButton) {
        sendReportApiCall()
    }
    
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            
            if status == INTULocationStatus.Success {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                
            }else if status == INTULocationStatus.TimedOut {
//                UIUtils.showToast("Error: Time out for getting location")
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            }else {
                UIUtils.showToast("Error: Could not get location")
            }
            
        }
    }
    
}
