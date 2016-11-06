//
//  NotificationType.swift
//  QuickMe
//
//  Created by Abdul Wahib on 5/22/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation

class NotificationType: NSObject {
    
    static let TYPE_NEW_REQUEST = "0";
    static let TYPE_NEW_OFFER = "1";
    static let TYPE_PRICE_UPDATED = "2";
    static let TYPE_OFFER_ACCEPTED = "3";
    static let TYPE_OFFER_CLOSED = "4";
    static let TYPE_LOCATION_UPDATED = "5";
    static let TYPE_CUSTOM_MESSAGE = "8"
    static let TYPE_USER_DISABLED = "9"
    static let TYPE_REQUEST_CANCEL = "10";
    static let TYPE_OFFER_CANCEL = "11";
    static let TYPE_PAYMENT = "12";
    static let TYPE_PROVIDER_ACCEPTED = "7"
}