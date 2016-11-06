//
//  NewRequestTableViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import INTULocationManager
import GoogleMaps
import GooglePlacePicker

class NewRequestTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    private let GOOGLE_MAPS_API_KEY = "AIzaSyBaKt0NkLEMhADsIVybjo8Dvqar4QkaeRQ"
    
    var selectedDate: NSDate! {
        didSet {
            dueDateButton.setTitle(selectedDate.formattedDate, forState: .Normal)
        }
    }

    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var maxPriceField: UITextField!
    @IBOutlet weak var dueDateButton: UIButton!
    @IBOutlet weak var expectedLocationButton: UIButton!
    @IBOutlet weak var mSubjectField: UITextField!
    @IBOutlet weak var mShareLocationSwitch: UISwitch!
    
    var placePicker: GMSPlacePicker?
    let imagePicker = UIImagePickerController()
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        getCurrentLocation()
    }
        
    // MARK: Helper Methods
    func initViews() {
        selectedDate = NSDate()
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.NEW_REQUEST_PAGE) {
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
    
    func showDatePickerView() {
        ActionSheetDatePicker.showPickerWithTitle(
            "Select Due Date",
            datePickerMode: UIDatePickerMode.Date,
            selectedDate: selectedDate,
            doneBlock: { (pickerview, pickerDate, selectedIndex) in
                if let date = pickerDate as? NSDate {
                    print(date.formattedDateForApi+"UTC+00:00")
                    self.selectedDate = date
                }
            },
            cancelBlock: { (pickerview) in
                
            },
            origin: self.view)
    }
    
    func saveRequestInDB(id: String) {
        let request = Request()
        request.requestId = id
        request.desc = descriptionTextArea.text
        request.date = selectedDate
        request.expectedDate = "\(selectedDate.formattedDateForApi)UTC+00:00"
        request.price = maxPriceField.text!
        request.clientId = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)
        request.phoneNumber = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
        request.name = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_FULL_NAME)
        request.location = "\(latitude);\(longitude)"
        RealmUtils.RequestTable.save(request)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func updateLocationLabel() {
        expectedLocationButton.setTitle("Location: \(self.latitude.roundToPlaces(2)), \(self.longitude.roundToPlaces(2))", forState: .Normal)
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
    
    // MARK: API Calls
    func postRequestAPICall() {
        let phoneNumber = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)
        let password = PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: phoneNumber!,
            URLParams.PASSWORD_PARAM: password!,
            URLParams.DESCRIPTION: descriptionTextArea.text!,
            URLParams.MAX_PRICE: maxPriceField.text!,
            URLParams.EXPECTED: "\(selectedDate.formattedDateForApi)UTC+00:00",
            URLParams.LOCATION: "\(latitude);\(longitude)"
        ]
        print(params)
        
        UIUtils.showProcessing("Please Wait")
        
        WebserviceUtils.callPostRequest(URLConstant.REQUEST, params: params, success: { (response) in
            if let json = response as? NSDictionary {
                UIUtils.hideProcessing()
                if let id = json.objectForKey(ResponseParams.ID_PARAM) as? Int {
                    self.saveRequestInDB("\(id)")
                }
                print(json)
            }
            }) { (error) in
                UIUtils.hideProcessing()
                UIUtils.showToast("Request Not Created")
                print(error.localizedDescription)
        }
        
    }
    
    func callUploadDocumentApi(image: UIImage) {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.TYPE : "1"
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
    
    // MARK: UINavigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.NEW_REQUEST_PAGE
                }
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.callUploadDocumentApi(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func stepperValueChanged(sender: UIStepper) {
        maxPriceField.text = "\(sender.value)"
    }
    
    @IBAction func dueDateButtonClick(sender: UIButton) {
        showDatePickerView()
    }
    
    @IBAction func postButtonClick(sender: UIButton) {
        postRequestAPICall()
    }
    
    @IBAction func expectedLocationClick(sender: UIButton) {
        
        let center = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        
        
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        GMSPlacesClient.provideAPIKey(GOOGLE_MAPS_API_KEY)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.latitude = place.coordinate.latitude
                self.longitude = place.coordinate.longitude
                self.updateLocationLabel()
//                self.locationName = place.name
//                self.locationLabel.text = self.locationName!
                
            }
        })
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
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            
            if status == INTULocationStatus.Success {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.updateLocationLabel()
                
                
            }else if status == INTULocationStatus.TimedOut {
//                UIUtils.showToast("Error: Time out for getting location")
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.updateLocationLabel()
            }else {
//                UIUtils.showToast("Error: Could not get location")
            }
            
        }
    }
    
}
