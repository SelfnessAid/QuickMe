//
//  RegisterViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/27/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, CountryCodesDelegate {
    
    let MAIN_MENU_SEGUE = "MAIN_MENU_SEGUE"
    let LOGIN_IDENTIFIER = "LOGIN_IDENTIFIER"
    let REGISTRATION_HELP_IDENTIFIER = "REGISTRATION_HELP_IDENTIFIER"
    let COUNTRY_CODE_IDENTIFIER = "COUNTRY_CODE_IDENTIFIER"
    
    
    var requestId = ""
    var codeRetries = 0
    
    var verificationCodeField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var numberCodeButton: UIButton!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            performSegueWithIdentifier(MAIN_MENU_SEGUE, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == REGISTRATION_HELP_IDENTIFIER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    dvc.url = URLConstant.REGISTER_PAGE
                    self.navigationController?.navigationBarHidden = false
                }
            }else if identifier == COUNTRY_CODE_IDENTIFIER {
                if let dvc = segue.destinationViewController as? CountryCodesViewController {
                    dvc.delegate = self
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Helper Methods
    func initViews() {
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            phoneNumberField.enabled = false
            phoneNumberField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
            fullNameField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_FULL_NAME)
            passwordField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
        }
    }
    
    func validateFields() -> Bool {
        let phoneNumber = phoneNumberField.text!
        let fullName = fullNameField.text!
        let password = passwordField.text!
        let confirmPass = confirmPasswordField.text!
        
        if phoneNumber.isEmpty {
            UIUtils.showToast("Phone Number is required")
            return false
        }
        
        if fullName.isEmpty {
            UIUtils.showToast("Full Name is required")
            return false
        }
        
        if password.isEmpty {
            UIUtils.showToast("Password is required")
            return false
        }
        
        if confirmPass.isEmpty {
            UIUtils.showToast("Confirm Password is required")
            return false
        }
        
        if password != confirmPass {
            UIUtils.showToast("Password doesn't match")
            return false
        }
        
        return true
    }
    
    func saveUserDetails() {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.USER_LOGGED_IN, value: true)
        
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_PHONE_NUMBER, value: phoneNumberField.text)
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_FULL_NAME, value: fullNameField.text)
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_PASSWORD, value: passwordField.text)
        
        performSegueWithIdentifier(MAIN_MENU_SEGUE, sender: self)
    }
    
    func showVerifyNumberDialog() {
        resignToHideKeyboard()
        let alert = UIAlertController(title: "Verification Code", message: "Enter Verification which you have received on \(phoneNumberField.text!)", preferredStyle:
            UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            self.verificationCodeField = textField
            self.verificationCodeField.placeholder = "Enter code here"
            self.verificationCodeField.keyboardType = .NumberPad
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            if self.verificationCodeField.text!.isEmpty {
                self.showVerifyNumberDialog()
                return
            }
            self.verificationCodeField.resignFirstResponder()
            self.callVerifyCodeApi()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resignToHideKeyboard() {
        phoneNumberField.resignFirstResponder()
        fullNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    // MARK: API Calls
    func callRequestValidationApi() {
        
        let headers = [
            "Authorization" : "33764899-BAC5-42E7-8511-5A8220123DAF"
        ]
        
        let params = [
            "number" : phoneNumberField.text!,
            "type" : "sms"
        ]
        
        UIUtils.showProcessing("Please wait")
        WebserviceUtils.callPostJSONRequest(URLConstant.CHECK_MOBI_VALIDATION_REQUEST, header: headers ,params: params, success: { (response) in
            UIUtils.hideProcessing()
            if let json = response as? NSDictionary {
                if let id = json["id"] as? String {
                    self.requestId = id
                    PreferenceUtils.saveVerficationCount(PreferenceUtils.getVerificationCount()+1)
                    self.showVerifyNumberDialog()
                }else {
                    UIUtils.showToast("Some error occurred while sending verification code")
                }
                
                print(json)
            }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    func callVerifyCodeApi() {
        let headers = [
            "Authorization" : "33764899-BAC5-42E7-8511-5A8220123DAF"
        ]
        
        let params = [
            "id" : requestId,
            "pin" : verificationCodeField.text!
        ]
        UIUtils.showProcessing("Verifing Code")
        WebserviceUtils.callPostJSONRequest(URLConstant.CHECK_MOBI_VERIFY_PIN, header: headers ,params: params, success: { (response) in
            UIUtils.hideProcessing()
            if let json = response as? NSDictionary {
                if let validated = json["validated"] as? Int where validated == 1 {
                    self.callRegisterApi()
                }else {
                    if self.codeRetries < 2 {
                        self.codeRetries += 1
                        self.showVerifyNumberDialog()
                    }
                    UIUtils.showToast("Invalid code")
                }
                print(json)
            }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    func callLoginApi() {
        let phoneNumber = "\(self.numberCodeButton.titleLabel!.text!)\(phoneNumberField.text!)"
        let password = passwordField.text!
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber,
            URLParams.PASSWORD_PARAM : password
        ]
        
        UIUtils.showProcessing("Please Wait")
        
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
                self.callRequestValidationApi()
            }else {
                UIUtils.showToast("Some Error Occured")
            }
        }
    }
    
    func callRegisterApi() {
        let phoneNumber = "\(self.numberCodeButton.titleLabel?.text!)\(phoneNumberField.text!)"
        let fullName = fullNameField.text!
        let password = passwordField.text!
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber,
            URLParams.NAME_PARAM : fullName,
            URLParams.PASSWORD_PARAM : password
        ]
        
        UIUtils.showProcessing("Registering")
        
        WebserviceUtils.callPostRequest(
            URLConstant.REGISTER,
            params: params,
            success: { (response) in
                UIUtils.hideProcessing()
                if let json = response as? NSDictionary {
                    print(json)
                    if let id = json.objectForKey(ResponseParams.ID_PARAM) as? Int {
                        print(id)
                        PreferenceUtils.saveStringToPrefs(PreferenceKeys.CLIENT_ID, value: "\(id)")
                        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                            if let token = delegate.registrationToken {
                                delegate.callRegisterDeviceTokenApi(token)
                            }
                        }
                        self.saveUserDetails()
                    }
                }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
            // Mean Account Already Exist
            if (error.localizedDescription == "Request failed: bad request (400)") {
                UIUtils.showToast("Account Already Exists")
                self.performSegueWithIdentifier(self.LOGIN_IDENTIFIER, sender: self)
            }else {
                UIUtils.showToast("Account not created")
            }
        }
    }
    
    // MARK: CountriesCode Delegate
    func countryCodeSelected(dialCode: String) {
        self.numberCodeButton.setTitle(dialCode, forState: UIControlState.Normal)
        self.numberCodeButton.setNeedsDisplay()
    }
    
    // MARK: UITextFieldDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: IBOutlets
    @IBAction func registerButtonClick(sender: AnyObject) {
        
        if !validateFields() {
            return
        }
        
        if PreferenceUtils.getVerificationCount() < 2 {
            callLoginApi()
        }else {
            UIUtils.showToast("You have exceeded the day limit of verification. Please try again after 24 hours")
        }
//                callRegisterApi()
    }
    
}
