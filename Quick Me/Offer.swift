//
//  Offer.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation
import RealmSwift

class Offer: Object {
    
    dynamic var comment: String!
    dynamic var estimatedDate: String! {
        didSet {
            readyBy = NSDate.dateFromString(estimatedDate)
        }
    }
    dynamic var msgType: String!
    dynamic var offerId: String!
    dynamic var phoneNumber: String!
    dynamic var price: String! {
        didSet {
            doublePrice = Double(price)!
        }
    }
    dynamic var requestId: String!
    dynamic var serverId: String!
    dynamic var serverName: String!
    
    dynamic var doublePrice: Double = 0.0
    dynamic var lastPrice: Double = 0.0
    dynamic var readyBy: NSDate!
    
    dynamic var closed = false
    dynamic var accepted = false
    dynamic var isCancelled = false
    dynamic var isDisputed = false
    dynamic var isRefunded = false
    dynamic var transactionId: String = ""
    
    override static func primaryKey() -> String? {
        return "offerId"
    }
    
}