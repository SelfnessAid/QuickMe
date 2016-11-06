//
//  MainMenuTableViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import Crashlytics
import Kingfisher
import AFNetworking
import INTULocationManager
import RealmSwift

class MainMenuTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let MY_REQUESTS_IDENTIFIER = "MY_REQUESTS_IDENTIFIER"
    let OTHERS_REQUEST_IDENTIFIER = "OTHERS_REQUEST_IDENTIFIER"
    
    let BECOME_PROVIDER_IDENTIFIER = "BECOME_PROVIDER_IDENTIFIER"
    let NEW_REQUEST_IDENTIFIER = "NEW_REQUEST_IDENTIFIER"
    let REPORT_PROBLEM_IDENTIFIER = "REPORT_PROBLEM_IDENTIFIER"
    
    
    let OTHERS_REQUEST_INDEXPATH = NSIndexPath(forRow: 3, inSection: 0)
    let PASSWORD_INDEXPATH = NSIndexPath(forRow: 2, inSection: 1)
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var providerSwitch: UISwitch!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var uploadProfilePictureButton: UIButton!
    @IBOutlet weak var uploadDocumentButton: UIButton!
    
    @IBOutlet weak var userBalanceLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var isEditMode = false
    var otherRequestVisible = false
    var isReadOnly = false
    var isDocumentSelected = false
    
    let imagePicker = UIImagePickerController()
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID))
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let token = delegate.registrationToken {
                delegate.callRegisterDeviceTokenApi(token)
            }
            delegate.callBecomeOnlineAPI()
            delegate.startSendLocationOfAcceptedOffers()
            delegate.callApiToCheckVersion()
            self.isReadOnly = delegate.isReadOnlyApplication
        }
        
        callGetProfilePicApi()
        getCurrentLocation()
        callCompleteFailedCloseOffersAPI()
        
        initViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        providerSwitch.on = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER)
        //        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER) {
        //            providerSwitch.enabled = false
        //        }
        userBalanceLabel.text = "$\(PreferenceUtils.getBalance().roundToPlaces(2)) AUD"
        accountDisabled()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenuTableViewController.accountDisabled), name: "accountDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenuTableViewController.becomeProvider), name: "becomeProvider", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenuTableViewController.refreshBalance), name: NSNotificationTypeQuickMe.REFRESH_BALANECE, object: nil)
        
        callGetProfilePicApi()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "accountDisabled", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "becomeProvider", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationTypeQuickMe.REFRESH_BALANECE, object: nil)
    }
    
    // MARK: Helper Methods
    func initViews() {
        
        let titleImageView = UIImageView(image: UIImage(named: "navigation_bar_logo"))
        titleImageView.bounds.size = CGSizeMake(35, 35)
        titleImageView.contentMode = .ScaleAspectFit
        
        self.navigationItem.titleView = titleImageView
        
        
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        providerSwitch.enabled = isEditMode
        fullNameField.enabled = isEditMode
        
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            phoneNumberLabel.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
            fullNameField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_FULL_NAME)
            passwordField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
            
            if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER) {
                providerSwitch.on = true
                otherRequestVisible = true
            }else {
                providerSwitch.on = false
            }
            
            self.tableView.reloadData()
        }
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.image = PreferenceUtils.getUserImage()
        
        if isReadOnly {
            editButton.enabled = false
            uploadProfilePictureButton.enabled = false
        }
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.HELP_MAIN_PAGE) {
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
    
    func saveUserData() {
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_FULL_NAME, value: fullNameField.text)
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_PASSWORD, value: passwordField.text)
    }
    
    func selectImageFromGallery() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func captureImageCamera() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func becomeProvider() {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.USER_IS_PROVIDER, value: true)
        providerSwitch.enabled = true
        providerSwitch.on = true
        providerSwitch.enabled = false
        tableView.reloadData()
    }
    
    func accountDisabled() {
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED) {
            isReadOnly = true
            editButton.enabled = false
            uploadProfilePictureButton.enabled = false
            uploadDocumentButton.enabled = false
            userStatusLabel.text = "DISABLED"
        }else {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if delegate.isReadOnlyApplication {
                    userStatusLabel.text = "EXPIRED"
                    isReadOnly = true
                    editButton.enabled = false
                    uploadProfilePictureButton.enabled = false
                    uploadDocumentButton.enabled = false
                }
            }
        }
    }
    
    func saveTheTransactionHistory(amount: String, descrip: String, balance: String, isAddition: Bool) {
        let item = BalanceHistory()
        item.amount = amount
        item.descrip = descrip
        item.date = NSDate()
        item.isAddtion = isAddition
        item.userBalance = balance
        RealmUtils.BalanceHistoryTable.save(item)
    }
    
    func refreshBalance() {
        userBalanceLabel.text = "$\(PreferenceUtils.getBalance()) AUD"
    }
    
    // MARK: API Calls
    func callUploadProfilePictureAPI(image: UIImage) {
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.TYPE : "0"
        ]
        UIUtils.showProcessing("Uploading")
        WebserviceUtils.callPostRequestMultipartData(URLConstant.UPLOAD, params: params, image: image, success: { (response) in
            UIUtils.hideProcessing()
            if let json = response as? NSDictionary {
                print(json)
            }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
        
    }
    
    func callUploadDocumentApi(image: UIImage) {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.TYPE : ""
        ]
        UIUtils.showProcessing("Uploading")
        WebserviceUtils.callPostRequestMultipartData(URLConstant.UPLOAD, params: params, image: image, success: { (response) in
            UIUtils.hideProcessing()
            if let json = response as? NSDictionary {
                print(json)
            }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    func callApiToSaveUserData() {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.ABN : "",
            URLParams.NEW_NAME_PARAM : fullNameField.text!,
            URLParams.NEW_PASSWORD_PARAM : passwordField.text!
        ]
        UIUtils.showProcessing("Saving")
        WebserviceUtils.callPostRequest(URLConstant.BECOME_PROVIDER, params: params, success: { (response) in
            UIUtils.hideProcessing()
            self.saveUserData()
            if let json = response as? NSDictionary {
                print(json)
            }
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
            UIUtils.showToast("Data Not saved")
        }
        
    }
    
    func callGetProfilePicApi() {
        //        let params = [
        //            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
        //            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
        //            URLParams.USER_ID : PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!
        //        ]
        
        let number = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!
        let id = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!
        let password = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!
        
        let url = "\(URLConstant.BASE_URL)/photo?phoneNumber=\(number)&userId=\(id)&password=\(password)"
        
        // TODO: Move this method and customize the name and parameters to track your key metrics
        //       Use your own string attributes to track common values over time
        //       Use your own number attributes to track median value over time
        Answers.logCustomEventWithName("Profile Image Download", customAttributes: ["Number":"\(number)", "User":"\(id)"])
        Answers.logCustomEventWithName("Image URL", customAttributes: ["URL":"photo?phoneNumber=\(number)&userId=\(id)&password=\(password)"])
        
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("image/png")
        manager.responseSerializer.acceptableContentTypes?.insert("image/jpeg")
        
        manager.securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy.validatesDomainName = false
        
        var params = [String:String]()
        params["sc"] = "AAKMVNNDKEEOWOQQJCNGJRELWLSFEWF12WFW"
        
        manager.GET(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                if let data = response as? NSData {
                    self.profileImageView.image = UIImage(data: data)
                    if self.profileImageView.image != nil {
                        PreferenceUtils.saveUserImage(self.profileImageView.image!)
                    }
                }
        }) { (session, error) -> Void in
            print(error)
        }
    }
    
    func callCompleteFailedCloseOffersAPI() {
        let offers = RealmUtils.OfferTable.getRefundedOffer()
        
        for offer in offers {
            
            let request = RealmUtils.RequestTable.getById(offer.requestId!)
            
            var paidAmount = offer.lastPrice - request!.doublePrice
            if paidAmount < 0 {
                paidAmount *= -1
            }
            
            let params = [
                URLParams.LOCATION : "\(latitude);\(longitude)",
                URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
                URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
                URLParams.SERVER_ID : offer.serverId!,
                URLParams.REQUEST_ID : offer.requestId!,
                URLParams.OFFER_ID : offer.offerId!,
                URLParams.EXTRA_PAID : "\(paidAmount)",
                URLParams.PAYMENT_ID : offer.transactionId,
                URLParams.EMAIL: "poor iPhone"
            ]
            
            WebserviceUtils.callPostRequest(URLConstant.CLOSE_OFFER, params: params, success: { (response) in
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        offer.closed = true
                    })
                }catch {
                    print(error)
                }
                RealmUtils.OfferTable.update(offer)
                
                if offer.lastPrice - request!.doublePrice > 0 {
                    
                }else { // Difference > 0
                    
                    // Commission: Refund
//                    let commission = (offer.doublePrice * 90) / 100
//                    var balance = PreferenceUtils.getBalance() + commission
//                    self.saveTheTransactionHistory("\(commission)", descrip: "Commission: \(request!.desc!) (\(offer.serverName!))",balance: "\(balance)", isAddition: true)
//                    PreferenceUtils.saveBalance(balance)
                    
//                    // Paypal Refund: Offer Closed
//                    balance = PreferenceUtils.getBalance() - paidAmount
//                    self.saveTheTransactionHistory("\(paidAmount)", descrip: "Paypal Refund: Difference at Offer Closed",balance: "\(balance)", isAddition: false)
//                    PreferenceUtils.saveBalance(balance)
                    
                    // Refund
                    let offerTotalPrice = offer.doublePrice + offer.lastPrice
                    let balance = PreferenceUtils.getBalance() - offerTotalPrice
                    self.saveTheTransactionHistory("\(offerTotalPrice)", descrip: "\(request!.desc!) (\(offer.serverName!))",balance: "\(balance)", isAddition: false)
                    PreferenceUtils.saveBalance(balance)

                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }
        
        
    }
    
    // MARK: UITextfield Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: IBActions
    @IBAction func providerSwitchValueChanged(sender: UISwitch) {
        
    }
    
    @IBAction func editButtonClick(sender: UIButton) {
        if !isEditMode {
            isEditMode = true
            sender.setTitle("SAVE", forState: .Normal)
        }else {
            isEditMode = false
            callApiToSaveUserData()
            sender.setTitle("EDIT", forState: .Normal)
        }
        
        if otherRequestVisible {
            self.tableView.reloadRowsAtIndexPaths([PASSWORD_INDEXPATH], withRowAnimation: .Bottom)
        }else {
            self.tableView.reloadRowsAtIndexPaths([OTHERS_REQUEST_INDEXPATH,PASSWORD_INDEXPATH], withRowAnimation: .Bottom)
        }
        self.tableView.reloadData()
        
        fullNameField.enabled = isEditMode
        
    }
    
    @IBAction func uploadProfileClick(sender: AnyObject) {
        let sheet = UIAlertController(title: "", message: "Select you profile image", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Capture from camera", style: .Default) { (alert) -> Void in
            self.captureImageCamera()
        }
        let galleryAction = UIAlertAction(title: "Select from gallery", style: .Default) { (alert) -> Void in
            self.selectImageFromGallery()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel) { (alert) -> Void in
            print("Cancel")
        }
        sheet.addAction(cameraAction)
        sheet.addAction(galleryAction)
        sheet.addAction(cancelAction)
        presentViewController(sheet, animated: true, completion: nil)
    }
    
    @IBAction func uploadDocumentButtonClick(sender: AnyObject) {
        
        let sheet = UIAlertController(title: "Document Upload", message: "Select your document location", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Capture from camera", style: .Default) { (alert) -> Void in
            self.isDocumentSelected = true
            self.captureImageCamera()
        }
        let galleryAction = UIAlertAction(title: "Select from gallery", style: .Default) { (alert) -> Void in
            self.isDocumentSelected = true
            self.selectImageFromGallery()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { (alert) -> Void in
            print("Cancel")
        }
        sheet.addAction(cameraAction)
        sheet.addAction(galleryAction)
        sheet.addAction(cancelAction)
        presentViewController(sheet, animated: true, completion: nil)
        
    }
    
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            
            if location == nil {
                return
            }
            
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
                //                UIUtils.showToast("Error: Could not get location")
            }
            
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            let imageData = NSData(data: UIImageJPEGRepresentation((pickedImage), 0.5)!)
//            let imageSize = imageData.length
//            let imageMBSize: Double = Double(imageSize) / (1024*1024)
            
//            if imageMBSize < 5 {
                if isDocumentSelected {
                    isDocumentSelected = false
                    callUploadDocumentApi(pickedImage)
                }else {
                    PreferenceUtils.saveUserImage(pickedImage)
                    profileImageView.image = pickedImage
                    callUploadProfilePictureAPI(pickedImage)
                }
//            }else {
//                UIUtils.showToast("Select image with size less than 5MB")
//            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UINavigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == MY_REQUESTS_IDENTIFIER {
                if let dvc = segue.destinationViewController as? RequestsViewController {
                    dvc.isOthersRequest = false
                }
            }else if identifier == OTHERS_REQUEST_IDENTIFIER {
                if let dvc = segue.destinationViewController as? RequestsViewController {
                    dvc.isOthersRequest = true
                }
            }else if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.HELP_MAIN_PAGE
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if isReadOnly {
            if identifier == BECOME_PROVIDER_IDENTIFIER || identifier == NEW_REQUEST_IDENTIFIER || identifier == REPORT_PROBLEM_IDENTIFIER {
                if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED) {
                    
                }
                return false
            }
        }
        return true
    }
    
    // MARK: TableView Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !providerSwitch.on && indexPath.section == OTHERS_REQUEST_INDEXPATH.section && indexPath.row == OTHERS_REQUEST_INDEXPATH.row {
            return 0.0
        }else if !isEditMode && indexPath.section == PASSWORD_INDEXPATH.section && indexPath.row == PASSWORD_INDEXPATH.row {
            return 0.0
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            return 97
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER) {
                return 0.0
            }
        }
        
        return 44
    }
    
}
