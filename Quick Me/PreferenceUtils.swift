//
//  PreferenceUtils.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/27/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation

class PreferenceUtils {
    
    
    // MARK: Save Values
    class func saveStringToPrefs(key: String, value: String?){
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
    }
    
    class func saveBoolToPrefs(key: String, value: Bool){
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
    }
    
    class func saveUserImage(image: UIImage) {
        NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: "userImage")
    }
    
    class func saveBalance(balance: Double) {
        NSUserDefaults.standardUserDefaults().setDouble(balance, forKey: PreferenceKeys.USER_BALANCE)
    }
    
    class func saveVerficationCount(count: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(count, forKey: PreferenceKeys.VERIFICATION_COUNT)
    }
    
    // MARK: Get Values
    class func getStringFromPrefs(key:String) -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key) as? String
    }
    
    class func getBoolFromPrefs(key: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    class func getUserImage() -> UIImage {
        if let imageData = NSUserDefaults.standardUserDefaults().objectForKey("userImage") {
            if let image = UIImage(data: imageData as! NSData){
                return image
            }
        }
        return UIImage(named: "person_avatar")!
    }
    
    class func getBalance() -> Double {
        return NSUserDefaults.standardUserDefaults().doubleForKey(PreferenceKeys.USER_BALANCE)
    }
    
    class func getVerificationCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(PreferenceKeys.VERIFICATION_COUNT)
    }
    
}
