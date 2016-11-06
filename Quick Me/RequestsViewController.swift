//
//  RequestsViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import CoreLocation
import INTULocationManager

class RequestsViewController: UIViewController, UITextFieldDelegate, LocationMapViewControllerDelegate {
    
    let SHOW_OFFERS_IDENTIFIER = "SHOW_OFFERS_IDENTIFIER"
    let MAKE_OFFER_IDENTIFIER = "MAKE_OFFER_IDENTIFIER"
    let LOCATION_PICKER_VIEW_IDENTIFIER = "LocationPickerViewIdentifier"
    
    
    let MY_REQUEST_STATE = "MYREQUESTSTATE"
    let OTHERS_REQUEST_STATE = "OTHERREQUESTSTATE"
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    
    
    var mainViewTapGesture: UITapGestureRecognizer!
    
    var isProvider = false
    var mRequests = [Request]()
    var mSelectedRequest: Request!
    var isOthersRequest = false
    var mListState = ""
    var isViewOffer = false
    var mSelectedOffer: Offer!
    
    var lat = 0.0
    var lng = 0.0
    var locationName = ""
    var radius: Double = 0
    var isLocationFilter = false
    
    var radiusTextfield: UITextField!
    
    var isReadOnly = false
    
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var activeOnlySwitch: UISwitch!
    @IBOutlet weak var providerOfferFilterSwitch: UISwitch!
    
    @IBOutlet weak var providerOfferFilterView: UIView!
    
    @IBOutlet weak var minPriceRangeField: UITextField!
    @IBOutlet weak var maxPriceRangeField: UITextField!
    
    @IBOutlet weak var descriptionFilterField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var providerOfferFilterMaxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var providerOfferFilterZeroHeightConstraint: NSLayoutConstraint!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentLocation()
        
        mRequests = getRequestsForList()
        
        mListState = MY_REQUEST_STATE
        if isOthersRequest {
            mListState = OTHERS_REQUEST_STATE
        }
        
