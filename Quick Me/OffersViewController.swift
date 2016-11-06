//
//  OffersViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/29/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import RealmSwift
import INTULocationManager
import AFNetworking

class OffersViewController: UIViewController {
    
    let GET_SALE_ID_CALL = 0
    let REFUND_ID_CALL = 1
    
    var mRequest: Request!
    var mOffers = [Offer]()
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var paypalConfig = PayPalConfiguration()
    var isLiveEnvironment = Constant.IS_LIVE_ENVIRONMENT
    
    let SHOW_OFFER_DETAILS = "SHOW_OFFER_DETAILS"
    let SHOW_MAP_IDENTIFIER = "SHOW_MAP_IDENTIFIER"
    
    
    var selectedOffer = Offer()
    var paidAmount = 0.0
    var sender: UIButton!
    
    var isCloseOfferAction = false
    var isRefundDueToSystemFailure = false
    var isRefundOffer = false
    
    var isReadOnly = false
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    
    
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var dueByDateLabel: UILabel!
    @IBOutlet weak var closedOfferSwitch: UISwitch!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            isReadOnly = delegate.isReadOnlyApplication
        }
        setupPaypal()
        getCurrentLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mOffers = RealmUtils.OfferTable.getAllRequestOffers(mRequest.requestId)
        initViews()
        tableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OffersViewController.showOffersList), name: NSNotificationTypeQuickMe.REFRESH_OFFERS_LIST, object: nil)
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.VIEW_OFFERS_PAGE) {
            mTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainMenuTableViewController.animateHelpButton), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSNotificationTypeQuickMe.REFRESH_OFFERS_LIST, object: nil)
        mTimer?.invalidate()
    }
    
    // MARK: Helper Methods
    
    func setupPaypal() {
        
        if isLiveEnvironment {
            PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentProduction)
        }else {
            PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
        }
        
        paypalConfig.acceptCreditCards = true
        paypalConfig.payPalShippingAddressOption = PayPalShippingAddressOption.PayPal
        paypalConfig.rememberUser = true
        paypalConfig.merchantName = "QuickMe"        
        paypalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        paypalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
    }
    
    func initViews() {
        tableView.tableFooterView = UIView()        
        
        UIUtils.removeBackButtonTitleOfNavigationBar(navigationItem)
        
        requestDescriptionLabel.text = mRequest.desc
        maxPriceLabel.text = "$\(mRequest.price)"
        dueByDateLabel.text = mRequest.date.formattedDate
        
        showOffersList()
        
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.VIEW_OFFERS_PAGE) {
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
        mOffers = RealmUtils.OfferTable.getAllRequestOffers(mRequest.requestId)
        closedOfferSwitch.on = PreferenceUtils.getBoolFromPrefs(PreferenceKeys.CLOSED_OFFERS_FILTER + mRequest.requestId)
        if closedOfferSwitch.on {
            hideClosedOffers()
        }
        
        // State of Last Sort
        lastSortState()
        tableView.reloadData()
    }
    
    func lastSortState() {
        if let sort = PreferenceUtils.getStringFromPrefs(PreferenceKeys.OFFER_SORT_CONSTANT + mRequest.requestId) {
            switch sort {
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
    
    func showSortingMenu() {
        let actionsheet = UIAlertController(title: "Sorting", message: "Select type of sorting", preferredStyle: .ActionSheet)
        let sortByPrice = UIAlertAction(title: "Price", style: .Default) { (action) in
            self.showSortDirectionMenu({
                self.sortByPrice()
                PreferenceUtils.saveStringToPrefs(PreferenceKeys.OFFER_SORT_CONSTANT + self.mRequest.requestId, value: SortConstant.PRICE_SORT)
            })
        }
        let sortByDate = UIAlertAction(title: "Ready By", style: .Default) { (action) in
            self.showSortDirectionMenu({
                self.sortByDate()
                PreferenceUtils.saveStringToPrefs(PreferenceKeys.OFFER_SORT_CONSTANT + self.mRequest.requestId, value: SortConstant.DUE_DATE_SORT)
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionsheet.addAction(sortByPrice)
        actionsheet.addAction(sortByDate)
        actionsheet.addAction(cancel)
        
        presentViewController(actionsheet, animated: true, completion: nil)
    }
    
    func showSortDirectionMenu(completionHandler: ()->Void) {
        let actionSheet = UIAlertController(title: "Order", message: "Select Order of Sorting", preferredStyle: .ActionSheet)
        let ascending = UIAlertAction(title: "Ascending", style: .Default) { (action) in
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.SORT_ORDER + self.mRequest.requestId, value: SortConstant.ASCENDING)
            completionHandler()
        }
        let descending = UIAlertAction(title: "Descending", style: .Default) { (action) in
            PreferenceUtils.saveStringToPrefs(PreferenceKeys.SORT_ORDER + self.mRequest.requestId, value: SortConstant.DESCENDING)
            completionHandler()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(ascending)
        actionSheet.addAction(descending)
        actionSheet.addAction(cancel)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func hideClosedOffers() {
        mOffers = mOffers.filter({ (offer) -> Bool in
            if offer.closed {
                return false
            }
            return true
        })
    }
    
    func parsePaymentResponse(json: NSDictionary) {
        if let response = json[ResponseParams.RESPONSE] as? NSDictionary {
            if let id = response.objectForKey(ResponseParams.ID_PARAM) as? String {
                print(id)
                if isCloseOfferAction {
                    callCloseOfferApi(id, offer: selectedOffer)
                }else {
                    callAcceptOfferApi(id,offer: selectedOffer)
                }
            }
        }
    }
    
    func showRefundDialog(amount: Double) {
        let dialog = UIAlertController(title: "Refund Amount", message: "Do you want to refund the \(amount * -1) ?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            if self.selectedOffer.isRefunded {
                self.callCloseOfferApi(self.selectedOffer.transactionId, offer: self.selectedOffer)
            }else {
                self.callToGetAccessTokenAPI(self.selectedOffer.transactionId)
            }
        }
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        dialog.addAction(yesAction)
        dialog.addAction(noAction)
        presentViewController(dialog, animated: true, completion: nil)
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
    
    // MARK: Sorting Methods
    func sortByPrice() {
        
        var isAscending = true
        if SortConstant.DESCENDING  == PreferenceUtils.getStringFromPrefs(PreferenceKeys.SORT_ORDER + self.mRequest.requestId) {
            isAscending = false
        }
        
        mOffers.sortInPlace { (o1, o2) -> Bool in
            if o1.price >= o2.price {
                return !isAscending
            }
            return isAscending
        }
        self.tableView.reloadData()
    }
    
    func sortByDate() {
        
        var isAscending = true
        if SortConstant.DESCENDING  == PreferenceUtils.getStringFromPrefs(PreferenceKeys.SORT_ORDER + self.mRequest.requestId) {
            isAscending = false
        }
        
        mOffers.sortInPlace { (o1, o2) -> Bool in
            if (o1.readyBy.compare(o2.readyBy) == NSComparisonResult.OrderedDescending) {
                return !isAscending
            }
            return isAscending
        }
        tableView.reloadData()
    }
    
    // MARK: API Calls
    func callAcceptOfferApi(id: String, offer: Offer) {
        
        isCloseOfferAction = false
        
        let params = [
            URLParams.LOCATION : "\(latitude);\(longitude)",
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.SERVER_ID : offer.serverId!,
            URLParams.REQUEST_ID : offer.requestId!,
            URLParams.OFFER_ID : offer.offerId!,
            URLParams.AMOUNT_PAID : "\(paidAmount)",
            URLParams.PAYMENT_ID : id,
            URLParams.EMAIL: "poor iPhone"
        ]
        
        UIUtils.showProcessing("Please Wait")
        
        WebserviceUtils.callPostRequest(URLConstant.ACCEPT_OFFER, params: params, success: { (response) in
            UIUtils.hideProcessing()
            let balance = PreferenceUtils.getBalance() + self.paidAmount
            PreferenceUtils.saveBalance(balance)
            self.saveTheTransactionHistory("\(self.paidAmount)", descrip: "Paypal Payment: \(offer.serverName!)'s offer accepted (Deposit to your balance: Max price of items + Service fee)",balance: "\(balance)", isAddition: true)
            self.acceptOfferAction(id)
        }) { (error) in
            UIUtils.hideProcessing()
            UIUtils.showToast("Some Error Occured, Doing refund")
            self.isCloseOfferAction = false
            self.isRefundDueToSystemFailure = true
            self.callToGetAccessTokenAPI(id)
            print(error.localizedDescription)
        }
        
        print(params)
        
    }
    
    func callCloseOfferApi(id: String, offer: Offer) {
        let params = [
            URLParams.LOCATION : "\(latitude);\(longitude)",
            URLParams.PHONE_NUMBER_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PHONE_NUMBER)!,
            URLParams.PASSWORD_PARAM : PreferenceUtils.getStringFromPrefs(PreferenceKeys.USER_PASSWORD)!,
            URLParams.SERVER_ID : offer.serverId!,
            URLParams.REQUEST_ID : offer.requestId!,
            URLParams.OFFER_ID : offer.offerId!,
            URLParams.EXTRA_PAID : "\(paidAmount)",
            URLParams.PAYMENT_ID : id,
            URLParams.EMAIL: "poor iPhone"
        ]
        UIUtils.showProcessing("Please Wait")
        WebserviceUtils.callPostRequest(URLConstant.CLOSE_OFFER, params: params, success: { (response) in
            UIUtils.hideProcessing()
            if !self.isRefundOffer { // Difference > 0
                // Offer Closed
                var balance = PreferenceUtils.getBalance() + self.paidAmount
                self.saveTheTransactionHistory("\(self.paidAmount)", descrip: "Paypal Payment: \(offer.serverName!)'s offer completed (Update your balance: Actual price of items - Max price of items)",balance: "\(balance)", isAddition: true)
                PreferenceUtils.saveBalance(balance)
                
                // Balance Zero
                balance = PreferenceUtils.getBalance() - offer.doublePrice - offer.lastPrice
                self.saveTheTransactionHistory("\(PreferenceUtils.getBalance())", descrip: "Request delivered (Deducted from your balance: Actual price of items + Service fee, Request: \(self.mRequest!.desc!)",balance: "\(balance)", isAddition: false)
                PreferenceUtils.saveBalance(balance)
                
//                // Commission Entry
//                let commission = (offer.doublePrice * 90) / 100
//                balance = PreferenceUtils.getBalance() + commission
//                self.saveTheTransactionHistory("\(commission)", descrip: "Commission: Accept (\(offer.serverName!)'s)",balance: "\(balance)", isAddition: true)
//                PreferenceUtils.saveBalance(balance)
            }else {
                self.isRefundOffer = false
                
//                // Commission: Refund
//                let commission = (offer.doublePrice * 90) / 100
//                var balance = PreferenceUtils.getBalance() + commission
//                self.saveTheTransactionHistory("\(commission)", descrip: "Commission: \(self.mRequest.desc!) (\(offer.serverName!)'s)",balance: "\(balance)", isAddition: true)
//                PreferenceUtils.saveBalance(balance)
                
                if !offer.isRefunded {
                    // Paypal Refund: Offer Closed
                    let balance = PreferenceUtils.getBalance() - self.paidAmount
                    self.saveTheTransactionHistory("\(self.paidAmount)", descrip: "Paypal Refund: \(offer.serverName!)'s offer completed (Update your balance: Actual price of items - Max price of items)",balance: "\(balance)", isAddition: false)
                    PreferenceUtils.saveBalance(balance)
                }
                
                // Refund
                let offerTotalPrice = offer.doublePrice + offer.lastPrice
                let balance = PreferenceUtils.getBalance() - offerTotalPrice
                self.saveTheTransactionHistory("\(offerTotalPrice)", descrip: "\(self.mRequest.desc!) (\(offer.serverName!)'s)",balance: "\(balance)", isAddition: false)
                PreferenceUtils.saveBalance(balance)
            }
            self.closeOfferAction()
        }) { (error) in
            UIUtils.hideProcessing()
            UIUtils.showToast("Server Error, Offer not closed")
            self.isCloseOfferAction = true
            self.isRefundDueToSystemFailure = true
            
            if offer.lastPrice - self.mRequest.doublePrice >= 0 {
                self.callToGetAccessTokenAPI(id)
            }else {
                
                if !offer.isRefunded {
                    let total = (offer.lastPrice - self.mRequest.doublePrice) * -1
                    self.saveTheTransactionHistory("\(total)", descrip: "Paypal Refund: \(offer.serverName!)'s offer completed (Update your balance: Actual price of items - Max price of items)", balance: "\(PreferenceUtils.getBalance()-Double(total))", isAddition: false)
                    PreferenceUtils.saveBalance(PreferenceUtils.getBalance()-Double(total))
                }
                self.makeOfferRefunded(offer)
                
//                self.saveTheTransactionHistory("\(total)", descrip: "PayPal payment, closing offer failed", balance: "\(PreferenceUtils.getBalance()+Double(total))", isAddition: true)
//                PreferenceUtils.saveBalance(PreferenceUtils.getBalance()+Double(total))
            }

            print(error.localizedDescription)
        }
        
        print(params)
    }
    
    // MARK: PAYPAL API CALLS
    
    func callToGetAccessTokenAPI(transactionId: String) {
        
        if let plainData = "\(Constant.CONFIG_CLIENT_ID):\(Constant.CLIENT_SECRET)".dataUsingEncoding(NSUTF8StringEncoding) {
            let authString = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            
            let headers = [
                "authorization": "Basic \(authString)",
                "content-type": "application/x-www-form-urlencoded"
            ]
            
            let params = [
                URLParams.GRANT_TYPE : "client_credentials"
            ]
            
            UIUtils.showProcessing("Please wait")
            WebserviceUtils.callPostRequest(URLConstant.GET_ACCESS_TOKEN_URL, header: headers, params: params, success: { (response) in
                if let json = response as? NSDictionary {
                    print(json)
                    if let token = json["access_token"] as? String {
                        print(token)
                        self.callApiToGetSaleDetails(token, transactionId: transactionId)
                    }
                }
                }, failure: { (error) in
                    UIUtils.hideProcessing()
                    UIUtils.showToast("Not able to refund amount")
                    print(error.localizedDescription)
            })
            
        }else {
            UIUtils.showToast("Error while getting access token")
        }
        
    }
    
    func callApiToGetSaleDetails(token: String,transactionId: String) {
        let headers = [
            "authorization": "Bearer \(token)",
            "content-type": "application/json"
        ]
        
        let url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/payment/\(transactionId)"
        UIUtils.showProcessing("Please Wait")
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
                                                self.callApiToMakeRefund(token, saleId: id,total: amount)
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
            UIUtils.hideProcessing()
            print(error.localizedDescription)
        }
        
        
    }
    
    func callApiToMakeRefund(token: String, saleId: String, total: String) {
        
        var params: AnyObject! = [
            "amount" : [
                "total" : "\(total)",
                "currency" : "AUD"
            ]
        ]
        var url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/sale/\(saleId)/refund"
        
        let headers = [
            "authorization": "Bearer \(token)",
            "content-type": "application/json"
        ]
        
        UIUtils.showProcessing("Refunding")
        let request = RealmUtils.RequestTable.getById(selectedOffer.requestId!)
        if isCloseOfferAction {
            
            if request == nil {
                UIUtils.showToast("Not able to refund amount")
                return
            }
            let amount =  selectedOffer.lastPrice - request!.doublePrice
            if amount < 0 {
                self.paidAmount = amount * -1
            }
            params = [
                "amount" : [
                    "total" : "\(self.paidAmount)",
                    "currency" : "AUD"
                ]
            ]
            
            url = "\(URLConstant.PAYPAL_BASE_URL)/v1/payments/capture/\(saleId)/refund"
        }
        
        WebserviceUtils.callPostJSONRequest(url, header: headers, params: params, success: { (response) in
            
            if let json = response as? NSDictionary {
                if let state = json["state"] as? String {
                    if state == "completed" {
                        UIUtils.showToast("Refund Complete")
                        UIUtils.hideProcessing()
                        
                        if self.isRefundDueToSystemFailure {
                            if self.isCloseOfferAction {
                                if ((self.selectedOffer.lastPrice - request!.doublePrice) > 0) {
                                    self.saveTheTransactionHistory("\(total)", descrip: "PayPal Payment: \(self.selectedOffer.serverName!) offer completed (Update your balance: Actual price of items - Max price of items)", balance: "\(PreferenceUtils.getBalance()+Double(total)!)", isAddition: true)
                                    PreferenceUtils.saveBalance(PreferenceUtils.getBalance()+Double(total)!)
                                    self.saveTheTransactionHistory("\(total)", descrip: "PayPal refund: Error completing \(self.selectedOffer.serverName!) offer.", balance: "\(PreferenceUtils.getBalance()-Double(total)!)", isAddition: false)
                                    PreferenceUtils.saveBalance(PreferenceUtils.getBalance()-Double(total)!)
                                }else {
                                    self.saveTheTransactionHistory("\(total)", descrip: "PayPal Refund: \(self.selectedOffer.serverName!) offer completed (Update your balance: Actual price of items - Max price of items)", balance: "\(PreferenceUtils.getBalance()-Double(total)!)", isAddition: false)
                                    PreferenceUtils.saveBalance(PreferenceUtils.getBalance()-Double(total)!)
                                    self.saveTheTransactionHistory("\(total)", descrip: "PayPal payment: Error completing \(self.selectedOffer.serverName!) offer.", balance: "\(PreferenceUtils.getBalance()+Double(total)!)", isAddition: true)
                                    PreferenceUtils.saveBalance(PreferenceUtils.getBalance()+Double(total)!)
                                }
                            }else {
                                var balance = PreferenceUtils.getBalance() + self.paidAmount
                                self.saveTheTransactionHistory("\(self.paidAmount)", descrip: "Paypal Payment, Offer Accepted",balance: "\(balance)", isAddition: true)
                                balance = PreferenceUtils.getBalance()
                                self.saveTheTransactionHistory("\(self.paidAmount)", descrip: "PayPal refund: Error accepting \(self.selectedOffer.serverName!) offer.",balance: "\(balance)", isAddition: false)
                            }
                            self.isCloseOfferAction = false
                            self.isRefundDueToSystemFailure = false
                        }else {
                            if self.isCloseOfferAction {
                                self.callCloseOfferApi(self.selectedOffer.transactionId, offer: self.selectedOffer)
                            }else {
                                UIUtils.hideProcessing()
                            }
                        }
                    }else {
                        UIUtils.hideProcessing()
                    }
                }else {
                    UIUtils.hideProcessing()
                }
                print(json)
            }
            self.isRefundDueToSystemFailure = false
        }) { (error) in
            UIUtils.hideProcessing()
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
    
    // MARK: Click Methods
    func closedOfferButtonClick(sender: UIButton) {
        isCloseOfferAction = true
        self.sender = sender
        let offer = mOffers[sender.tag]
        selectedOffer = offer
        
        let request = RealmUtils.RequestTable.getById(offer.requestId!)
        if request == nil {
            return
        }
        
        let amount =  offer.lastPrice - request!.doublePrice
        
        if amount < 0 {
            isRefundOffer = true
            showRefundDialog(amount)
            return
        }
        
        let message = "Paypal Payment: \(offer.serverName!)'s offer completed (Update your balance: Actual price of items - Max price of items)"
        
        let item = PayPalItem(
            name: "\(message)",
            withQuantity: UInt(1),
            withPrice: NSDecimalNumber(double: amount.roundToPlaces(2)),
            withCurrency: "AUD",
            withSku: "\(offer.serverName!)'s offer completed (Update your balance: Actual price of items - Max price of items)")
        
        let items = [item]
        
        let payment = PayPalPayment(amount: NSDecimalNumber(double: amount), currencyCode: "AUD", shortDescription: message, intent: .Sale)
        payment.items = items
        
        if payment.processable {
            if let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: paypalConfig, delegate: self) {
                paidAmount = amount
                presentViewController(paymentViewController, animated: true, completion: nil)
            }
        }else {
            print("Some Error has occurred")
        }
        
        
        
    }
    
    func acceptOfferButtonClick(sender: UIButton) {
        
        // Check if any other offer is accepted for this request
        if RealmUtils.OfferTable.hasAcceptedOffers(mRequest.requestId!) {
            UIUtils.showToast("You have already accepted an offer")
            return
        }
        
        
        isCloseOfferAction = false
        self.sender = sender
        
        let offer = mOffers[sender.tag]
        selectedOffer = offer
        
        let request = RealmUtils.RequestTable.getById(offer.requestId!)
        if request == nil {
            return
        }
        
        let amount = request!.doublePrice + offer.doublePrice
        
        let message = "Paypal Payment: \(offer.serverName!)'s offer accepted (Deposit to your balance: Max price of items + Service fee)"
        
        let item = PayPalItem(
            name: "Offer",
            withQuantity: UInt(1),
            withPrice: NSDecimalNumber(double: amount.roundToPlaces(2)),
            withCurrency: "AUD",
            withSku: "\(offer.serverName!)'s offer accepted (Deposit to your balance: Max price of items + Service fee)")
        
        let items = [item]
        
        let payment = PayPalPayment(amount: NSDecimalNumber(double: amount), currencyCode: "AUD", shortDescription: message, intent: .Sale)
        payment.items = items
        
        if payment.processable {
            if let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: paypalConfig, delegate: self) {
                paidAmount = amount
                presentViewController(paymentViewController, animated: true, completion: nil)
            }
        }else {
            print("Some Error has occurred")
        }
    }
    
    // MARK: DB Methods
    func acceptOfferAction(transactionId: String) {
        
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                selectedOffer.accepted = true
                selectedOffer.transactionId = transactionId
            })
        }catch {
            print(error)
        }
        RealmUtils.OfferTable.update(selectedOffer)
        tableView.reloadData()
        sender.enabled = false
        sender.setTitle("Accepted", forState: .Normal)
    }
    
    func closeOfferAction() {
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                selectedOffer.closed = true
            })
        }catch {
            print(error)
        }
        RealmUtils.OfferTable.update(selectedOffer)
        if closedOfferSwitch.on {
            hideClosedOffers()
        }
        tableView.reloadData()
        sender.enabled = false
        sender.setTitle("Closed", forState: .Normal)
    }
    
    func makeOfferRefunded(offer: Offer) {
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                selectedOffer.isRefunded = true
            })
        }catch {
            print(error)
        }
        RealmUtils.OfferTable.update(selectedOffer)
    }
    
    // MARK: UINavigation Delegate Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == SHOW_OFFER_DETAILS {
                if let dvc = segue.destinationViewController as? OfferTableViewController {
                    dvc.isViewMode = true
                    dvc.mRequest = mRequest
                    dvc.mOffer = mOffers[tableView.indexPathForSelectedRow!.row]
                }
            }else if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.VIEW_OFFERS_PAGE
                }
            }else if identifier == SHOW_MAP_IDENTIFIER {
                if let dvc = segue.destinationViewController as? MapViewController {
                    dvc.mRequest = mRequest                    
                }
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func closedOfferSwitchValueChanged(sender: UISwitch) {
        PreferenceUtils.saveBoolToPrefs(PreferenceKeys.CLOSED_OFFERS_FILTER + mRequest.requestId, value: sender.on)
        if sender.on {
            hideClosedOffers()
        }else {
            mOffers = RealmUtils.OfferTable.getAllRequestOffers(mRequest.requestId)
            lastSortState()
        }
        tableView.reloadData()
    }
    
    @IBAction func sortButtonClick(sender: UIBarButtonItem) {
        showSortingMenu()
    }
    
    // MARK: Current Location Related methods
    func getCurrentLocation(){
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Neighborhood, timeout: 60.0, delayUntilAuthorized: true) { (location:CLLocation!, accuracy:INTULocationAccuracy, status:INTULocationStatus) -> Void in
            
            if status == INTULocationStatus.Success {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                
            }else if status == INTULocationStatus.TimedOut {
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

// MARK: Paypal Payment Delegate
extension OffersViewController : PayPalPaymentDelegate, PayPalProfileSharingDelegate {
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, willCompletePayment completedPayment: PayPalPayment, completionBlock: PayPalPaymentDelegateCompletionBlock) {
        
        self.parsePaymentResponse(completedPayment.confirmation)
        paymentViewController.dismissViewControllerAnimated(true) { () -> Void in
            print("Here is the proof of payment confirmation: \(completedPayment.confirmation)")
        }
    }
    
    // PayPalProfileSharingDelegate
    func payPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [NSObject : AnyObject]) {
        print(profileSharingAuthorization)
    }
    
    func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController) {
        profileSharingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension OffersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mOffers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! OfferTableViewCell
        
        cell.offerPrice.textColor = UIColor.blackColor()
        
        let offer = mOffers[indexPath.row]
        cell.offerDate.text = offer.readyBy.formattedDate
        cell.offerPrice.text = "$\(offer.price)"
        cell.offerComments.text = offer.comment
        
        if offer.isDisputed {
            cell.offerPrice.textColor = UIColor.redColor()
            cell.offerPrice.text = "$\(offer.price) (DISPUTED)"
        }
        
        
        if offer.accepted {
            cell.acceptOfferButton.setTitle("Accepted", forState: .Normal)
            cell.acceptOfferButton.enabled = false
            
            cell.closeOfferButton.setTitle("Close Offer", forState: .Normal)
            cell.closeOfferButton.hidden = false
            cell.closeOfferButton.enabled = true
            cell.closeOfferButton.tag = indexPath.row
            cell.closeOfferButton.addTarget(self, action: #selector(OffersViewController.closedOfferButtonClick(_:)), forControlEvents: .TouchUpInside)
        }else {
            cell.acceptOfferButton.setTitle("Accept Offer", forState: .Normal)
            cell.acceptOfferButton.enabled = true
            cell.acceptOfferButton.tag = indexPath.row
            cell.acceptOfferButton.addTarget(self, action: #selector(OffersViewController.acceptOfferButtonClick(_:)), forControlEvents: .TouchUpInside)
            cell.closeOfferButton.hidden = true
            cell.closeOfferButton.enabled = false
        }
        
        if offer.closed{
            cell.closeOfferButton.hidden = false
            cell.closeOfferButton.enabled = false
            cell.closeOfferButton.setTitle("Closed", forState: .Normal)
        }
        
        if isReadOnly {
            cell.closeOfferButton.enabled = false
            cell.acceptOfferButton.enabled = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
