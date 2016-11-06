//
//  AppDelegate.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/27/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import Google
import OCMapper
import INTULocationManager
import Fabric
import Crashlytics
import AFNetworking
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    var isSandbox = true
    
    var connectedToGCM = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    var timerForOnline = NSTimer()
    var timerForLocationUpdates = NSTimer()
    var lastLocation: CLLocation!
    
    private var selectedOffer: Offer!
    
    var isReadOnlyApplication = false
    
    private let GOOGLE_MAPS_API_KEY = "AIzaSyBaKt0NkLEMhADsIVybjo8Dvqar4QkaeRQ"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        
        // Setup Paypal Content
        PayPalMobile .initializeWithClientIdsForEnvironments([PayPalEnvironmentProduction: Constant.CONFIG_CLIENT_ID_LIVE,
            PayPalEnvironmentSandbox: Constant.CONFIG_CLIENT_ID_SANDBOX])
        
        // Register for Local and Push Notifications
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        application.registerForRemoteNotifications()
        
        // Setup GCM Content
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        // Set GCM Configuration
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        
        // Google Maps
        GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
        
        
        
        // Checking if User is Disabled of not
        isReadOnlyApplication = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_DISABLED)
        
        // Override point for customization after application launch.
        UIUtils.ChangeStatusBarColor(UIStatusBarStyle.LightContent)
        
        // Setup Fabrics
        Fabric.with([Crashlytics.self])
        
        // Checking is Application is opened using Push notification
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                if let data = notification[ResponseParams.DATA] as? String {
                    let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let json = try NSJSONSerialization .JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                            if let type = notification[ResponseParams.TYPE] as? String {
                                print(json)
                                saveTheNotificationData(type, json: json)
                            }
                        }
                    }catch {
                        print("Json Parsing Error")
                    }
                }
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // [END receive_apns_token]
        // [START get_gcm_reg_token]
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:isSandbox]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions) { (token, error) in
            if error == nil {
                print(token)
                self.registrationToken = token
                self.callRegisterDeviceTokenApi(token)
            }else {
                print(error.description)
            }
            
        }
        // [END get_gcm_reg_token]
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to get Device Token")
        print(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Push Notification Recieved")
        
        print(userInfo)

        if let data = userInfo[ResponseParams.DATA] as? String {
            let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding)
            do {
                if let json = try NSJSONSerialization .JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    if let type = userInfo[ResponseParams.TYPE] as? String {
                        print(json)
                        saveTheNotificationData(type, json: json)
                    }
                }
            }catch {
                print("Json Parsing Error")
            }
        }
        
        if let type = userInfo[ResponseParams.TYPE] as? String where type == NotificationType.TYPE_CUSTOM_MESSAGE {
            if let data = userInfo[ResponseParams.DATA] as? String {
                let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding)
                do {
                    if let json = try NSJSONSerialization .JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let message = json[ResponseParams.MESSAGE] as? String {
                            print(json)
                            if let title = userInfo[ResponseParams.MESSAGE] as? String {
                                let navigationController = application.windows[0].rootViewController as! UINavigationController
                                if let activeViewCont = navigationController.visibleViewController {
                                    UIUtils.showMessage(title, message: message, controller: activeViewCont, okHandler: {
                                        print("Alert Dismiss")
                                    })
                                }else {
                                    UIUtils.showToast(message)
                                }
                            }
                        }
                    }
                }catch {
                    print("Json Parsing Error")
                }
            }
        }else {
            if let message = userInfo[ResponseParams.MESSAGE] as? String {
                if let type = userInfo[ResponseParams.TYPE] as? String where type != NotificationType.TYPE_PAYMENT {
                    showLocalNotification(message)
                }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        callBecomeOfflineAPI()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GCMService.sharedInstance().disconnect()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        callBecomeOnlineAPI()
        // Connect to the GCM server to receive non-APNS notifications
        
        GCMService.sharedInstance().connectWithHandler({(error:NSError?) -> Void in
            if let error = error {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // ...
            }
        })
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions) { (token, error) in
            if error == nil {
                print(token)
                self.registrationToken = token
                self.callRegisterDeviceTokenApi(token)
            }else {
                print(error.description)
            }
            
        }
        
    }
    
    // MARK: Methods
    func saveTheNotificationData(type: String, json: NSDictionary) -> Void {
        
        switch type {
        case NotificationType.TYPE_NEW_REQUEST:
            if let request = ObjectMapper.sharedInstance().objectFromSource(json, toInstanceOfClass: Request.self) as? Request {
                print(request)
                request.isFromPush = true
                RealmUtils.RequestTable.save(request)
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.REFRESH_REQUESTS_LIST, object: self, userInfo: json as [NSObject : AnyObject])
            }
            break
        case NotificationType.TYPE_NEW_OFFER:
            if let offer = ObjectMapper.sharedInstance().objectFromSource(json, toInstanceOfClass: Offer.self) as? Offer {
                print(offer)
                RealmUtils.OfferTable.save(offer)
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.REFRESH_OFFERS_LIST, object: self, userInfo: json as [NSObject : AnyObject])
            }
            break
        case NotificationType.TYPE_PRICE_UPDATED:
            if let offer = ObjectMapper.sharedInstance().objectFromSource(json, toInstanceOfClass: Offer.self) as? Offer {
                RealmUtils.OfferTable.updatePrice(offer.offerId, price: offer.price)
            }
            break
        case NotificationType.TYPE_OFFER_ACCEPTED:
            if let offer = ObjectMapper.sharedInstance().objectFromSource(json, toInstanceOfClass: Offer.self) as? Offer {
                RealmUtils.OfferTable.updateAccepted(offer.offerId)
            }
            break
        case NotificationType.TYPE_OFFER_CLOSED:
            if let offer = ObjectMapper.sharedInstance().objectFromSource(json, toInstanceOfClass: Offer.self) as? Offer {
                RealmUtils.OfferTable.updateClosed(offer.offerId)
                if let offer = RealmUtils.OfferTable.getOffer(offer.offerId) {
                    
                    if offer.serverId != PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID) {
                        return
                    }
                    
                    // Commission Entry
                    let commission = (offer.doublePrice * 90) / 100
                    let balance = PreferenceUtils.getBalance() + commission + offer.lastPrice
                    let request = RealmUtils.RequestTable.getById(offer.requestId!)
                    self.saveTheTransactionHistory("\(commission+offer.lastPrice)", descrip: "Offer successfully COMPLETED, here is your commission plus the actual price of the items. Request: \(request!.desc!) (\(request!.name!))",balance: "\(balance)", isAddition: true)
                    PreferenceUtils.saveBalance(balance)
                }
            }
            break
        case NotificationType.TYPE_LOCATION_UPDATED:
            NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.LOCATION_RECEIVED, object: self, userInfo: json as [NSObject : AnyObject])
            break
        case NotificationType.TYPE_REQUEST_CANCEL:
            if let id = json[URLParams.REQUEST_ID] as? String {
                RealmUtils.RequestTable.cancelRequest(id)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.REFRESH_REQUESTS_LIST, object: nil)
            break
        case NotificationType.TYPE_OFFER_CANCEL:
            if let id = json[URLParams.OFFER_ID] as? String {
                RealmUtils.OfferTable.cancelOffer(id)
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.REFRESH_OFFERS_LIST, object: nil)
            }
            break
        case NotificationType.TYPE_PROVIDER_ACCEPTED:
            PreferenceUtils.saveBoolToPrefs(PreferenceKeys.USER_IS_PROVIDER, value: true)
            NSNotificationCenter.defaultCenter().postNotificationName("becomeProvider", object: nil)
            break
            
        case NotificationType.TYPE_USER_DISABLED:
            PreferenceUtils.saveBoolToPrefs(PreferenceKeys.USER_DISABLED, value: true)
            isReadOnlyApplication = true
            NSNotificationCenter.defaultCenter().postNotificationName("accountDisabled", object: nil)
            break
        case NotificationType.TYPE_CUSTOM_MESSAGE:
            break
        case NotificationType.TYPE_PAYMENT:
            print(json)
            if let msgId = json["msgId"] as? Int {
                if PreferenceUtils.getBoolFromPrefs("\(msgId)") {
                    return
                }
                PreferenceUtils.saveBoolToPrefs("\(msgId)", value: true)
            }
            
            if var amount = json["amount"] as? Double {
                print(amount)
                var addition = true
                let balance = PreferenceUtils.getBalance() + amount
                if amount < 0 {
                    amount *= -1
                    addition = false
                }
                if let id = json["offerId"] as? Int {
                    if id != 0 {
                        // Make Offer Disputed
                        if let offer = RealmUtils.OfferTable.getOffer("\(id)") {
                            
                            // Updating Balance only when offer is accepted
                            if offer.accepted && !offer.closed {
                                
                                if let request = RealmUtils.RequestTable.getById(offer.requestId) {
                                    if PreferenceUtils.getStringFromPrefs(PreferenceKeys.CLIENT_ID) == request.clientId {
                                        // Make refund of offer if user is creator of request
                                        if offer.accepted && !offer.closed && !offer.transactionId.isEmpty {
                                            self.selectedOffer = offer
                                            if let amount = json["amount"] as? Double where amount > 0 {
                                                print("Amount is positive, no refund needed")
                                            }else {
                                                saveTheTransactionHistory("\(amount)", descrip: "PayPal refund: \(offer.serverName!)'s offer has been disputed.", balance: "\(balance)", isAddition: addition)
                                                PreferenceUtils.saveBalance(balance)
                                                self.callToGetAccessTokenAPI(offer.transactionId, amount: amount)
                                            }
                                        }
                                        
                                    }else {
                                        saveTheTransactionHistory("\(amount)", descrip: "Balance update by the administrator", balance: "\(balance)", isAddition: addition)
                                        PreferenceUtils.saveBalance(balance)
                                    }
                                }
                                
                                RealmUtils.OfferTable.updateAccepted("\(id)")
                                RealmUtils.OfferTable.updateClosed("\(id)")
                                RealmUtils.OfferTable.updateDisputed("\(id)")
                            }
                            
                            
                        }
                    }else {
                        saveTheTransactionHistory("\(amount)", descrip: "Balance update by the administrator", balance: "\(balance)", isAddition: addition)
                        PreferenceUtils.saveBalance(balance)
                    }
                    print(id)
                }else {
                    saveTheTransactionHistory("\(amount)", descrip: "Balance update by the administrator", balance: "\(balance)", isAddition: addition)
                    PreferenceUtils.saveBalance(balance)
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationTypeQuickMe.REFRESH_BALANECE, object: nil)
            break
        default:
            break
        }
        
        
        
    }
    
    func showLocalNotification(message: String) {
//        let localNotification = UILocalNotification()
//        localNotification.fireDate = NSDate()
//        localNotification.alertBody = message
        if !message.isEmpty {
            UIUtils.showToast(message)
        }
//        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func startSendLocationOfAcceptedOffers() {
//        let offers = RealmUtils.OfferTable.getOnlyAcceptedOffers()
//        if offers.count > 0 {
//            self.getCurrentLocation()
//            timerForLocationUpdates.invalidate()
//            timerForLocationUpdates = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(AppDelegate.getCurrentLocation), userInfo: nil, repeats: true)
//        }
//        print(offers)
    }
    
    func saveTheTransactionHistory(amount: String, descrip: String, balance: String, isAddition: Bool) {
        let item = BalanceHistory()
        item.amount = amount
        item.descrip = descrip
        item.date = NSDate()
        item.isAddtion = isAddition
        item.userBalance = balance
        RealmUtils.BalanceHistoryTable.save(item)
        UIUtils.showToast("Your balance has been updated")
    }
    
    // MARK: PAYPAL API CALLS
    func callToGetAccessTokenAPI(transactionId: String, amount: Double) {
        
        if let plainData = "\(Constant.CONFIG_CLIENT_ID):\(Constant.CLIENT_SECRET)".dataUsingEncoding(NSUTF8StringEncoding) {
            let authString = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            
            let headers = [
                "authorization": "Basic \(authString)",
                "content-type": "application/x-www-form-urlencoded"
            ]
            
            let params = [
                URLParams.GRANT_TYPE : "client_credentials"
            ]
            
            WebserviceUtils.callPostRequest(URLConstant.GET_ACCESS_TOKEN_URL, header: headers, params: params, success: { (response) in
                if let json = response as? NSDictionary {
                    print(json)
                    if let token = json["access_token"] as? String {
                        print(token)
                        self.callApiToGetSaleDetails(token, transactionId: transactionId, price: amount)
                    }
                }
                }, failure: { (error) in
                    UIUtils.showToast("Not able to refund amount")
                    print(error.localizedDescription)
            })
            
        }else {
            UIUtils.showToast("Not able to refund amount")
        }
        
    }
    
    func callApiToGetSaleDetails(token: String,transactionId: String, price: Double) {
        let headers = [
            "authorization": "Bearer \(token)",
            "content-type": "application/json"
        ]
        
        let url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/payment/\(transactionId)"
        WebserviceUtils.callGetRequest(url,header: headers ,params: nil, success: { (response) in
            if let json = response as? NSDictionary {
                print(json)
                if let sale = SaleModel(dictionary: json) {
                    if let transactions = sale.transactions {
                        if transactions.count > 0 {
                            let transaction = transactions[0]
                            if let related_resources = transaction.related_resources {
                                if related_resources.count > 0 {
                                    let resource = related_resources[0]
                                    if let sale = resource.sale {
                                        if let amount = sale.amount?.total {
                                            if let id = sale.id {
                                                print(id)
                                                print(amount)
                                                self.callApiToMakeRefund(token, saleId: id,total: "\(price)")
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    func callApiToMakeRefund(token: String, saleId: String, total: String) {
        
    
        var url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/sale/\(saleId)/refund"
        
        let headers = [
            "authorization": "Bearer \(token)",
            "content-type": "application/json"
        ]
        
        let request = RealmUtils.RequestTable.getById(selectedOffer.requestId!)
        
            
            if request == nil {
                UIUtils.showToast("Not able to refund amount")
                return
            }
        
            let params = [
                "amount" : [
                    "total" : total,
                    "currency" : "AUD"
                ]
            ]
            
            url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/capture/\(saleId)/refund"
        
        
        WebserviceUtils.callPostJSONRequest(url, header: headers, params: params, success: { (response) in
            
            if let json = response as? NSDictionary {
                if let state = json["state"] as? String {
                    if state == "completed" {
                        UIUtils.showToast("Refund Complete")
                        // Save Transaction Histroy
                        
                    }else {
                        UIUtils.showToast("Refund Failed")
                    }
                }else {
                    UIUtils.showToast("Refund Failed")
                }
                print(json)
            }
        }) { (error) in
            print(error.localizedDescription)
            if let info = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? [String: String]{
                if let message = info["message"] {
                    UIUtils.showToast(message)
                }
            }else {
                UIUtils.showToast("Error occured while doing refund")
            }
        }
        
        
    }
    
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            if status == INTULocationStatus.Success {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.callApiToSendLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
            }else if status == INTULocationStatus.TimedOut {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.callApiToSendLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
    }

    // MARK: API Calls
    func callRegisterDeviceTokenApi(token: String) {
        
        if !PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            return
        }
        
        let params = [
            URLParams.PHONE_NUMBER_PARAM: PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM: PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.GOOGLE_ID: token,
            URLParams.TYPE: "iOS"
        ]
        
        WebserviceUtils.callPostRequest(URLConstant.SET_GOOGLE_ID, params: params, success: { (response) in
            print("Device Token Registered")
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func callApiToSendLocation(latitude: Double, longitude: Double) {
        let offers = RealmUtils.OfferTable.getOnlyAcceptedOffers()
        
        if offers.count > 0 {
            
            let params = [
                URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
                URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
                URLParams.LOCATION : "\(latitude);\(longitude)"
            ]
            
            for _ in offers {
                WebserviceUtils.callPostRequest(URLConstant.LOCATION_UPDATE, params: params, success: { (response) in
                    if let json = response {
                        print(json)
                    }
                    }, failure: { (error) in
                        print(error.localizedDescription)
                })
            }
            
        }
    }        
    
    func callApiToCheckVersion() {
        
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        
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
            "\(URLConstant.BASE_URL)/lastSupportedVersion?os=ios",
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                if let data = response as? NSData {
                    if let version = String(data: data, encoding: NSUTF8StringEncoding) {
                        if Double(versionNumber) < Double(version) {
                            self.isReadOnlyApplication = true
                            NSNotificationCenter.defaultCenter().postNotificationName("accountDisabled", object: nil)
                            PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_STATUS, value: "EXPIRED")
                        }else {
                            PreferenceUtils.saveStringToPrefs(PreferenceKeys.USER_STATUS, value: "ACTIVE")
                        }
                    }
                }
        }) { (session, error) -> Void in
            print(error)
        }
        
    }
    
    func callBecomeOnlineAPI() {
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            
            timerForOnline.invalidate()
            timerForOnline = NSTimer.scheduledTimerWithTimeInterval(5*60, target: self, selector: #selector(AppDelegate.callBecomeOnlineAPI), userInfo: nil, repeats: true) // 5mins
            
            let params = [
                URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
                URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
                URLParams.ONLINE : "\(NSDate().formattedDateForApi)UTC+00:00"
            ]
            
            WebserviceUtils.callPostRequest(URLConstant.SET_ONLINE, params: params, success: { (response) in
                if let json = response as? NSDictionary {
                        print(json)
                }
                }, failure: { (error) in
                    print(error.localizedDescription)
            })
        }
    }
    
    func callBecomeOfflineAPI() {
        if PreferenceUtils.getBoolFromPrefs(PreferenceKeys.USER_LOGGED_IN) {
            timerForOnline.invalidate()
            let params = [
                URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
                URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
                URLParams.OFFLINE : "\(NSDate().formattedDateForApi)UTC+00:00"
            ]
            
            WebserviceUtils.callPostRequest(URLConstant.SET_OFFLINE, params: params, success: { (response) in
                if let json = response as? NSDictionary {
                    print(json)
                }
                }, failure: { (error) in
                    print(error.localizedDescription)
            })
            
        }
    }
    
}

