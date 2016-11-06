//
//  ProviderViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/22/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class ProviderViewController: UIViewController {

    @IBOutlet weak var applyNowButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var abnTextField: UITextField!
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://quickme.com.au/providerApplication.html")!))
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED) {
            applyNowButton.enabled = false
        }
    }

    // MARK: API Calls
    func callApiToBecomeProvider() {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.ABN : abnTextField.text!
        ]
        
        UIUtils.showProcessing("Please Wait")
        WebserviceUtils.callPostRequest(URLConstant.BECOME_PROVIDER, params: params, success: { (response) in
            UIUtils.hideProcessing()
            self.navigationController?.popViewControllerAnimated(true)
            }) { (error) in
                UIUtils.hideProcessing()
                print(error.localizedDescription)
        }
        
        
    }
    
    // MARK: IBOutlets
    @IBAction func applyNowButtonClick(sender: AnyObject) {
        callApiToBecomeProvider()
    }
    
}
