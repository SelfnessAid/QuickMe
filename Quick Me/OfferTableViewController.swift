//
//  OfferTableViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import INTULocationManager
import RealmSwift

class OfferTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let SHOW_MAP_IDENTIFIER = "SHOW_MAP_IDENTIFIER"
    
    
    var mRequest: Request!
    var mOffer: Offer!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isEditMode = false
    var isViewMode = false
    
    var selectedDate: NSDate! {
        didSet {
            readyByButton.setTitle(selectedDate.formattedDate, forState: .Normal)
        }
    }
    
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    @IBOutlet weak var offerPriceLabel: UILabel!

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dueByLabel: UILabel!
    
    @IBOutlet weak var priceOfferField: UITextField!
    @IBOutlet weak var updatePriceField: UITextField!
    @IBOutlet weak var readyByButton: UIButton!
    @IBOutlet weak var commentsTextArea: UITextView!
    
    @IBOutlet weak var requestPersonName: UILabel!
    @IBOutlet weak var requestPersonNumber: UILabel!
    @IBOutlet weak var offerPersonName: UILabel!
    @IBOutlet weak var offerPersonNumber: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!    
    @IBOutlet weak var cancelOfferButton: UIButton!
    
    var isReadOnly = false
    let imagePicker = UIImagePickerController()
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            isReadOnly = delegate.isReadOnlyApplication
        }
        
        initViews()
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        if !isEditMode || !isViewMode {
            getCurrentLocation()
        }
    }
    
    // MARK: Helper Methods
    func initViews() -> Void {
        selectedDate = NSDate()
        
        if let request = mRequest {
            descriptionTextView.text = request.desc
            priceLabel.text = "$\(request.price)"
            dueByLabel.text = request.date.formattedDate
            requestPersonName.text = request.name
            requestPersonNumber.text = request.phoneNumber
        }
        
        if let offer = mOffer {
            priceOfferField.text = "\(offer.price)"
            selectedDate = offer.readyBy
            offerPersonName.text = offer.serverName
            offerPersonNumber.text = offer.phoneNumber
            readyByButton.enabled = false
            commentsTextArea.text = offer.comment
            commentsTextArea.editable = false
            sendButton.setTitle("Update actual price of items", forState: .Normal)
            updatePriceField.text = "\(offer.lastPrice)"
            priceOfferField.enabled = false
            isEditMode = true
            
            if offer.accepted {
                statusLabel.text = "ACCEPTED"
            }
            
            if offer.closed {
                statusLabel.text = "CLOSED"
            }
            
            if offer.isDisputed {
                statusLabel.text = "DISPUTED"
            }
            
            
            if offer.isCancelled {
                cancelOfferButton.setTitle("CANCELLED", forState: .Normal)
                cancelOfferButton.enabled = false
            }
            
            
        }
        
        if isViewMode {
            updatePriceField.enabled = false
        }
        
        if isReadOnly {
            sendButton.enabled = false
            readyByButton.enabled = false
            cancelOfferButton.enabled = false
        }
        
        
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.NEW_OFFER_PAGE) {
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
    
    func showReadyByDatePicker() {
        ActionSheetDatePicker.showPickerWithTitle(
            "Select Due Date",
            datePickerMode: UIDatePickerMode.Date,
            selectedDate: selectedDate,
            doneBlock: { (pickerview, pickerDate, selectedIndex) in
                if let date = pickerDate as? NSDate {
                    print(date)
                    self.selectedDate = date
                }
            },
            cancelBlock: { (pickerview) in
                
            },
            origin: self.view)
    }
    
    func saveOfferInDB(id: String) {
        let offer = Offer()
        
        offer.requestId = mRequest.requestId
        offer.offerId = id
        offer.serverName = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_FULL_NAME)
        offer.price = priceOfferField.text!
        offer.comment = commentsTextArea.text!
        offer.readyBy = selectedDate!
        offer.serverId = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)
        
        
        RealmUtils.OfferTable.save(offer)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func updateOfferInDB() {
//        let offer = mOffer
//        
//        do {
//            let realm = try Realm()
//            try realm.write({ () -> Void in
//                offer.lastPrice = Double(updatePriceField.text!)!
//            })
//        }catch {
//            print(error)
//        }
        
        RealmUtils.OfferTable.updatePrice(mOffer.offerId, price: updatePriceField.text!)
        
        
//        RealmUtils.OfferTable.update(offer)
        navigationController?.popViewControllerAnimated(true)
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
    
    // MARK: API Call
    func sendOfferApiCall() {
        let phoneNumber = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
        let password = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
//        let clientId = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)
        let name = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_FULL_NAME)
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber!,
            URLParams.PASSWORD_PARAM: password!,
            URLParams.COMMENT: commentsTextArea.text!,
            URLParams.PRICE: priceOfferField.text!,
            URLParams.ESTIMATED: "\(selectedDate.formattedDateForApi)UTC+00:00",
            URLParams.LOCATION: "\(latitude);\(longitude)",
            URLParams.CLIENT_ID: mRequest.clientId!,
            URLParams.REQUEST_ID: mRequest.requestId!,
            URLParams.MY_NAME: name!
        ]
        
        print(params)
        
        UIUtils.showProcessing("Please Wait")
        WebserviceUtils.callPostRequest(URLConstant.OFFER, params: params, success: { (response) in
            if let json = response as? NSDictionary {
                UIUtils.hideProcessing()
                if let id = json.objectForKey(ResponseParams.ID_PARAM) as? Int {
                    self.saveOfferInDB("\(id)")
                }
                print(json)
            }
            }) { (error) in
                UIUtils.hideProcessing()
                print(error)
        }
        
        
    }
    
    func updateOfferPriceApiCall() {
        let phoneNumber = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
        let password = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
//        let clientId = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)
        
        let params = [
            URLParams.LOCATION: "\(latitude);\(longitude)",
            URLParams.PHONE_NUMBER_PARAM: phoneNumber!,
            URLParams.PASSWORD_PARAM: password!,
            URLParams.PRICE: updatePriceField.text!,
            URLParams.REQUEST_ID: mRequest.requestId!,
            URLParams.CLIENT_ID: mRequest.clientId!,
            URLParams.OFFER_ID: mOffer.offerId!
        ]
        
        UIUtils.showProcessing("Please Wait")
        WebserviceUtils.callPostRequest(URLConstant.SET_PRICE, params: params, success: { (response) in
            UIUtils.hideProcessing()
            self.updateOfferInDB()            
        }) { (error) in
            print(error)
            UIUtils.showToast(error.localizedDescription)
        }
        
        print(params)
    }
    
    func callOfferCancelApiCall() {
        if let offer = mOffer {
            let params = [
                URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
                URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
                URLParams.OFFER_ID : offer.offerId!,
                URLParams.CLIENT_ID : PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!
            ]
            
            UIUtils.showProcessing("Cancelling")
            WebserviceUtils.callPostRequest(URLConstant.CANCEL_OFFER, params: params, success: { (response) in
                UIUtils.hideProcessing()
                self.cancelOfferButton.setTitle("Cancelled".uppercaseString, forState: .Normal)
                self.cancelOfferButton.enabled = false
                RealmUtils.OfferTable.cancelOffer(offer.offerId)
                self.navigationController?.popViewControllerAnimated(true)
                }, failure: { (error) in
                    UIUtils.hideProcessing()
                    print(error.localizedDescription)
            })
            
        }
    }
    
    func callUploadDocumentApi(image: UIImage) {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.TYPE : "2"
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
    
    // MARK: IBActions
    @IBAction func readyByDateClick(sender: UIButton) {
        showReadyByDatePicker()
    }

    @IBAction func sendButtonClick(sender: UIButton) {
        if isEditMode {
            updateOfferPriceApiCall()
        }else {
            sendOfferApiCall()
        }
//        saveOfferInDB("\(RealmUtils.OfferTable.getNewId())")
    }
    
    @IBAction func seeOnMapButtonClick(sender: UIButton) {
        
    }
    
    @IBAction func cancelOfferButtonClick(sender: AnyObject) {
        callOfferCancelApiCall()
    }
    
    @IBAction func uploadDocumentClick(sender: UIButton) {
        let sheet = UIAlertController(title: "Document Upload", message: "Select your document location", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Capture from camera", style: .Default) { (alert) -> Void in
            self.captureImageCamera()
        }
        let galleryAction = UIAlertAction(title: "Select from gallery", style: .Default) { (alert) -> Void in
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
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.callUploadDocumentApi(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
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
    
    // MARK: UINavigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == SHOW_MAP_IDENTIFIER {
                if let dvc = segue.destinationViewController as? MapViewController {
                    dvc.mRequest = mRequest
                    dvc.mOffer = mOffer
                }
            }else if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.NEW_OFFER_PAGE
                }
            }
        }
    }
    
    // MARK: TABLEView Delegate & Datasource Methods
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        if isViewMode && indexPath.section == 2 && indexPath.row == 1 {
//            return 0.0
//        }
        
        if !isEditMode && indexPath.section == 2 && indexPath.row == 1 {
            return 0.0
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 90
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            return 90
        }
        
        if isViewMode && indexPath.section == 3 && indexPath.row == 0 {
            return 0.0
        }
        
        
        // OFFER PERSON NAME & NUMBER ROW Hiding when offer is not accepted
        if !mOffer.accepted && indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3) {
            return 0.0
        }
        // OFFER PERSON NAME & NUMBER ROW Hiding if Not View Mode
        if !isViewMode && indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3) {
            return 0.0
        }

        // STATUS ROW
        if indexPath.section == 1 && indexPath.row == 4 {
            if let offer = mOffer {
                if !offer.accepted && !offer.closed {
                    return 0.0
                }
            }else {
                return 0.0
            }
        }
        
        // MAP Button ROW
//        if indexPath.section == 3 && indexPath.row == 1 {
//            if let offer = mOffer {
//                if !offer.accepted {
//                    return 0.0
//                }
//            }else {
//                return 0.0
//            }
//        }
        
        // CANCEL OFFER BUTTON
        if indexPath.section == 3 && indexPath.row == 1 {
            if let offer = mOffer {
                if offer.accepted {
                    return 0.0
                }
            }
            if isViewMode{
                return 0.0
            }else if !isEditMode && !isViewMode {
                return 0.0
            }
        }
        
        return 44
    }
    
}
