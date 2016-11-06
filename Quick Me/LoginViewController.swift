//
//  LoginViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/20/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let MAIN_MENU_SEGUE = "MAIN_MENU_SEGUE"
    let LOGIN_HELP_IDENTIFIER = "LOGIN_HELP_IDENTIFIER"
    

    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == LOGIN_HELP_IDENTIFIER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    dvc.url = URLConstant.LOGIN_PAGE
                    self.navigationController?.navigationBarHidden = false
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Helper Methods
    func initViews() {
        
    }
    
    func validateFields() -> Bool {
        let phoneNumber = phoneNumberField.text!
        let password = passwordField.text!
        
        if phoneNumber.isEmpty {
            UIUtils.showToast("Phone Number is required")
            return false
        }
        
        if password.isEmpty {
            UIUtils.showToast("Password is required")
            return false
        }
        return true
    }
    
    func saveUserDetails() {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.USER_LOGGED_IN, value: true)
        
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_PHONE_NUMBER, value: phoneNumberField.text)
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_PASSWORD, value: passwordField.text)
        
        performSegueWithIdentifier(MAIN_MENU_SEGUE, sender: self)
    }
    
    // MARK: API Calls
    func callLoginApi() {
        let phoneNumber = phoneNumberField.text!
        let password = passwordField.text!
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber,
            URLParams.PASSWORD_PARAM : password
        ]
        
        UIUtils.showProcessing("Logging In")
        
        WebserviceUtils.callPostRequest(
            URLConstant.LOGIN,
            params: params,
            success: { (response) in
                UIUtils.hideProcessing()
                if let json = response as? NSDictionary {
                    print(json)
                    if let id = json.objectForKey(ResponseParams.ID_PARAM) as? Int {
                        print(id)
                        if let name = json.objectForKey("name") as? String {
                            PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_FULL_NAME, value: "\(name)")
                        }
                        PreferenceUtils.saveStringToPrefs(PreferenceKeys.CLIENT_ID, value: "\(id)")
                        
                        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                            if let token = delegate.registrationToken {
                                delegate.callRegisterDeviceTokenApi(token)
                            }
                        }
                    }
                }
                self.saveUserDetails()
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
            // Mean Account Already Exist
            if (error.localizedDescription == "Request failed: bad request (400)") {
                UIUtils.showToast("Not able to login")
            }else {
                UIUtils.showToast("Not able to login")
            }
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: IBActions
    @IBAction func loginButtonClick(sender: AnyObject) {
        if !validateFields() {
            return
        }
        callLoginApi()
    }
    
    @IBAction func goBackButtonClick(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