        isReadOnly = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED)
        
        isProvider = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER)
        initViews()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RequestsViewController.callAllFiltersAndLastSort), name: NSNotificationTypeQuickMe.REFRESH_REQUESTS_LIST, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationTypeQuickMe.REFRESH_REQUESTS_LIST, object: nil)
    }
    
    // MARK: Helper Methods
    func initViews() {
        title = "My Requests"
        if isOthersRequest {
            title = "Requests received"
        }
        
        tableView.tableFooterView = UIView()
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        mainViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(RequestsViewController.dismissKeyboardAndSaveFilter))
        
        activeOnlySwitch.on = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.ACTIVE_ONLY_FILTER + mListState)
        minPriceRangeField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.MIN_PRICE_FILTER + mListState)
        maxPriceRangeField.text = PreferenceUtils.getStringFromPrefs(PreferenceKeys.MAX_PRICE_FILTER + mListState)
        
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) && PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_IS_PROVIDER) {
            providerOfferFilterSwitch.on = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.OFFER_SENT_FILTER + mListState)
            providerOfferFilterView.hidden = false
            providerOfferFilterMaxHeightConstraint.priority = 999
            providerOfferFilterZeroHeightConstraint.priority = 500
        }else {
            providerOfferFilterSwitch.on = false
            providerOfferFilterView.hidden = true
            providerOfferFilterMaxHeightConstraint.priority = 500
            providerOfferFilterZeroHeightConstraint.priority = 999
        }
        
        callAllFiltersAndLastSort()
        
        
        if isOthersRequest {
            if !PreferenceUtils.getBoolFromPrefs(URLConstant.REQUEST_RECEIVED_PAGE) {
                mTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainMenuTableViewController.animateHelpButton), userInfo: nil, repeats: true)
            }
        }else {
            if !PreferenceUtils.getBoolFromPrefs(URLConstant.MY_REQUESTS_PAGE) {
                mTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainMenuTableViewController.animateHelpButton), userInfo: nil, repeats: true)
            }
        }
        
        
    }
    
    func animateHelpButton() {
        if helpBarButton.tintColor == UIColor.whiteColor() {
            helpBarButton.tintColor = UIColor.clearColor()
        }else {
            helpBarButton.tintColor = UIColor.whiteColor()
        }
    }
    
    func getRequestsForList() -> [Request] {
        var requests: [Request]!
        if let id = PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID) {
            if !isOthersRequest {
                requests = RealmUtils.RequestTable.readAll(id)
            }else {
                // For one phone testing
//                requests = RealmUtils.RequestTable.readAll()
                // Real Environment
                requests = RealmUtils.RequestTable.readAllOthersRequest(id)
            }
        }
        
        
        return requests
    }
    
    func dismissKeyboardAndSaveFilter() {
        minPriceRangeField.resignFirstResponder()
        maxPriceRangeField.resignFirstResponder()
        mainView.removeGestureRecognizer(mainViewTapGesture)
        
        // Saving the Price Filter
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.MIN_PRICE_FILTER + mListState, value: minPriceRangeField.text)
        PreferenceUtils.saveStringToPrefs(PreferenceKeys.MAX_PRICE_FILTER + mListState, value: maxPriceRangeField.text)
        
        callAllFiltersAndLastSort()
        
    }
    
    func showSortingMenu() {
        let actionsheet = UIAlertController(title: "Sorting", message: "Select type of sorting", preferredStyle: .ActionSheet)
        let sortByDescription = UIAlertAction(title: "Description", style: .Default) { (action) in
            self.showSortDirectionMenu({
                self.sortByDescription()
                PreferenceUtils.saveStringToPrefs(PreferenceKeys.REQUEST_SORT_CONSTANT + self.mListState, value: SortConstant.DESCRIPTION_SORT)
            })
        }
        let sortByPrice = UIAlertAction(title: "Price", style: .Default) { (action) in
            self.showSortDirectionMenu({
                self.sortByPrice()
                PreferenceUtils.saveStringToPrefs(PreferenceKeys.REQUEST_SORT_CONSTANT + self.mListState, value: SortConstant.PRICE_SORT)
            })
        }
        let sortByDate = UIAlertAction(title: "Due Date", style: .Default) { (action) in
            self.showSortDirectionMenu({
                self.sortByDate()
                PreferenceUtils.saveStringToPrefs(PreferenceKeys.REQUEST_SORT_CONSTANT + self.mListState, value: SortConstant.DUE_DATE_SORT)
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionsheet.addAction(sortByDescription)
        actionsheet.addAction(sortByPrice)
        actionsheet.addAction(sortByDate)
        actionsheet.addAction(cancel)
        
        presentViewController(actionsheet, animated: true, completion: nil)
    }
    
    func showSortDirectionMenu(completionHandler: ()->Void) {
        let actionSheet = UIAlertController(title: "Order", message: "Select Order of Sorting", preferredStyle: .ActionSheet)
        let ascending = UIAlertAction(title: "Ascending", style: .Default) { (action) in
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.SORT_ORDER + self.mListState, value: SortConstant.ASCENDING)
            completionHandler()
        }
        let descending = UIAlertAction(title: "Descending", style: .Default) { (action) in
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.SORT_ORDER + self.mListState, value: SortConstant.DESCENDING)
            completionHandler()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(ascending)
        actionSheet.addAction(descending)
        actionSheet.addAction(cancel)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func lastSortState() {
        // State of Last Sort
        if let sort = PreferenceUtils.getStringFromPrefs(PreferenceKeys.REQUEST_SORT_CONSTANT + mListState) {
            switch sort {
            case SortConstant.DESCRIPTION_SORT:
                sortByDescription()
                break
            case SortConstant.PRICE_SORT:
                sortByPrice()
                break
            case SortConstant.DUE_DATE_SORT:
                sortByDate()
                break
            default:
                break
            }
        }
    }
    
    // MARK: Filter Methods
    func filterPriceRange() {
        
        if minPriceRangeField.text!.isEmpty || maxPriceRangeField.text!.isEmpty {
            maxPriceRangeField.text! = ""
            minPriceRangeField.text! = ""
            
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.MIN_PRICE_FILTER + mListState, value: minPriceRangeField.text)
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.MAX_PRICE_FILTER + mListState, value: maxPriceRangeField.text)
            
            mRequests = getRequestsForList()
            lastSortState()
            tableView.reloadData()
            return
        }
        
        let min = Double(minPriceRangeField.text!)
        let max = Double(maxPriceRangeField.text!)
        
        mRequests = mRequests.filter { (request) -> Bool in
            if request.doublePrice >= min && request.doublePrice <= max {
                return true
            }
            return false
        }
        
        tableView.reloadData()
        
    }
    
    func filterActiveOnly() {
        if activeOnlySwitch.on {
            mRequests = mRequests.filter { (request) -> Bool in
                let offers = RealmUtils.OfferTable.getAllRequestOffers(request.requestId)
                
                for offer in offers {
                    if offer.accepted && !offer.closed {
                        return true
                    }
                }
                return false
            }
        }
    }
    
    func filterOfferSent() {
        if providerOfferFilterSwitch.on {
            mRequests = mRequests.filter { (request) -> Bool in
                let offers = RealmUtils.OfferTable.getAllRequestOffers(request.requestId)
                if offers.count > 0 {
                    return true
                }
                return false
            }
        }
    }
    
    func filterLocation() {
        if self.lat != 0.0 && self.lng != 0.0 && isLocationFilter {
            let selectedLocation = CLLocation(latitude: self.lat, longitude: self.lng)
            var filterRequest = [Request]()
            for request in mRequests {
                if let location = request.location {
                    let splitLocation = location.componentsSeparatedByString(";")
                    if splitLocation.count < 2 {
                        continue
                    }
                    
                    let lat = Double(splitLocation[0])!
                    let lng = Double(splitLocation[1])!
                    
                    let requestLocation = CLLocation(latitude: lat, longitude: lng)
                    
                    let distance = (selectedLocation.distanceFromLocation(requestLocation))
                    
                    if distance <= self.radius {
                        filterRequest.append(request)
                    }
                }
            }
            mRequests = filterRequest
        }
    }
    
    func filterDescription() {
        if !descriptionFilterField.text!.isEmpty {
            mRequests = mRequests.filter { (request) -> Bool in
                if request.desc.lowercaseString.containsString(descriptionFilterField.text!.lowercaseString) {
                    return true
                }
                return false
            }
        }
    }
    
    func callAllFiltersAndLastSort() {
        mRequests = getRequestsForList()
        lastSortState()
        
        filterPriceRange()
        filterActiveOnly()
        filterOfferSent()
        filterLocation()
        
        if !descriptionFilterField.text!.isEmpty {
            filterDescription()
        }
        
        tableView.reloadData()
    }
    
    // MARK: Sorting Methods
    func sortByPrice() {
        
        var isAscending = true
        
        if SortConstant.DESCENDING  == PreferenceUtils.getStringFromPrefs(PreferenceKeys.SORT_ORDER + self.mListState) {
            isAscending = false
        }
        
        mRequests.sortInPlace { (r1, r2) -> Bool in
            if r1.price >= r2.price {
                return !isAscending
            }
            return isAscending
        }
        self.tableView.reloadData()
    }
    
    func sortByDate() {
        
        var isAscending = true
        
        if SortConstant.DESCENDING  == PreferenceUtils.getStringFromPrefs(PreferenceKeys.SORT_ORDER + self.mListState) {
            isAscending = false
        }
        
        mRequests.sortInPlace { (r1, r2) -> Bool in
            if (r1.date.compare(r2.date) == NSComparisonResult.OrderedDescending) {
                return !isAscending
            }
            return isAscending
        }
        tableView.reloadData()
    }
    
    func sortByDescription() {
        
        var isAscending = true
        
        if SortConstant.DESCENDING  == PreferenceUtils.getStringFromPrefs(PreferenceKeys.SORT_ORDER + self.mListState) {
            isAscending = false
        }
        
        mRequests.sortInPlace { (r1, r2) -> Bool in
            if (r1.desc.compare(r2.desc) == NSComparisonResult.OrderedDescending) {
                return !isAscending
            }
            return isAscending
        }
        tableView.reloadData()
    }
    
    // MARK: UITextFieldDelegate Methods
    func textFieldDidBeginEditing(textField: UITextField) {
        mainView.addGestureRecognizer(mainViewTapGesture)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == descriptionFilterField {
            callAllFiltersAndLastSort()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Click Methods
    func showOffersButtonClick(sender: UIButton) {
        mSelectedRequest = mRequests[sender.tag]
        performSegueWithIdentifier(SHOW_OFFERS_IDENTIFIER, sender: self)
    }
    
    func makeOfferButton(sender: UIButton) {
        mSelectedRequest = mRequests[sender.tag]
        performSegueWithIdentifier(MAKE_OFFER_IDENTIFIER, sender: self)
    }
    
    func viewOfferButtonClick(sender: UIButton) {
        print(sender.tag)
        mSelectedRequest = mRequests[sender.tag]
        isViewOffer = true
        mSelectedOffer = RealmUtils.OfferTable.getOffer(mSelectedRequest.requestId, clientId: PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!)
        performSegueWithIdentifier(MAKE_OFFER_IDENTIFIER, sender: self)
    }
    
    func cancelRequestButtonClick(sender: UIButton) {
        print(sender.tag)
        let request = mRequests[sender.tag]
        callCancelRequestApi(request, index: sender.tag)
    }
    
    // MARK: API Calls
    func callCancelRequestApi(request: Request, index: Int) {
        let params = [
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.REQUEST_ID : request.requestId!
        ]
        UIUtils.showProcessing("Cancelling")
        WebserviceUtils.callPostRequest(URLConstant.CANCEL_REQUEST, params: params, success: { (response) in
            UIUtils.hideProcessing()
            RealmUtils.RequestTable.cancelRequest(request.requestId!)
            self.mRequests.removeAtIndex(index)
            self.tableView.reloadData()
        }) { (error) in
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: UINavigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == MAKE_OFFER_IDENTIFIER {
                if let dvc = segue.destinationViewController as? OfferTableViewController {
                    dvc.mRequest = mSelectedRequest
                    if isViewOffer {
                        dvc.mOffer = mSelectedOffer
                        isViewOffer = false
                    }
                }
            }else if identifier == SHOW_OFFERS_IDENTIFIER {
                if let dvc = segue.destinationViewController as? OffersViewController {
                    dvc.mRequest = mSelectedRequest
                }
            }else if identifier == LOCATION_PICKER_VIEW_IDENTIFIER {
                if let dvc = segue.destinationViewController as? LocationMapViewController {
                    dvc.latitude = self.lat
                    dvc.longitude = self.lng
                    if radius == 0.0 {
                        dvc.circlueRadius = self.radius
                    }else {
                        dvc.circlueRadius = self.radius
                    }
                    
                    dvc.delegate = self
                }
            }else if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    if isOthersRequest {
                        dvc.url = URLConstant.REQUEST_RECEIVED_PAGE
                    }else {
                        dvc.url = URLConstant.MY_REQUESTS_PAGE
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if isReadOnly {
            if identifier == MAKE_OFFER_IDENTIFIER {
                if !isViewOffer {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: LocationMapViewController Delegate
    func showLocationDetails(latitude: Double?, longitude: Double?, locationName: String?, radius: Double) {
        if let l = latitude {
            self.lat = l
        }else {
            self.locationLabel.text = "\(lat),\(lng)"
        }
        
        if let l = longitude {
            self.lng = l
        }else {
            self.locationLabel.text = "\(lat),\(lng)"
        }
        
        if let l = locationName where !l.isEmpty {
            self.locationName = l
            self.locationLabel.text = self.locationName
        }else {
            self.locationLabel.text = "\(lat),\(lng)"
        }
        
        self.radius = radius
        self.locationLabel.text?.appendContentsOf(" + \(radius/1000)KM")
        isLocationFilter = true
        
        self.callAllFiltersAndLastSort()
    }
    
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 1.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            
            if status == INTULocationStatus.Success {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.lat = location.coordinate.latitude
                self.lng = location.coordinate.longitude
                
            }else if status == INTULocationStatus.TimedOut {
                //                UIUtils.showToast("Error: Time out for getting location")
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.lat = location.coordinate.latitude
                self.lng = location.coordinate.longitude
            }else {
                //                UIUtils.showToast("Error: Could not get location")
            }
            
        }
    }
    
    // MARK: IBActions
    @IBAction func sortButtonClick(sender: UIBarButtonItem) {
        showSortingMenu()
    }
    
    @IBAction func activeOnlySwitchValuedChanged(sender: UISwitch) {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.ACTIVE_ONLY_FILTER + mListState, value: sender.on)
        callAllFiltersAndLastSort()
        tableView.reloadData()
    }
    
    @IBAction func offerSentSwitchValuedChanged(sender: UISwitch) {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.OFFER_SENT_FILTER + mListState, value: sender.on)
        callAllFiltersAndLastSort()
        tableView.reloadData()
    }
    
    @IBAction func locationEditButtonCLick(sender: AnyObject) {
        
        //        var center = CLLocationCoordinate2DMake(51.5108396, -0.0922251)
        //        if lat != 0.0 && lng != 0.0 {
        //            center = CLLocationCoordinate2DMake(lat, lng)
        //        }
        //
        //
        //
        //        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        //        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        //        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        //        let config = GMSPlacePickerConfig(viewport: viewport)
        //        placePicker = GMSPlacePicker(config: config)
        //
        //
        //        let circleCenter = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        //        let circ = GMSCircle(position: circleCenter, radius: radius * 1000)
        //        circ.map = placePicker?.config.
        //        circ.map = placePicker;
        //
        //
        //
        //        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
        //            if let error = error {
        //                print("Pick Place error: \(error.localizedDescription)")
        //                return
        //            }
        //
        //            if let place = place {
        //                self.lat = place.coordinate.latitude.roundToPlaces(2)
        //                self.lng = place.coordinate.longitude.roundToPlaces(2)
        //                self.locationName = place.name
        //                self.locationLabel.text = self.locationName
        //                self.showRadiusEntryDialog()
        //            }
        //        })
        
    }
    
}

extension RequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RequestTableViewCell
        
        let request = mRequests[indexPath.row]
        
        cell.requestShowOfferButton.tag = indexPath.row
        cell.requestShowOfferButton.addTarget(self, action: #selector(RequestsViewController.showOffersButtonClick(_:)), forControlEvents: .TouchUpInside)
        cell.requestDate.text = request.date.formattedDate
        cell.requestPrice.text = "$\(request.price)"
        cell.requestDescription.text = request.desc
        cell.requestPrice.textColor = UIColor.blackColor()
        cell.requestMakeOfferButton.setTitle("Make an offer", forState: .Normal)
        
        
        if isOthersRequest {
            cell.requestShowOfferButton.hidden = true
            cell.requestShowOfferButton.enabled = false
            
            cell.requestcancelButton.hidden = true
            cell.requestcancelButton.enabled = false
            
            
            if let offer = RealmUtils.OfferTable.getOffer(request.requestId, clientId: PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!) {
                cell.requestMakeOfferButton.hidden = false
                cell.requestMakeOfferButton.enabled = true
                cell.requestMakeOfferButton.tag = indexPath.row
                
                cell.requestMakeOfferButton.setTitle("View Offer", forState: .Normal)
                cell.requestMakeOfferButton.removeTarget(self, action: #selector(RequestsViewController.makeOfferButton(_:)), forControlEvents: .TouchUpInside)
                cell.requestMakeOfferButton.addTarget(self, action: #selector(RequestsViewController.viewOfferButtonClick(_:)), forControlEvents: .TouchUpInside)
            }else {
                if isProvider {
                    cell.requestMakeOfferButton.hidden = false
                    cell.requestMakeOfferButton.enabled = true
                    cell.requestMakeOfferButton.tag = indexPath.row
                    cell.requestMakeOfferButton.removeTarget(self, action: #selector(RequestsViewController.viewOfferButtonClick(_:)), forControlEvents: .TouchUpInside)
                    cell.requestMakeOfferButton.addTarget(self, action: #selector(RequestsViewController.makeOfferButton(_:)), forControlEvents: .TouchUpInside)
                    
                    if isReadOnly {
                        cell.requestMakeOfferButton.enabled = false
                    }
                    
                }
            }
        }else {
            cell.requestMakeOfferButton.hidden = true
            cell.requestMakeOfferButton.enabled = false
            cell.requestShowOfferButton.hidden = false
            cell.requestShowOfferButton.enabled = true
            cell.requestShowOfferButton.tag = indexPath.row
            cell.requestShowOfferButton.addTarget(self, action: #selector(RequestsViewController.showOffersButtonClick(_:)), forControlEvents: .TouchUpInside)
            
            cell.requestcancelButton.hidden = false
            
            if request.isCancelled {
                cell.requestcancelButton.setTitle("Cancelled", forState: .Normal)
                cell.requestcancelButton.enabled = false
                cell.requestcancelButton.removeTarget(self, action: #selector(RequestsViewController.cancelRequestButtonClick(_:)), forControlEvents: .TouchUpInside)
            }else {
                if !RealmUtils.OfferTable.hasAcceptedOffers(request.requestId!) {
                    cell.requestcancelButton.setTitle("Cancel Request", forState: .Normal)
                    cell.requestcancelButton.enabled = true
                    cell.requestcancelButton.tag = indexPath.row
                    cell.requestcancelButton.addTarget(self, action: #selector(RequestsViewController.cancelRequestButtonClick(_:)), forControlEvents: .TouchUpInside)
                }else {
                    cell.requestcancelButton.hidden = true
                    cell.requestcancelButton.enabled = false
                }
                
                if isReadOnly {
                    cell.requestcancelButton.enabled = false
                    cell.requestcancelButton.hidden = true
                }
                
            }
            
        }
        
        if let offer = RealmUtils.OfferTable.getOffer(request.requestId, clientId: PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID)!) {
            
            if offer.accepted {
                cell.requestPrice.textColor = UIColor.redColor()
                cell.requestPrice.text = "$\(request.price) (ACCEPTED)"
            }
            
            if offer.closed {
                cell.requestPrice.textColor = UIColor.redColor()
                cell.requestPrice.text = "$\(request.price) (CLOSED)"
            }
            
            if offer.isDisputed {
                cell.requestPrice.textColor = UIColor.redColor()
                cell.requestPrice.text = "$\(request.price) (DISPUTED)"
            }
        }
        
        
        if isReadOnly {
            cell.requestcancelButton.enabled = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
