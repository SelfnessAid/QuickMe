//
//  URLConstant.swift
//  Quick Me
//
//  Created by Abdul Wahib on 5/3/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation

class URLConstant: NSObject {
//    static let BASE_URL = "http://ec2-52-10-137-114.us-west-2.compute.amazonaws.com:8080"
    static let BASE_URL = "https://ec2-52-10-137-114.us-west-2.compute.amazonaws.com:8443"
//    static let PAYPAL_BASE_URL = "https://api.paypal.com"
    static let PAYPAL_BASE_URL = "https://api.sandbox.paypal.com"
    static let GET_ACCESS_TOKEN_URL = "\(PAYPAL_BASE_URL)/v1/oauth2/token"
    
    static let CHECK_MOBI_VALIDATION_REQUEST = "https://api.checkmobi.com/v1/validation/request"
    static let CHECK_MOBI_VERIFY_PIN = "https://api.checkmobi.com/v1/validation/verify"
    
    
    static let REGISTER = "\(BASE_URL)/register"
    static let LOGIN = "\(BASE_URL)/login"
    
    static let REQUEST = "\(BASE_URL)/request"
    static let OFFER = "\(BASE_URL)/offer"
    static let SET_PRICE = "\(BASE_URL)/setPrice"
    static let ACCEPT_OFFER = "\(BASE_URL)/acceptOffer"
    static let CLOSE_OFFER = "\(BASE_URL)/closeOffer"
    static let REPORT = "\(BASE_URL)/report"
    static let SET_GOOGLE_ID = "\(BASE_URL)/setGoogleId"
    static let SET_ONLINE = "\(BASE_URL)/userOnline"
    static let SET_OFFLINE = "\(BASE_URL)/userOffline"
    static let LOCATION_UPDATE = "\(BASE_URL)/locationUpdate"
    
    static let UPLOAD = "\(BASE_URL)/upload"
    static let CANCEL_REQUEST = "\(BASE_URL)/cancelRequest"
    static let CANCEL_OFFER = "\(BASE_URL)/cancelOffer"
    
    static let NOTIFICATION_SETTINGS = "\(BASE_URL)/notificationSettings"
    
    static let LAST_SUPPORTED_VERSION = "\(BASE_URL)/lastSupportedVersion?os=ios"
    
    static let BECOME_PROVIDER = "\(BASE_URL)/user"
    static let PHOTO = "\(BASE_URL)/photo"
    
    
    // HELP URLS
    static let HELP_MAIN_PAGE = "http://quickme.com.au/ios/main.html"
    static let NEW_REQUEST_PAGE = "http://quickme.com.au/ios/request.html"
    static let VIEW_OFFERS_PAGE = "http://quickme.com.au/ios/view_offers.html"
    static let NEW_OFFER_PAGE = "http://quickme.com.au/ios/offer.html"
    static let MY_REQUESTS_PAGE = "http://quickme.com.au/ios/my_requests.html"
    static let REQUEST_RECEIVED_PAGE = "http://quickme.com.au/ios/requests_received.html"
    static let PAYMENT_HISTORY_PAGE = "http://quickme.com.au/ios/payment_history.html"
    static let NOTIFICATION_SETTINGS_PAGE = "http://quickme.com.au/ios/notification_settings.html"
    static let REPORT_PAGE = "http://quickme.com.au/ios/report_problem.html"
    static let LOGIN_PAGE = "http://quickme.com.au/ios/login.html"
    static let REGISTER_PAGE = "http://quickme.com.au/ios/registration.html"
    
}
